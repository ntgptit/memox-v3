import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/app_shell.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_bottom_nav.dart';

Future<void> _pumpRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      // The shell renders MxBottomNav, which reads the MxColors theme extension.
      theme: MxTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('createAppRouter', () {
    testWidgets('boot lands on the Library via the root redirect', (
      tester,
    ) async {
      final GoRouter router = createAppRouter();
      addTearDown(router.dispose);

      await _pumpRouter(tester, router);

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        RoutePaths.library,
      );
      // The destinations are hosted by the bottom-nav shell (WBS 1.2.6).
      expect(find.byType(MxAppShell), findsOneWidget);
      expect(find.byType(MxBottomNav), findsOneWidget);
      // indexedStack keeps every branch alive, so the Library placeholder's
      // own label resolves to exactly one widget.
      expect(find.text(RouteNames.library), findsOneWidget);
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
        RoutePaths.progress,
        RoutePaths.settings,
      ]) {
        router.go(path);
        await tester.pumpAndSettle();

        expect(router.routerDelegate.currentConfiguration.uri.path, path);
        // The shell + bottom nav stay mounted across tab switches.
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
