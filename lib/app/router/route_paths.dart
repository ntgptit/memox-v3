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

  /// Per-card history timeline — child of the deck flashcard list (kit `09`).
  /// `:flashcardId` is the inspected card (matches
  /// `docs/business/navigation/navigation-flow.md` §Library routes).
  static const String flashcardHistoryRelative = ':flashcardId/history';
  static const String flashcardHistory =
      '$deckFlashcards/$flashcardHistoryRelative';

  /// Search-branch variants of the detail routes (reuse the same relative
  /// segments under [search]) so a Search result opens inside the Search branch.
  static const String searchFolder = '$search/$folderRelative';
  static const String searchDeckFlashcards = '$search/$deckFlashcardsRelative';

  /// Study — an immersive flow registered as **top-level** routes (outside the
  /// bottom-nav shell) so the session has no bottom nav, per
  /// `docs/wireframes/12-study-entry-gate.md` + `13-study-session-review.md`.
  static const String study = '$library/study';

  /// The study entry gate. `:entryType` ∈ `deck`/`folder`; `:entryRefId`
  /// is the deck/folder id. WBS 4.1.2 / 4.2.2.
  static const String studyEntry = '$study/:entryType/:entryRefId';

  /// The global `today` study entry — a literal route (no `:entryRefId`); a
  /// `today` scope studies due cards across all decks. WBS 4.1.2.
  static const String studyToday = '$study/today';

  /// The active study session. `:sessionId` is the persisted session id. Listed
  /// before [studyEntry] so the literal `session` segment wins over `:entryType`.
  static const String studySession = '$study/session/:sessionId';

  /// The end-of-session result summary (`/library/study/session/:sessionId/result`).
  /// Reached via `pushReplacement` from the session's Finish action (WBS 4.7.2).
  static const String studyResult = '$study/session/:sessionId/result';
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
  /// Parsed by the gate via `StudyType.fromStorage` (WP-SR1b-1); an unrecognized
  /// value surfaces the gate error state. The CTA surfaces that emit it stay
  /// Future.
  static const String studyTypeQueryParam = 'study_type';

  /// Optional `mode` query param on the session route (`StudyMode.name`, e.g.
  /// `match`) selecting the study-mode surface; absent → `review` (WP-SM3). The
  /// per-phase `current_mode` chain (WBS 4.5.12+) supersedes this later.
  static const String modeQueryParam = 'mode';
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
