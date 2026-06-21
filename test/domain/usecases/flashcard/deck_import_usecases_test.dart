import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/flashcard_import_duplicate.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/import_row_issue_type.dart';
import 'package:memox/domain/types/import_text_separator.dart';
import 'package:memox/domain/usecases/flashcard/commit_deck_import_usecase.dart';
import 'package:memox/domain/usecases/flashcard/parse_deck_import_csv_usecase.dart';
import 'package:memox/domain/usecases/flashcard/prepare_deck_import_usecase.dart';

/// Fake returning canned existing-deck card contents for the prepare stage and
/// recording the commit call for the commit stage.
class _FakeFlashcardRepository implements FlashcardRepository {
  _FakeFlashcardRepository([this._existing = const []]);
  final List<({String front, String back})> _existing;

  List<({String front, String back})>? committedRows;
  String? committedDeckId;

  @override
  Future<Result<List<({String front, String back})>>> loadDeckCardContents({
    required DeckId deckId,
  }) async => (failure: null, data: _existing);

  @override
  Future<Result<int>> commitDeckImport({
    required DeckId deckId,
    required List<({String front, String back})> rows,
  }) async {
    committedDeckId = deckId;
    committedRows = rows;
    return (failure: null, data: rows.length);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

FlashcardImportPreview _previewOf(List<({String front, String back})> rows) =>
    FlashcardImportPreview(
      rows: <FlashcardImportRow>[
        for (final (int i, ({String front, String back}) r) in rows.indexed)
          FlashcardImportRow(lineNumber: i + 1, front: r.front, back: r.back),
      ],
    );

void main() {
  // ParseDeckImportCsvUseCase (WBS 6.2.1 parse + 6.2.2 row validation): RFC-4180
  // CSV parse → preview rows + malformedRow (structural) + missingFront/
  // missingBack (content) issues.
  group('ParseDeckImportCsvUseCase', () {
    const ParseDeckImportCsvUseCase parse = ParseDeckImportCsvUseCase();

    test('parses simple two-column rows, trimmed, with line numbers', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: 'eat, 먹다\n drink ,마시다',
      );

      expect(preview.issues, isEmpty);
      expect(preview.canCommit, isTrue);
      expect(preview.rows, hasLength(2));
      expect(preview.rows[0].front, 'eat');
      expect(preview.rows[0].back, '먹다');
      expect(preview.rows[0].lineNumber, 1);
      expect(preview.rows[1].front, 'drink', reason: 'trimmed');
      expect(preview.rows[1].lineNumber, 2);
    });

    test('drops a leading front,back header (case-insensitive)', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: 'Front,Back\na,b',
      );

      expect(preview.rows, hasLength(1));
      expect(preview.rows.single.front, 'a');
      expect(preview.rows.single.lineNumber, 2);
    });

    test('preserves quoted commas and escaped quotes', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: '"a, b","say ""hi"""',
      );

      expect(preview.issues, isEmpty);
      expect(preview.rows.single.front, 'a, b');
      expect(preview.rows.single.back, 'say "hi"');
    });

    test('a quoted field may embed a newline (single record)', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: '"line1\nline2",back',
      );

      expect(preview.rows, hasLength(1));
      expect(preview.rows.single.front, 'line1\nline2');
      expect(preview.rows.single.back, 'back');
    });

    test(
      'a quoted field may embed a CRLF (normalised to LF), line counted',
      () {
        final FlashcardImportPreview preview = parse.call(
          rawCsv: '"line1\r\nline2",back\nc,d',
        );

        expect(preview.rows, hasLength(2));
        expect(preview.rows[0].front, 'line1\nline2', reason: 'CRLF → LF');
        expect(
          preview.rows[1].lineNumber,
          2,
          reason:
              'lineNumber is the logical record index (quoted multi-line '
              'field counts as one record)',
        );
      },
    );

    test('a header with extra columns is still dropped (C7-consistent)', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: 'Front,Back,Notes\na,b',
      );

      expect(preview.rows, hasLength(1));
      expect(preview.rows.single.front, 'a');
    });

    test('header-only input yields an empty preview', () {
      final FlashcardImportPreview preview = parse.call(rawCsv: 'front,back\n');

      expect(preview.rows, isEmpty);
      expect(preview.issues, isEmpty);
      expect(preview.canCommit, isFalse);
    });

    test('skips fully blank lines but keeps line numbers', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: 'a,b\n\n   \nc,d',
      );

      expect(preview.rows, hasLength(2));
      expect(preview.rows[1].front, 'c');
      expect(preview.rows[1].lineNumber, 4, reason: 'blank lines counted');
    });

    test('handles CRLF line endings', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: 'a,b\r\nc,d\r\n',
      );

      expect(preview.rows, hasLength(2));
      expect(preview.rows[1].back, 'd');
    });

    test('extra columns are ignored; take the first two (C7)', () {
      final FlashcardImportPreview preview = parse.call(rawCsv: 'a,b\nx,y,z');

      expect(preview.issues, isEmpty);
      expect(preview.rows, hasLength(2));
      expect(preview.rows[1].front, 'x');
      expect(preview.rows[1].back, 'y', reason: 'third column ignored');
    });

    test('a single-column row is malformed and excluded', () {
      final FlashcardImportPreview preview = parse.call(rawCsv: 'a,b\nonlyone');

      expect(preview.rows, hasLength(1), reason: 'only the valid row');
      expect(preview.rows.single.front, 'a');
      expect(preview.issues, hasLength(1));
      expect(preview.issues.single.kind, ImportRowIssueType.malformedRow);
      expect(preview.issues.single.lineNumber, 2);
      expect(preview.canCommit, isFalse, reason: 'issue blocks commit');
    });

    test(
      'an empty front is a missingFront issue, row excluded (6.2.2/C30)',
      () {
        final FlashcardImportPreview preview = parse.call(rawCsv: 'a,b\n,back');

        expect(preview.rows, hasLength(1), reason: 'only the valid row');
        expect(preview.rows.single.front, 'a');
        expect(preview.issues, hasLength(1));
        expect(preview.issues.single.kind, ImportRowIssueType.missingFront);
        expect(preview.issues.single.lineNumber, 2);
        expect(preview.canCommit, isFalse);
      },
    );

    test('an empty back is a missingBack issue (6.2.2/C30)', () {
      final FlashcardImportPreview preview = parse.call(rawCsv: 'front,   ');

      expect(preview.rows, isEmpty);
      expect(preview.issues.single.kind, ImportRowIssueType.missingBack);
      expect(preview.issues.single.lineNumber, 1);
      expect(preview.canCommit, isFalse);
    });

    test('a row empty on both sides reports both issues', () {
      // A bare separator → two empty columns (not a blank line) → both issues.
      final FlashcardImportPreview preview = parse.call(rawCsv: ',');

      expect(preview.rows, isEmpty);
      expect(preview.issues, hasLength(2));
      expect(preview.issues.map((i) => i.kind).toSet(), <ImportRowIssueType>{
        ImportRowIssueType.missingFront,
        ImportRowIssueType.missingBack,
      });
      expect(preview.issues.every((i) => i.lineNumber == 1), isTrue);
    });

    test('empty input yields an empty preview', () {
      final FlashcardImportPreview preview = parse.call(rawCsv: '');
      expect(preview.rows, isEmpty);
      expect(preview.issues, isEmpty);
      expect(preview.canCommit, isFalse);
    });

    // WBS 6.9.1 — structured-text separators (decision row I8).
    test('parses an explicit tab separator', () {
      final preview = parse.call(
        rawCsv: 'eat\t먹다\ndrink\t마시다',
        separator: ImportTextSeparator.tab,
      );
      expect(preview.issues, isEmpty);
      expect(preview.rows.map((r) => r.front), <String>['eat', 'drink']);
    });

    test('parses an explicit semicolon / pipe separator', () {
      expect(
        parse
            .call(rawCsv: 'a;1', separator: ImportTextSeparator.semicolon)
            .rows
            .single
            .back,
        '1',
      );
      expect(
        parse
            .call(rawCsv: 'a|1', separator: ImportTextSeparator.pipe)
            .rows
            .single
            .back,
        '1',
      );
    });

    test('auto detects the comma separator', () {
      final preview = parse.call(
        rawCsv: 'a,1\nb,2',
        separator: ImportTextSeparator.auto,
      );
      expect(preview.issues, isEmpty);
      expect(preview.rows, hasLength(2));
      expect(preview.rows[0].back, '1');
    });

    test('auto picks the higher-frequency separator (strict win)', () {
      // First line: 2 semicolons vs 1 pipe → semicolon wins; split on ';' gives
      // 3 columns → first two kept (C7).
      final preview = parse.call(
        rawCsv: 'a;b;c|d',
        separator: ImportTextSeparator.auto,
      );
      expect(preview.issues, isEmpty);
      expect(preview.rows.single.front, 'a');
      expect(preview.rows.single.back, 'b');
    });

    test('auto fails closed on an ambiguous tie (I8)', () {
      // One comma and one pipe on the first line → tie → invalid input.
      final preview = parse.call(
        rawCsv: 'a,b|c',
        separator: ImportTextSeparator.auto,
      );
      expect(preview.rows, isEmpty);
      expect(preview.issues.single.kind, ImportRowIssueType.malformedRow);
      expect(preview.canCommit, isFalse);
    });

    test('auto fails closed when no known separator is present', () {
      final preview = parse.call(
        rawCsv: 'justonecolumn',
        separator: ImportTextSeparator.auto,
      );
      expect(preview.rows, isEmpty);
      expect(preview.issues.single.kind, ImportRowIssueType.malformedRow);
    });

    test('auto on blank-lines-only input is empty (guard precedes detect)', () {
      final preview = parse.call(
        rawCsv: '\n  \n',
        separator: ImportTextSeparator.auto,
      );
      expect(preview.rows, isEmpty);
      expect(preview.issues, isEmpty, reason: 'empty input, not ambiguous');
      expect(preview.canCommit, isFalse);
    });
  });

  // PrepareDeckImportUseCase (WBS 6.6.1): skipExactDuplicates over a clean
  // preview vs earlier file rows + existing deck cards (decision row I7).
  group('PrepareDeckImportUseCase', () {
    test('keeps all rows when there are no duplicates', () async {
      final useCase = PrepareDeckImportUseCase(
        repository: _FakeFlashcardRepository(const []),
      );
      final result = await useCase.call(
        deckId: 'd1',
        preview: _previewOf(const [
          (front: 'a', back: '1'),
          (front: 'b', back: '2'),
        ]),
      );

      expect(result.failure, isNull);
      expect(result.data!.previewItems, hasLength(2));
      expect(result.data!.skippedDuplicates, isEmpty);
      expect(result.data!.importCount, 2);
    });

    test(
      'skips an in-file repeat (case-insensitive), keeping the first',
      () async {
        final useCase = PrepareDeckImportUseCase(
          repository: _FakeFlashcardRepository(const []),
        );
        final result = await useCase.call(
          deckId: 'd1',
          preview: _previewOf(const [
            (front: 'Eat', back: '먹다'),
            (front: ' eat ', back: '먹다'), // dup of row 1 after trim+casefold
            (front: 'drink', back: '마시다'),
          ]),
        );

        expect(result.data!.previewItems.map((r) => r.front), <String>[
          'Eat',
          'drink',
        ]);
        expect(result.data!.skippedDuplicates, hasLength(1));
        expect(
          result.data!.skippedDuplicates.single.source,
          FlashcardImportDuplicateSource.importFile,
        );
      },
    );

    test('skips a row matching an existing deck card', () async {
      final useCase = PrepareDeckImportUseCase(
        repository: _FakeFlashcardRepository(const [
          (front: 'eat', back: '먹다'),
        ]),
      );
      final result = await useCase.call(
        deckId: 'd1',
        preview: _previewOf(const [
          (front: 'EAT', back: ' 먹다 '), // matches existing deck card
          (front: 'new', back: 'card'),
        ]),
      );

      expect(result.data!.previewItems.map((r) => r.front), <String>['new']);
      expect(
        result.data!.skippedDuplicates.single.source,
        FlashcardImportDuplicateSource.deck,
      );
    });

    test(
      'existing-deck clash takes precedence over an in-file repeat',
      () async {
        final useCase = PrepareDeckImportUseCase(
          repository: _FakeFlashcardRepository(const [(front: 'a', back: 'b')]),
        );
        final result = await useCase.call(
          deckId: 'd1',
          preview: _previewOf(const [
            (front: 'a', back: 'b'),
            (front: 'a', back: 'b'),
          ]),
        );

        expect(result.data!.previewItems, isEmpty);
        expect(result.data!.skippedDuplicates, hasLength(2));
        expect(
          result.data!.skippedDuplicates.every(
            (d) => d.source == FlashcardImportDuplicateSource.deck,
          ),
          isTrue,
        );
      },
    );

    test('seenInFile only tracks kept rows (deck-skip vs file-repeat)', () async {
      // existing deck has a/b. Rows: a/b (deck-skip), c/d (kept), c/d (file-repeat).
      final useCase = PrepareDeckImportUseCase(
        repository: _FakeFlashcardRepository(const [(front: 'a', back: 'b')]),
      );
      final result = await useCase.call(
        deckId: 'd1',
        preview: _previewOf(const [
          (front: 'a', back: 'b'),
          (front: 'c', back: 'd'),
          (front: 'c', back: 'd'),
        ]),
      );

      expect(result.data!.previewItems.map((r) => r.front), <String>['c']);
      final sources = result.data!.skippedDuplicates
          .map((d) => d.source)
          .toList();
      expect(sources, <FlashcardImportDuplicateSource>[
        FlashcardImportDuplicateSource.deck, // row 1 vs deck
        FlashcardImportDuplicateSource.importFile, // row 3 repeats kept row 2
      ]);
    });

    test('propagates a repository read failure', () async {
      final useCase = PrepareDeckImportUseCase(
        repository: _FailingFlashcardRepository(),
      );
      final result = await useCase.call(
        deckId: 'd1',
        preview: _previewOf(const [(front: 'a', back: 'b')]),
      );

      expect(result.data, isNull);
      expect(result.failure, isNotNull);
    });
  });

  // CommitDeckImportUseCase (WBS 6.4.1): reject blank deck id / empty items,
  // then delegate a single transactional commit.
  group('CommitDeckImportUseCase', () {
    FlashcardImportPreparation prep(List<({String front, String back})> rows) =>
        FlashcardImportPreparation(
          previewItems: <FlashcardImportRow>[
            for (final (int i, ({String front, String back}) r) in rows.indexed)
              FlashcardImportRow(
                lineNumber: i + 1,
                front: r.front,
                back: r.back,
              ),
          ],
        );

    test('commits the prepared rows and returns the count', () async {
      final repo = _FakeFlashcardRepository();
      final useCase = CommitDeckImportUseCase(repository: repo);

      final result = await useCase.call(
        deckId: 'd1',
        preparation: prep(const [
          (front: 'a', back: '1'),
          (front: 'b', back: '2'),
        ]),
      );

      expect(result.failure, isNull);
      expect(result.data, 2);
      expect(repo.committedDeckId, 'd1');
      expect(repo.committedRows!.map((r) => r.front), <String>['a', 'b']);
    });

    test('rejects a blank deck id without touching the repository', () async {
      final repo = _FakeFlashcardRepository();
      final useCase = CommitDeckImportUseCase(repository: repo);

      final result = await useCase.call(
        deckId: '  ',
        preparation: prep(const [(front: 'a', back: '1')]),
      );

      expect(result.data, isNull);
      expect(result.failure, isA<ValidationFailure>());
      expect(repo.committedRows, isNull);
    });

    test('rejects an empty preparation', () async {
      final repo = _FakeFlashcardRepository();
      final useCase = CommitDeckImportUseCase(repository: repo);

      final result = await useCase.call(
        deckId: 'd1',
        preparation: FlashcardImportPreparation.empty,
      );

      expect(result.data, isNull);
      expect(result.failure, isA<ValidationFailure>());
      expect(repo.committedRows, isNull);
    });
  });
}

/// Fake whose deck-content read fails, to verify failure propagation.
class _FailingFlashcardRepository implements FlashcardRepository {
  @override
  Future<Result<List<({String front, String back})>>> loadDeckCardContents({
    required DeckId deckId,
  }) async => (
    failure: const Failure.storage(
      operation: StorageOp.read,
      table: 'flashcards',
      cause: 'boom',
    ),
    data: null,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
