import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/id_generator.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/deck_mapper.dart';
import 'package:memox/data/mappers/flashcard_mapper.dart';
import 'package:memox/data/repositories/flashcard_export_writer.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/deck_csv_export.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/flashcard_status_filter.dart';

part 'flashcard_repository_impl_imports.dart';
part 'flashcard_repository_impl_export.dart';

/// Drift-backed [FlashcardRepository].
///
/// Reads compose the [FlashcardDao] (cards + detail + count) with the
/// [FolderDao] (deck row + folder breadcrumb + the content-revision change
/// stream). Errors are surfaced as [Failure] values, never raw exceptions
/// (`docs/contracts/error-contract.md`).
class FlashcardRepositoryImpl implements FlashcardRepository {
  FlashcardRepositoryImpl(this._dao, this._folderDao);

  final FlashcardDao _dao;
  final FolderDao _folderDao;

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    String deckId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
    FlashcardStatusFilter statusFilter = FlashcardStatusFilter.all,
    List<String> selectedTags = const <String>[],
    DateTime? now,
  }) {
    final String? normalized =
        (searchTerm == null || StringUtils.trimmed(searchTerm).isEmpty)
        ? null
        : StringUtils.normalize(searchTerm);
    final List<String> normalizedTags = _normalizeTags(selectedTags);
    final int nowMs = (now ?? DateTime.now().toUtc()).millisecondsSinceEpoch;

    return _folderDao.watchContentChanges().asyncMap(
      (_) =>
          _load(deckId, normalized, sort, statusFilter, normalizedTags, nowMs),
    );
  }

  @override
  Future<Result<FlashcardDetail>> getFlashcardDetail({
    required String flashcardId,
  }) async {
    try {
      final FlashcardRow? flashcardRow = await _dao.findFlashcard(flashcardId);
      if (flashcardRow == null) {
        return Result<FlashcardDetail>.err(
          Failure.notFound(entity: 'flashcard', id: flashcardId),
        );
      }
      final DeckRow? deckRow = await _folderDao.findDeck(flashcardRow.deckId);
      if (deckRow == null) {
        return Result<FlashcardDetail>.err(
          Failure.notFound(entity: 'deck', id: flashcardRow.deckId),
        );
      }
      final Deck deck = DeckMapper.fromRow(deckRow);
      final List<FolderBreadcrumbSegment> breadcrumb =
          (await _folderDao.breadcrumb(deck.folderId))
              .map(
                (FolderBreadcrumbResult row) =>
                    FolderBreadcrumbSegment(id: row.id, name: row.name),
              )
              .toList(growable: false);
      final List<String> tags = (await _dao.findFlashcardTags(
        flashcardId,
      )).map((FlashcardTagRow row) => row.tag).toList(growable: false);
      final FlashcardProgressRow? progressRow = await _dao
          .findFlashcardProgress(flashcardId);
      return Result<FlashcardDetail>.ok(
        FlashcardDetail(
          deck: deck,
          breadcrumb: breadcrumb,
          flashcard: FlashcardMapper.fromRow(flashcardRow),
          tags: tags,
          progress: progressRow == null
              ? null
              : FlashcardProgressSnapshot(
                  boxNumber: progressRow.boxNumber,
                  dueAt: _dateFromMs(progressRow.dueAt),
                  buriedUntil: _dateFromMs(progressRow.buriedUntil),
                  isSuspended: progressRow.isSuspended,
                  reviewCount: progressRow.reviewCount,
                  lapseCount: progressRow.lapseCount,
                  lastStudiedAt: _dateFromMs(progressRow.lastStudiedAt),
                ),
        ),
      );
    } catch (error) {
      return Result<FlashcardDetail>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'flashcards',
        ),
      );
    }
  }

  @override
  Future<Result<DeckCsvExport>> exportDeckCsv({required String deckId}) =>
      _exportDeckCsv(this, deckId: deckId);

  @override
  Future<Result<List<Flashcard>>> existingByFrontBackPairs(
    String deckId,
    List<({String front, String back})> pairs,
  ) => _existingByFrontBackPairs(this, deckId, pairs);

  Future<Result<FlashcardListDetail>> _load(
    String deckId,
    String? normalizedSearch,
    ContentSortMode sort,
    FlashcardStatusFilter statusFilter,
    List<String> normalizedTags,
    int nowMs,
  ) async {
    try {
      final DeckRow? deckRow = await _folderDao.findDeck(deckId);
      if (deckRow == null) {
        return Result<FlashcardListDetail>.err(
          Failure.notFound(entity: 'deck', id: deckId),
        );
      }
      final Deck deck = DeckMapper.fromRow(deckRow);

      final List<FolderBreadcrumbSegment> breadcrumb =
          (await _folderDao.breadcrumb(deck.folderId))
              .map(
                (FolderBreadcrumbResult row) =>
                    FolderBreadcrumbSegment(id: row.id, name: row.name),
              )
              .toList(growable: false);

      final List<Flashcard> cards = (await _dao.getFlashcards(
        deckId: deckId,
        sort: sort,
        normalizedSearch: normalizedSearch,
        statusFilter: statusFilter,
        nowMs: nowMs,
      )).map(FlashcardMapper.fromRow).toList(growable: false);

      final List<Flashcard> filteredCards = normalizedTags.isEmpty
          ? cards
          : _filterByTags(
              cards,
              await _dao.loadFlashcardTagsInDeck(deckId),
              normalizedTags,
            );

      final int totalCount = await _dao.countFlashcards(deckId);

      return Result<FlashcardListDetail>.ok(
        FlashcardListDetail(
          deck: deck,
          breadcrumb: breadcrumb,
          cards: filteredCards,
          totalCount: totalCount,
        ),
      );
    } catch (error) {
      return Result<FlashcardListDetail>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'flashcards',
        ),
      );
    }
  }

  @override
  Future<Result<int>> commitDeckImport({
    required String deckId,
    required List<DeckImportPreviewRow> rows,
  }) => _commitDeckImport(this, deckId: deckId, rows: rows);

  @override
  Future<Result<Flashcard>> createFlashcard({
    required String deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  }) async {
    final String trimmedFront = StringUtils.trimmed(front);
    if (trimmedFront.isEmpty) {
      return Future<Result<Flashcard>>.value(
        const Result<Flashcard>.err(
          Failure.validation(field: 'front', code: ValidationCode.empty),
        ),
      );
    }

    final String trimmedBack = StringUtils.trimmed(back);
    if (trimmedBack.isEmpty) {
      return Future<Result<Flashcard>>.value(
        const Result<Flashcard>.err(
          Failure.validation(field: 'back', code: ValidationCode.empty),
        ),
      );
    }

    final String? trimmedExample = _optionalText(exampleSentence);
    final String? trimmedPronunciation = _optionalText(pronunciation);
    final String? trimmedHint = _optionalText(hint);
    final List<String> normalizedTags = _normalizeTags(tags);
    try {
      final DeckRow? deckRow = await _folderDao.findDeck(deckId);
      if (deckRow == null) {
        return Result<Flashcard>.err(
          Failure.notFound(entity: 'deck', id: deckId),
        );
      }
      final FlashcardRow created = await _dao.transaction(
        () => _insertFlashcard(
          this,
          deckId: deckId,
          front: trimmedFront,
          back: trimmedBack,
          exampleSentence: trimmedExample,
          pronunciation: trimmedPronunciation,
          hint: trimmedHint,
          tags: normalizedTags,
          nowMs: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
      );

      return Result<Flashcard>.ok(FlashcardMapper.fromRow(created));
    } on _RuleViolation catch (violation) {
      return Result<Flashcard>.err(violation.failure);
    } catch (error) {
      return Result<Flashcard>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'flashcards',
        ),
      );
    }
  }

  @override
  Future<Result<Flashcard>> updateFlashcard({
    required String flashcardId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
    FlashcardProgressEditPolicy progressPolicy =
        FlashcardProgressEditPolicy.keepProgress,
  }) async {
    final String trimmedFront = StringUtils.trimmed(front);
    if (trimmedFront.isEmpty) {
      return Future<Result<Flashcard>>.value(
        const Result<Flashcard>.err(
          Failure.validation(field: 'front', code: ValidationCode.empty),
        ),
      );
    }

    final String trimmedBack = StringUtils.trimmed(back);
    if (trimmedBack.isEmpty) {
      return Future<Result<Flashcard>>.value(
        const Result<Flashcard>.err(
          Failure.validation(field: 'back', code: ValidationCode.empty),
        ),
      );
    }

    final String? trimmedExample = _optionalText(exampleSentence);
    final String? trimmedPronunciation = _optionalText(pronunciation);
    final String? trimmedHint = _optionalText(hint);
    final List<String> normalizedTags = _normalizeTags(tags);

    try {
      final FlashcardRow updated = await _dao.transaction(() async {
        final FlashcardRow? existing = await _dao.findFlashcard(flashcardId);
        if (existing == null) {
          throw _RuleViolation(
            Failure.notFound(entity: 'flashcard', id: flashcardId),
          );
        }
        final int nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
        await _dao.updateFlashcardContent(
          id: flashcardId,
          front: trimmedFront,
          back: trimmedBack,
          exampleSentence: trimmedExample,
          pronunciation: trimmedPronunciation,
          hint: trimmedHint,
          updatedAt: nowMs,
        );
        if (progressPolicy == FlashcardProgressEditPolicy.resetProgress) {
          await _dao.resetFlashcardProgress(
            flashcardId: flashcardId,
            nowMs: nowMs,
          );
        }
        await _dao.replaceFlashcardTags(
          flashcardId: flashcardId,
          tags: normalizedTags,
        );
        await _dao
            .into(_dao.attachedDatabase.cardEvents)
            .insert(
              CardEventsCompanion.insert(
                id: IdGenerator.newId(),
                flashcardId: flashcardId,
                type: 'edited',
                occurredAt: nowMs,
              ),
            );
        return (await _dao.findFlashcard(flashcardId))!;
      });

      return Result<Flashcard>.ok(FlashcardMapper.fromRow(updated));
    } on _RuleViolation catch (violation) {
      return Result<Flashcard>.err(violation.failure);
    } catch (error) {
      return Result<Flashcard>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'flashcards',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteFlashcard({required String flashcardId}) async {
    try {
      final FlashcardRow? row = await _dao.findFlashcard(flashcardId);
      if (row == null) {
        return Result<void>.err(
          Failure.notFound(entity: 'flashcard', id: flashcardId),
        );
      }
      await _dao.deleteFlashcardById(flashcardId);
      return const Result<void>.ok(null);
    } catch (error) {
      return Result<void>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'flashcards',
        ),
      );
    }
  }

  @override
  Future<Result<void>> reorderFlashcards({
    required String deckId,
    required List<String> orderedIds,
  }) async {
    try {
      if (orderedIds.isEmpty) {
        return const Result<void>.err(
          Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.insufficientContent,
          ),
        );
      }
      final Failure? duplicateFailure = _duplicateIdsFailure(orderedIds);
      if (duplicateFailure != null) {
        return Result<void>.err(duplicateFailure);
      }

      final List<FlashcardRow> currentRows = await _dao.getFlashcards(
        deckId: deckId,
        sort: ContentSortMode.manual,
        statusFilter: FlashcardStatusFilter.all,
        nowMs: DateTime.now().toUtc().millisecondsSinceEpoch,
      );
      final Map<String, FlashcardRow> currentById = <String, FlashcardRow>{
        for (final FlashcardRow row in currentRows) row.id: row,
      };

      for (final String id in orderedIds) {
        if (currentById.containsKey(id)) {
          continue;
        }
        final FlashcardRow? row = await _dao.findFlashcard(id);
        if (row == null) {
          return Result<void>.err(
            Failure.notFound(entity: 'flashcard', id: id),
          );
        }
        return const Result<void>.err(
          Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.invalidFormat,
          ),
        );
      }

      if (orderedIds.length != currentRows.length) {
        return const Result<void>.err(
          Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.insufficientContent,
          ),
        );
      }

      await _dao.transaction(() async {
        final int nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
        for (int index = 0; index < orderedIds.length; index++) {
          await _dao.updateSortOrder(orderedIds[index], index, nowMs);
        }
      });
      return const Result<void>.ok(null);
    } catch (error) {
      return Result<void>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'flashcards',
        ),
      );
    }
  }

  static List<Flashcard> _filterByTags(
    List<Flashcard> cards,
    List<FlashcardTagRow> tagRows,
    List<String> selectedTags,
  ) {
    final Map<String, Set<String>> tagsByCardId = <String, Set<String>>{};
    for (final FlashcardTagRow row in tagRows) {
      tagsByCardId.putIfAbsent(row.flashcardId, () => <String>{}).add(row.tag);
    }

    return cards
        .where((Flashcard card) {
          final Set<String> tags = tagsByCardId[card.id] ?? const <String>{};
          return selectedTags.every(tags.contains);
        })
        .toList(growable: false);
  }

  static DateTime? _dateFromMs(int? ms) =>
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  static Failure? _duplicateIdsFailure(List<String> orderedIds) {
    final Set<String> seen = <String>{};
    for (final String id in orderedIds) {
      if (!seen.add(id)) {
        return const Failure.validation(
          field: 'orderedIds',
          code: ValidationCode.duplicate,
        );
      }
    }
    return null;
  }
}
