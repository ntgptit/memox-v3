import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
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
import 'package:memox/domain/usecases/flashcard/create_flashcard_usecase.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_view.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

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
  totalCount: 0,
);

Flashcard _flashcard({String front = '안녕하세요', String back = 'Hello'}) =>
    Flashcard(
      id: 'c1',
      deckId: 'd1',
      front: front,
      back: back,
      exampleSentence: 'Example sentence',
      pronunciation: 'annyeonghaseyo',
      hint: 'Greeting root',
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

FlashcardDetail _flashcardDetail() => FlashcardDetail(
  deck: _deck(),
  breadcrumb: const <FolderBreadcrumbSegment>[
    FolderBreadcrumbSegment(id: 'f1', name: 'Korean'),
  ],
  flashcard: _flashcard(),
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

final class _ControllableFlashcardRepository implements FlashcardRepository {
  _ControllableFlashcardRepository({
    this.createCompleter,
    Result<Flashcard>? createResult,
  }) : createResult =
           createResult ??
           Result<Flashcard>.ok(_flashcard(front: '새 카드', back: 'New card'));

  final Completer<Result<Flashcard>>? createCompleter;
  final Result<Flashcard> createResult;

  int createCallCount = 0;

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
    createCallCount += 1;
    if (createCompleter != null) {
      return createCompleter!.future;
    }
    return Future<Result<Flashcard>>.value(createResult);
  }

  @override
  Future<Result<FlashcardDetail>> getFlashcardDetail({
    required FlashcardId flashcardId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Flashcard>>> existingByFrontBackPairs(
    DeckId deckId,
    List<({String front, String back})> pairs,
  ) {
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
  required _ControllableFlashcardRepository repository,
  required Widget child,
  FlashcardDetail? flashcardDetail,
}) => ProviderScope(
  overrides: [
    flashcardEditorContextQueryProvider('d1').overrideWith(
      (Ref ref) => Stream<FlashcardListDetail>.value(_deckContext()),
    ),
    createFlashcardUseCaseProvider.overrideWithValue(
      CreateFlashcardUseCase(repository),
    ),
    if (flashcardDetail != null)
      flashcardEditorDetailQueryProvider(
        'c1',
      ).overrideWith((Ref ref) async => flashcardDetail),
  ],
  child: MaterialApp(
    locale: const Locale('en'),
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: _EditorHost(child: child),
  ),
);

Future<void> _openEditor(WidgetTester tester) async {
  await tester.tap(find.text('Open editor'));
  await tester.pumpAndSettle();
}

MxPrimaryButton _primaryButton(WidgetTester tester, String label) {
  final Iterable<MxPrimaryButton> buttons = tester.widgetList<MxPrimaryButton>(
    find.byType(MxPrimaryButton),
  );
  return buttons.firstWhere((MxPrimaryButton button) => button.label == label);
}

MxSecondaryButton _secondaryButton(WidgetTester tester, String label) {
  final Iterable<MxSecondaryButton> buttons = tester
      .widgetList<MxSecondaryButton>(find.byType(MxSecondaryButton));
  return buttons.firstWhere(
    (MxSecondaryButton button) => button.label == label,
  );
}

MxIconButton _iconButton(WidgetTester tester, String tooltip) => tester
    .widgetList<MxIconButton>(find.byType(MxIconButton))
    .firstWhere((MxIconButton button) => button.tooltip == tooltip);

void main() {
  group('FlashcardEditorView', () {
    testWidgets(
      'creates a blank draft with save disabled until front and back are filled',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapApp(
            repository: _ControllableFlashcardRepository(),
            child: const FlashcardEditorView(deckId: 'd1'),
          ),
        );
        await _openEditor(tester);

        expect(find.text('0 / 60'), findsOneWidget);
        expect(find.text('0 / 240'), findsOneWidget);
        expect(_primaryButton(tester, 'Save').onPressed, isNull);
        expect(_primaryButton(tester, 'Save card').onPressed, isNull);

        await tester.enterText(find.byType(TextFormField).at(0), 'abc');
        await tester.pump();

        expect(find.text('3 / 60'), findsOneWidget);
        expect(find.text('0 / 240'), findsOneWidget);
        expect(_primaryButton(tester, 'Save').onPressed, isNull);
        expect(_primaryButton(tester, 'Save card').onPressed, isNull);

        await tester.enterText(find.byType(TextFormField).at(1), 'hello');
        await tester.pump();

        expect(find.text('3 / 60'), findsOneWidget);
        expect(find.text('5 / 240'), findsOneWidget);
        expect(_primaryButton(tester, 'Save').onPressed, isNotNull);
        expect(_primaryButton(tester, 'Save card').onPressed, isNotNull);
      },
    );

    testWidgets('keeps save-and-add-another local until save is tapped', (
      WidgetTester tester,
    ) async {
      final _ControllableFlashcardRepository repository =
          _ControllableFlashcardRepository();

      await tester.pumpWidget(
        _wrapApp(
          repository: repository,
          child: const FlashcardEditorView(deckId: 'd1'),
        ),
      );
      await _openEditor(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'abc');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(1), 'hello');
      await tester.pump();

      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      expect(repository.createCallCount, 0);

      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      expect(repository.createCallCount, 0);
      expect(_primaryButton(tester, 'Save').onPressed, isNotNull);
      expect(_secondaryButton(tester, 'Cancel').onPressed, isNotNull);
    });

    testWidgets(
      'shows busy save state and blocks close while the controller is loading',
      (WidgetTester tester) async {
        final Completer<Result<Flashcard>> createCompleter =
            Completer<Result<Flashcard>>();
        final _ControllableFlashcardRepository repository =
            _ControllableFlashcardRepository(createCompleter: createCompleter);

        await tester.pumpWidget(
          _wrapApp(
            repository: repository,
            child: const FlashcardEditorView(deckId: 'd1'),
          ),
        );
        await _openEditor(tester);

        await tester.enterText(find.byType(TextFormField).at(0), 'abc');
        await tester.pump();
        await tester.enterText(find.byType(TextFormField).at(1), 'hello');
        await tester.pump();

        await tester.tap(find.text('Save'));
        await tester.pump();

        expect(repository.createCallCount, 1);
        expect(_iconButton(tester, 'Close').onPressed, isNull);
        expect(_secondaryButton(tester, 'Cancel').onPressed, isNull);
        expect(_primaryButton(tester, 'Save').onPressed, isNull);
        expect(_primaryButton(tester, 'Save card').onPressed, isNull);
        expect(_primaryButton(tester, 'Save card').icon, Icons.hourglass_top);

        createCompleter.complete(
          Result<Flashcard>.ok(_flashcard(front: 'abc', back: 'hello')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Library home'), findsOneWidget);
        expect(find.text('New flashcard'), findsNothing);
      },
    );

    testWidgets('hydrates edit fields once and keeps the loaded draft clean', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapApp(
          repository: _ControllableFlashcardRepository(),
          flashcardDetail: _flashcardDetail(),
          child: const FlashcardEditorView(deckId: 'd1', flashcardId: 'c1'),
        ),
      );
      await _openEditor(tester);
      await tester.pumpAndSettle();

      expect(find.text('안녕하세요'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('noun'), findsOneWidget);
      expect(find.text('greeting'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Library home'), findsOneWidget);
      expect(find.text('Edit card'), findsNothing);
    });
  });
}
