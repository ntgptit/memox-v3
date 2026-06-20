import 'package:go_router/go_router.dart';
import 'package:memox/app/app_shell.dart';
import 'package:memox/app/router/redirect.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/presentation/features/dashboard/routes/dashboard_routes.dart';
import 'package:memox/presentation/features/folders/routes/folder_routes.dart';
import 'package:memox/presentation/features/search/routes/search_routes.dart';

/// Builds the application [GoRouter].
///
/// Foundation routing baseline (WBS 1.1.3) + bottom-nav shell (WBS 1.2.6): the
/// five top-level destinations from `docs/business/navigation/navigation-flow.md`
/// (Home · Library · Search · Progress · Settings) are branches of a
/// [StatefulShellRoute.indexedStack] hosted by [MxAppShell],
/// so each tab keeps its own navigation stack. The bare root (`/`) redirects to
/// [RouteDefaults.initialLocation]. Each destination renders a
/// [RoutePlaceholder] until its real screen ships; feature route registries
/// (`lib/presentation/features/**/routes/*.dart`) compose into the matching
/// branch as features land. `app_router.dart` must not import feature screens
/// directly (see `memox.routing.app_router_no_feature_screen_imports`).
GoRouter createAppRouter() => GoRouter(
  initialLocation: RoutePaths.root,
  redirect: rootRedirect,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MxAppShell(navigationShell: navigationShell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(routes: dashboardBranchRoutes()),
        StatefulShellBranch(routes: libraryBranchRoutes()),
        StatefulShellBranch(routes: searchBranchRoutes()),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RoutePaths.progress,
              name: RouteNames.progress,
              builder: (context, state) =>
                  const RoutePlaceholder(routeName: RouteNames.progress),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RoutePaths.settings,
              name: RouteNames.settings,
              builder: (context, state) =>
                  const RoutePlaceholder(routeName: RouteNames.settings),
            ),
          ],
        ),
      ],
    ),
  ],
);
