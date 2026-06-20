import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/deck_mapper.dart';
import 'package:memox/data/mappers/flashcard_mapper.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/flashcard_duplicate_check_result.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/ids.dart';

/// Drift-backed [FlashcardRepository].
///
/// Mutations run inside [FlashcardDao] transactions and enforce front/back
/// required-after-trim validation, optional-note collapsing, tag normalization,
/// the initial-progress invariant, and the cascade-on-delete. The list-watch
/// composes the deck row, its folder breadcrumb, and the card stream into the
/// read model. [idGenerator] and [nowMs] are injectable so tests get
/// deterministic ids and timestamps.
///
/// Spec: `docs/contracts/repository-contracts/flashcard-repository.md`,
/// `docs/business/flashcard/flashcard-management.md`.
class FlashcardRepositoryImpl implements FlashcardRepository {
  FlashcardRepositoryImpl({
    required FlashcardDao dao,
    required DeckDao deckDao,
    required FolderDao folderDao,
    IdGenerator? idGenerator,
    int Function()? nowMs,
  }) : _dao = dao,
       _deckDao = deckDao,
       _folderDao = folderDao,
       _idGenerator = idGenerator ?? IdGenerator(),
       _nowMs = nowMs ?? _defaultNowMs;

  final FlashcardDao _dao;
  final DeckDao _deckDao;
  final FolderDao _folderDao;
  final IdGenerator _idGenerator;
  final int Function() _nowMs;

  static int _defaultNowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;

  // ---- Reads ----

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    DeckId deckId, {
    String? searchTerm,
    List<TagName> tags = const <TagName>[],
    ContentSortMode sort = ContentSortMode.manual,
  }) {
    final String term = (searchTerm ?? '').trim().toLowerCase();
    // Normalize the selected filter tags with the same rule that stored them
    // (`_normalizeTags`: trim + lowercase + dedup, blanks dropped) so the filter
    // matches storage; an empty/whitespace selection imposes no tag filter (C38).
    final Set<TagName> filterTags = _normalizeTags(tags).toSet();
    return _dao.watchFlashcardsInDeck(deckId).asyncMap((
      List<FlashcardRow> rows,
    ) async {
      try {
        final DeckRow? deckRow = await _deckDao.findDeckById(deckId);
        if (deckRow == null) {
          return _fail<FlashcardListDetail>(
            const Failure.notFound(entity: 'deck'),
          );
        }
        final Deck deck = DeckMapper.fromRow(deckRow);
        final List<Folder> breadcrumb = (await _folderDao.getBreadcrumb(
          deckRow.folderId,
        )).map(FolderMapper.fromRow).toList(growable: false);

        final Map<String, List<TagName>> tagsByCard = await _tagsByCard(
          rows.map((FlashcardRow r) => r.id).toList(growable: false),
        );
        final List<Flashcard> all = rows
            .map(
              (FlashcardRow r) => FlashcardMapper.fromRow(
                r,
                tags: tagsByCard[r.id] ?? const <TagName>[],
              ),
            )
            .toList(growable: false);

        // Search (front/back contains term) AND tag filter (card carries every
        // selected tag) compose; an empty term/tag set skips that predicate.
        // `totalCount` stays the full deck total regardless of either (C39).
        final List<Flashcard> filtered = all
            .where(
              (Flashcard c) =>
                  (term.isEmpty ||
                      c.front.toLowerCase().contains(term) ||
                      c.back.toLowerCase().contains(term)) &&
                  (filterTags.isEmpty ||
                      filterTags.every((TagName t) => c.tags.contains(t))),
            )
            .toList(growable: false);

        return _ok(
          FlashcardListDetail(
            deck: deck,
            breadcrumb: breadcrumb,
            cards: filtered,
            totalCount: all.length,
          ),
        );
      } catch (error) {
        return _fail<FlashcardListDetail>(_storageRead(error));
      }
    });
  }

  // ---- Mutations ----

  @override
  Future<Result<Flashcard>> createFlashcard({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  }) async {
    final String trimmedFront = front.trim();
    final String trimmedBack = back.trim();
    final Failure? invalid = _validateContent(trimmedFront, trimmedBack);
    if (invalid != null) return _fail<Flashcard>(invalid);

    final List<TagName> normalizedTags = _normalizeTags(tags);

    try {
      return await _dao.runInTransaction(() async {
        final DeckRow? deck = await _deckDao.findDeckById(deckId);
        if (deck == null) {
          return _fail<Flashcard>(const Failure.notFound(entity: 'deck'));
        }

        final List<FlashcardRow> siblings = await _dao.flashcardsInDeck(deckId);
        final int now = _nowMs();
        final Flashcard card = Flashcard(
          id: _idGenerator.newId(),
          deckId: deckId,
          front: trimmedFront,
          back: trimmedBack,
          exampleSentence: _blankToNull(exampleSentence),
          pronunciation: _blankToNull(pronunciation),
          hint: _blankToNull(hint),
          tags: normalizedTags,
          sortOrder: _nextSortOrder(siblings),
          createdAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
        );

        await _dao.insertFlashcard(_insertCompanion(card, now));
        // Initial progress row: box 1, due_at NULL, zero counters (NEW card).
        await _dao.insertProgress(
          FlashcardProgressCompanion.insert(flashcardId: card.id),
        );
        for (final TagName tag in normalizedTags) {
          await _dao.insertTag(
            FlashcardTagsCompanion.insert(flashcardId: card.id, tag: tag),
          );
        }
        return _ok(card);
      });
    } catch (error) {
      return _fail<Flashcard>(_storageWrite(error));
    }
  }

  @override
  Future<Result<Flashcard>> updateFlashcard({
    required FlashcardId flashcardId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
    FlashcardProgressEditPolicy progressPolicy =
        FlashcardProgressEditPolicy.keepProgress,
  }) async {
    final String trimmedFront = front.trim();
    final String trimmedBack = back.trim();
    final Failure? invalid = _validateContent(trimmedFront, trimmedBack);
    if (invalid != null) return _fail<Flashcard>(invalid);

    final List<TagName> normalizedTags = _normalizeTags(tags);

    try {
      return await _dao.runInTransaction(() async {
        final FlashcardRow? row = await _dao.findFlashcardById(flashcardId);
        if (row == null) {
          return _fail<Flashcard>(const Failure.notFound(entity: 'flashcard'));
        }

        final int now = _nowMs();
        final String? example = _blankToNull(exampleSentence);
        final String? pron = _blankToNull(pronunciation);
        final String? hintValue = _blankToNull(hint);

        await _dao.updateFlashcardColumns(
          flashcardId,
          FlashcardsCompanion(
            front: Value(trimmedFront),
            back: Value(trimmedBack),
            exampleSentence: Value(example),
            pronunciation: Value(pron),
            hint: Value(hintValue),
            updatedAt: Value(now),
          ),
        );

        // Replace the full tag set.
        await _dao.deleteTagsForFlashcard(flashcardId);
        for (final TagName tag in normalizedTags) {
          await _dao.insertTag(
            FlashcardTagsCompanion.insert(flashcardId: flashcardId, tag: tag),
          );
        }

        if (progressPolicy == FlashcardProgressEditPolicy.resetProgress) {
          await _dao.updateProgressColumns(
            flashcardId,
            const FlashcardProgressCompanion(
              boxNumber: Value(1),
              dueAt: Value(null),
              reviewCount: Value(0),
              lapseCount: Value(0),
            ),
          );
        }

        return _ok(
          FlashcardMapper.fromRow(row, tags: normalizedTags).copyWith(
            front: trimmedFront,
            back: trimmedBack,
            exampleSentence: example,
            pronunciation: pron,
            hint: hintValue,
            updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
          ),
        );
      });
    } catch (error) {
      return _fail<Flashcard>(_storageWrite(error));
    }
  }

  @override
  Future<Result<void>> deleteFlashcard({
    required FlashcardId flashcardId,
  }) async {
    try {
      return await _dao.runInTransaction(() async {
        final FlashcardRow? row = await _dao.findFlashcardById(flashcardId);
        if (row == null) {
          return _fail<void>(const Failure.notFound(entity: 'flashcard'));
        }
        // Progress + tag rows cascade via their ON DELETE CASCADE FKs.
        await _dao.deleteFlashcardById(flashcardId);
        return _ok<void>(null);
      });
    } catch (error) {
      return _fail<void>(_storageWrite(error));
    }
  }

  @override
  Future<Result<void>> reorderFlashcards({
    required DeckId deckId,
    required List<FlashcardId> orderedIds,
  }) async {
    try {
      return await _dao.runInTransaction(() async {
        final List<FlashcardRow> siblings = await _dao.flashcardsInDeck(deckId);
        final Failure? invalid = _validateReorder(siblings, orderedIds);
        if (invalid != null) return _fail<void>(invalid);

        final int now = _nowMs();
        for (int i = 0; i < orderedIds.length; i++) {
          await _dao.updateFlashcardColumns(
            orderedIds[i],
            FlashcardsCompanion(sortOrder: Value(i), updatedAt: Value(now)),
          );
        }
        return _ok<void>(null);
      });
    } catch (error) {
      return _fail<void>(_storageWrite(error));
    }
  }

  @override
  Future<Result<FlashcardDuplicateCheckResult>> checkManualDuplicate({
    required DeckId deckId,
    required String front,
    required String back,
    FlashcardId? excludeId,
  }) async {
    final String loweredFront = front.trim().toLowerCase();
    final String loweredBack = back.trim().toLowerCase();

    try {
      final List<FlashcardRow> cards = await _dao.flashcardsInDeck(deckId);
      final List<FlashcardId> matches = cards
          .where(
            (FlashcardRow c) =>
                c.id != excludeId &&
                c.front.trim().toLowerCase() == loweredFront &&
                c.back.trim().toLowerCase() == loweredBack,
          )
          .map((FlashcardRow c) => c.id)
          .toList(growable: false);

      return _ok(
        matches.isEmpty
            ? FlashcardDuplicateCheckResult.unique
            : FlashcardDuplicateCheckResult(
                isDuplicate: true,
                matchingFlashcardIds: matches,
              ),
      );
    } catch (error) {
      return _fail<FlashcardDuplicateCheckResult>(_storageRead(error));
    }
  }

  // ---- Helpers ----

  /// Reject empty-after-trim front or back ([ValidationCode.empty]). Decision
  /// rows C2, C3, C8.
  Failure? _validateContent(String trimmedFront, String trimmedBack) {
    if (trimmedFront.isEmpty) {
      return const Failure.validation(
        field: 'front',
        code: ValidationCode.empty,
      );
    }
    if (trimmedBack.isEmpty) {
      return const Failure.validation(
        field: 'back',
        code: ValidationCode.empty,
      );
    }
    return null;
  }

  /// Trim, drop blanks, lowercase, and dedupe tags case-insensitively while
  /// preserving first-seen order (`docs/business/tags/tag-system.md`).
  List<TagName> _normalizeTags(List<String> tags) {
    final Set<String> seen = <String>{};
    final List<TagName> result = <TagName>[];
    for (final String raw in tags) {
      final String normalized = raw.trim().toLowerCase();
      if (normalized.isEmpty) continue;
      if (seen.add(normalized)) result.add(normalized);
    }
    return List<TagName>.unmodifiable(result);
  }

  /// Collapse blank-after-trim optional text to `null`, never an empty string.
  String? _blankToNull(String? value) {
    final String trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Next `sort_order` among [siblings]: append after the current max (0 when
  /// there are none).
  int _nextSortOrder(List<FlashcardRow> siblings) {
    if (siblings.isEmpty) return 0;
    return siblings
            .map((FlashcardRow s) => s.sortOrder)
            .reduce((int a, int b) => a > b ? a : b) +
        1;
  }

  FlashcardsCompanion _insertCompanion(Flashcard card, int now) =>
      FlashcardsCompanion.insert(
        id: card.id,
        deckId: card.deckId,
        front: card.front,
        back: card.back,
        exampleSentence: Value(card.exampleSentence),
        pronunciation: Value(card.pronunciation),
        hint: Value(card.hint),
        sortOrder: card.sortOrder,
        createdAt: now,
        updatedAt: now,
      );

  /// Reject a reorder whose [orderedIds] is not exactly the [siblings] set:
  /// duplicates, or any missing/extra/cross-deck id. Validated before any write,
  /// so the previous order is preserved on rejection (C34).
  Failure? _validateReorder(
    List<FlashcardRow> siblings,
    List<FlashcardId> orderedIds,
  ) {
    final Set<String> orderedSet = orderedIds.toSet();
    final bool hasDuplicates = orderedSet.length != orderedIds.length;
    final Set<String> siblingIds = siblings
        .map((FlashcardRow s) => s.id)
        .toSet();
    final bool sameSet =
        orderedSet.length == siblingIds.length &&
        orderedSet.containsAll(siblingIds);
    return hasDuplicates || !sameSet
        ? const Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.invalidFormat,
          )
        : null;
  }

  /// Tags grouped by flashcard id, normalized values in stable (alphabetical)
  /// order, for the list read.
  Future<Map<String, List<TagName>>> _tagsByCard(
    List<String> flashcardIds,
  ) async {
    final Map<String, List<TagName>> byCard = <String, List<TagName>>{};
    final List<FlashcardTagRow> rows = await _dao.tagsForFlashcards(
      flashcardIds,
    );
    for (final FlashcardTagRow row in rows) {
      byCard.putIfAbsent(row.flashcardId, () => <TagName>[]).add(row.tag);
    }
    return byCard;
  }

  // ---- Result + failure builders ----

  Result<T> _ok<T>(T data) => (failure: null, data: data);

  Result<T> _fail<T>(Failure failure) => (failure: failure, data: null);

  Failure _storageWrite(Object error) => Failure.storage(
    operation: StorageOp.write,
    table: 'flashcards',
    cause: error.toString(),
  );

  Failure _storageRead(Object error) => Failure.storage(
    operation: StorageOp.read,
    table: 'flashcards',
    cause: error.toString(),
  );
}
