import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/domain/usecases/flashcard/create_flashcard_usecase.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_editor_screen.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';

Deck _deck() => Deck(
  id: 'd1',
  folderId: 'f1',
  name: 'N5',
  targetLanguage: TargetLanguage.korean,
  sortOrder: 0,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

FlashcardListDetail _detail() => FlashcardListDetail(
  deck: _deck(),
  breadcrumb: const <FolderBreadcrumbSegment>[
    FolderBreadcrumbSegment(id: 'f1', name: 'Korean'),
  ],
  cards: const <Flashcard>[],
  totalCount: 0,
);

Flashcard _createdFlashcard() => Flashcard(
  id: 'c-new',
  deckId: 'd1',
  front: '안녕하세요',
  back: 'Hello',
  exampleSentence: 'Example sentence',
  sortOrder: 0,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

class _CreateCall {
  const _CreateCall({
    required this.deckId,
    required this.front,
    required this.back,
    required this.exampleSentence,
    required this.pronunciation,
    required this.hint,
  });

  final DeckId deckId;
  final String front;
  final String back;
  final String? exampleSentence;
  final String? pronunciation;
  final String? hint;
}

class _RecordingFlashcardRepository implements FlashcardRepository {
  _RecordingFlashcardRepository({
    Result<Flashcard>? createResult,
  }) : createResult = createResult ?? Result<Flashcard>.ok(_createdFlashcard());

  final Result<Flashcard> createResult;

  _CreateCall? lastCreateCall;

  @override
  Future<Result<Flashcard>> createFlashcard({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
  }) async {
    lastCreateCall = _CreateCall(
      deckId: deckId,
      front: front,
      back: back,
      exampleSentence: exampleSentence,
      pronunciation: pronunciation,
      hint: hint,
    );
    return createResult;
  }

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    DeckId deckId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
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
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => child),
                ),
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
        (Ref ref) => Stream<FlashcardListDetail>.value(_detail()),
      ),
      createFlashcardUseCaseProvider.overrideWithValue(
        CreateFlashcardUseCase(repository),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      theme: theme ?? AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _EditorHost(
        child: FlashcardEditorScreen(deckId: 'd1'),
      ),
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

void main() {
  group('FlashcardEditorScreen', () {
    testWidgets(
      'DT1 onDisplay: renders the interactive form and keeps save disabled at first',
      (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapApp(repository: _RecordingFlashcardRepository()),
      );
      await _openEditor(tester);

      expect(find.text('New flashcard'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Add details'), findsOneWidget);
      expect(_primaryButton(tester, 'Save').onPressed, isNull);
      expect(_primaryButton(tester, 'Save card').onPressed, isNull);
    });

    testWidgets('DT2 onDisplay: expands the optional fields section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapApp(repository: _RecordingFlashcardRepository()),
      );
      await _openEditor(tester);

      await tester.ensureVisible(find.text('Add details'));
      await tester.tap(find.text('Add details'));
      await tester.pumpAndSettle();

      expect(find.text('Add details'), findsNothing);
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('DT3 onNavigate: close button pops immediately on a clean draft', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapApp(repository: _RecordingFlashcardRepository()),
      );
      await _openEditor(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Library home'), findsOneWidget);
      expect(find.text('New flashcard'), findsNothing);
    });

    testWidgets(
      'DT4 onNavigate: dirty close asks for discard and cancel keeps editing',
      (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapApp(repository: _RecordingFlashcardRepository()),
      );
      await _openEditor(tester);

      await tester.enterText(find.byType(TextFormField).at(0), '안녕하세요');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);

      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      expect(find.text('New flashcard'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.text('Library home'), findsOneWidget);
      expect(find.text('New flashcard'), findsNothing);
    });

    testWidgets(
      'DT5 onInsert: save trims inputs, shows success feedback, and pops',
      (
      WidgetTester tester,
    ) async {
      final _RecordingFlashcardRepository repository =
          _RecordingFlashcardRepository();

      await tester.pumpWidget(_wrapApp(repository: repository));
      await _openEditor(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        '  안녕하세요  ',
      );
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(1), '  Hello  ');
      await tester.pump();

      await tester.ensureVisible(find.text('Add details'));
      await tester.tap(find.text('Add details'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(2),
        '  Example sentence  ',
      );
      await tester.pump();
      await tester.enterText(
        find.byType(TextFormField).at(3),
        '  Greeting root  ',
      );
      await tester.pump();
      await tester.enterText(
        find.byType(TextFormField).at(4),
        '  annyeonghaseyo  ',
      );
      await tester.pump();

      expect(_primaryButton(tester, 'Save').onPressed, isNotNull);
      expect(_primaryButton(tester, 'Save card').onPressed, isNotNull);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repository.lastCreateCall, isNotNull);
      expect(repository.lastCreateCall!.deckId, 'd1');
      expect(repository.lastCreateCall!.front, '안녕하세요');
      expect(repository.lastCreateCall!.back, 'Hello');
      expect(repository.lastCreateCall!.exampleSentence, 'Example sentence');
      expect(repository.lastCreateCall!.pronunciation, 'annyeonghaseyo');
      expect(repository.lastCreateCall!.hint, 'Greeting root');
      expect(find.text('Flashcard created.'), findsOneWidget);
      expect(find.text('Library home'), findsOneWidget);
      expect(find.text('New flashcard'), findsNothing);
    });
  });
}
