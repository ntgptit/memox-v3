import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/progress/screens/progress_screen.dart';

/// Progress route registry, composed by `app_router.dart`.
List<RouteBase> progressRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.progress,
    name: RouteNames.progress,
    builder: (_, _) => const ProgressScreen(),
  ),
];
