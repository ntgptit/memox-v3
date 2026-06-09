import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';

/// Dashboard route registry, composed by `app_router.dart`.
List<RouteBase> dashboardRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.home,
    name: RouteNames.home,
    builder: (_, _) => const DashboardScreen(),
  ),
];
