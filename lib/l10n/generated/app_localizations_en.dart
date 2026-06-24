// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MemoX';

  @override
  String get appDescription => 'Local-first flashcard app';

  @override
  String get homeTitle => 'Home';

  @override
  String get libraryTitle => 'Library';

  @override
  String get progressTitle => 'Progress';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get librarySearchHint => 'Search folders';

  @override
  String libraryFolderCountHeader(int count) {
    return '$count folders';
  }

  @override
  String get libraryLoadingLabel => 'Loading folders';

  @override
  String get libraryEmptyTitle => 'Start your library';

  @override
  String get libraryEmptyMessage =>
      'Folders keep related decks together. Add one to organize your decks.';

  @override
  String get libraryLoadFailedTitle => 'Couldn\'t load your library';

  @override
  String get libraryLoadFailedMessage =>
      'Something went wrong loading your folders.';

  @override
  String get commonRetryLabel => 'Retry';

  @override
  String get librarySearchNoResultsTitle => 'No folders found';

  @override
  String librarySearchNoResultsMessage(String term) {
    return 'No folders match \"$term\".';
  }

  @override
  String get librarySearchClearLabel => 'Clear';

  @override
  String get libraryOverflowTooltip => 'Folder actions';

  @override
  String folderMetaDecks(int count) {
    return '$count decks';
  }

  @override
  String folderMetaSubfolders(int count) {
    return '$count subfolders';
  }

  @override
  String folderMetaCards(int count) {
    return '$count cards';
  }

  @override
  String folderDueBadge(int count) {
    return '$count due';
  }

  @override
  String get folderActionRename => 'Rename';

  @override
  String get folderActionMove => 'Move to folder';

  @override
  String get folderActionDelete => 'Delete folder';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get folderRenameTitle => 'Rename folder';

  @override
  String get folderRenameFieldLabel => 'Folder name';

  @override
  String get folderRenameConfirm => 'Rename';

  @override
  String get folderRenamedSnack => 'Folder renamed';

  @override
  String get folderDeleteTitle => 'Delete this folder?';

  @override
  String folderDeleteBlastRadius(int decks, int cards) {
    return 'This permanently deletes this folder, $decks decks and $cards cards, plus all study progress. This can\'t be undone.';
  }

  @override
  String get folderDeleteConfirm => 'Delete';

  @override
  String get folderDeletedSnack => 'Folder deleted';

  @override
  String get folderMoveTitle => 'Move folder';

  @override
  String get folderMoveRootLabel => 'Library (root)';

  @override
  String get folderMoveBlockCycle => 'Can\'t move into itself or a subfolder';

  @override
  String get folderMoveBlockLockedDecks => 'This folder holds decks';

  @override
  String get folderMovedSnack => 'Folder moved';

  @override
  String get folderErrorNameEmpty => 'Enter a folder name.';

  @override
  String get folderErrorNameDuplicate =>
      'A folder with this name already exists here.';

  @override
  String get folderErrorNotFound => 'That folder no longer exists.';

  @override
  String get folderErrorMoveCycle =>
      'You can\'t move a folder into itself or one of its subfolders.';

  @override
  String get folderErrorMoveLockedDecks =>
      'That folder holds decks, so it can\'t take a subfolder.';

  @override
  String get folderActionGenericError =>
      'Something went wrong. Please try again.';

  @override
  String get folderMetaEmpty => 'Empty';

  @override
  String get librarySearchTooltip => 'Search folders';

  @override
  String get libraryCreateFolderTooltip => 'New folder';

  @override
  String get libraryCreateFolderLabel => 'Create folder';

  @override
  String get folderCreateTitle => 'New folder';

  @override
  String get folderCreateNameLabel => 'Folder name';

  @override
  String get folderCreateColorLabel => 'Color';

  @override
  String get folderCreateIconLabel => 'Icon';

  @override
  String get folderCreateConfirm => 'Create';

  @override
  String get folderCreatedSnack => 'Folder created';

  @override
  String get folderDetailSearchTooltip => 'Search this folder';

  @override
  String get folderDetailSearchHint => 'Search this folder';

  @override
  String get folderDetailLoadFailedTitle => 'Couldn\'t load folder';

  @override
  String get folderDetailLoadFailedMessage =>
      'We couldn\'t reach this folder. Check your connection and try again.';

  @override
  String get folderDetailEmptyTitle => 'Empty folder';

  @override
  String get folderDetailEmptyMessage =>
      'Add a deck of cards, or nest a subfolder to keep things organized.';

  @override
  String get folderDetailCreateDeck => 'Create deck';

  @override
  String get folderDetailCreateSubfolder => 'Create subfolder';

  @override
  String folderDetailDecksHeader(int count) {
    return '$count decks';
  }

  @override
  String folderDetailFoldersHeader(int count) {
    return '$count folders';
  }

  @override
  String get folderStatDecks => 'Decks';

  @override
  String get folderStatCards => 'Cards';

  @override
  String get folderStatDue => 'Due';

  @override
  String get folderStatSubfolders => 'Subfolders';

  @override
  String get deckCreateTitle => 'New deck';

  @override
  String get deckCreateNameLabel => 'Deck name';

  @override
  String get deckCreateLanguageLabel => 'Language';

  @override
  String get deckCreateConfirm => 'Create';

  @override
  String get deckLanguageKorean => 'Korean';

  @override
  String get deckLanguageEnglish => 'English';

  @override
  String get deckActionRename => 'Rename';

  @override
  String get deckActionDelete => 'Delete deck';

  @override
  String get deckOverflowTooltip => 'Deck options';

  @override
  String get deckCreatedSnack => 'Deck created';

  @override
  String get deckRenamedSnack => 'Deck renamed';

  @override
  String get deckDeletedSnack => 'Deck deleted';

  @override
  String get deckDeleteTitle => 'Delete this deck?';

  @override
  String deckDeleteMessage(int count) {
    return 'This permanently deletes this deck and its $count cards, plus all study progress. This can\'t be undone.';
  }

  @override
  String get deckDeleteConfirm => 'Delete';

  @override
  String get flashcardSearchTooltip => 'Search cards';

  @override
  String get flashcardSearchHint => 'Search cards';

  @override
  String get flashcardLoadFailedTitle => 'Couldn\'t load cards';

  @override
  String get flashcardLoadFailedMessage =>
      'We couldn\'t reach this deck. Check your connection and try again.';

  @override
  String get flashcardEmptyTitle => 'No cards yet';

  @override
  String get flashcardEmptyMessage =>
      'Add your first flashcard to start studying.';

  @override
  String get flashcardAddCardLabel => 'Add card';

  @override
  String flashcardCountHeader(int count) {
    return '$count cards';
  }

  @override
  String get flashcardErrorEmpty => 'Front and back are both required.';

  @override
  String get flashcardErrorDuplicate =>
      'A card with this front and back already exists.';

  @override
  String get flashcardErrorNotFound => 'That card no longer exists.';

  @override
  String get flashcardActionGenericError =>
      'Something went wrong. Please try again.';

  @override
  String get cardCreateTitle => 'Add card';

  @override
  String get cardEditTitle => 'Edit card';

  @override
  String get cardFrontLabel => 'Front';

  @override
  String get cardBackLabel => 'Back';

  @override
  String get cardCreateConfirm => 'Add';

  @override
  String get cardEditConfirm => 'Save';

  @override
  String get cardCreatedSnack => 'Card added';

  @override
  String get cardSavedSnack => 'Card saved';

  @override
  String get cardDeleteTitle => 'Delete this card?';

  @override
  String get cardDeleteMessage =>
      'This permanently deletes this card and its study progress. This can\'t be undone.';

  @override
  String get cardDeleteConfirm => 'Delete';

  @override
  String get cardDeletedSnack => 'Card deleted';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchDockHint => 'Search everything';

  @override
  String get searchIdleTitle => 'Search your library';

  @override
  String get searchIdleMessage => 'Find folders, decks, and cards.';

  @override
  String get searchNoResultsTitle => 'No results';

  @override
  String searchNoResultsMessage(String query) {
    return 'Nothing matches “$query”. Try a different word or check the spelling.';
  }

  @override
  String get searchFailedTitle => 'Search failed';

  @override
  String get searchFailedMessage => 'We couldn\'t run that search just now.';

  @override
  String get searchRetry => 'Try again';

  @override
  String get searchSectionFolders => 'Folders';

  @override
  String get searchSectionDecks => 'Decks';

  @override
  String get searchSectionFlashcards => 'Flashcards';

  @override
  String searchMoreCount(int count) {
    return '+$count more';
  }

  @override
  String dashboardCardsDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards due',
      one: '1 card due',
    );
    return '$_temp0';
  }

  @override
  String dashboardDecksWithDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count decks',
      one: '1 deck',
    );
    return '$_temp0';
  }

  @override
  String get dashboardCaughtUpTitle => 'All caught up';

  @override
  String get dashboardCaughtUpMessage => 'Nothing due right now.';

  @override
  String get dashboardProgressShortcutSub => 'Goal, streak & accuracy';

  @override
  String get dashboardLibraryShortcutSub => 'Browse folders & decks';

  @override
  String get dashboardLoadFailedTitle => 'Couldn\'t load your dashboard';

  @override
  String get dashboardLoadFailedMessage =>
      'Something went wrong loading today\'s summary.';

  @override
  String get libraryRootLabel => 'Root';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get sortSheetTitle => 'Sort by';

  @override
  String get sortModeManual => 'Manual';

  @override
  String get sortModeName => 'Name (A–Z)';

  @override
  String get sortModeNewest => 'Newest';

  @override
  String get deckActionMove => 'Move to folder';

  @override
  String get deckMoveTitle => 'Move to folder';

  @override
  String get deckMoveBlockSubfolders => 'This folder holds subfolders';

  @override
  String get deckMovedSnack => 'Deck moved';

  @override
  String get deckMoveNoTargets => 'No other folder can hold this deck yet.';

  @override
  String get deckLastStudiedJustNow => 'just now';

  @override
  String deckLastStudiedMinutes(int count) {
    return 'last ${count}m ago';
  }

  @override
  String deckLastStudiedHours(int count) {
    return 'last ${count}h ago';
  }

  @override
  String deckLastStudiedDays(int count) {
    return 'last ${count}d ago';
  }

  @override
  String deckLastStudiedWeeks(int count) {
    return 'last ${count}w ago';
  }

  @override
  String get commonDone => 'Done';

  @override
  String get flashcardReorderCardsAction => 'Reorder cards';

  @override
  String flashcardReorderTitle(String deck) {
    return 'Reorder · $deck';
  }

  @override
  String get flashcardReorderHint => 'Drag the handles to reorder cards.';

  @override
  String flashcardReorderCountHeader(int count) {
    return '$count cards · drag to reorder';
  }

  @override
  String get flashcardStateNew => 'New · not studied';

  @override
  String flashcardStateBoxDueIn(int box, int days) {
    return 'Box $box · due in ${days}d';
  }

  @override
  String flashcardStateBoxDueToday(int box) {
    return 'Box $box · due today';
  }

  @override
  String get cardDiscardTitle => 'Discard changes?';

  @override
  String get cardDiscardMessage =>
      'Your edits to this card haven\'t been saved.';

  @override
  String get cardDiscardConfirm => 'Discard';

  @override
  String get cardDeleteTooltip => 'Delete card';

  @override
  String get cardDetailsLabel => 'Details';

  @override
  String get cardDetailsOptional => 'Optional';

  @override
  String get cardDetailsSummary => 'example · pronunciation · hint';

  @override
  String get cardExampleLabel => 'Example';

  @override
  String get cardPronunciationLabel => 'Pronunciation';

  @override
  String get cardHintLabel => 'Hint';

  @override
  String get cardTagsLabel => 'Tags';

  @override
  String get cardAddTagLabel => 'Add tag';

  @override
  String get cardSaveFailedMessage => 'Changes couldn\'t be saved.';

  @override
  String get cardLoadFailedTitle => 'Couldn\'t load card';

  @override
  String get cardLoadFailedMessage => 'We couldn\'t fetch this card to edit.';

  @override
  String get commonBack => 'Back';

  @override
  String get studyEntryTitle => 'Study';

  @override
  String get studySessionTitle => 'Study';

  @override
  String get studySessionPlaceholder => 'Review session — coming soon.';

  @override
  String get studyPreparing => 'Preparing study…';

  @override
  String get studyEntryErrorTitle => 'Couldn\'t start study';

  @override
  String get studyEntryErrorMessage =>
      'We couldn\'t prepare this study session. Please try again.';

  @override
  String get studyEmptyCaughtUpTitle => 'All caught up!';

  @override
  String get studyEmptyDeckNoCardsTitle => 'No cards in this deck';

  @override
  String get studyEmptyDeckNoCardsMessage =>
      'Add flashcards to start studying.';

  @override
  String get studyEmptyDeckNoDueMessage =>
      'No cards are due in this deck right now.';

  @override
  String get studyEmptyFolderNoCardsTitle => 'No cards in this folder';

  @override
  String get studyEmptyFolderNoCardsMessage =>
      'Add a deck and some cards to start studying.';

  @override
  String get studyEmptyFolderNoDueMessage =>
      'No cards are due in this folder right now.';

  @override
  String get studyEmptyTodayAllDoneTitle => 'All done for today!';

  @override
  String get studyEmptyTodayAllDoneMessage =>
      'Come back tomorrow to keep your streak going.';

  @override
  String get studyEmptyTodayNoContentTitle => 'No flashcards yet';

  @override
  String get studyEmptyTodayNoContentMessage =>
      'Create a deck and add cards to start studying.';

  @override
  String get studyEmptyAllBuriedTitle => 'All cards buried for today';

  @override
  String get studyEmptyAllBuriedMessage => 'They\'ll return tomorrow.';

  @override
  String get studyEmptyAllSuspendedTitle => 'All cards are suspended';

  @override
  String get studyEmptyAllSuspendedMessage =>
      'Resume some cards to start studying.';

  @override
  String get studyResumeTitle => 'Resume your session?';

  @override
  String get studyResumeMessage =>
      'You have an unfinished study session for this scope.';

  @override
  String get studyResumeAction => 'Resume';

  @override
  String get studyStartOverAction => 'Start over';

  @override
  String get studyStartOverTitle => 'Start over?';

  @override
  String get studyStartOverMessage =>
      'This discards your current progress for this session and starts fresh.';

  @override
  String get studyActionStudyNew => 'Study new instead';

  @override
  String get studyReviewFrontLabel => 'FRONT';

  @override
  String get studyReviewBackLabel => 'BACK';

  @override
  String get studyReviewEmptyTitle => 'Nothing to review';

  @override
  String get studyReviewEmptyMessage => 'This session has no cards.';

  @override
  String get studyReviewLoadFailedTitle => 'Couldn\'t load the session';

  @override
  String get studyReviewLoadFailedMessage =>
      'We couldn\'t load this study session.';

  @override
  String get studyReviewSwipeHint =>
      'Swipe right if you knew it, left if you didn\'t';

  @override
  String get studyReviewFinishTitle => 'Review complete';

  @override
  String get studyReviewFinishMessage =>
      'You\'ve gone through every card in this session.';

  @override
  String get studyReviewFinishAction => 'Finish session';

  @override
  String get studyExitTitle => 'Exit study session?';

  @override
  String get studyExitMessage =>
      'Your progress is saved and you can resume later. Leave this session?';

  @override
  String get studyExitConfirm => 'Exit';

  @override
  String get studyExitCancel => 'Keep studying';

  @override
  String get studyActionBury => 'Bury until tomorrow';

  @override
  String get studyActionSuspend => 'Suspend card';

  @override
  String get studyResultTitle => 'Session complete';

  @override
  String get studyResultLoading => 'Saving your results…';

  @override
  String get studyResultHeroTitle => 'Nice work!';

  @override
  String studyResultCardsReviewed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards reviewed',
      one: '1 card reviewed',
    );
    return '$_temp0';
  }

  @override
  String get studyResultCorrect => 'Correct';

  @override
  String get studyResultWrong => 'Wrong';

  @override
  String get studyResultAnswered => 'Answered';

  @override
  String get studyResultDone => 'Done';

  @override
  String get studyResultLoadFailedTitle => 'Couldn\'t load your results';

  @override
  String get studyResultLoadFailedMessage =>
      'Something went wrong loading this session\'s summary.';

  @override
  String get studyResultSaveFailedBanner =>
      'Couldn\'t save your results. Your progress is kept locally.';

  @override
  String get studyResultRetry => 'Retry save';

  @override
  String get studyResultDefensiveTitle => 'No cards answered';

  @override
  String get studyResultDefensiveMessage =>
      'This session has no recorded answers.';

  @override
  String get studyMatchTitle => 'Match the pairs';

  @override
  String get studyMatchSubtitle => 'Tap a term, then its meaning.';

  @override
  String studyMatchProgress(int matched, int left) {
    return '$matched matched · $left left';
  }

  @override
  String get studyGuessPrompt => 'What does this mean?';

  @override
  String get studyGuessTapToContinue => 'Tap to continue';

  @override
  String get studyRecallPrompt => 'Recall the meaning';

  @override
  String get studyRecallHint => 'Say it in your head, then reveal.';

  @override
  String get studyRecallShowAnswer => 'Show answer';

  @override
  String get studyRecallAnswerLabel => 'Answer';

  @override
  String get studyRecallGradePrompt => 'How well did you know it?';

  @override
  String get studyRecallMissed => 'Missed';

  @override
  String get studyRecallGotIt => 'Got it';

  @override
  String get studyFillPrompt => 'Type the answer';

  @override
  String get studyFillAnswerLabel => 'Your answer';

  @override
  String get studyFillCheck => 'Check answer';

  @override
  String get studyFillWrongMessage => 'Not quite — see the answer below.';

  @override
  String get studyFillCorrectLabel => 'Correct answer';

  @override
  String get studyFillRetry => 'Retry';

  @override
  String get studyFillNext => 'Next';

  @override
  String get studyFillMarkCorrect => 'Mark correct';

  @override
  String get studyFillHint => 'Hint';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statsCardsThisWeekLabel => 'CARDS THIS WEEK';

  @override
  String get statsPerDeckMasteryTitle => 'Per-deck mastery';

  @override
  String statsMasteryPercent(int percent) {
    return '$percent%';
  }

  @override
  String statsCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get statsNoDecksHint => 'No decks to show yet';

  @override
  String get statsLoadFailedTitle => 'Couldn\'t load your stats';

  @override
  String get statsLoadFailedMessage =>
      'Something went wrong loading your stats.';

  @override
  String get cardHistoryTitle => 'History';

  @override
  String get cardHistoryActivityLabel => 'ACTIVITY';

  @override
  String get cardHistoryReviewsLabel => 'Reviews';

  @override
  String get cardHistoryRetentionLabel => 'Retention';

  @override
  String get cardHistoryAvgTimeLabel => 'Avg time';

  @override
  String get cardHistoryStatEmpty => '—';

  @override
  String cardHistoryBoxChip(int box) {
    return 'Box $box';
  }

  @override
  String cardHistoryDurationSeconds(String value) {
    return '${value}s';
  }

  @override
  String cardHistoryRowMeta(String relative, String time) {
    return '$relative · $time';
  }

  @override
  String get cardHistoryToday => 'Today';

  @override
  String get cardHistoryYesterday => 'Yesterday';

  @override
  String cardHistoryDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get cardHistoryAttemptCorrect => 'Reviewed · Correct';

  @override
  String get cardHistoryAttemptRecovered => 'Reviewed · Recovered';

  @override
  String get cardHistoryAttemptForgot => 'Reviewed · Forgot';

  @override
  String get cardHistoryEventCreated => 'Card created';

  @override
  String get cardHistoryEventEdited => 'Card edited';

  @override
  String get cardHistoryEventReset => 'Progress reset';

  @override
  String get cardHistoryEventAudio => 'Audio added';

  @override
  String get cardHistoryEmptyTitle => 'No history yet';

  @override
  String get cardHistoryEmptyMessage =>
      'Study this card and your reviews will show up here.';

  @override
  String get cardHistoryLoadFailedTitle => 'Couldn\'t load history';

  @override
  String get cardHistoryLoadFailedMessage =>
      'We couldn\'t fetch this card\'s activity.';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get tagManagementTitle => 'Tags';

  @override
  String tagManagementCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count TAGS',
      one: '1 TAG',
    );
    return '$_temp0';
  }

  @override
  String tagManagementCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get tagManagementActionsTooltip => 'Tag actions';

  @override
  String tagManagementSheetHeader(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$name · $_temp0';
  }

  @override
  String get tagManagementRenameAction => 'Rename';

  @override
  String get tagManagementMergeAction => 'Merge into…';

  @override
  String get tagManagementDeleteAction => 'Delete';

  @override
  String get tagManagementRenameTitle => 'Rename tag';

  @override
  String get tagManagementRenameFieldLabel => 'Tag name';

  @override
  String get tagManagementRenameConfirm => 'Save';

  @override
  String get tagManagementMergeConfirm => 'Merge tags';

  @override
  String tagManagementMergePrompt(String name) {
    return 'A tag “$name” already exists. Merge them?';
  }

  @override
  String tagManagementMergeSheetTitle(String name) {
    return 'Merge “$name” into';
  }

  @override
  String get tagManagementSearchHint => 'Search tags';

  @override
  String get tagManagementEmptyTitle => 'No tags yet';

  @override
  String get tagManagementEmptyMessage =>
      'Add tags to your cards and they\'ll appear here to manage.';

  @override
  String get tagManagementSearchEmptyTitle => 'No tags found';

  @override
  String get tagManagementSearchEmptyMessage => 'No tags match your search.';

  @override
  String get tagManagementLoadFailedTitle => 'Couldn\'t load tags';

  @override
  String get tagManagementLoadFailedMessage =>
      'Something went wrong loading your tags.';

  @override
  String tagManagementDeleteTitle(String name) {
    return 'Delete tag “$name”?';
  }

  @override
  String tagManagementDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return 'The tag is removed from $_temp0. The cards themselves stay. This can\'t be undone.';
  }

  @override
  String get tagManagementDeleteConfirm => 'Delete';

  @override
  String get tagManagementBusyRenaming => 'Renaming…';

  @override
  String get tagManagementBusyMerging => 'Merging tags…';

  @override
  String get tagManagementBusyDeleting => 'Deleting…';

  @override
  String get tagManagementRenameFailedTitle => 'Couldn\'t rename tag';

  @override
  String get tagManagementRenameFailedMessage =>
      'Something went wrong updating this tag. Your tags are unchanged.';

  @override
  String get tagManagementMergeFailedTitle => 'Couldn\'t merge tags';

  @override
  String get tagManagementMergeFailedMessage =>
      'Something went wrong merging these tags. Your tags are unchanged.';

  @override
  String get tagManagementDeleteFailedTitle => 'Couldn\'t delete tag';

  @override
  String get tagManagementDeleteFailedMessage =>
      'Something went wrong deleting this tag. Your tags are unchanged.';

  @override
  String get deckImportTitle => 'Import';

  @override
  String get deckImportEmptyTitle => 'Import cards from a file';

  @override
  String get deckImportEmptyMessage =>
      'Pick a CSV or TSV file from your device to bring its cards into MemoX.';

  @override
  String get deckImportChooseFile => 'Choose file';

  @override
  String get deckImportSupportedFormats => 'Supports CSV and TSV files.';

  @override
  String get deckImportReadyToParse => 'ready to parse';

  @override
  String deckImportFileMeta(String size, String type, String status) {
    return '$size · $type · $status';
  }

  @override
  String deckImportSizeBytes(int bytes) {
    return '$bytes B';
  }

  @override
  String deckImportSizeKb(String value) {
    return '$value KB';
  }

  @override
  String deckImportSizeMb(String value) {
    return '$value MB';
  }

  @override
  String get deckImportClearFile => 'Remove file';

  @override
  String get deckImportParseFile => 'Parse file';

  @override
  String get deckImportParseHint =>
      'We\'ll show a preview before anything is imported.';

  @override
  String get deckImportParsing => 'Parsing…';

  @override
  String get deckImportImporting => 'Importing…';

  @override
  String deckImportPreviewSummary(int found, int valid, int skip) {
    return '$found found · $valid valid · $skip to skip';
  }

  @override
  String deckImportSkipWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards have problems and will be skipped.',
      one: '1 card has problems and will be skipped.',
    );
    return '$_temp0';
  }

  @override
  String deckImportAllValid(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count cards look good.',
      one: '1 card looks good.',
    );
    return '$_temp0';
  }

  @override
  String deckImportPreviewLabel(int count) {
    return 'PREVIEW $count';
  }

  @override
  String deckImportCardPair(String front, String back) {
    return '$front — $back';
  }

  @override
  String get deckImportSkippedRow => 'Skipped row';

  @override
  String get deckImportDuplicateReason => 'Duplicate card';

  @override
  String get deckImportSkipBadge => 'Skip';

  @override
  String deckImportCommitButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count valid cards',
      one: 'Import 1 valid card',
    );
    return '$_temp0';
  }

  @override
  String deckImportSuccessTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards imported',
      one: '1 card imported',
    );
    return '$_temp0';
  }

  @override
  String deckImportSuccessMessage(String deck) {
    return 'They\'re now in your $deck deck, ready to study.';
  }

  @override
  String get deckImportThisDeck => 'current';

  @override
  String deckImportPartialTitle(int imported, int skipped) {
    return '$imported imported · $skipped skipped';
  }

  @override
  String get deckImportPartialMessage =>
      'Some rows were invalid or duplicates and were left out.';

  @override
  String get deckImportImportAnother => 'Import another file';

  @override
  String get deckImportOpenDeck => 'Open deck';

  @override
  String get deckImportFailedTitle => 'Import failed';

  @override
  String get deckImportFailedMessage =>
      'Nothing was imported. The file may be corrupt or in an unsupported format.';

  @override
  String get deckImportChooseAnother => 'Choose another file';

  @override
  String get learningSettingsTitle => 'Learning';

  @override
  String get learningSettingsSaving => 'Saving…';

  @override
  String get learningSettingsErrorTitle => 'Couldn\'t load settings';

  @override
  String get learningSettingsErrorMessage =>
      'Something went wrong loading your learning settings.';

  @override
  String get learningGoalTitle => 'Daily goal';

  @override
  String get learningGoalOnDesc => 'Cards to study each day';

  @override
  String get learningGoalOffDesc => 'Turned off — study freely';

  @override
  String get learningGoalUnit => 'cards / day';

  @override
  String get learningReminderTitle => 'Daily reminder';

  @override
  String get learningReminderOffDesc => 'No reminder set';
}
