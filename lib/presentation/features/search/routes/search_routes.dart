import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/search/screens/global_search_screen.dart';

/// Route registry for the top-level Search destination (design redesign).
///
/// Composed into the app router's Search shell branch so `app_router.dart` never
/// imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`). `/search` is a primary
/// bottom-nav destination with a bottom search dock. WBS 3.5.2.
List<RouteBase> searchBranchRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.search,
    name: RouteNames.search,
    builder: (context, state) => const GlobalSearchScreen(),
  ),
];
