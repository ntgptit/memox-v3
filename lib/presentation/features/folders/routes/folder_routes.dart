import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';

/// Route registry for the Library (folders) feature branch.
///
/// Composed into the app router's Library shell branch so `app_router.dart`
/// never imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`). Folder-detail and
/// search child routes register here as those screens land (WBS 3.2.2 / 3.5.2).
/// WBS 3.1.2.
List<RouteBase> libraryBranchRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.library,
    name: RouteNames.library,
    builder: (context, state) => const LibraryOverviewScreen(),
  ),
];
