/// Named-route identifiers for GoRouter.
///
/// Route names are the single source of truth for `goNamed`/`pushNamed` call
/// sites — never pass a raw string literal (see `memox.routing.no_raw_route_name_string`).
/// Top-level destinations mirror `docs/business/navigation/navigation-flow.md`
/// §Top-level destinations.
abstract final class RouteNames {
  static const String root = 'root';
  static const String home = 'home';
  static const String library = 'library';

  /// Top-level global Search destination (folders/decks/flashcards). A primary
  /// bottom-nav tab with a bottom-anchored search dock (design redesign).
  static const String search = 'search';

  static const String progress = 'progress';
  static const String settings = 'settings';

  /// Tag management (`/settings/learning/tags`, kit screen 11) — a top-level
  /// immersive route (shell hidden). WBS 8.3.2.
  static const String settingsLearningTags = 'settingsLearningTags';

  /// Folder detail (subfolders + decks), pushed within the Library branch.
  static const String folderDetail = 'folderDetail';

  /// A deck's flashcard list, pushed within the Library branch.
  static const String deckFlashcards = 'deckFlashcards';

  /// Card create / edit editor screen, pushed over a deck's flashcard list
  /// (mock `07` / `08`). WBS 2.11.2 / 2.12.2.
  static const String flashcardCreate = 'flashcardCreate';
  static const String flashcardEdit = 'flashcardEdit';

  /// Per-card read-only history timeline (`…/flashcards/:flashcardId/history`),
  /// pushed within the Library branch (kit screen 09). WBS 7.6.3.
  static const String flashcardHistory = 'flashcardHistory';

  /// Folder detail / deck flashcard list reached from a **Search** result, so
  /// the push stays inside the Search branch (Back returns to `/search`). Same
  /// screens as the Library-branch routes, distinct names per GoRouter's
  /// unique-name rule.
  static const String searchFolderDetail = 'searchFolderDetail';
  static const String searchDeckFlashcards = 'searchDeckFlashcards';

  /// Study entry gate (`/library/study/:entryType/:entryRefId`) and the active
  /// session (`/library/study/session/:sessionId`) — top-level immersive routes.
  /// WBS 4.1.2 / 4.2.2 / 4.5.3.
  static const String studyEntry = 'studyEntry';
  static const String studyToday = 'studyToday';
  static const String studySession = 'studySession';

  /// End-of-session result summary (`/library/study/session/:sessionId/result`).
  /// WBS 4.7.2.
  static const String studyResult = 'studyResult';
}
