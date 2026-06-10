import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/flashcard_status_filter.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/usecases/flashcard/commit_deck_import_usecase.dart';
import 'package:memox/domain/usecases/flashcard/parse_deck_import_csv_usecase.dart';

class _RecordingFlashcardRepository implements FlashcardRepository {
  _RecordingFlashcardRepository({Result<int>? commitResult})
    : commitResult = commitResult ?? const Result<int>.ok(2);

  final Result<int> commitResult;

  DeckId? lastCommitDeckId;
  List<DeckImportPreviewRow>? lastCommitRows;

  @override
  Future<Result<int>> commitDeckImport({
    required DeckId deckId,
    required List<DeckImportPreviewRow> rows,
  }) async {
    lastCommitDeckId = deckId;
    lastCommitRows = rows;
    return commitResult;
  }

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
  Future<Result<FlashcardDetail>> getFlashcardDetail({
    required FlashcardId flashcardId,
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
}

void main() {
  group('ParseDeckImportCsvUseCase', () {
    test('parses header, quotes, escaped quotes, and blank rows', () {
      const String rawCsv =
          'front,back\n'
          '"Hello, world","She said ""hi"""\n'
          '\n'
          'Goodbye,Farewell';

      final DeckImportPreview preview = const ParseDeckImportCsvUseCase().call(
        rawCsv: rawCsv,
      );

      expect(preview.rows, hasLength(2));
      expect(preview.rows[0].lineNumber, 2);
      expect(preview.rows[0].front, 'Hello, world');
      expect(preview.rows[0].back, 'She said "hi"');
      expect(preview.rows[1].lineNumber, 4);
      expect(preview.rows[1].front, 'Goodbye');
      expect(preview.rows[1].back, 'Farewell');
      expect(preview.issues, isEmpty);
    });

    test('collects row-level issues for empty front and back cells', () {
      const String rawCsv = 'front,back\n,Hello\nHi,\n,,note';

      final DeckImportPreview preview = const ParseDeckImportCsvUseCase().call(
        rawCsv: rawCsv,
      );

      expect(preview.rows, isEmpty);
      expect(preview.issues, hasLength(3));
      expect(preview.issues[0].lineNumber, 2);
      expect(preview.issues[0].code, DeckImportIssueCode.frontRequired);
      expect(preview.issues[1].lineNumber, 3);
      expect(preview.issues[1].code, DeckImportIssueCode.backRequired);
      expect(preview.issues[2].lineNumber, 4);
      expect(preview.issues[2].code, DeckImportIssueCode.frontAndBackRequired);
    });
  });

  group('CommitDeckImportUseCase', () {
    test('rejects an empty deck id before calling the repository', () async {
      final _RecordingFlashcardRepository repository =
          _RecordingFlashcardRepository();
      final CommitDeckImportUseCase useCase = CommitDeckImportUseCase(
        repository,
      );

      final Result<int> result = await useCase.call(
        deckId: '   ',
        preview: const DeckImportPreview(
          rows: <DeckImportPreviewRow>[
            DeckImportPreviewRow(lineNumber: 2, front: 'Hello', back: 'World'),
          ],
          issues: <DeckImportIssue>[],
        ),
      );

      expect(result, isA<Err<int>>());
      expect((result as Err<int>).failure, isA<ValidationFailure>());
      expect(repository.lastCommitRows, isNull);
    });

    test(
      'rejects previews with validation issues before calling the repo',
      () async {
        final _RecordingFlashcardRepository repository =
            _RecordingFlashcardRepository();
        final CommitDeckImportUseCase useCase = CommitDeckImportUseCase(
          repository,
        );

        final Result<int> result = await useCase.call(
          deckId: 'd1',
          preview: const DeckImportPreview(
            rows: <DeckImportPreviewRow>[
              DeckImportPreviewRow(
                lineNumber: 2,
                front: 'Hello',
                back: 'World',
              ),
            ],
            issues: <DeckImportIssue>[
              DeckImportIssue(
                lineNumber: 3,
                code: DeckImportIssueCode.backRequired,
              ),
            ],
          ),
        );

        expect(result, isA<Err<int>>());
        expect((result as Err<int>).failure, isA<ValidationFailure>());
        expect(repository.lastCommitRows, isNull);
      },
    );

    test(
      'rejects previews with no valid rows before calling the repo',
      () async {
        final _RecordingFlashcardRepository repository =
            _RecordingFlashcardRepository();
        final CommitDeckImportUseCase useCase = CommitDeckImportUseCase(
          repository,
        );

        final Result<int> result = await useCase.call(
          deckId: 'd1',
          preview: const DeckImportPreview(
            rows: <DeckImportPreviewRow>[],
            issues: <DeckImportIssue>[],
          ),
        );

        expect(result, isA<Err<int>>());
        expect((result as Err<int>).failure, isA<ValidationFailure>());
        expect(repository.lastCommitRows, isNull);
      },
    );

    test(
      'trims the deck id and delegates valid rows to the repository',
      () async {
        final _RecordingFlashcardRepository repository =
            _RecordingFlashcardRepository();
        final CommitDeckImportUseCase useCase = CommitDeckImportUseCase(
          repository,
        );

        final Result<int> result = await useCase.call(
          deckId: '  d1  ',
          preview: const DeckImportPreview(
            rows: <DeckImportPreviewRow>[
              DeckImportPreviewRow(
                lineNumber: 2,
                front: 'Hello',
                back: 'World',
              ),
            ],
            issues: <DeckImportIssue>[],
          ),
        );

        expect(result, isA<Ok<int>>());
        expect(repository.lastCommitDeckId, 'd1');
        expect(repository.lastCommitRows, hasLength(1));
        expect(repository.lastCommitRows!.single.front, 'Hello');
      },
    );
  });
}
