import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/app_shell.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_bottom_nav.dart';

Future<void> _pumpRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    ProviderScope(
      // Stub the Library stream so the router test stays deterministic (no
      // Drift timer); the shell still builds the real Library screen.
      overrides: [
        libraryOverviewStreamProvider.overrideWith(
          (ref) =>
              Stream<LibraryOverview>.value(const LibraryOverview(folders: [])),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        // The shell renders MxBottomNav + the real Library screen, both of
        // which read the MxColors theme extension and l10n.
        theme: MxTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('createAppRouter', () {
    testWidgets('boot lands on the Library shell', (tester) async {
      final GoRouter router = createAppRouter();
      addTearDown(router.dispose);

      await _pumpRouter(tester, router);

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        RoutePaths.library,
      );
      expect(find.byType(MxAppShell), findsOneWidget);
      expect(find.byType(MxBottomNav), findsOneWidget);
      // The Library branch hosts the real overview screen (WBS 3.1.2).
      expect(find.byType(LibraryOverviewScreen), findsOneWidget);
    });

    testWidgets('navigating to the bare root redirects to the Library', (
      tester,
    ) async {
      final GoRouter router = createAppRouter();
      addTearDown(router.dispose);

      await _pumpRouter(tester, router);
      router.go(RoutePaths.root);
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        RoutePaths.library,
      );
    });

    testWidgets('each top-level destination becomes the active branch', (
      tester,
    ) async {
      final GoRouter router = createAppRouter();
      addTearDown(router.dispose);
      await _pumpRouter(tester, router);

      for (final String path in <String>[
        RoutePaths.home,
        RoutePaths.library,
        RoutePaths.search,
        RoutePaths.progress,
        RoutePaths.settings,
      ]) {
        router.go(path);
        await tester.pumpAndSettle();

        expect(router.routerDelegate.currentConfiguration.uri.path, path);
        expect(find.byType(MxAppShell), findsOneWidget);
        expect(find.byType(MxBottomNav), findsOneWidget);
      }
    });

    testWidgets('tapping a bottom-nav destination switches the branch', (
      tester,
    ) async {
      final GoRouter router = createAppRouter();
      addTearDown(router.dispose);
      await _pumpRouter(tester, router);

      // Boots on Library; tap the Settings tab label.
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        RoutePaths.settings,
      );
    });
  });
}
