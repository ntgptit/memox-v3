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

  /// Folder detail (subfolders + decks), pushed within the Library branch.
  static const String folderDetail = 'folderDetail';

  /// A deck's flashcard list, pushed within the Library branch.
  static const String deckFlashcards = 'deckFlashcards';

  /// Card create / edit editor screen, pushed over a deck's flashcard list
  /// (mock `07` / `08`). WBS 2.11.2 / 2.12.2.
  static const String flashcardCreate = 'flashcardCreate';
  static const String flashcardEdit = 'flashcardEdit';

  /// Folder detail / deck flashcard list reached from a **Search** result, so
  /// the push stays inside the Search branch (Back returns to `/search`). Same
  /// screens as the Library-branch routes, distinct names per GoRouter's
  /// unique-name rule.
  static const String searchFolderDetail = 'searchFolderDetail';
  static const String searchDeckFlashcards = 'searchDeckFlashcards';
}
