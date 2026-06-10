import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
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
import 'package:memox/domain/usecases/flashcard/prepare_deck_import_usecase.dart';

class _RecordingFlashcardRepository implements FlashcardRepository {
  _RecordingFlashcardRepository({
    Result<int>? commitResult,
    Map<DeckId, List<Flashcard>>? existingCardsByDeck,
  }) : commitResult = commitResult ?? const Result<int>.ok(2),
       existingCardsByDeck = existingCardsByDeck ?? <DeckId, List<Flashcard>>{};

  final Result<int> commitResult;
  final Map<DeckId, List<Flashcard>> existingCardsByDeck;

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
  Future<Result<List<Flashcard>>> existingByFrontBackPairs(
    DeckId deckId,
    List<({String front, String back})> pairs,
  ) async {
    final List<Flashcard> existingCards =
        existingCardsByDeck[deckId] ?? const <Flashcard>[];
    if (pairs.isEmpty || existingCards.isEmpty) {
      return const Result<List<Flashcard>>.ok(<Flashcard>[]);
    }

    final Set<String> requestedKeys = <String>{
      for (final ({String front, String back}) pair in pairs)
        _pairKey(pair.front, pair.back),
    };
    return Result<List<Flashcard>>.ok(
      existingCards
          .where(
            (Flashcard card) =>
                requestedKeys.contains(_pairKey(card.front, card.back)),
          )
          .toList(growable: false),
    );
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

String _pairKey(String front, String back) =>
    '${StringUtils.normalize(front)}\u0000${StringUtils.normalize(back)}';

Future<DeckImportPreview> _prepareImportPreview({
  required String deckId,
  required String rawContent,
  DeckImportSourceFormat sourceFormat = DeckImportSourceFormat.csv,
  DeckImportStructuredTextSeparator structuredTextSeparator =
      DeckImportStructuredTextSeparator.auto,
  Map<DeckId, List<Flashcard>> existingCardsByDeck =
      const <DeckId, List<Flashcard>>{},
}) async {
  final _RecordingFlashcardRepository repository =
      _RecordingFlashcardRepository(existingCardsByDeck: existingCardsByDeck);
  final Result<DeckImportPreview> result =
      await PrepareDeckImportUseCase(repository).call(
        deckId: deckId,
        rawContent: rawContent,
        sourceFormat: sourceFormat,
        structuredTextSeparator: structuredTextSeparator,
      );
  expect(result, isA<Ok<DeckImportPreview>>());
  return (result as Ok<DeckImportPreview>).value;
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

  group('PrepareDeckImportUseCase', () {
    test('empty import still returns an empty preview', () async {
      final DeckImportPreview preview = await _prepareImportPreview(
        deckId: 'd1',
        rawContent: '',
      );

      expect(preview.totalRowCount, 0);
      expect(preview.rows, isEmpty);
      expect(preview.issues, isEmpty);
      expect(preview.skippedDuplicates, isEmpty);
    });

    test(
      'duplicates inside the same CSV batch are skipped after the first row',
      () async {
        final DeckImportPreview preview = await _prepareImportPreview(
          deckId: 'd1',
          rawContent: 'front,back\nHello,World\nhello,world\nBye,See ya',
        );

        expect(preview.totalRowCount, 3);
        expect(preview.rows.map((row) => row.front), <String>['Hello', 'Bye']);
        expect(preview.skippedDuplicates, hasLength(1));
        expect(
          preview.skippedDuplicates.single.source,
          DeckImportDuplicateSource.importFile,
        );
      },
    );

    test(
      'duplicates against cards already in the target deck are skipped',
      () async {
        final DeckImportPreview preview = await _prepareImportPreview(
          deckId: 'deck-1',
          rawContent: 'front,back\nHello,World\nBye,See ya',
          existingCardsByDeck: <DeckId, List<Flashcard>>{
            'deck-1': <Flashcard>[
              Flashcard(
                id: 'existing',
                deckId: 'deck-1',
                front: 'hello',
                back: 'world',
                sortOrder: 0,
                createdAt: DateTime.utc(2026, 1, 1),
                updatedAt: DateTime.utc(2026, 1, 1),
              ),
            ],
          },
        );

        expect(preview.rows.map((row) => row.front), <String>['Bye']);
        expect(preview.skippedDuplicates, hasLength(1));
        expect(
          preview.skippedDuplicates.single.source,
          DeckImportDuplicateSource.deck,
        );
      },
    );

    test('the same content in another deck stays importable', () async {
      final DeckImportPreview preview = await _prepareImportPreview(
        deckId: 'deck-2',
        rawContent: 'front,back\nHello,World\nBye,See ya',
        existingCardsByDeck: <DeckId, List<Flashcard>>{
          'deck-1': <Flashcard>[
            Flashcard(
              id: 'existing',
              deckId: 'deck-1',
              front: 'hello',
              back: 'world',
              sortOrder: 0,
              createdAt: DateTime.utc(2026, 1, 1),
              updatedAt: DateTime.utc(2026, 1, 1),
            ),
          ],
        },
      );

      expect(preview.rows.map((row) => row.front), <String>['Hello', 'Bye']);
      expect(preview.skippedDuplicates, isEmpty);
    });

    test('duplicate comparison is normalized by trim and case', () async {
      final DeckImportPreview preview = await _prepareImportPreview(
        deckId: 'deck-1',
        rawContent: 'front,back\n  Hello  ,  World  \nhello,world',
      );

      expect(preview.rows.map((row) => row.front), <String>['Hello']);
      expect(preview.skippedDuplicates, hasLength(1));
      expect(
        preview.skippedDuplicates.single.source,
        DeckImportDuplicateSource.importFile,
      );
    });

    test(
      'invalid empty front/back rows stay invalid, not duplicates',
      () async {
        final DeckImportPreview preview = await _prepareImportPreview(
          deckId: 'deck-1',
          rawContent: 'front,back\n,Hello\nHi,\n,,note',
        );

        expect(preview.rows, isEmpty);
        expect(preview.issues, hasLength(3));
        expect(preview.skippedDuplicates, isEmpty);
        expect(preview.issues.map((issue) => issue.code), <DeckImportIssueCode>[
          DeckImportIssueCode.frontRequired,
          DeckImportIssueCode.backRequired,
          DeckImportIssueCode.frontAndBackRequired,
        ]);
      },
    );

    test(
      'mixed CSV input produces valid, invalid, and skipped counts',
      () async {
        final DeckImportPreview preview = await _prepareImportPreview(
          deckId: 'deck-1',
          rawContent:
              'front,back\nHello,World\nHello,World\n,Missing\nBye,See ya',
          existingCardsByDeck: <DeckId, List<Flashcard>>{
            'deck-1': <Flashcard>[
              Flashcard(
                id: 'existing',
                deckId: 'deck-1',
                front: 'bye',
                back: 'see ya',
                sortOrder: 0,
                createdAt: DateTime.utc(2026, 1, 1),
                updatedAt: DateTime.utc(2026, 1, 1),
              ),
            ],
          },
        );

        expect(preview.totalRowCount, 4);
        expect(preview.rows, hasLength(1));
        expect(preview.issues, hasLength(1));
        expect(preview.skippedDuplicates, hasLength(2));
        expect(preview.canCommit, isFalse);
      },
    );

    test(
      'commit inserts only the valid non-duplicate rows from a prepared preview',
      () async {
        final _RecordingFlashcardRepository repository =
            _RecordingFlashcardRepository();
        final CommitDeckImportUseCase commitUseCase = CommitDeckImportUseCase(
          repository,
        );
        const DeckImportPreview preview = DeckImportPreview(
          totalRowCount: 3,
          rows: <DeckImportPreviewRow>[
            DeckImportPreviewRow(lineNumber: 2, front: 'Hello', back: 'World'),
            DeckImportPreviewRow(lineNumber: 4, front: 'Bye', back: 'See ya'),
          ],
          issues: <DeckImportIssue>[],
          skippedDuplicates: <DeckImportSkippedDuplicate>[
            DeckImportSkippedDuplicate(
              lineNumber: 3,
              front: 'hello',
              back: 'world',
              source: DeckImportDuplicateSource.importFile,
            ),
          ],
        );

        final Result<int> result = await commitUseCase.call(
          deckId: 'd1',
          preview: preview,
        );

        expect(result, isA<Ok<int>>());
        expect(repository.lastCommitRows, hasLength(2));
        expect(repository.lastCommitRows!.map((row) => row.front), <String>[
          'Hello',
          'Bye',
        ]);
      },
    );

    test('provider wiring resolves the prepare use case', () {
      final _RecordingFlashcardRepository repository =
          _RecordingFlashcardRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [flashcardRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final PrepareDeckImportUseCase useCase = container.read(
        prepareDeckImportUseCaseProvider,
      );

      expect(useCase, isA<PrepareDeckImportUseCase>());
    });

    test(
      'commit rejects a preview that contains only duplicates and invalid rows',
      () async {
        final _RecordingFlashcardRepository repository =
            _RecordingFlashcardRepository();
        final CommitDeckImportUseCase commitUseCase = CommitDeckImportUseCase(
          repository,
        );

        final Result<int> result = await commitUseCase.call(
          deckId: 'd1',
          preview: const DeckImportPreview(
            totalRowCount: 2,
            rows: <DeckImportPreviewRow>[],
            issues: <DeckImportIssue>[],
            skippedDuplicates: <DeckImportSkippedDuplicate>[
              DeckImportSkippedDuplicate(
                lineNumber: 2,
                front: 'Hello',
                back: 'World',
                source: DeckImportDuplicateSource.deck,
              ),
            ],
          ),
        );

        expect(result, isA<Err<int>>());
        expect((result as Err<int>).failure, isA<ValidationFailure>());
        expect(repository.lastCommitRows, isNull);
      },
    );

    test('structured text with tab separators parses correctly', () async {
      final DeckImportPreview preview = await _prepareImportPreview(
        deckId: 'deck-1',
        rawContent: 'Hello\tWorld\nBye\tSee ya',
        sourceFormat: DeckImportSourceFormat.structuredText,
        structuredTextSeparator: DeckImportStructuredTextSeparator.tab,
      );

      expect(preview.rows.map((row) => row.front), <String>['Hello', 'Bye']);
      expect(preview.rows.map((row) => row.back), <String>['World', 'See ya']);
    });

    test('structured text with colon separators parses correctly', () async {
      final DeckImportPreview preview = await _prepareImportPreview(
        deckId: 'deck-1',
        rawContent: 'Hello:World\nBye:See ya',
        sourceFormat: DeckImportSourceFormat.structuredText,
        structuredTextSeparator: DeckImportStructuredTextSeparator.colon,
      );

      expect(preview.rows.map((row) => row.front), <String>['Hello', 'Bye']);
      expect(preview.rows.map((row) => row.back), <String>['World', 'See ya']);
    });

    test('structured text with slash separators parses correctly', () async {
      final DeckImportPreview preview = await _prepareImportPreview(
        deckId: 'deck-1',
        rawContent: 'Hello/World\nBye/See ya',
        sourceFormat: DeckImportSourceFormat.structuredText,
        structuredTextSeparator: DeckImportStructuredTextSeparator.slash,
      );

      expect(preview.rows.map((row) => row.front), <String>['Hello', 'Bye']);
      expect(preview.rows.map((row) => row.back), <String>['World', 'See ya']);
    });

    test(
      'structured text with semicolon separators parses correctly',
      () async {
        final DeckImportPreview preview = await _prepareImportPreview(
          deckId: 'deck-1',
          rawContent: 'Hello;World\nBye;See ya',
          sourceFormat: DeckImportSourceFormat.structuredText,
          structuredTextSeparator: DeckImportStructuredTextSeparator.semicolon,
        );

        expect(preview.rows.map((row) => row.front), <String>['Hello', 'Bye']);
        expect(preview.rows.map((row) => row.back), <String>[
          'World',
          'See ya',
        ]);
      },
    );

    test('structured text with pipe separators parses correctly', () async {
      final DeckImportPreview preview = await _prepareImportPreview(
        deckId: 'deck-1',
        rawContent: 'Hello|World\nBye|See ya',
        sourceFormat: DeckImportSourceFormat.structuredText,
        structuredTextSeparator: DeckImportStructuredTextSeparator.pipe,
      );

      expect(preview.rows.map((row) => row.front), <String>['Hello', 'Bye']);
      expect(preview.rows.map((row) => row.back), <String>['World', 'See ya']);
    });

    test(
      'comma-separated structured text stays compatible with CSV parsing',
      () async {
        final DeckImportPreview csvPreview = const ParseDeckImportCsvUseCase()
            .call(rawCsv: 'Hello,World\nBye,See ya');
        final DeckImportPreview structuredPreview = await _prepareImportPreview(
          deckId: 'deck-1',
          rawContent: 'Hello,World\nBye,See ya',
          sourceFormat: DeckImportSourceFormat.structuredText,
          structuredTextSeparator: DeckImportStructuredTextSeparator.comma,
        );

        expect(
          structuredPreview.rows.map((row) => row.front),
          csvPreview.rows.map((row) => row.front),
        );
        expect(
          structuredPreview.rows.map((row) => row.back),
          csvPreview.rows.map((row) => row.back),
        );
      },
    );

    test(
      'auto-detect structured text picks the tab separator deterministically',
      () async {
        final DeckImportPreview preview = await _prepareImportPreview(
          deckId: 'deck-1',
          rawContent: 'Hello\tWorld\nBye\tSee ya',
          sourceFormat: DeckImportSourceFormat.structuredText,
        );

        expect(preview.rows.map((row) => row.front), <String>['Hello', 'Bye']);
        expect(preview.skippedDuplicates, isEmpty);
      },
    );

    test('malformed structured rows surface as invalid preview rows', () async {
      final DeckImportPreview preview = await _prepareImportPreview(
        deckId: 'deck-1',
        rawContent: 'Hello World',
        sourceFormat: DeckImportSourceFormat.structuredText,
        structuredTextSeparator: DeckImportStructuredTextSeparator.tab,
      );

      expect(preview.rows, isEmpty);
      expect(preview.issues, hasLength(1));
      expect(preview.issues.single.code, DeckImportIssueCode.invalidFormat);
    });

    test(
      'empty structured text follows the same empty-preview policy',
      () async {
        final DeckImportPreview preview = await _prepareImportPreview(
          deckId: 'deck-1',
          rawContent: '   \n\t\n',
          sourceFormat: DeckImportSourceFormat.structuredText,
          structuredTextSeparator: DeckImportStructuredTextSeparator.auto,
        );

        expect(preview.totalRowCount, 0);
        expect(preview.rows, isEmpty);
        expect(preview.issues, isEmpty);
      },
    );

    test('structured text validation matches CSV validation', () async {
      final DeckImportPreview csvPreview = const ParseDeckImportCsvUseCase()
          .call(rawCsv: 'front,back\n,Hello\nHi,');
      final DeckImportPreview structuredPreview = await _prepareImportPreview(
        deckId: 'deck-1',
        rawContent: ',Hello\nHi,',
        sourceFormat: DeckImportSourceFormat.structuredText,
        structuredTextSeparator: DeckImportStructuredTextSeparator.comma,
      );

      expect(
        structuredPreview.issues.map((issue) => issue.code),
        csvPreview.issues.map((issue) => issue.code),
      );
    });

    test(
      'structured text duplicate detection works inside the input',
      () async {
        final DeckImportPreview preview = await _prepareImportPreview(
          deckId: 'deck-1',
          rawContent: 'Hello\tWorld\nhello\tworld',
          sourceFormat: DeckImportSourceFormat.structuredText,
          structuredTextSeparator: DeckImportStructuredTextSeparator.tab,
        );

        expect(preview.rows.map((row) => row.front), <String>['Hello']);
        expect(preview.skippedDuplicates, hasLength(1));
        expect(
          preview.skippedDuplicates.single.source,
          DeckImportDuplicateSource.importFile,
        );
      },
    );

    test(
      'structured text duplicate detection works against the existing deck',
      () async {
        final DeckImportPreview preview = await _prepareImportPreview(
          deckId: 'deck-1',
          rawContent: 'Hello\tWorld\nBye\tSee ya',
          sourceFormat: DeckImportSourceFormat.structuredText,
          structuredTextSeparator: DeckImportStructuredTextSeparator.tab,
          existingCardsByDeck: <DeckId, List<Flashcard>>{
            'deck-1': <Flashcard>[
              Flashcard(
                id: 'existing',
                deckId: 'deck-1',
                front: 'hello',
                back: 'world',
                sortOrder: 0,
                createdAt: DateTime.utc(2026, 1, 1),
                updatedAt: DateTime.utc(2026, 1, 1),
              ),
            ],
          },
        );

        expect(preview.rows.map((row) => row.front), <String>['Bye']);
        expect(
          preview.skippedDuplicates.single.source,
          DeckImportDuplicateSource.deck,
        );
      },
    );

    test(
      'structured text commit inserts only the valid non-duplicate rows',
      () async {
        final _RecordingFlashcardRepository repository =
            _RecordingFlashcardRepository();
        final PrepareDeckImportUseCase prepareUseCase =
            PrepareDeckImportUseCase(repository);
        final CommitDeckImportUseCase commitUseCase = CommitDeckImportUseCase(
          repository,
        );

        final DeckImportPreview preview =
            (await prepareUseCase.call(
                      deckId: 'deck-1',
                      rawContent: 'Hello\tWorld\nhello\tworld\nBye\tSee ya',
                      sourceFormat: DeckImportSourceFormat.structuredText,
                      structuredTextSeparator:
                          DeckImportStructuredTextSeparator.tab,
                    )
                    as Ok<DeckImportPreview>)
                .value;

        final Result<int> result = await commitUseCase.call(
          deckId: 'deck-1',
          preview: preview,
        );

        expect(result, isA<Ok<int>>());
        expect(repository.lastCommitRows, hasLength(2));
        expect(repository.lastCommitRows!.map((row) => row.front), <String>[
          'Hello',
          'Bye',
        ]);
      },
    );
  });
}
