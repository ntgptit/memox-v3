import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/app_shell.dart';
import 'package:memox/app/di/app_providers.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/dashboard_engagement.dart';
import 'package:memox/domain/models/deck_mastery.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/models/stats_overview.dart';
import 'package:memox/domain/models/week_activity.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/stats/viewmodels/stats_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    ProviderScope(
      // Stub the Library stream so the router test stays deterministic (no
      // Drift timer); the shell still builds the real Library screen.
      overrides: [
        // /settings now renders the real SettingsScreen hub, which watches the
        // account/learning/appearance/language controllers — all backed by
        // SharedPreferences. Stub prefs so the whole chain loads defaults.
        sharedPreferencesProvider.overrideWith((ref) async {
          SharedPreferences.setMockInitialValues(<String, Object>{});
          return SharedPreferences.getInstance();
        }),
        libraryOverviewStreamProvider.overrideWith(
          (ref) =>
              Stream<LibraryOverview>.value(const LibraryOverview(folders: [])),
        ),
        // /home renders the real (engagement) DashboardScreen, which loads the
        // engagement read model from the DB; stub it so the router test stays
        // deterministic. (The dashboard moved from the summary to the engagement
        // provider, so the old dashboardSummary stub no longer covered /home and the
        // unstubbed provider left /home in a perpetual loading state → pumpAndSettle
        // timed out.)
        dashboardEngagementProvider.overrideWith(
          (ref) async => (failure: null, data: const DashboardEngagement()),
        ),
        // /progress now renders the real StatsScreen (Stats tab), which loads a
        // read model from the DB; stub it so the router test stays deterministic.
        statsOverviewProvider.overrideWith(
          (ref) async => (
            failure: null,
            data: const StatsOverview(
              weekActivity: WeekActivity(days: <DayActivity>[]),
              deckMastery: <DeckMastery>[],
            ),
          ),
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
