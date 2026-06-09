import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/routes/flashcard_routes.dart';
import 'package:memox/presentation/features/flashcards/screens/deck_import_screen.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';

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
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: DeckImportScreen(deckId: deckId),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _previewCsv(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(MxPrimaryButton));
  await tester.tap(find.byType(MxPrimaryButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('DT1 onDisplay: valid deck id shows the CSV preview shell', (
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
    expect(find.text(l10n.importCommitDeferredAction), findsOneWidget);
    expect(find.text(l10n.importCommitDeferredMessage), findsOneWidget);
    expect(find.byType(RoutePlaceholder), findsNothing);

    final MxSecondaryButton commitButton = tester.widget<MxSecondaryButton>(
      find.byType(MxSecondaryButton).last,
    );
    expect(commitButton.onPressed, isNull);
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

      expect(find.byType(DeckImportScreen), findsOneWidget);
      expect(find.text(l10n.flashcardsImportRouteIntroMessage), findsNothing);
      expect(
        find.text(l10n.flashcardsImportMissingDeckMessage),
        findsOneWidget,
      );
      expect(find.text(l10n.importSourceTitle.toUpperCase()), findsNothing);
      expect(find.text(l10n.commonBack), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
    },
  );

  testWidgets('DT3 onPreview: empty CSV input shows localized validation', (
    WidgetTester tester,
  ) async {
    await _pumpDeckImportScreen(tester, deckId: 'd1');

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DeckImportScreen)),
    );

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.pump();
    await _previewCsv(tester);

    expect(find.text(l10n.importCsvEmptyMessage), findsOneWidget);
    expect(find.text(l10n.importPreviewTitle), findsNothing);
  });

  testWidgets('DT4 onPreview: valid CSV with front,back previews rows', (
    WidgetTester tester,
  ) async {
    await _pumpDeckImportScreen(tester, deckId: 'd1');

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DeckImportScreen)),
    );

    await tester.enterText(
      find.byType(TextFormField),
      'front,back\nHello,World\nGoodbye,Farewell',
    );
    await tester.pump();
    await _previewCsv(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text(l10n.importPreviewSubtitle(2)), findsOneWidget);
    expect(find.text(l10n.importPreviewSummary(2, 0)), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('World'), findsOneWidget);
    expect(find.text('Goodbye'), findsOneWidget);
    expect(find.text('Farewell'), findsOneWidget);
    expect(find.text(l10n.importNothingTitle), findsNothing);
  });

  testWidgets('DT5 onPreview: quoted CSV values parse correctly', (
    WidgetTester tester,
  ) async {
    await _pumpDeckImportScreen(tester, deckId: 'd1');

    await tester.enterText(
      find.byType(TextFormField),
      'front,back\n"Hello, world","She said ""hi"""',
    );
    await tester.pump();
    await _previewCsv(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
    await tester.pumpAndSettle();

    expect(find.text('Hello, world'), findsOneWidget);
    expect(find.text('She said "hi"'), findsOneWidget);
    expect(find.text('Line 2'), findsOneWidget);
  });

  testWidgets(
    'DT6 onPreview: rows with empty front or back show row-level validation',
    (WidgetTester tester) async {
      await _pumpDeckImportScreen(tester, deckId: 'd1');

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(DeckImportScreen)),
      );

      await tester.enterText(
        find.byType(TextFormField),
        'front,back\n,Hello\nHi,\n,,note',
      );
      await tester.pump();
      await _previewCsv(tester);
      await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(find.text('Line 2'), findsOneWidget);
      expect(find.text(l10n.flashcardEditorFrontError), findsOneWidget);
      expect(find.text('Line 3'), findsOneWidget);
      expect(find.text(l10n.flashcardEditorBackError), findsOneWidget);
      expect(find.text('Line 4'), findsOneWidget);
      expect(
        find.text(l10n.importCsvFrontAndBackRequiredMessage),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'DT7 onPreview: preview keeps commit deferred and does not navigate',
    (WidgetTester tester) async {
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

      final MxSecondaryButton commitButton = tester.widget<MxSecondaryButton>(
        find.byType(MxSecondaryButton).last,
      );
      expect(commitButton.onPressed, isNull);
      expect(find.text(l10n.importCommitDeferredMessage), findsOneWidget);
      expect(find.byType(DeckImportScreen), findsOneWidget);
    },
  );
}
