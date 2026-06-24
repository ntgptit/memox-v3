import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/stats/screens/stats_screen.dart';

/// Route registry for the Stats tab (`/progress` shell branch; screen 18).
///
/// Composed into the app router's fourth (Stats) shell branch so
/// `app_router.dart` never imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`). The route keeps the
/// `progress` name/path (the bottom-nav tab is labelled "Stats" per the mock;
/// the deeper Progress detail is screen 19). WBS 7.5.x.
List<RouteBase> statsBranchRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.progress,
    name: RouteNames.progress,
    builder: (context, state) => const StatsScreen(),
  ),
];
