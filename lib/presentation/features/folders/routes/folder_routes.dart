import 'package:go_router/go_router.dart';

import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';

/// Library-branch route registry, composed by `app_router.dart`
/// (`memox.app_router_no_feature_screen_imports`). Folder-detail and
/// flashcard-list remain placeholders until those screens land.
List<RouteBase> libraryBranchRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.library,
    name: RouteNames.library,
    builder: (_, _) => const LibraryOverviewScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: '${RoutePaths.folderSegment}/:${RoutePaths.idParam}',
        name: RouteNames.folderDetail,
        builder: (_, GoRouterState state) => RoutePlaceholder(
          routeName: RouteNames.folderDetail,
          params: <String, String>{
            RoutePaths.idParam: state.pathParameters[RoutePaths.idParam] ?? '',
          },
        ),
      ),
      GoRoute(
        path:
            '${RoutePaths.deckSegment}/:${RoutePaths.deckIdParam}/${RoutePaths.flashcardsSegment}',
        name: RouteNames.flashcardList,
        builder: (_, GoRouterState state) => RoutePlaceholder(
          routeName: RouteNames.flashcardList,
          params: <String, String>{
            RoutePaths.deckIdParam:
                state.pathParameters[RoutePaths.deckIdParam] ?? '',
          },
        ),
      ),
    ],
  ),
];
