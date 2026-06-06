import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';

/// The single sanctioned navigation surface (`memox.common_navigation_extension_usage`).
///
/// UI code navigates through these semantic methods instead of raw `GoRouter`
/// APIs, so route names/params stay centralized in `RouteNames` / `RoutePaths`.
extension AppNavigation on BuildContext {
  /// Switch to the Library tab root.
  void goLibrary() => goNamed(RouteNames.library);

  /// Open global Library search: `/library/search`.
  void pushLibrarySearch() => pushNamed(RouteNames.librarySearch);

  /// Drill into a folder: `/library/folder/:id`.
  void pushFolderDetail(String folderId) => pushNamed(
    RouteNames.folderDetail,
    pathParameters: <String, String>{RoutePaths.idParam: folderId},
  );

  /// Open a deck's flashcard list: `/library/deck/:deckId/flashcards`.
  void pushFlashcardList(String deckId) => pushNamed(
    RouteNames.flashcardList,
    pathParameters: <String, String>{RoutePaths.deckIdParam: deckId},
  );

  /// Open the new-flashcard editor: `/library/deck/:deckId/flashcards/new`.
  void pushFlashcardCreate(String deckId) => pushNamed(
    RouteNames.flashcardCreate,
    pathParameters: <String, String>{RoutePaths.deckIdParam: deckId},
  );

  /// Open the flashcard editor:
  /// `/library/deck/:deckId/flashcards/:flashcardId/edit`.
  void pushFlashcardEdit(String deckId, String flashcardId) => pushNamed(
    RouteNames.flashcardEdit,
    pathParameters: <String, String>{
      RoutePaths.deckIdParam: deckId,
      RoutePaths.flashcardIdParam: flashcardId,
    },
  );

  /// Open the deck import flow: `/library/deck/:deckId/import`.
  void pushDeckImport(String deckId) => pushNamed(
    RouteNames.deckImport,
    pathParameters: <String, String>{RoutePaths.deckIdParam: deckId},
  );
}
