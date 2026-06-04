/// Named-route identifiers for GoRouter.
///
/// Widgets navigate with `context.goNamed`/`pushNamed` using these constants —
/// never hardcoded path strings. See `docs/business/navigation/navigation-flow.md`.
abstract final class RouteNames {
  RouteNames._();

  // ── Top-level shell destinations ─────────────────────────────
  static const String home = 'home';
  static const String library = 'library';
  static const String progress = 'progress';
  static const String settings = 'settings';

  // ── Settings sub-screens (shell hidden) ──────────────────────
  static const String settingsAccount = 'settings-account';
  static const String settingsLearning = 'settings-learning';
  static const String settingsLearningTags = 'settings-learning-tags';
  static const String settingsAudioSpeech = 'settings-audio-speech';

  // ── Library tree ─────────────────────────────────────────────
  static const String folderDetail = 'folder-detail';
  static const String flashcardList = 'flashcard-list';
  static const String flashcardCreate = 'flashcard-create';
  static const String flashcardEdit = 'flashcard-edit';
  static const String deckImport = 'deck-import';

  /// Future Proposal — no live V1 route. Add wiring when scope guard promotes.
  static const String flashcardHistory = 'flashcard-history';

  // ── Study tree (shell hidden) ────────────────────────────────
  static const String studyEntry = 'study-entry';
  static const String studyToday = 'study-today';
  static const String studySession = 'study-session';
  static const String studyResult = 'study-result';
}
