import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/deck_csv_export.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/flashcard_status_filter.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/domain/usecases/flashcard/delete_flashcard_usecase.dart';
import 'package:memox/domain/usecases/flashcard/get_flashcard_detail_usecase.dart';
import 'package:memox/domain/usecases/flashcard/update_flashcard_usecase.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_editor_screen.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';

Deck _deck() => Deck(
  id: 'd1',
  folderId: 'f1',
  name: 'N5',
  targetLanguage: TargetLanguage.korean,
  sortOrder: 0,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

FlashcardListDetail _deckContext() => FlashcardListDetail(
  deck: _deck(),
  breadcrumb: const <FolderBreadcrumbSegment>[
    FolderBreadcrumbSegment(id: 'f1', name: 'Korean'),
  ],
  cards: const <Flashcard>[],
  totalCount: 1,
);

FlashcardDetail _freshDetail() => FlashcardDetail(
  deck: _deck(),
  breadcrumb: const <FolderBreadcrumbSegment>[
    FolderBreadcrumbSegment(id: 'f1', name: 'Korean'),
  ],
  flashcard: Flashcard(
    id: 'c1',
    deckId: 'd1',
    front: '안녕하세요',
    back: 'Hello',
    exampleSentence: 'Example sentence',
    pronunciation: 'annyeonghaseyo',
    hint: 'Greeting root',
    sortOrder: 0,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  ),
  tags: const <String>['noun', 'greeting'],
  progress: FlashcardProgressSnapshot(
    boxNumber: 3,
    dueAt: DateTime.utc(2026, 1, 2),
    buriedUntil: null,
    isSuspended: false,
    reviewCount: 8,
    lapseCount: 1,
    lastStudiedAt: DateTime.utc(2026, 1, 1),
  ),
);

FlashcardDetail _freshProgressDetail() => FlashcardDetail(
  deck: _deck(),
  breadcrumb: const <FolderBreadcrumbSegment>[
    FolderBreadcrumbSegment(id: 'f1', name: 'Korean'),
  ],
  flashcard: Flashcard(
    id: 'c1',
    deckId: 'd1',
    front: '안녕하세요',
    back: 'Hello',
    exampleSentence: 'Example sentence',
    pronunciation: 'annyeonghaseyo',
    hint: 'Greeting root',
    sortOrder: 0,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  ),
  tags: const <String>['noun', 'greeting'],
  progress: FlashcardProgressSnapshot(
    boxNumber: 1,
    dueAt: DateTime.utc(2026, 1, 2),
    buriedUntil: null,
    isSuspended: false,
    reviewCount: 0,
    lapseCount: 0,
    lastStudiedAt: null,
  ),
);

FlashcardDetail _savedDetail() => FlashcardDetail(
  deck: _deck(),
  breadcrumb: const <FolderBreadcrumbSegment>[
    FolderBreadcrumbSegment(id: 'f1', name: 'Korean'),
  ],
  flashcard: Flashcard(
    id: 'c1',
    deckId: 'd1',
    front: '안녕',
    back: 'Hello there',
    exampleSentence: 'Example sentence',
    pronunciation: 'annyeonghaseyo',
    hint: 'Greeting root',
    sortOrder: 0,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 2),
  ),
  tags: const <String>['noun', 'greeting'],
  progress: FlashcardProgressSnapshot(
    boxNumber: 1,
    dueAt: DateTime.utc(2026, 1, 2),
    buriedUntil: null,
    isSuspended: false,
    reviewCount: 8,
    lapseCount: 1,
    lastStudiedAt: DateTime.utc(2026, 1, 1),
  ),
);

class _UpdateCall {
  const _UpdateCall({
    required this.flashcardId,
    required this.front,
    required this.back,
    required this.exampleSentence,
    required this.pronunciation,
    required this.hint,
    required this.tags,
    required this.progressPolicy,
  });

  final FlashcardId flashcardId;
  final String front;
  final String back;
  final String? exampleSentence;
  final String? pronunciation;
  final String? hint;
  final List<String> tags;
  final FlashcardProgressEditPolicy progressPolicy;
}

class _RecordingFlashcardRepository implements FlashcardRepository {
  _RecordingFlashcardRepository({
    Result<FlashcardDetail>? detailResult,
    Result<Flashcard>? updateResult,
    Result<void>? deleteResult,
  }) : detailResult =
           detailResult ?? Result<FlashcardDetail>.ok(_freshDetail()),
       updateResult = updateResult ?? Result<Flashcard>.ok(_savedFlashcard()),
       deleteResult = deleteResult ?? const Result<void>.ok(null);

  final Result<FlashcardDetail> detailResult;
  final Result<Flashcard> updateResult;
  final Result<void> deleteResult;

  _UpdateCall? lastUpdateCall;
  FlashcardId? lastDeleteFlashcardId;

  static Flashcard _savedFlashcard() => _savedDetail().flashcard.copyWith(
    front: '안녕',
    back: 'Hello there',
    updatedAt: DateTime.utc(2026, 1, 2),
  );

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
  }) async => detailResult;

  @override
  Future<Result<List<Flashcard>>> existingByFrontBackPairs(
    DeckId deckId,
    List<({String front, String back})> pairs,
  ) async => const Result<List<Flashcard>>.ok(<Flashcard>[]);

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
    lastUpdateCall = _UpdateCall(
      flashcardId: flashcardId,
      front: front,
      back: back,
      exampleSentence: exampleSentence,
      pronunciation: pronunciation,
      hint: hint,
      tags: tags,
      progressPolicy: progressPolicy,
    );
    return updateResult;
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
  Future<Result<void>> deleteFlashcard({
    required FlashcardId flashcardId,
  }) async {
    lastDeleteFlashcardId = flashcardId;
    return deleteResult;
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
}

class _EditorHost extends StatelessWidget {
  const _EditorHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Library home'),
          ElevatedButton(
            onPressed: () {
              unawaited(
                Navigator.of(
                  context,
                ).push<void>(MaterialPageRoute<void>(builder: (_) => child)),
              );
            },
            child: const Text('Open editor'),
          ),
        ],
      ),
    ),
  );
}

Widget _wrapApp({
  required _RecordingFlashcardRepository repository,
  ThemeData? theme,
}) => ProviderScope(
  overrides: [
    flashcardEditorContextQueryProvider('d1').overrideWith(
      (Ref ref) => Stream<FlashcardListDetail>.value(_deckContext()),
    ),
    getFlashcardDetailUseCaseProvider.overrideWithValue(
      GetFlashcardDetailUseCase(repository),
    ),
    updateFlashcardUseCaseProvider.overrideWithValue(
      UpdateFlashcardUseCase(repository),
    ),
    deleteFlashcardUseCaseProvider.overrideWithValue(
      DeleteFlashcardUseCase(repository),
    ),
  ],
  child: MaterialApp(
    locale: const Locale('en'),
    theme: theme ?? AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const _EditorHost(
      child: FlashcardEditorScreen(deckId: 'd1', flashcardId: 'c1'),
    ),
  ),
);

Future<void> _openEditor(WidgetTester tester) async {
  await tester.tap(find.text('Open editor'));
  await tester.pumpAndSettle();
}

void main() {
  group('FlashcardEditorScreen edit mode', () {
    testWidgets('DT1 onDisplay: loads the existing flashcard and danger zone', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapApp(repository: _RecordingFlashcardRepository()),
      );
      await _openEditor(tester);

      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Save and add another'), findsNothing);
      expect(find.text('Danger zone'), findsOneWidget);
      expect(find.text('Delete this flashcard?'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.text('안녕하세요'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('noun'), findsOneWidget);
      expect(find.text('greeting'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('DT6 onNavigate: clean close pops immediately', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapApp(repository: _RecordingFlashcardRepository()),
      );
      await _openEditor(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Library home'), findsOneWidget);
      expect(find.text('Danger zone'), findsNothing);
    });

    testWidgets(
      'DT2 onDisplay: shows load error state when the card detail fails',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapApp(
            repository: _RecordingFlashcardRepository(
              detailResult: const Result<FlashcardDetail>.err(
                Failure.notFound(entity: 'flashcard', id: 'c1'),
              ),
            ),
          ),
        );
        await _openEditor(tester);

        expect(find.text("Couldn't load this card"), findsOneWidget);
        expect(find.text('Back to deck'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets(
      'DT7 onNavigate: dirty close asks for discard and keeps editing',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapApp(repository: _RecordingFlashcardRepository()),
        );
        await _openEditor(tester);

        await tester.enterText(find.byType(TextFormField).at(0), '안녕');
        await tester.pump();

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(find.text('Discard changes?'), findsOneWidget);
        expect(find.text('Keep editing'), findsOneWidget);

        await tester.tap(find.text('Keep editing'));
        await tester.pumpAndSettle();

        expect(find.text('Danger zone'), findsOneWidget);
      },
    );

    testWidgets('DT3 onEdit: save asks for progress policy and can reset', (
      WidgetTester tester,
    ) async {
      final _RecordingFlashcardRepository repository =
          _RecordingFlashcardRepository();

      await tester.pumpWidget(_wrapApp(repository: repository));
      await _openEditor(tester);

      await tester.enterText(find.byType(TextFormField).at(0), '안녕');
      await tester.pump();

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('You changed the learning content.'), findsOneWidget);
      expect(find.text('Keep'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(repository.lastUpdateCall, isNotNull);
      expect(repository.lastUpdateCall!.flashcardId, 'c1');
      expect(repository.lastUpdateCall!.front, '안녕');
      expect(repository.lastUpdateCall!.back, 'Hello');
      expect(
        repository.lastUpdateCall!.progressPolicy,
        FlashcardProgressEditPolicy.resetProgress,
      );
      expect(find.text('Flashcard updated.'), findsOneWidget);
      expect(find.text('Library home'), findsOneWidget);
    });

    testWidgets('DT4 onEdit: delete confirms through the danger zone', (
      WidgetTester tester,
    ) async {
      final _RecordingFlashcardRepository repository =
          _RecordingFlashcardRepository();

      await tester.pumpWidget(_wrapApp(repository: repository));
      await _openEditor(tester);

      await tester.ensureVisible(find.text('Delete card').first);
      await tester.tap(find.text('Delete card').first);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);

      await tester.tap(find.text('Delete card').last);
      await tester.pumpAndSettle();

      expect(repository.lastDeleteFlashcardId, 'c1');
      expect(find.text('Flashcard deleted.'), findsOneWidget);
      expect(find.text('Library home'), findsOneWidget);
      expect(find.text('Edit card'), findsNothing);
    });

    testWidgets('DT5 onEdit: save failure leaves the draft open', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapApp(
          repository: _RecordingFlashcardRepository(
            detailResult: Result<FlashcardDetail>.ok(_freshProgressDetail()),
            updateResult: const Result<Flashcard>.err(
              Failure.storage(
                operation: StorageOp.write,
                cause: 'offline',
                table: 'flashcards',
              ),
            ),
          ),
        ),
      );
      await _openEditor(tester);

      await tester.enterText(find.byType(TextFormField).at(0), '안녕');
      await tester.pump();

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>('flashcard_editor_save_failed_banner'),
        ),
        findsOneWidget,
      );
      expect(find.text('Danger zone'), findsOneWidget);
    });
  });
}
