/// Path templates, segment/param tokens, and path builders for GoRouter.
///
/// Single source of truth for URL structure. Widgets build concrete paths
/// through the static builders here; raw string concatenation is forbidden.
/// See `docs/business/navigation/navigation-flow.md`.
abstract final class RoutePaths {
  RoutePaths._();

  // ── Top-level absolute paths ─────────────────────────────────
  static const String root = '/';
  static const String home = '/home';
  static const String library = '/library';
  static const String progress = '/progress';
  static const String settings = '/settings';

  // ── Path params (token names) ────────────────────────────────
  static const String idParam = 'id';
  static const String deckIdParam = 'deckId';
  static const String flashcardIdParam = 'flashcardId';
  static const String entryTypeParam = 'entryType';
  static const String entryRefIdParam = 'entryRefId';
  static const String sessionIdParam = 'sessionId';

  // ── Query params ─────────────────────────────────────────────
  static const String studyTypeQueryParam = 'study_type';
  static const String modeQueryParam = 'mode';
  static const String filterQueryParam = 'filter';
  static const String tagQueryParam = 'tag';

  // ── Relative segments ────────────────────────────────────────
  static const String settingsAccountSegment = 'account';
  static const String settingsLearningSegment = 'learning';
  static const String settingsLearningTagsSegment = 'tags';
  static const String settingsAudioSpeechSegment = 'audio-speech';

  static const String searchSegment = 'search';
  static const String folderSegment = 'folder';
  static const String deckSegment = 'deck';
  static const String flashcardsSegment = 'flashcards';
  static const String newSegment = 'new';
  static const String editSegment = 'edit';
  static const String importSegment = 'import';

  static const String studySegment = 'study';
  static const String todaySegment = 'today';
  static const String sessionSegment = 'session';
  static const String resultSegment = 'result';

  // ── Settings sub-screens (absolute) ──────────────────────────
  static const String settingsAccount = '$settings/$settingsAccountSegment';
  static const String settingsLearning = '$settings/$settingsLearningSegment';
  static const String settingsLearningTags =
      '$settingsLearning/$settingsLearningTagsSegment';
  static const String settingsAudioSpeech =
      '$settings/$settingsAudioSpeechSegment';

  // ── Library route templates (with :params for GoRoute.path) ──
  static const String librarySearchTemplate = '$library/$searchSegment';
  static const String folderDetailTemplate =
      '$library/$folderSegment/:$idParam';
  static const String flashcardListTemplate =
      '$library/$deckSegment/:$deckIdParam/$flashcardsSegment';
  static const String flashcardCreateTemplate =
      '$flashcardListTemplate/$newSegment';
  static const String flashcardEditTemplate =
      '$flashcardListTemplate/:$flashcardIdParam/$editSegment';
  static const String deckImportTemplate =
      '$library/$deckSegment/:$deckIdParam/$importSegment';

  // ── Study route templates ────────────────────────────────────
  static const String studyTodayTemplate =
      '$library/$studySegment/$todaySegment';
  static const String studySessionTemplate =
      '$library/$studySegment/$sessionSegment/:$sessionIdParam';
  static const String studyResultTemplate =
      '$studySessionTemplate/$resultSegment';
  static const String studyEntryTemplate =
      '$library/$studySegment/:$entryTypeParam/:$entryRefIdParam';

  // ── Concrete path builders ───────────────────────────────────
  static const String librarySearch = librarySearchTemplate;

  static String folderDetail(String folderId) =>
      '$library/$folderSegment/$folderId';

  static String flashcardList(String deckId) =>
      '$library/$deckSegment/$deckId/$flashcardsSegment';

  static String flashcardCreate(String deckId) =>
      '${flashcardList(deckId)}/$newSegment';

  static String flashcardEdit(String deckId, String flashcardId) =>
      '${flashcardList(deckId)}/$flashcardId/$editSegment';

  static String deckImport(String deckId) =>
      '$library/$deckSegment/$deckId/$importSegment';

  static String studyEntry(String entryType, String entryRefId) =>
      '$library/$studySegment/$entryType/$entryRefId';

  static const String studyToday = studyTodayTemplate;

  static String studySession(String sessionId) =>
      '$library/$studySegment/$sessionSegment/$sessionId';

  static String studyResult(String sessionId) =>
      '${studySession(sessionId)}/$resultSegment';
}

/// Boot-time navigation defaults.
///
/// V1 boots into the Library; do not replace with an onboarding wizard.
/// See `docs/business/navigation/navigation-flow.md` §Top-level destinations.
abstract final class RouteDefaults {
  RouteDefaults._();

  static const String initialLocation = RoutePaths.library;
}
