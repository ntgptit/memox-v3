import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/decks/screens/flashcard_list_screen.dart';
import 'package:memox/presentation/features/folders/screens/folder_detail_screen.dart';
import 'package:memox/presentation/features/search/screens/global_search_screen.dart';

/// Route registry for the top-level Search destination (design redesign).
///
/// Composed into the app router's Search shell branch so `app_router.dart` never
/// imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`). `/search` is a primary
/// bottom-nav destination with a bottom search dock.
///
/// Folder detail and the deck flashcard list are registered as **child** routes
/// of `/search` (distinct route names from the Library-branch copies) so tapping
/// a search result pushes within the Search branch — the bottom nav stays on
/// Search and Back returns to `/search`. (Navigating deeper *inside* an opened
/// detail still uses the Library-branch routes; that is a documented V1 edge.)
/// WBS 3.5.2 / 3.5.3.
List<RouteBase> searchBranchRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.search,
    name: RouteNames.search,
    builder: (context, state) => const GlobalSearchScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.folderRelative,
        name: RouteNames.searchFolderDetail,
        builder: (context, state) => FolderDetailScreen(
          folderId: state.pathParameters[RouteParams.id] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.deckFlashcardsRelative,
        name: RouteNames.searchDeckFlashcards,
        builder: (context, state) => FlashcardListScreen(
          deckId: state.pathParameters[RouteParams.deckId] ?? '',
        ),
      ),
    ],
  ),
];
