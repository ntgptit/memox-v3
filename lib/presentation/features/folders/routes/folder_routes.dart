import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_list_screen.dart';
import 'package:memox/presentation/features/folders/screens/folder_detail_screen.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';
import 'package:memox/presentation/features/search/screens/global_search_screen.dart';

/// Library-branch route registry, composed by `app_router.dart`
/// (`memox.app_router_no_feature_screen_imports`). Flashcard create/edit and
/// deck import remain placeholders until those screens land (07/08/10).
List<RouteBase> libraryBranchRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.library,
    name: RouteNames.library,
    builder: (_, _) => const LibraryOverviewScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.searchSegment,
        name: RouteNames.librarySearch,
        builder: (_, _) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: '${RoutePaths.folderSegment}/:${RoutePaths.idParam}',
        name: RouteNames.folderDetail,
        builder: (_, GoRouterState state) => FolderDetailScreen(
          folderId: state.pathParameters[RoutePaths.idParam] ?? '',
        ),
      ),
      GoRoute(
        path:
            '${RoutePaths.deckSegment}/:${RoutePaths.deckIdParam}/${RoutePaths.flashcardsSegment}',
        name: RouteNames.flashcardList,
        builder: (_, GoRouterState state) => FlashcardListScreen(
          deckId: state.pathParameters[RoutePaths.deckIdParam] ?? '',
        ),
      ),
    ],
  ),
];
