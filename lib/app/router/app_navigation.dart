import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_extras.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_type.dart';

/// The single sanctioned navigation surface (`memox.common_navigation_extension_usage`).
///
/// UI code navigates through these semantic methods instead of raw `GoRouter`
/// APIs, so route names/params stay centralized in `RouteNames` / `RoutePaths`.
extension AppNavigation on BuildContext {
  /// Switch to the Library tab root.
  void goLibrary() => goNamed(RouteNames.library);

  /// Switch to the Home tab root.
  void goHome() => goNamed(RouteNames.home);

  /// Switch to the Settings tab root.
  void goSettings() => goNamed(RouteNames.settings);

  /// Open global Library search: `/library/search`.
  void pushLibrarySearch() => pushNamed(RouteNames.librarySearch);

  /// Open a folder detail screen: `/library/folder/:id`.
  void goFolderDetail(String folderId) => goNamed(
    RouteNames.folderDetail,
    pathParameters: <String, String>{RoutePaths.idParam: folderId},
  );

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

  /// Open the Account & Sync settings sub-screen.
  void pushSettingsAccount() => pushNamed(RouteNames.settingsAccount);

  /// Open the Learning settings sub-screen.
  void pushSettingsLearning() => pushNamed(RouteNames.settingsLearning);

  /// Open the Tag management sub-screen.
  void pushSettingsLearningTags() => pushNamed(RouteNames.settingsLearningTags);

  /// Open the Audio & Speech settings sub-screen.
  void pushSettingsAudioSpeech() => pushNamed(RouteNames.settingsAudioSpeech);

  /// Replace the current location with a study session route.
  void pushReplacementStudySession(String sessionId) => pushReplacementNamed(
    RouteNames.studySession,
    pathParameters: <String, String>{RoutePaths.sessionIdParam: sessionId},
    extra: RouteExtras.studyNavigationToken,
  );

  /// Open a persisted study session: `/library/study/session/:sessionId`.
  void pushStudySession(String sessionId) => goNamed(
    RouteNames.studySession,
    pathParameters: <String, String>{RoutePaths.sessionIdParam: sessionId},
    extra: RouteExtras.studyNavigationToken,
  );

  /// Navigate to the study gate with semantic route parameters.
  void goStudyEntry({
    required EntryType entryType,
    String? entryRefId,
    StudyType? studyType,
    StudyMode? mode,
  }) {
    final Map<String, String> queryParameters = <String, String>{};
    if (studyType != null) {
      queryParameters[RoutePaths.studyTypeQueryParam] = switch (studyType) {
        StudyType.newCards => 'new',
        StudyType.srsReview => 'srs_review',
      };
    }
    if (mode != null) {
      queryParameters[RoutePaths.modeQueryParam] = mode.name;
    }
    if (entryType == EntryType.today) {
      goNamed(
        RouteNames.studyToday,
        queryParameters: queryParameters,
        extra: RouteExtras.studyNavigationToken,
      );
      return;
    }
    goNamed(
      RouteNames.studyEntry,
      pathParameters: <String, String>{
        RoutePaths.entryTypeParam: entryType.name,
        RoutePaths.entryRefIdParam: entryRefId ?? '',
      },
      queryParameters: queryParameters,
      extra: RouteExtras.studyNavigationToken,
    );
  }
}
