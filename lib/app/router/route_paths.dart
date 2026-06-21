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

  /// Top-level global Search destination (design redesign).
  static const String search = '/search';

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

  /// Card editor — child of the deck flashcard list (mock `07`/`08`). Relative
  /// segments are registered as children of [deckFlashcardsRelative]; the
  /// absolute forms are for reference. `:flashcardId` is the edited card
  /// (matches `docs/business/navigation/navigation-flow.md` §Library routes).
  static const String flashcardCreateRelative = 'new';
  static const String flashcardCreate =
      '$deckFlashcards/$flashcardCreateRelative';
  static const String flashcardEditRelative = ':flashcardId/edit';
  static const String flashcardEdit = '$deckFlashcards/$flashcardEditRelative';

  /// Search-branch variants of the detail routes (reuse the same relative
  /// segments under [search]) so a Search result opens inside the Search branch.
  static const String searchFolder = '$search/$folderRelative';
  static const String searchDeckFlashcards = '$search/$deckFlashcardsRelative';

  /// Study — an immersive flow registered as **top-level** routes (outside the
  /// bottom-nav shell) so the session has no bottom nav, per
  /// `docs/wireframes/12-study-entry-gate.md` + `13-study-session-review.md`.
  static const String study = '$library/study';

  /// The study entry gate. `:entryType` ∈ `deck`/`folder`/`today`; `:entryRefId`
  /// is the deck/folder id. WBS 4.1.2 / 4.2.2.
  static const String studyEntry = '$study/:entryType/:entryRefId';

  /// The active study session. `:sessionId` is the persisted session id. Listed
  /// before [studyEntry] so the literal `session` segment wins over `:entryType`.
  static const String studySession = '$study/session/:sessionId';
}

/// Path/query parameter keys for GoRouter — never pass a raw string literal as
/// a parameter key (`memox.routing.no_raw_route_param_key`).
abstract final class RouteParams {
  /// The `:id` path segment for the folder-detail route.
  static const String id = 'id';

  /// The `:deckId` path segment for the deck flashcard-list route (matches
  /// `docs/business/navigation/navigation-flow.md` §Library routes).
  static const String deckId = 'deckId';

  /// The `:flashcardId` path segment for the card edit route (mock `08`;
  /// matches `docs/business/navigation/navigation-flow.md` §Library routes).
  static const String flashcardId = 'flashcardId';

  /// The `:entryType` path segment for the study entry gate (`deck`/`folder`/
  /// `today`).
  static const String entryType = 'entryType';

  /// The `:entryRefId` path segment for the study entry gate (deck/folder id).
  static const String entryRefId = 'entryRefId';

  /// The `:sessionId` path segment for the active study session route.
  static const String sessionId = 'sessionId';

  /// Optional `study_type` query param (`StudyType.storageValue`) on the entry
  /// gate; absent → the entry default (`deck`/`folder` → new, `today` → review).
  /// The key is defined now; the gate parses/honors it in **WP-SR1b** (WP-SR1a
  /// applies only the entry default).
  static const String studyTypeQueryParam = 'study_type';
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
