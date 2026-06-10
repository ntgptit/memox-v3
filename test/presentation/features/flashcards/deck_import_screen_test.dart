import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/deck_csv_export.dart';
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
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/routes/flashcard_routes.dart';
import 'package:memox/presentation/features/flashcards/screens/deck_import_screen.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';

final class _RecordingFlashcardRepository implements FlashcardRepository {
  _RecordingFlashcardRepository({
    this.commitResult = const Result<int>.ok(2),
    this.commitCompleter,
  });

  final Result<int> commitResult;
  final Completer<Result<int>>? commitCompleter;

  int commitCallCount = 0;
  DeckId? lastCommitDeckId;
  List<DeckImportPreviewRow>? lastCommitRows;

  @override
  Future<Result<int>> commitDeckImport({
    required DeckId deckId,
    required List<DeckImportPreviewRow> rows,
  }) {
    commitCallCount += 1;
    lastCommitDeckId = deckId;
    lastCommitRows = rows;
    if (commitCompleter != null) {
      return commitCompleter!.future;
    }
    return Future<Result<int>>.value(commitResult);
  }

  @override
  Future<Result<List<Flashcard>>> existingByFrontBackPairs(
    DeckId deckId,
    List<({String front, String back})> pairs,
  ) async => const Result<List<Flashcard>>.ok(<Flashcard>[]);

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

  @override
  Future<Result<DeckCsvExport>> exportDeckCsv({required DeckId deckId}) {
    throw UnimplementedError();
  }
}

class _Host extends StatelessWidget {
  const _Host({required this.child});

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
            child: const Text('Open import'),
          ),
        ],
      ),
    ),
  );
}

Widget _wrapApp({
  required FlashcardRepository repository,
  required Widget child,
}) => ProviderScope(
  overrides: [
    parseDeckImportCsvUseCaseProvider.overrideWithValue(
      const ParseDeckImportCsvUseCase(),
    ),
    commitDeckImportUseCaseProvider.overrideWithValue(
      CommitDeckImportUseCase(repository),
    ),
  ],
  child: MaterialApp(
    locale: const Locale('en'),
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: _Host(child: child),
  ),
);

Future<void> _openImport(WidgetTester tester) async {
  await tester.tap(find.text('Open import'));
  await tester.pumpAndSettle();
}

Future<void> _pumpDeckImportRoute(
  WidgetTester tester, {
  required String deckId,
}) async {
  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );
  final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.deckImport(deckId),
    routes: flashcardRoutes(rootNavigatorKey),
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpDeckImportScreen(
  WidgetTester tester, {
  required String deckId,
  FlashcardRepository? repository,
}) async {
  await tester.pumpWidget(
    _wrapApp(
      repository: repository ?? _RecordingFlashcardRepository(),
      child: DeckImportScreen(deckId: deckId),
    ),
  );
  await _openImport(tester);
}

Future<void> _previewCsv(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(MxPrimaryButton));
  await tester.tap(find.byType(MxPrimaryButton));
  await tester.pumpAndSettle();
}

MxSecondaryButton _commitButton(WidgetTester tester) {
  final Iterable<MxSecondaryButton> buttons = tester
      .widgetList<MxSecondaryButton>(find.byType(MxSecondaryButton));
  return buttons.single;
}

void main() {
  testWidgets('DT1 onDisplay: valid deck id shows the import shell', (
    WidgetTester tester,
  ) async {
    await _pumpDeckImportRoute(tester, deckId: 'd1');

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DeckImportScreen)),
    );

    expect(find.byType(DeckImportScreen), findsOneWidget);
    expect(find.text(l10n.flashcardsImportTitle), findsOneWidget);
    expect(find.text(l10n.flashcardsImportRouteIntroMessage), findsOneWidget);
    expect(find.text(l10n.importSourceTitle.toUpperCase()), findsOneWidget);
    expect(find.text(l10n.importCsvContentLabel), findsOneWidget);
    expect(find.text(l10n.importCsvRulesText), findsOneWidget);
    expect(find.text(l10n.importPreviewAction), findsOneWidget);
    expect(find.text(l10n.commonImport), findsOneWidget);
  });

  testWidgets(
    'DT2 onDisplay: missing deck id shows controlled invalid-state callout',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DeckImportScreen(deckId: ''),
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(DeckImportScreen)),
      );

      expect(find.text(l10n.flashcardsImportRouteIntroMessage), findsNothing);
      expect(
        find.text(l10n.flashcardsImportMissingDeckMessage),
        findsOneWidget,
      );
      expect(find.text(l10n.commonBack), findsOneWidget);
    },
  );

  testWidgets('DT3 onPreview: valid CSV enables commit and clears on edit', (
    WidgetTester tester,
  ) async {
    await _pumpDeckImportScreen(tester, deckId: 'd1');

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DeckImportScreen)),
    );

    await tester.enterText(
      find.byType(TextFormField),
      'front,back\nHello,World',
    );
    await tester.pump();
    await _previewCsv(tester);

    expect(find.text(l10n.importPreviewCommitReadyMessage), findsOneWidget);
    expect(_commitButton(tester).onPressed, isNotNull);

    await tester.enterText(
      find.byType(TextFormField),
      'front,back\nHello,World\nGoodbye,Farewell',
    );
    await tester.pump();

    expect(find.text(l10n.commonImport), findsOneWidget);
    expect(find.text(l10n.importCommitCardsAction(2)), findsNothing);
    expect(_commitButton(tester).onPressed, isNull);
  });

  testWidgets('DT4 onPreview: validation issues keep commit disabled', (
    WidgetTester tester,
  ) async {
    await _pumpDeckImportScreen(tester, deckId: 'd1');

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DeckImportScreen)),
    );

    await tester.enterText(find.byType(TextFormField), 'front,back\n,');
    await tester.pump();
    await _previewCsv(tester);

    expect(find.text(l10n.importValidationIssuesSubtitle), findsOneWidget);
    expect(_commitButton(tester).onPressed, isNull);
  });

  testWidgets('DT5 onInsert: commit succeeds, shows success, and pops', (
    WidgetTester tester,
  ) async {
    final _RecordingFlashcardRepository repository =
        _RecordingFlashcardRepository();

    await _pumpDeckImportScreen(tester, deckId: 'd1', repository: repository);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DeckImportScreen)),
    );

    await tester.enterText(
      find.byType(TextFormField),
      'front,back\nHello,World\nGoodbye,Farewell',
    );
    await tester.pump();
    await _previewCsv(tester);
    await tester.tap(find.text(l10n.importCommitCardsAction(2)));
    await tester.pumpAndSettle();

    expect(repository.commitCallCount, 1);
    expect(repository.lastCommitDeckId, 'd1');
    expect(repository.lastCommitRows, hasLength(2));
    expect(find.text(l10n.importSuccessMessage(2)), findsOneWidget);
    expect(find.text('Library home'), findsOneWidget);
    expect(find.byType(DeckImportScreen), findsNothing);
  });

  testWidgets('DT6 onInsert: commit failure stays on screen with error', (
    WidgetTester tester,
  ) async {
    final _RecordingFlashcardRepository repository =
        _RecordingFlashcardRepository(
          commitResult: const Result<int>.err(
            Failure.storage(
              operation: StorageOp.write,
              cause: 'boom',
              table: 'flashcards',
            ),
          ),
        );

    await _pumpDeckImportScreen(tester, deckId: 'd1', repository: repository);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DeckImportScreen)),
    );

    await tester.enterText(
      find.byType(TextFormField),
      'front,back\nHello,World',
    );
    await tester.pump();
    await _previewCsv(tester);
    await tester.tap(find.text(l10n.importCommitCardsAction(1)));
    await tester.pumpAndSettle();

    expect(repository.commitCallCount, 1);
    expect(find.text(l10n.importFailedMessage), findsOneWidget);
    expect(find.text('Library home'), findsNothing);
    expect(find.byType(DeckImportScreen), findsOneWidget);
    expect(find.text(l10n.importCommitCardsAction(1)), findsOneWidget);
  });

  testWidgets('DT7 onInsert: commit blocks double submit while saving', (
    WidgetTester tester,
  ) async {
    final Completer<Result<int>> commitCompleter = Completer<Result<int>>();
    final _RecordingFlashcardRepository repository =
        _RecordingFlashcardRepository(commitCompleter: commitCompleter);

    await _pumpDeckImportScreen(tester, deckId: 'd1', repository: repository);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DeckImportScreen)),
    );

    await tester.enterText(
      find.byType(TextFormField),
      'front,back\nHello,World',
    );
    await tester.pump();
    await _previewCsv(tester);

    expect(_commitButton(tester).onPressed, isNotNull);

    await tester.tap(find.text(l10n.importCommitCardsAction(1)));
    await tester.pump();

    expect(repository.commitCallCount, 1);
    expect(_commitButton(tester).onPressed, isNull);
    expect(find.text(l10n.importCommittingMessage), findsOneWidget);

    await tester.tap(find.text(l10n.importCommitCardsAction(1)));
    await tester.pump();
    expect(repository.commitCallCount, 1);

    commitCompleter.complete(const Result<int>.ok(1));
    await tester.pumpAndSettle();
  });
}
