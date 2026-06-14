// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MemoX';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRename => 'Rename';

  @override
  String get commonImport => 'Import';

  @override
  String get commonMove => 'Move';

  @override
  String get commonClear => 'Clear';

  @override
  String get homeTitle => 'Home';

  @override
  String get libraryTitle => 'Library';

  @override
  String get progressTitle => 'Progress';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get dashboardGreetingTitle => 'Good evening, learner';

  @override
  String get dashboardGreetingSubtitle => 'Ready to study today?';

  @override
  String get dashboardTodayReviewTitle => 'Today Review';

  @override
  String get dashboardNewStudyTitle => 'New Study';

  @override
  String get dashboardNewStudyEmptyMessage =>
      'Add or import cards before starting a new study session.';

  @override
  String get dashboardContinueSessionAction => 'Continue';

  @override
  String get dashboardResumeSectionTitle => 'Continue studying';

  @override
  String dashboardStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get dashboardDueTodayTitle => 'Due today';

  @override
  String dashboardDueTodayMessage(int count) {
    return '$count cards ready to review';
  }

  @override
  String get dashboardNoDueTitle => 'No cards due now';

  @override
  String get dashboardNoDueMessage =>
      'Open your library to add cards or start a focused deck session.';

  @override
  String get dashboardStudyTodayAction => 'Study';

  @override
  String get dashboardOpenLibraryAction => 'View library';

  @override
  String get progressEntryDeck => 'Deck';

  @override
  String get progressEntryFolder => 'Folder';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsStudySectionTitle => 'Study';

  @override
  String get settingsAppSectionTitle => 'App';

  @override
  String get settingsAboutSectionTitle => 'About';

  @override
  String get settingsOverviewFooter => 'Made for calm learning · MemoX';

  @override
  String get settingsAccountTitle => 'Account';

  @override
  String get settingsAccountLinkedOverviewTitle => 'Account & sync';

  @override
  String get settingsAccountSignInSyncTitle => 'Sign in & sync';

  @override
  String get settingsAccountSignInSyncSubtitle =>
      'Save your progress across devices';

  @override
  String get settingsAccountSigningIn => 'Signing in...';

  @override
  String settingsAccountOverviewSyncedMockSubtitle(Object email) {
    return '$email · synced 2 min ago';
  }

  @override
  String settingsAccountOverviewSyncErrorSubtitle(Object email) {
    return '$email · last synced 2 days ago';
  }

  @override
  String get settingsOverviewSyncRetry => 'Retry';

  @override
  String get settingsAppearanceOverviewSubtitle => 'Light, dark, system';

  @override
  String get settingsSoonChip => 'SOON';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageOverviewSubtitle => 'English';

  @override
  String get settingsLearningOverviewTitle => 'Learning';

  @override
  String get settingsLearningDailyGoalSectionTitle => 'Daily goal';

  @override
  String get settingsLearningGoalToggleTitle => 'Set a daily goal';

  @override
  String get settingsLearningGoalToggleSubtitleOn =>
      'Track how many cards you complete each day.';

  @override
  String get settingsLearningGoalToggleSubtitleOff =>
      'Pause goal tracking without losing your streak.';

  @override
  String get settingsLearningGoalOffHint =>
      'Goal is off. Your streak is frozen — it won’t reset while paused.';

  @override
  String get settingsLearningCardsPerDayLabel => 'Cards per day';

  @override
  String get settingsLearningDragHint => 'Drag to adjust in steps of 5';

  @override
  String get settingsLearningStreakToggleTitle => 'Show streak counter';

  @override
  String get settingsLearningStreakToggleSubtitle =>
      'Display your current streak on Home and Stats.';

  @override
  String get settingsLearningReminderSectionTitle => 'Reminder';

  @override
  String get settingsLearningReminderHint =>
      'A gentle nudge once a day. Off by default.';

  @override
  String get settingsLearningReminderToggleTitle => 'Daily reminder';

  @override
  String get settingsLearningReminderToggleSubtitleOn =>
      'Nudge me to study every day.';

  @override
  String get settingsLearningReminderToggleSubtitleOff =>
      'You decide when to come back.';

  @override
  String get settingsLearningReminderTimeLabel => 'Reminder time';

  @override
  String get settingsLearningReminderTimeValue => '20:00';

  @override
  String get settingsLearningNotificationsBlockedTitle =>
      'Notifications are blocked';

  @override
  String get settingsLearningNotificationsBlockedBody =>
      'Allow MemoX in your phone’s notification settings to receive the reminder.';

  @override
  String get settingsLearningOpenSystemSettings => 'Open system settings';

  @override
  String get settingsLearningTagsSectionTitle => 'Tags';

  @override
  String settingsLearningTagsSubtitle(int count) {
    return '$count tags across all decks';
  }

  @override
  String get settingsLearningFutureStudyDefaultsTitle => 'Study defaults';

  @override
  String get settingsLearningFutureStudyDefaultsHint =>
      'Available in a future update.';

  @override
  String get settingsLearningFutureDefaultShuffleTitle => 'Default shuffle';

  @override
  String get settingsLearningFutureDefaultShuffleSubtitle =>
      'Randomize card order in every session';

  @override
  String get settingsLearningFutureDefaultStudyModeTitle =>
      'Default study mode';

  @override
  String get settingsLearningFutureDefaultStudyModeSubtitle =>
      'Review, Match, Guess, Recall, or Fill';

  @override
  String get settingsLearningFutureExampleSentenceTitle =>
      'Show example sentence';

  @override
  String get settingsLearningFutureExampleSentenceSubtitle =>
      'Reveal the example with the meaning';

  @override
  String get settingsLearningSavedChip => 'Saved';

  @override
  String get settingsLearningOverviewSummary =>
      '20 cards / day · 5 study modes';

  @override
  String settingsCardsCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get settingsManageTagsTitle => 'Manage tags';

  @override
  String get settingsManageTagsOverviewSubtitle => '14 tags';

  @override
  String tagHashLabel(String tag) {
    return '#$tag';
  }

  @override
  String get settingsTagsSearchHint => 'Search tags';

  @override
  String settingsTagsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags',
      one: '1 tag',
    );
    return '$_temp0';
  }

  @override
  String settingsTagsCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get settingsTagsSortMostCards => 'Most cards';

  @override
  String get settingsTagsEmptyTitle => 'No tags yet';

  @override
  String get settingsTagsEmptyMessage =>
      'Tags are added when you create or edit flashcards. Open a card to add your first tag.';

  @override
  String get settingsTagsEmptyAction => 'Go to library';

  @override
  String get settingsTagsSearchEmptyTitle => 'No matching tags';

  @override
  String get settingsTagsSearchEmptyMessage => 'No tags match your search.';

  @override
  String get settingsTagsActionRename => 'Rename';

  @override
  String get settingsTagsActionMerge => 'Merge into another tag';

  @override
  String get settingsTagsActionDelete => 'Delete tag (keeps cards)';

  @override
  String get settingsTagsContextSheetTitle => 'Tag actions';

  @override
  String get settingsTagsMostUsedBadge => 'Most used';

  @override
  String get settingsTagsRenameTitle => 'Rename tag';

  @override
  String get settingsTagsRenameHint => 'Enter a new name';

  @override
  String get settingsTagsRenameConfirm => 'Rename';

  @override
  String settingsTagsRenameHelper(String tag) {
    return 'Renaming updates every card that uses $tag.';
  }

  @override
  String settingsTagsRenameConflictMessage(String tag) {
    return 'A tag called $tag already exists. Continuing will merge these two tags.';
  }

  @override
  String settingsTagsMergeSheetTitle(String source) {
    return 'Merge \"$source\" into…';
  }

  @override
  String get settingsTagsMergeSheetHint => 'Pick the destination tag.';

  @override
  String settingsTagsMergeSheetSummary(int count, String source) {
    return 'All $count cards tagged $source will be re-tagged with the destination tag. The tag $source will be deleted.';
  }

  @override
  String get settingsTagsMergeSuggestedSectionTitle => 'Suggested';

  @override
  String get settingsTagsMergeAllTagsSectionTitle => 'All tags';

  @override
  String get settingsTagsMergeConfirmAction => 'Merge';

  @override
  String get settingsTagsDeleteTitle => 'Delete tag?';

  @override
  String settingsTagsDeleteMessage(String tag, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return 'Delete \"$tag\"? This removes the tag from $_temp0. Cards are not deleted.';
  }

  @override
  String get settingsTagsDeleteConfirm => 'Delete';

  @override
  String get settingsTagsOpErrorTitle => 'Couldn\'t rename tag';

  @override
  String get settingsTagsOpErrorBody =>
      'Nothing changed. Try again in a moment.';

  @override
  String get settingsTagsRetry => 'Retry';

  @override
  String get flashcardsTagErrorEmpty => 'Tag name is required.';

  @override
  String get flashcardsTagErrorComma => 'Tags cannot contain commas.';

  @override
  String get flashcardsTagErrorTooLong => 'Tag too long (max 50 chars).';

  @override
  String get settingsAudioSpeechTitle => 'Audio & speech';

  @override
  String get settingsAudioSpeechOverviewSummary => 'Korean voice · 0.9× speed';

  @override
  String get settingsAudioSpeechSaved => 'Saved';

  @override
  String get settingsAudioSpeechGeneralSectionTitle => 'General';

  @override
  String get settingsAudioSpeechAutoPlayTitle => 'Auto-play on reveal';

  @override
  String get settingsAudioSpeechAutoPlaySubtitle =>
      'Speak the front when a new card appears.';

  @override
  String get settingsAudioSpeechPlayAfterGradingTitle => 'Play after grading';

  @override
  String get settingsAudioSpeechPlayAfterGradingSubtitle =>
      'Replay the term after you rate the card.';

  @override
  String get settingsAudioSpeechLanguageSectionTitle => 'Language';

  @override
  String get settingsAudioSpeechKoreanTabFlag => '한';

  @override
  String get settingsAudioSpeechKoreanTabLabel => 'Korean';

  @override
  String get settingsAudioSpeechEnglishTabFlag => 'EN';

  @override
  String get settingsAudioSpeechEnglishTabLabel => 'English';

  @override
  String settingsAudioSpeechVoiceSectionTitle(Object language) {
    return 'Voice · $language';
  }

  @override
  String get settingsAudioSpeechKoreanLanguageLabel => 'Korean';

  @override
  String get settingsAudioSpeechEnglishLanguageLabel => 'English';

  @override
  String get settingsAudioSpeechKoreanSampleText => '오늘도 한 단어 더 외워봐요.';

  @override
  String get settingsAudioSpeechKoreanSampleHint =>
      'Today, let’s remember one more word.';

  @override
  String get settingsAudioSpeechEnglishSampleText =>
      'One word a day keeps forgetting away.';

  @override
  String get settingsAudioSpeechKoreanSystemVoiceName => 'System default';

  @override
  String get settingsAudioSpeechKoreanSystemVoiceMeta =>
      'Uses your phone’s default Korean voice';

  @override
  String get settingsAudioSpeechKoreanSujiVoiceName => 'Suji';

  @override
  String get settingsAudioSpeechKoreanSujiVoiceMeta =>
      'Female · neural · offline';

  @override
  String get settingsAudioSpeechKoreanMinhoVoiceName => 'Minho';

  @override
  String get settingsAudioSpeechKoreanMinhoVoiceMeta =>
      'Male · neural · offline';

  @override
  String get settingsAudioSpeechKoreanEunhaVoiceName => 'Eunha';

  @override
  String get settingsAudioSpeechKoreanEunhaVoiceMeta => 'Female · standard';

  @override
  String get settingsAudioSpeechEnglishSystemVoiceName => 'System default';

  @override
  String get settingsAudioSpeechEnglishSystemVoiceMeta =>
      'Uses your phone’s default English voice';

  @override
  String get settingsAudioSpeechEnglishEmmaVoiceName => 'Emma';

  @override
  String get settingsAudioSpeechEnglishEmmaVoiceMeta =>
      'Female · neural · offline';

  @override
  String get settingsAudioSpeechEnglishRyanVoiceName => 'Ryan';

  @override
  String get settingsAudioSpeechEnglishRyanVoiceMeta =>
      'Male · neural · offline';

  @override
  String get settingsAudioSpeechDefaultVoiceBadge => 'Default';

  @override
  String settingsAudioSpeechNoVoicesTitle(Object language) {
    return 'No $language voices installed';
  }

  @override
  String settingsAudioSpeechNoVoicesBody(Object language) {
    return 'Download a $language voice from your phone’s speech settings to enable playback.';
  }

  @override
  String get settingsAudioSpeechOpenSystemSpeech => 'Open system speech';

  @override
  String get settingsAudioSpeechSpeechRateLabel => 'Speech rate';

  @override
  String get settingsAudioSpeechSpeechRateMinLabel => '0.3×';

  @override
  String get settingsAudioSpeechSpeechRateDefaultLabel => 'Default';

  @override
  String get settingsAudioSpeechSpeechRateMaxLabel => '0.7×';

  @override
  String get settingsAudioSpeechPitchLabel => 'Pitch';

  @override
  String get settingsAudioSpeechPitchMinLabel => '0.70';

  @override
  String get settingsAudioSpeechPitchDefaultLabel => '1.00';

  @override
  String get settingsAudioSpeechPitchMaxLabel => '1.50';

  @override
  String get settingsAudioSpeechVolumeLabel => 'Volume';

  @override
  String get settingsAudioSpeechVolumeMinLabel => '0%';

  @override
  String get settingsAudioSpeechVolumeMidLabel => '50%';

  @override
  String get settingsAudioSpeechVolumeMaxLabel => '100%';

  @override
  String settingsAudioSpeechRateValueLabel(String value) {
    return '$value×';
  }

  @override
  String settingsAudioSpeechVolumeValueLabel(String value) {
    return '$value%';
  }

  @override
  String settingsAudioSpeechResetVoiceSettings(Object language) {
    return 'Reset $language voice settings';
  }

  @override
  String get settingsAudioSpeechResetAction => 'Reset';

  @override
  String get settingsAudioSpeechPreviewSectionTitle => 'Preview';

  @override
  String get settingsAudioSpeechPreviewHint =>
      'A short safe phrase. Only the front of cards is spoken.';

  @override
  String get settingsAudioSpeechPreviewVoiceLabel => 'Preview voice';

  @override
  String get settingsAudioSpeechPlayingLabel => 'Playing… tap to stop';

  @override
  String get settingsAudioSpeechSupportedLanguagesTitle =>
      'About supported languages';

  @override
  String get settingsAudioSpeechSupportedLanguagesBody =>
      'MemoX currently speaks Korean and English. Other-language cards stay silent and never read the back.';

  @override
  String get settingsAudioSpeechChangesSavedText =>
      'Changes save automatically.';

  @override
  String get settingsAudioSpeechEngineUnavailableTitle =>
      'Text-to-speech is unavailable';

  @override
  String get settingsAudioSpeechEngineUnavailableBody =>
      'Install a TTS engine in your phone’s settings to enable voice playback.';

  @override
  String get settingsAudioSpeechOpenSystemSettings => 'Open system settings';

  @override
  String get settingsAboutMemoXTitle => 'About MemoX';

  @override
  String settingsAboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutMessage =>
      'MemoX keeps flashcard learning local-first, calm, and ready to back up when you choose.';

  @override
  String get settingsAboutLegalese => 'MemoX';

  @override
  String get errorUnexpected => 'Something went wrong.';

  @override
  String get foldersRenameTitle => 'Rename folder';

  @override
  String get foldersUpdatedMessage => 'Folder updated.';

  @override
  String get foldersMoveTitle => 'Move folder';

  @override
  String get foldersMoveRootTitle => 'Library root';

  @override
  String get foldersMoveRootSubtitle => 'Move this folder to root';

  @override
  String get foldersMovedMessage => 'Folder moved.';

  @override
  String get foldersDeletedMessage => 'Folder deleted.';

  @override
  String get folderDeleteDialogTitle => 'Delete this folder?';

  @override
  String get folderDeleteDialogReassurance =>
      'Cards in those decks move to \"Unsorted\" - nothing is permanently lost.';

  @override
  String get folderDeleteDialogConfirmLabel => 'Type to confirm';

  @override
  String get folderDeleteDialogDeleteButton => 'Delete folder';

  @override
  String folderDetailDeckMeta(int cardCount, String relativeTime) {
    return '$cardCount cards · last $relativeTime';
  }

  @override
  String get decksDeleteTitle => 'Delete deck';

  @override
  String get decksDeleteMessage =>
      'This will delete the entire deck and all flashcards inside it.';

  @override
  String get decksDeletedMessage => 'Deck deleted.';

  @override
  String get flashcardsActionsTitle => 'Flashcard actions';

  @override
  String get flashcardsSearchHint => 'Search flashcards';

  @override
  String get flashcardsEmptyTitle => 'No flashcards yet';

  @override
  String get flashcardsEmptyMessage =>
      'Add cards manually or import them into this deck.';

  @override
  String get flashcardsNoResultsTitle => 'No matching flashcards';

  @override
  String get flashcardsNoResultsMessage =>
      'No flashcards in this deck match your search.';

  @override
  String get flashcardsClearSearchAction => 'Clear';

  @override
  String get flashcardEditorTitle => 'New flashcard';

  @override
  String get flashcardEditorBreadcrumbFolder => 'Folder';

  @override
  String get flashcardEditorBreadcrumbDeck => 'Deck';

  @override
  String get flashcardEditorBreadcrumbCurrent => 'New card';

  @override
  String get flashcardEditorDestinationDeckLabel => 'Selected deck';

  @override
  String get flashcardEditorRequiredWord => 'Required';

  @override
  String get flashcardEditorFrontHeading => 'Front';

  @override
  String get flashcardEditorBackHeading => 'Back';

  @override
  String get flashcardEditorFrontPlaceholder => 'The term you want to remember';

  @override
  String get flashcardEditorBackPlaceholder =>
      'Add the meaning or translation.';

  @override
  String get flashcardEditorMoreFieldsLabel => 'Add details';

  @override
  String get flashcardEditorMoreFieldsSummary =>
      'example · hint · pronunciation';

  @override
  String get flashcardEditorExampleLabel => 'Example';

  @override
  String get flashcardEditorPronunciationLabel => 'Pronunciation';

  @override
  String get flashcardEditorHintLabel => 'Hint';

  @override
  String get flashcardEditorTagsLabel => 'TAGS';

  @override
  String get flashcardEditorTagsOptionalLabel => 'optional';

  @override
  String get flashcardEditorAddTagLabel => 'Add tag';

  @override
  String get flashcardEditorSaveCardLabel => 'Save card';

  @override
  String get flashcardEditorSaveHelperText =>
      'Front and back are required to save.';

  @override
  String get flashcardEditorSampleExample => '안녕하세요, 저는 민수입니다.';

  @override
  String get flashcardEditorSamplePronunciation => 'annyeonghaseyo';

  @override
  String get flashcardEditorSampleHint => 'Start with a casual greeting.';

  @override
  String get flashcardEditorFrontError => 'Front is required.';

  @override
  String get flashcardEditorBackError => 'Back is required.';

  @override
  String get flashcardEditorSaveFailedMessage =>
      'Couldn\'t save this flashcard. Try again.';

  @override
  String get flashcardsEditTitle => 'Edit card';

  @override
  String get flashcardsLoadErrorTitle => 'Couldn\'t load this card';

  @override
  String get flashcardsLoadErrorMessage =>
      'Your data is safe on this device. Try again in a moment.';

  @override
  String get flashcardsLoadErrorBackAction => 'Back to deck';

  @override
  String get flashcardsEditDangerZoneLabel => 'Danger zone';

  @override
  String get flashcardsEditSaveHelperText =>
      'Changes save to this device only.';

  @override
  String get flashcardsEditSaveFailedMessage =>
      'Couldn\'t save changes. Nothing was lost. Tap Save to try again.';

  @override
  String get flashcardsDeleteCardTitle => 'Delete this flashcard?';

  @override
  String flashcardsDeleteCardMessage(int reviewCount) {
    return 'Removes the card and its $reviewCount reviews of history. Other cards in this deck are unaffected.';
  }

  @override
  String get flashcardsDeleteCardAction => 'Delete card';

  @override
  String get flashcardsFieldTagsLabel => 'Tags';

  @override
  String get flashcardsTagsSheetTitle => 'Add tag';

  @override
  String get flashcardsTagsConfirmAction => 'Add';

  @override
  String get flashcardsSaveAndAddNextTooltip => 'Save and add another';

  @override
  String get flashcardsSavedMessage => 'Flashcard saved.';

  @override
  String get flashcardsSaveChanges => 'Save changes';

  @override
  String get flashcardsLearningContentChangedTitle =>
      'You changed the learning content.';

  @override
  String get flashcardsLearningContentChangedMessage =>
      'Keep existing progress or reset this card?';

  @override
  String get flashcardsKeepProgressAction => 'Keep';

  @override
  String get flashcardsResetProgressAction => 'Reset';

  @override
  String get flashcardsUpdatedMessage => 'Flashcard updated.';

  @override
  String get flashcardsCreatedMessage => 'Flashcard created.';

  @override
  String get flashcardsDiscardChangesTitle => 'Discard changes?';

  @override
  String get flashcardsDiscardChangesMessage =>
      'Your unsaved flashcard changes will be lost.';

  @override
  String get flashcardsDiscardChangesAction => 'Discard';

  @override
  String get flashcardsKeepEditingAction => 'Keep editing';

  @override
  String get studyEntryTitle => 'Study';

  @override
  String get studyEntryPreparingTitle => 'Preparing study session';

  @override
  String get studyEntryPreparingMessage =>
      'Validating scope and loading study state.';

  @override
  String get studyEntryResumeRequiredTitle =>
      'Study session already in progress';

  @override
  String get studyEntryResumeRequiredMessage =>
      'We found an existing study session for this scope. Choose how to continue.';

  @override
  String get studyEntryResumeRequiredHeader => 'Choose an action';

  @override
  String get studyEntryResumeRequiredResumeAction => 'Resume';

  @override
  String get studyEntryResumeRequiredStartOverAction => 'Start over';

  @override
  String get studyEntryResumeRequiredStartOverConfirmTitle =>
      'Start over and discard the current session?';

  @override
  String get studyEntryResumeRequiredStartOverConfirmMessage =>
      'This will cancel the existing session and create a new one for the same study scope.';

  @override
  String get studyEntryResumeRequiredStartOverConfirmAction => 'Start over';

  @override
  String get studyEntryResumeRequiredStartOverFailed =>
      'Couldn\'t start over. Try again.';

  @override
  String get studyEntryInvalidTitle => 'Can\'t open study';

  @override
  String get studyEntryInvalidMessage =>
      'The study route parameters are invalid.';

  @override
  String get studySessionTitle => 'Study session';

  @override
  String get studySessionGuessModeLabel => 'GUESS';

  @override
  String get studySessionGuessPromptLabel => 'What is this?';

  @override
  String studySessionGuessNextCardInLabel(String seconds) {
    return 'Next card in ${seconds}s';
  }

  @override
  String get studySessionGuessSkipAction => 'Skip to next card';

  @override
  String get studySessionGuessCorrectAnnouncement => 'Correct';

  @override
  String studySessionGuessWrongAnnouncement(String answer) {
    return 'Wrong. The answer was $answer.';
  }

  @override
  String studySessionGuessOptionSemanticsLabel(
    String letter,
    String title,
    String description,
  ) {
    return 'Option $letter: $title. $description';
  }

  @override
  String studySessionProgressLabel(int current, int total) {
    return '$current / $total';
  }

  @override
  String get studySessionFrontLabel => 'Front';

  @override
  String get studySessionBackLabel => 'Back';

  @override
  String get studySessionMeaningLabel => 'Meaning';

  @override
  String get studySessionSwipeHint => 'Swipe left for the next card';

  @override
  String get studySessionRecallModeLabel => 'RECALL';

  @override
  String studySessionRecallShowAnswerAction(int seconds) {
    return 'Show answer · ${seconds}s';
  }

  @override
  String get studySessionRecallTimeoutCaption => 'Time\'s up — grade yourself';

  @override
  String get studySessionEditCardAction => 'Edit this card';

  @override
  String get studySessionSpeakFrontAction => 'Speak front';

  @override
  String get studySessionFillModeLabel => 'FILL';

  @override
  String get studySessionFillHintAction => 'Hint';

  @override
  String get studySessionFillCheckAction => 'Check';

  @override
  String get studySessionFillMarkCorrectAction => 'Mark correct';

  @override
  String get studySessionFillTryAgainAction => 'Try again';

  @override
  String get studySessionFillSpeakCorrectAnswerAction => 'Speak correct answer';

  @override
  String get studySessionFillReadyToFinishMessage =>
      'All cards are answered. Finish the session to save your progress.';

  @override
  String studySessionFillCorrectAnnouncement(String front) {
    return 'Correct. $front.';
  }

  @override
  String studySessionFillWrongAnnouncement(String input, String front) {
    return 'Wrong. You typed $input. The answer is $front.';
  }

  @override
  String get studySessionBuryUntilTomorrowAction => 'Bury until tomorrow';

  @override
  String get studySessionSuspendAction => 'Suspend card';

  @override
  String get studySessionBurySuccessMessage => 'Card buried until tomorrow.';

  @override
  String get studySessionSuspendSuccessMessage => 'Card suspended.';

  @override
  String get studySessionCardActionFailedMessage =>
      'Couldn\'t update the card. Please try again.';

  @override
  String get studyPreviousAction => 'Previous';

  @override
  String get studySessionShowAction => 'Show answer';

  @override
  String get studySessionHideAction => 'Hide answer';

  @override
  String get studySessionSavingAnswerMessage => 'Saving your answer...';

  @override
  String get studySessionRecordFailedMessage =>
      'Couldn\'t save this answer. Please try again.';

  @override
  String get studySessionAllAnsweredMessage =>
      'All cards are answered. Finish the session to save your progress.';

  @override
  String get studySessionFinalizingMessage => 'Finalizing your session...';

  @override
  String get studySessionFinalizeFailedMessage =>
      'Couldn\'t finish this session. Please try again.';

  @override
  String get studySessionNotFoundTitle => 'Session not found';

  @override
  String get studySessionNotFoundMessage =>
      'This study session no longer exists.';

  @override
  String get studySessionLoadFailedTitle => 'Couldn\'t load session';

  @override
  String get studySessionLoadFailedMessage =>
      'Couldn\'t load this session. Please try again.';

  @override
  String get studySessionExitConfirmTitle => 'Leave this session?';

  @override
  String get studySessionExitConfirmMessage =>
      'Your progress is saved and you can resume later.';

  @override
  String get studySessionExitConfirmAction => 'Leave session';

  @override
  String get studySessionExitKeepStudyingAction => 'Keep studying';

  @override
  String get studyFinalizeAction => 'Finish session';

  @override
  String get studyResultTitle => 'Study result';

  @override
  String get studyResultCards => 'Cards';

  @override
  String get studyResultAnswered => 'Answered';

  @override
  String studyResultCardsCompleted(int completed, int total) {
    return '$completed of $total cards completed';
  }

  @override
  String get studyResultBackToLibraryAction => 'Back to Library';

  @override
  String get studyResultBackToHomeAction => 'Go to Home';

  @override
  String get studyResultCompleted => 'Completed';

  @override
  String get studyResultCancelled => 'Cancelled';

  @override
  String get studyResultFailedFinalize => 'Finalize failed. Retry when ready.';

  @override
  String get studyResultInProgress => 'In progress';

  @override
  String get studyResultDraft => 'Draft';

  @override
  String get studyResultBreakdownTitle => 'Results';

  @override
  String get studyResultPassed => 'Passed';

  @override
  String get studyResultForgot => 'Forgot';

  @override
  String get studyResultInvalidTitle => 'Can\'t open result';

  @override
  String get studyResultInvalidMessage =>
      'The study result route parameters are invalid.';

  @override
  String get studyResultNotCompleteTitle => 'Result unavailable';

  @override
  String studyResultNotCompleteMessageWithStatus(String status) {
    return 'This study session has not been completed yet. Current status: $status.';
  }

  @override
  String relativeTimeAgo(String unit, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    String _temp3 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    String _temp4 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    String _temp5 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    String _temp6 = intl.Intl.selectLogic(unit, {
      'justNow': 'just now',
      'minutes': '$_temp0',
      'hours': '$_temp1',
      'days': '$_temp2',
      'weeks': '$_temp3',
      'months': '$_temp4',
      'years': '$_temp5',
      'other': 'just now',
    });
    return '$_temp6';
  }

  @override
  String get studyForgotAction => 'Forgot';

  @override
  String get studyNextAction => 'Next';

  @override
  String get studyGotItAction => 'Got it';

  @override
  String get studyEmpty_deck_noCards_title => 'No flashcards in this deck';

  @override
  String get studyEmpty_deck_noCards_cta => 'Add flashcards';

  @override
  String get studyEmpty_deck_noDueCards_title => 'All caught up';

  @override
  String get studyEmpty_deck_noDueCards_cta => 'Study new instead';

  @override
  String get studyEmpty_folder_noCards_title => 'No cards in this folder';

  @override
  String get studyEmpty_folder_noCards_cta => 'Add a deck';

  @override
  String get studyEmpty_folder_noDueCards_title =>
      'All caught up for this folder';

  @override
  String get studyEmpty_folder_noDueCards_cta => 'Study new instead';

  @override
  String get studyEmpty_today_allDone_title => 'All done for today!';

  @override
  String get studyEmpty_today_allDone_message =>
      'Great work. Check back tomorrow for your next review.';

  @override
  String get studyEmpty_today_allDone_cta => 'Back to dashboard';

  @override
  String get studyEmpty_today_noContent_title =>
      'You haven\'t created any flashcards yet';

  @override
  String get studyEmpty_today_noContent_cta => 'Create your first deck';

  @override
  String studyEmptyNextDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'in $_temp0';
  }

  @override
  String studyEmptyNextDueInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return 'in $_temp0';
  }

  @override
  String get studyEmptyNextDueSoon => 'soon';

  @override
  String get studyEmpty_allBuried_title => 'All cards buried';

  @override
  String get studyEmpty_allBuried_message =>
      'You buried every card for now. They\'ll return tomorrow.';

  @override
  String get studyEmpty_allBuried_cta => 'Study new instead';

  @override
  String get studyEmpty_allSuspended_title => 'All cards suspended';

  @override
  String get studyEmpty_allSuspended_message =>
      'Resume some cards to study them again.';

  @override
  String get studyEmpty_allSuspended_cta => 'View flashcards';

  @override
  String get flashcardsImportTitle => 'Import flashcards';

  @override
  String get flashcardsImportRouteIntroMessage =>
      'Deck import V1 now supports CSV paste preview and transactional commit. File picker, Excel, and structured text stay deferred.';

  @override
  String get flashcardsImportMissingDeckMessage =>
      'This import route needs a deck ID. Go back and open import from a deck.';

  @override
  String get importSourceTitle => 'Import from';

  @override
  String get importCsvContentLabel => 'CSV content';

  @override
  String get importCsvHint => 'front,back';

  @override
  String get importCsvRulesText =>
      'Use front and back columns. Optional extra columns are ignored in V1.';

  @override
  String get importPreviewAction => 'Preview import';

  @override
  String importCommitCardsAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count cards',
      one: 'Import 1 card',
    );
    return '$_temp0';
  }

  @override
  String importSuccessMessage(int count) {
    return 'Imported $count flashcards.';
  }

  @override
  String get importValidationIssuesTitle => 'Validation issues';

  @override
  String get importValidationIssuesSubtitle =>
      'Fix every issue before importing.';

  @override
  String importValidationIssueLine(int line) {
    return 'Line $line';
  }

  @override
  String get importPreviewTitle => 'Preview';

  @override
  String importPreviewSubtitle(int count) {
    return '$count flashcards ready to create';
  }

  @override
  String importPreviewSummary(int valid, int invalid) {
    return '$valid valid · $invalid issues';
  }

  @override
  String get importPreviewRowsTitle => 'Valid rows';

  @override
  String get importPreviewCommitReadyMessage =>
      'Preview is clean. You can import these cards now.';

  @override
  String get importCommittingMessage => 'Importing cards...';

  @override
  String get importFailedMessage => 'Import failed. Try again.';

  @override
  String get importCsvEmptyMessage => 'Paste CSV content before previewing.';

  @override
  String get importCsvFrontAndBackRequiredMessage =>
      'Front and back are required.';

  @override
  String get importNothingTitle => 'Nothing to import';

  @override
  String get importNothingMessage =>
      'No valid rows or blocks were produced from the source.';

  @override
  String get sharedErrorTitle => 'Something went wrong';

  @override
  String get sharedStreakLabel => 'Streak';

  @override
  String get commonRetry => 'Retry';

  @override
  String get libraryFilterTooltip => 'Filters';

  @override
  String get librarySearchHint => 'Search folders';

  @override
  String get librarySearchClearTooltip => 'Clear search';

  @override
  String get librarySearchShortcutLabel => 'K';

  @override
  String get libraryNewFolderLabel => 'New folder';

  @override
  String get libraryLoadFailedTitle => 'Couldn\'t load your library';

  @override
  String get libraryLoadFailedMessage =>
      'Something went wrong while loading your folders.';

  @override
  String get libraryLoadingFoldersLabel => 'Loading folders';

  @override
  String get libraryEmptyTitle => 'Start your library';

  @override
  String get libraryEmptyMessage =>
      'Folders keep related decks together. Add one to organize your decks.';

  @override
  String get librarySearchNoResultsTitle => 'No folders found';

  @override
  String get librarySearchNoResultsMessage => 'No folder matches your search.';

  @override
  String get folderCreateDialogTitle => 'New folder';

  @override
  String get folderCreateDialogDescription => 'Group related decks together.';

  @override
  String get folderCreateFieldLabel => 'Folder name';

  @override
  String get folderCreateColorLabel => 'Color';

  @override
  String get folderCreateIconLabel => 'Icon';

  @override
  String get libraryFolderDuplicateError =>
      'A folder with this name already exists.';

  @override
  String get libraryCreateFolderError =>
      'Couldn\'t create the folder. Please try again.';

  @override
  String libraryFolderCountLabel(int count) {
    return '$count folders';
  }

  @override
  String libraryDueSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards due today',
      one: '1 card due today',
    );
    return '$_temp0';
  }

  @override
  String libraryDueSummarySubtitle(int folderCount, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      folderCount,
      locale: localeName,
      other: '$folderCount folders',
      one: '1 folder',
    );
    return 'Across $_temp0 · ~$minutes min';
  }

  @override
  String get librarySortRecentLabel => 'Recent';

  @override
  String libraryFolderDecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count decks',
      one: '1 deck',
      zero: 'No decks',
    );
    return '$_temp0';
  }

  @override
  String libraryFolderSubfoldersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subfolders',
      one: '1 subfolder',
      zero: 'No subfolders',
    );
    return '$_temp0';
  }

  @override
  String libraryFolderCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
      zero: 'No cards',
    );
    return '$_temp0';
  }

  @override
  String libraryFolderNewCount(int count) {
    return '$count new';
  }

  @override
  String libraryFolderDueCount(int count) {
    return '$count due';
  }

  @override
  String get libraryOverflowTooltip => 'Folder actions';

  @override
  String get folderDetailSearchHint => 'Search this folder';

  @override
  String get folderDetailSearchSheetTitle => 'Search this folder';

  @override
  String get folderDetailMasteryUnavailableLabel => 'Mastery unavailable';

  @override
  String get folderDetailStartStudyLabel => 'Start study';

  @override
  String get folderDetailSortSheetTitle => 'Sort folder';

  @override
  String get folderDetailSortManualLabel => 'Manual order';

  @override
  String get folderDetailSortNameLabel => 'Name';

  @override
  String get folderDetailSortNewestLabel => 'Newest';

  @override
  String get folderDetailSortLastStudiedLabel => 'Last studied';

  @override
  String get folderDetailMostDueLabel => 'Most due';

  @override
  String get folderDetailEmptyFolderChipLabel => 'Empty folder';

  @override
  String get folderDetailEmptyTitle => 'What goes in here?';

  @override
  String get folderDetailEmptyMessage =>
      'Add decks to study cards directly, or nest subfolders to keep things organized. Folders hold one or the other once you start.';

  @override
  String get folderDetailEmptyHint =>
      'Once this folder holds decks or subfolders, the other option moves into the overflow menu.';

  @override
  String folderDetailNoResultsTitle(String query) {
    return 'No items match \"$query\"';
  }

  @override
  String get folderDetailNoResultsMessage =>
      'Try a different spelling or clear the search to see everything.';

  @override
  String get folderNotFoundTitle => 'Folder not found';

  @override
  String get folderNotFoundMessage =>
      'This folder may have been moved or deleted.';

  @override
  String get folderEmptyLockedTitle => 'This folder is empty';

  @override
  String get folderEmptyLockedMessage => 'Use the button below to add to it.';

  @override
  String get folderUnlockedTitle => 'This folder is empty';

  @override
  String get folderUnlockedMessage => 'Choose how to fill it:';

  @override
  String get folderModeLockHint =>
      'A folder can hold subfolders or decks — not both.';

  @override
  String get folderNewSubfolderLabel => 'New subfolder';

  @override
  String get folderNewDeckLabel => 'New deck';

  @override
  String folderDeleteDialogRemovalMessage(String summaryText) {
    return ' and its $summaryText will be removed from your library.';
  }

  @override
  String get subfolderCreateDialogTitle => 'New subfolder';

  @override
  String get subfolderCreateFieldLabel => 'Subfolder name';

  @override
  String get deckCreateDialogTitle => 'New deck';

  @override
  String get deckCreateFieldLabel => 'Deck name';

  @override
  String get folderRenameDialogDescription =>
      'Only the folder name changes — every deck and card inside stays put.';

  @override
  String get folderRenameDialogFieldLabel => 'New name';

  @override
  String folderRenameDialogHelper(String summary) {
    return '$summary will keep this folder as their home.';
  }

  @override
  String get folderDeckDuplicateError =>
      'A deck with this name already exists.';

  @override
  String get folderChildCreateError =>
      'Couldn\'t create that. Please try again.';

  @override
  String get libraryFolderActionsRename => 'Rename';

  @override
  String get libraryFolderActionsMove => 'Move to folder';

  @override
  String get libraryFolderActionsImport => 'Import flashcards';

  @override
  String get libraryFolderActionsDelete => 'Delete folder';

  @override
  String get libraryFolderActionError =>
      'Couldn\'t complete that action. Please try again.';

  @override
  String get folderMovePickerSearchHint => 'Search folders';

  @override
  String get folderMovePickerCycleReason =>
      'Can\'t move a folder into itself or its subfolders.';

  @override
  String get folderMovePickerLockedReason =>
      'Locked to decks — can\'t hold folders.';

  @override
  String get folderSummaryAllCaughtUp => 'All caught up';

  @override
  String get folderSummarySubfoldersStat => 'subfolders';

  @override
  String get folderSummaryCardsStat => 'cards';

  @override
  String get folderSummaryDueStat => 'due total';

  @override
  String get searchFieldHint => 'Search folders, decks, cards';

  @override
  String get searchClearTooltip => 'Clear search';

  @override
  String get searchEmptyTitle => 'Search your library';

  @override
  String get searchEmptyMessage =>
      'Type at least 2 characters to find folders, decks, and cards.';

  @override
  String get searchNoResultsTitle => 'No results';

  @override
  String get searchNoResultsMessage =>
      'Nothing in your library matches that search.';

  @override
  String get searchErrorTitle => 'Search failed';

  @override
  String get searchErrorMessage =>
      'Something went wrong while searching. Please try again.';

  @override
  String get searchRetryLabel => 'Try again';

  @override
  String get searchSectionFolders => 'Folders';

  @override
  String get searchSectionDecks => 'Decks';

  @override
  String get searchSectionFlashcards => 'Flashcards';

  @override
  String get searchResultFolderSubtitle => 'Folder';

  @override
  String get searchResultDeckSubtitle => 'Deck';

  @override
  String searchMoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count more',
      one: '+1 more',
    );
    return '$_temp0';
  }

  @override
  String get commonDone => 'Done';

  @override
  String get flashcardListAddCardAction => 'Add flashcard';

  @override
  String get flashcardListErrorTitle => 'Deck unavailable';

  @override
  String get flashcardListErrorMessage =>
      'We couldn\'t open this deck. Please try again.';

  @override
  String get flashcardListActionError =>
      'Something went wrong. Please try again.';

  @override
  String flashcardListSubtitle(int count, String language) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards · $language',
      one: '1 card · $language',
    );
    return '$_temp0';
  }

  @override
  String get flashcardListLanguageKorean => 'Korean';

  @override
  String get flashcardListLanguageEnglish => 'English';

  @override
  String get flashcardListLanguageOther => 'Other language';

  @override
  String get flashcardDeckReorderAction => 'Reorder cards';

  @override
  String get flashcardDeleteOneTitle => 'Delete this flashcard?';

  @override
  String get flashcardDeleteOneMessage =>
      'Review history for this card will be removed. Other cards in this deck are unaffected.';

  @override
  String get flashcardDeletedOneMessage => 'Flashcard deleted.';

  @override
  String get flashcardReorderError => 'Couldn\'t save the new order.';

  @override
  String get progressRangeWeek => 'Week';

  @override
  String get progressRangeMonth => 'Month';

  @override
  String get progressRangeAllTime => 'All time';

  @override
  String get progressCardsStudiedTitle => 'Cards studied';

  @override
  String get progressCardsStudiedCaptionWeek => 'over the past 7 days';

  @override
  String get progressCardsStudiedCaptionMonth => 'over the past 28 days';

  @override
  String get progressCardsStudiedCaptionAllTime => 'all time';

  @override
  String get progressAccuracyTitle => 'Accuracy';

  @override
  String get progressVsPreviousWeek => 'vs previous week';

  @override
  String get progressVsPreviousMonth => 'vs previous month';

  @override
  String get progressBoxDistributionTitle => 'Box distribution';

  @override
  String get progressBoxTotalCaption => 'total cards across boxes';

  @override
  String progressBoxLabel(int box) {
    return 'B$box';
  }

  @override
  String get progressBoxLegendLeast => 'B1 · least known';

  @override
  String get progressBoxLegendBest => 'B8 · best known';

  @override
  String get progressStreakTitle => 'Streak';

  @override
  String get progressStreakCurrent => 'Current';

  @override
  String get progressStreakLongest => 'Longest';

  @override
  String progressStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get progressCardStatesTitle => 'Card states';

  @override
  String get progressSuspendedTitle => 'Suspended';

  @override
  String get progressSuspendedSubtitle =>
      'Out of rotation until you resume them';

  @override
  String get progressSuspendedCaption => 'in your library';

  @override
  String get progressBuriedTitle => 'Buried today';

  @override
  String get progressBuriedSubtitle => 'Skipped until tomorrow';

  @override
  String get progressBuriedCaption => 'today only';

  @override
  String get progressFooterWeek => 'Read-only summary · last 7 days';

  @override
  String get progressFooterMonth => 'Read-only summary · last 28 days';

  @override
  String get progressFooterAllTime => 'Read-only summary · all time';

  @override
  String get progressChartEmptyHint =>
      'No study sessions in this range yet. Start any deck to begin tracking trends.';

  @override
  String progressChartInsufficientHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Only $count days of data so far.',
      one: 'Only 1 day of data so far.',
    );
    return '$_temp0';
  }

  @override
  String progressTrendBanner(int days) {
    return 'Trend appears after $days days of data.';
  }

  @override
  String get progressAccuracyEmptyHint =>
      'Accuracy appears once you\'ve answered cards.';

  @override
  String get progressBoxEmptyHint =>
      'Cards spread across boxes as you study them.';

  @override
  String get progressStreakEmptyHint =>
      'A streak starts after one study session.';

  @override
  String get progressErrorTitle => 'Couldn\'t summarise your progress';

  @override
  String get progressErrorMessage =>
      'Your study history is safe on this device. Try again in a moment.';

  @override
  String flashcardListCountHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count CARDS',
      one: '1 CARD',
    );
    return '$_temp0';
  }

  @override
  String flashcardListReorderHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count CARDS · DRAG TO REORDER',
      one: '1 CARD · DRAG TO REORDER',
    );
    return '$_temp0';
  }

  @override
  String get flashcardsEmptyAddFirstAction => 'Add first flashcard';

  @override
  String get flashcardsEmptyImportAction => 'Import cards (CSV, TSV, Anki)';

  @override
  String get flashcardEditorSavingLabel => 'Saving…';

  @override
  String get flashcardEditorSavingHelperText => 'Saving to this device…';

  @override
  String get flashcardEditorRetrySaveLabel => 'Retry save';

  @override
  String get flashcardEditorOptionalDetailsHeading => 'Optional details';

  @override
  String flashcardsEditMeta(int reviewCount, String relativeTime) {
    String _temp0 = intl.Intl.pluralLogic(
      reviewCount,
      locale: localeName,
      other: 'Last edited $relativeTime · $reviewCount reviews',
      one: 'Last edited $relativeTime · 1 review',
      zero: 'Last edited $relativeTime',
    );
    return '$_temp0';
  }

  @override
  String get cardHistoryTitle => 'Card history';

  @override
  String get cardHistoryStateSuspended => 'Suspended';

  @override
  String relativeTimeUntil(String unit, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count minutes',
      one: 'in 1 minute',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count hours',
      one: 'in 1 hour',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'in 1 day',
    );
    String _temp3 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count weeks',
      one: 'in 1 week',
    );
    String _temp4 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count months',
      one: 'in 1 month',
    );
    String _temp5 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count years',
      one: 'in 1 year',
    );
    String _temp6 = intl.Intl.selectLogic(unit, {
      'justNow': 'now',
      'minutes': '$_temp0',
      'hours': '$_temp1',
      'days': '$_temp2',
      'weeks': '$_temp3',
      'months': '$_temp4',
      'years': '$_temp5',
      'other': 'now',
    });
    return '$_temp6';
  }

  @override
  String cardHistoryResetSubLabel(String date) {
    return 'Includes attempts before last reset on $date.';
  }

  @override
  String get cardHistoryResultPerfect => 'Perfect';

  @override
  String get cardHistoryResultPassed => 'Passed';

  @override
  String get cardHistoryResultRecovered => 'Recovered';

  @override
  String get cardHistoryResultForgot => 'Forgot';

  @override
  String get cardHistoryBoxUnknown => '—';

  @override
  String cardHistoryModeLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'review': 'Review',
      'match': 'Match',
      'guess': 'Guess',
      'recall': 'Recall',
      'fill': 'Fill',
      'other': 'Study',
    });
    return 'Mode: $_temp0';
  }

  @override
  String get cardHistoryEmptyTitle => 'No reviews yet';

  @override
  String get cardHistoryEmptyMessage =>
      'History appears here after you study this card.';

  @override
  String get cardHistoryEmptyAction => 'Study this card now';

  @override
  String get cardHistoryErrorTitle => 'Couldn\'t load history';

  @override
  String get cardHistoryErrorMessage =>
      'Your data is safe on this device. Try again in a moment.';

  @override
  String get cardHistoryNotFoundTitle => 'Card no longer exists';

  @override
  String get cardHistoryNotFoundMessage => 'This flashcard has been deleted.';

  @override
  String get cardHistoryResetAction => 'Reset progress';

  @override
  String get cardHistoryResetConfirmTitle => 'Reset progress?';

  @override
  String get cardHistoryResetConfirmMessage =>
      'Attempts history is kept; only SRS state is reset.';

  @override
  String get cardHistoryResetDoneMessage => 'Progress reset';

  @override
  String get cardHistoryActionError => 'Something went wrong. Try again.';

  @override
  String get cardHistoryViewAction => 'View history';

  @override
  String get cardHistoryBreadcrumbCurrent => 'History';

  @override
  String cardHistoryBoxChip(int box, int total) {
    return 'Box $box / $total';
  }

  @override
  String get cardHistoryProgressTitle => 'Current progress';

  @override
  String cardHistoryBoxStepLabel(int box) {
    return 'Box $box';
  }

  @override
  String get cardHistoryStatDue => 'Due';

  @override
  String get cardHistoryStatReviews => 'Reviews';

  @override
  String get cardHistoryStatRecall => 'Recall rate';

  @override
  String get cardHistoryStatLapses => 'Lapses';

  @override
  String get cardHistoryStatStreak => 'Correct streak';

  @override
  String get cardHistoryStatSinceAdded => 'Since added';

  @override
  String cardHistoryPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String cardHistoryStreakValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in a row',
      one: '1 in a row',
    );
    return '$_temp0';
  }

  @override
  String cardHistorySinceAddedValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String cardHistoryTimelineHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Timeline · $count events',
      one: 'Timeline · 1 event',
    );
    return '$_temp0';
  }

  @override
  String get cardHistoryChipCorrect => 'Correct';

  @override
  String get cardHistoryChipRecovered => 'Recovered';

  @override
  String get cardHistoryChipForgot => 'Forgot';

  @override
  String get cardHistoryDescCorrect => 'Answered correctly';

  @override
  String get cardHistoryDescRecovered => 'Got it back after a slip';

  @override
  String get cardHistoryDescForgot => 'Couldn’t recall — reset to box 1';

  @override
  String get cardHistoryPartialDescription => 'Logged with missing details';

  @override
  String cardHistoryDurationValue(String seconds) {
    return '${seconds}s';
  }

  @override
  String get cardHistoryDurationMissing => 'duration not logged';

  @override
  String get cardHistoryEventCreatedChip => 'Created';

  @override
  String get cardHistoryEventEditedChip => 'Edited';

  @override
  String get cardHistoryEventAudioChip => 'Audio added';

  @override
  String cardHistoryEventCreatedDescription(String deck) {
    return 'Card added to $deck';
  }

  @override
  String get cardHistoryEventEditedDescription => 'Card edited';

  @override
  String get cardHistoryEventAudioDescription => 'Pronunciation recorded';

  @override
  String get cardHistoryEventResetChip => 'Reset';

  @override
  String get cardHistoryEventResetDescription => 'Progress reset to box 1';

  @override
  String get cardHistoryBeginning => 'Beginning of history';

  @override
  String get cardHistoryFilterSheetTitle => 'Filter timeline';

  @override
  String get cardHistoryFilterAll => 'All events';

  @override
  String get cardHistoryFilterReviews => 'Reviews only';

  @override
  String get cardHistoryFilterLifecycle => 'Card changes';
}
