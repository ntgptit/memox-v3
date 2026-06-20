/// URL path constants for GoRouter.
///
/// Paths are the single source of truth for `go`/`push`/`replace` call sites —
/// never pass a raw path literal (see `memox.routing.no_raw_route_path_string`).
/// Top-level destinations mirror `docs/business/navigation/navigation-flow.md`
/// §Top-level destinations.
abstract final class RoutePaths {
  static const String root = '/';
  static const String home = '/home';
  static const String library = '/library';
  static const String progress = '/progress';
  static const String settings = '/settings';

  /// Folder detail — child of [library]. `:id` is the folder id. Relative
  /// segment (`folderRelative`) is used when registering it as a child route;
  /// the absolute form is for reference.
  static const String folderRelative = 'folder/:id';
  static const String folder = '$library/$folderRelative';

  /// A deck's flashcard list — child of [library]. `:deckId` is the deck id.
  static const String deckFlashcardsRelative = 'deck/:deckId/flashcards';
  static const String deckFlashcards = '$library/$deckFlashcardsRelative';
}

/// Path/query parameter keys for GoRouter — never pass a raw string literal as
/// a parameter key (`memox.routing.no_raw_route_param_key`).
abstract final class RouteParams {
  /// The `:id` path segment for the folder-detail route.
  static const String id = 'id';

  /// The `:deckId` path segment for the deck flashcard-list route (matches
  /// `docs/business/navigation/navigation-flow.md` §Library routes).
  static const String deckId = 'deckId';
}

/// Router-level defaults.
///
/// `initialLocation` is where app boot lands after the root (`/`) redirect — the
/// Library, per `docs/business/navigation/navigation-flow.md` §Top-level
/// destinations ("Current V1 app boot redirects `/` to
/// `RouteDefaults.initialLocation = RoutePaths.library`").
abstract final class RouteDefaults {
  static const String initialLocation = RoutePaths.library;
}
