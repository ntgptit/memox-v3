import 'package:go_router/go_router.dart';
import 'package:memox/app/router/redirect.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';

/// Builds the application [GoRouter].
///
/// Foundation routing baseline (WBS 1.1.3): registers the top-level
/// destinations from `docs/business/navigation/navigation-flow.md` and redirects
/// the bare root (`/`) to [RouteDefaults.initialLocation]. Each destination
/// renders a [RoutePlaceholder] until its real screen ships; feature route
/// registries (`lib/presentation/features/**/routes/*.dart`) compose into this
/// router as features land. `app_router.dart` must not import feature screens
/// directly (see `memox.routing.app_router_no_feature_screen_imports`).
GoRouter createAppRouter() => GoRouter(
  initialLocation: RoutePaths.root,
  redirect: rootRedirect,
  routes: <RouteBase>[
    GoRoute(
      path: RoutePaths.home,
      name: RouteNames.home,
      builder: (context, state) =>
          const RoutePlaceholder(routeName: RouteNames.home),
    ),
    GoRoute(
      path: RoutePaths.library,
      name: RouteNames.library,
      builder: (context, state) =>
          const RoutePlaceholder(routeName: RouteNames.library),
    ),
    GoRoute(
      path: RoutePaths.progress,
      name: RouteNames.progress,
      builder: (context, state) =>
          const RoutePlaceholder(routeName: RouteNames.progress),
    ),
    GoRoute(
      path: RoutePaths.settings,
      name: RouteNames.settings,
      builder: (context, state) =>
          const RoutePlaceholder(routeName: RouteNames.settings),
    ),
  ],
);
