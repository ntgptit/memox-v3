import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';

/// Route registry for the Dashboard (`/home`) branch (design redesign).
///
/// Composed into the app router's Home shell branch so `app_router.dart` never
/// imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`). WBS 5.x.
List<RouteBase> dashboardBranchRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.home,
    name: RouteNames.home,
    builder: (context, state) => const DashboardScreen(),
  ),
];
