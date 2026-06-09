import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/routes/flashcard_routes.dart';
import 'package:memox/presentation/features/flashcards/screens/deck_import_screen.dart';

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

void main() {
  testWidgets('DT1 onDisplay: valid deck id shows the real import shell', (
    WidgetTester tester,
  ) async {
    await _pumpDeckImportRoute(tester, deckId: 'd1');

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DeckImportScreen)),
    );

    expect(find.byType(DeckImportScreen), findsOneWidget);
    expect(find.text(l10n.flashcardsImportTitle), findsOneWidget);
    expect(find.text(l10n.flashcardsImportRouteIntroMessage), findsOneWidget);
    expect(
      find.text(l10n.flashcardsImportFormatsSectionTitle.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(l10n.importCsvLabel), findsOneWidget);
    expect(find.text(l10n.importExcelLabel), findsOneWidget);
    expect(find.text(l10n.importTextContentLabel), findsOneWidget);
    expect(find.text(l10n.flashcardsImportSoonMessage), findsNWidgets(3));
    expect(find.byType(RoutePlaceholder), findsNothing);
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
      expect(
        find.text(l10n.flashcardsImportFormatsSectionTitle.toUpperCase()),
        findsNothing,
      );
      expect(find.text(l10n.commonBack), findsOneWidget);
      expect(find.text(l10n.importCsvLabel), findsNothing);
      expect(find.byType(RoutePlaceholder), findsNothing);
    },
  );
}
