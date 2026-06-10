import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/deck_csv_export.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/models/flashcard_duplicate_check_result.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/flashcard_status_filter.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/domain/usecases/flashcard/check_manual_duplicate_flashcard_usecase.dart';

class _DuplicateRepository implements FlashcardRepository {
  _DuplicateRepository({
    FlashcardDetail? detail,
    List<Flashcard>? matches,
    Result<List<Flashcard>>? existingResult,
  }) : detail = detail ?? _detail(),
       matches = matches ?? <Flashcard>[],
       existingResult =
           existingResult ??
           Result<List<Flashcard>>.ok(matches ?? <Flashcard>[]);

  final FlashcardDetail detail;
  final List<Flashcard> matches;
  final Result<List<Flashcard>> existingResult;

  @override
  Future<Result<FlashcardDetail>> getFlashcardDetail({
    required FlashcardId flashcardId,
  }) async {
    if (flashcardId == detail.flashcard.id) {
      return Result<FlashcardDetail>.ok(detail);
    }
    return Result<FlashcardDetail>.err(
      Failure.notFound(entity: 'flashcard', id: flashcardId),
    );
  }

  @override
  Future<Result<List<Flashcard>>> existingByFrontBackPairs(
    DeckId deckId,
    List<({String front, String back})> pairs,
  ) async => existingResult;

  @override
  Future<Result<Flashcard>> createFlashcard({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    DeckId deckId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
    FlashcardStatusFilter statusFilter = FlashcardStatusFilter.all,
    List<String> selectedTags = const <String>[],
    DateTime? now,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteFlashcard({required FlashcardId flashcardId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> reorderFlashcards({
    required DeckId deckId,
    required List<FlashcardId> orderedIds,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DeckCsvExport>> exportDeckCsv({required DeckId deckId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<int>> commitDeckImport({
    required DeckId deckId,
    required List<DeckImportPreviewRow> rows,
  }) {
    throw UnimplementedError();
  }

  static FlashcardDetail _detail() => FlashcardDetail(
    deck: Deck(
      id: 'deck-1',
      folderId: 'folder-1',
      name: 'Deck',
      targetLanguage: TargetLanguage.korean,
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    ),
    breadcrumb: const <FolderBreadcrumbSegment>[],
    flashcard: Flashcard(
      id: 'card-1',
      deckId: 'deck-1',
      front: 'Front',
      back: 'Back',
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    ),
    tags: const <String>[],
    progress: null,
  );
}

void main() {
  group('CheckManualDuplicateFlashcardUseCase', () {
    test('returns no duplicate when nothing matches', () async {
      final CheckManualDuplicateFlashcardUseCase useCase =
          CheckManualDuplicateFlashcardUseCase(_DuplicateRepository());

      final Result<FlashcardDuplicateCheckResult> result = await useCase.call(
        deckId: 'deck-1',
        front: 'Hello',
        back: 'World',
      );

      expect(result, isA<Ok<FlashcardDuplicateCheckResult>>());
      expect(
        (result as Ok<FlashcardDuplicateCheckResult>).value.hasDuplicate,
        isFalse,
      );
    });

    test(
      'detects a duplicate in the same deck after trim and case fold',
      () async {
        final CheckManualDuplicateFlashcardUseCase useCase =
            CheckManualDuplicateFlashcardUseCase(
              _DuplicateRepository(
                matches: <Flashcard>[
                  Flashcard(
                    id: 'dup-1',
                    deckId: 'deck-1',
                    front: 'hello',
                    back: 'world',
                    sortOrder: 0,
                    createdAt: DateTime.utc(2026, 1, 1),
                    updatedAt: DateTime.utc(2026, 1, 1),
                  ),
                ],
              ),
            );

        final Result<FlashcardDuplicateCheckResult> result = await useCase.call(
          deckId: 'deck-1',
          front: '  HELLO  ',
          back: '  World  ',
        );

        expect(result, isA<Ok<FlashcardDuplicateCheckResult>>());
        final FlashcardDuplicateCheckResult value =
            (result as Ok<FlashcardDuplicateCheckResult>).value;
        expect(value.hasDuplicate, isTrue);
        expect(value.duplicateFlashcardId, 'dup-1');
      },
    );

    test('ignores the edited flashcard itself', () async {
      final CheckManualDuplicateFlashcardUseCase useCase =
          CheckManualDuplicateFlashcardUseCase(
            _DuplicateRepository(
              matches: <Flashcard>[
                Flashcard(
                  id: 'card-1',
                  deckId: 'deck-1',
                  front: 'hello',
                  back: 'world',
                  sortOrder: 0,
                  createdAt: DateTime.utc(2026, 1, 1),
                  updatedAt: DateTime.utc(2026, 1, 1),
                ),
              ],
            ),
          );

      final Result<FlashcardDuplicateCheckResult> result = await useCase.call(
        deckId: 'deck-1',
        flashcardId: 'card-1',
        front: 'hello',
        back: 'world',
      );

      expect(result, isA<Ok<FlashcardDuplicateCheckResult>>());
      expect(
        (result as Ok<FlashcardDuplicateCheckResult>).value.hasDuplicate,
        isFalse,
      );
    });

    test('returns not found when the edited flashcard is missing', () async {
      final CheckManualDuplicateFlashcardUseCase useCase =
          CheckManualDuplicateFlashcardUseCase(_DuplicateRepository());

      final Result<FlashcardDuplicateCheckResult> result = await useCase.call(
        deckId: 'deck-1',
        flashcardId: 'missing',
        front: 'hello',
        back: 'world',
      );

      expect(result, isA<Err<FlashcardDuplicateCheckResult>>());
      expect(
        (result as Err<FlashcardDuplicateCheckResult>).failure,
        isA<NotFoundFailure>(),
      );
    });

    test('returns not found when the deck is missing', () async {
      final CheckManualDuplicateFlashcardUseCase useCase =
          CheckManualDuplicateFlashcardUseCase(
            _DuplicateRepository(
              existingResult: const Result<List<Flashcard>>.err(
                Failure.notFound(entity: 'deck', id: 'deck-1'),
              ),
            ),
          );

      final Result<FlashcardDuplicateCheckResult> result = await useCase.call(
        deckId: 'deck-1',
        front: 'hello',
        back: 'world',
      );

      expect(result, isA<Err<FlashcardDuplicateCheckResult>>());
      expect(
        (result as Err<FlashcardDuplicateCheckResult>).failure,
        isA<NotFoundFailure>(),
      );
    });

    test('returns validation failure for blank front/back', () async {
      final CheckManualDuplicateFlashcardUseCase useCase =
          CheckManualDuplicateFlashcardUseCase(_DuplicateRepository());

      final Result<FlashcardDuplicateCheckResult> result = await useCase.call(
        deckId: 'deck-1',
        front: '   ',
        back: 'world',
      );

      expect(result, isA<Err<FlashcardDuplicateCheckResult>>());
      expect(
        (result as Err<FlashcardDuplicateCheckResult>).failure,
        isA<ValidationFailure>(),
      );
    });
  });
}
