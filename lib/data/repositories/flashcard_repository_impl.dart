import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/mappers/flashcard_mapper.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_duplicate_check_result.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Drift-backed [FlashcardRepository].
///
/// Mutations run inside [FlashcardDao] transactions and enforce front/back
/// required-after-trim validation, the parent-deck existence check (the
/// parent-child invariant, WBS 2.16.1), and blank-optional → `null` storage.
/// The duplicate check is a pure read used by the editor's non-blocking
/// soft-warning (WBS 2.20.1).
///
/// [idGenerator] and [nowMs] are injectable so tests get deterministic ids and
/// timestamps.
class FlashcardRepositoryImpl implements FlashcardRepository {
  FlashcardRepositoryImpl({
    required FlashcardDao dao,
    required DeckDao deckDao,
    IdGenerator? idGenerator,
    int Function()? nowMs,
  }) : _dao = dao,
       _deckDao = deckDao,
       _idGenerator = idGenerator ?? IdGenerator(),
       _nowMs = nowMs ?? _defaultNowMs;

  final FlashcardDao _dao;
  final DeckDao _deckDao;
  final IdGenerator _idGenerator;
  final int Function() _nowMs;

  static int _defaultNowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;

  @override
  Future<Result<Flashcard>> createFlashcard({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    String? partOfSpeech,
  }) async {
    final String trimmedFront = front.trim();
    final String trimmedBack = back.trim();
    final Failure? invalid = _validateFrontBack(trimmedFront, trimmedBack);
    if (invalid != null) return _fail<Flashcard>(invalid);

    try {
      return await _dao.runInTransaction(() async {
        // Parent-child invariant (WBS 2.16.1): the deck must exist.
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
          exampleSentence: _nullIfBlank(exampleSentence),
          pronunciation: _nullIfBlank(pronunciation),
          hint: _nullIfBlank(hint),
          partOfSpeech: _nullIfBlank(partOfSpeech),
          isFlagged: false,
          sortOrder: _nextSortOrder(siblings),
          createdAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
        );
        await _dao.insertFlashcard(_insertCompanion(card, now));
        return _ok(card);
      });
    } catch (error) {
      return _fail<Flashcard>(_storageWrite(error));
    }
  }

  @override
  Future<Result<Flashcard>> updateFlashcard({
    required FlashcardId id,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    String? partOfSpeech,
  }) async {
    final String trimmedFront = front.trim();
    final String trimmedBack = back.trim();
    final Failure? invalid = _validateFrontBack(trimmedFront, trimmedBack);
    if (invalid != null) return _fail<Flashcard>(invalid);

    try {
      return await _dao.runInTransaction(() async {
        final FlashcardRow? row = await _dao.findFlashcardById(id);
        if (row == null) {
          return _fail<Flashcard>(const Failure.notFound(entity: 'flashcard'));
        }

        final int now = _nowMs();
        await _dao.updateFlashcardColumns(
          id,
          FlashcardsCompanion(
            front: Value(trimmedFront),
            back: Value(trimmedBack),
            exampleSentence: Value(_nullIfBlank(exampleSentence)),
            pronunciation: Value(_nullIfBlank(pronunciation)),
            hint: Value(_nullIfBlank(hint)),
            partOfSpeech: Value(_nullIfBlank(partOfSpeech)),
            updatedAt: Value(now),
          ),
        );
        return _ok(
          FlashcardMapper.fromRow(row).copyWith(
            front: trimmedFront,
            back: trimmedBack,
            exampleSentence: _nullIfBlank(exampleSentence),
            pronunciation: _nullIfBlank(pronunciation),
            hint: _nullIfBlank(hint),
            partOfSpeech: _nullIfBlank(partOfSpeech),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
          ),
        );
      });
    } catch (error) {
      return _fail<Flashcard>(_storageWrite(error));
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

  /// Reject an empty-after-trim front or back ([ValidationCode.empty]). Front is
  /// checked first so its field is reported when both are empty.
  Failure? _validateFrontBack(String trimmedFront, String trimmedBack) {
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

  /// Trim optional text and return `null` when blank (never an empty string).
  String? _nullIfBlank(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  int _nextSortOrder(List<FlashcardRow> siblings) {
    if (siblings.isEmpty) return 0;
    return siblings
            .map((FlashcardRow c) => c.sortOrder)
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
        partOfSpeech: Value(card.partOfSpeech),
        isFlagged: Value(card.isFlagged),
        sortOrder: card.sortOrder,
        createdAt: now,
        updatedAt: now,
      );

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

  Result<T> _ok<T>(T data) => (failure: null, data: data);

  Result<T> _fail<T>(Failure failure) => (failure: failure, data: null);
}
