import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/decks/screens/flashcard_list_screen.dart';
import 'package:memox/presentation/features/folders/screens/folder_detail_screen.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';

/// Route registry for the Library (folders) feature branch.
///
/// Composed into the app router's Library shell branch so `app_router.dart`
/// never imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`). Folder detail and the
/// deck flashcard list are **child** routes of `/library`, so they push within
/// the Library tab and keep the bottom nav. WBS 3.1.2 / 3.2.2 / 3.4.2.
List<RouteBase> libraryBranchRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.library,
    name: RouteNames.library,
    builder: (context, state) => const LibraryOverviewScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.folderRelative,
        name: RouteNames.folderDetail,
        builder: (context, state) => FolderDetailScreen(
          folderId: state.pathParameters[RouteParams.id] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.deckFlashcardsRelative,
        name: RouteNames.deckFlashcards,
        builder: (context, state) => FlashcardListScreen(
          deckId: state.pathParameters[RouteParams.deckId] ?? '',
        ),
      ),
    ],
  ),
];
