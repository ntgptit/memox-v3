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
}
