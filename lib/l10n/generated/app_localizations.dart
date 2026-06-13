import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MemoX'**
  String get appName;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get commonRename;

  /// No description provided for @commonImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get commonImport;

  /// No description provided for @commonMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get commonMove;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @dashboardGreetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Good evening, learner'**
  String get dashboardGreetingTitle;

  /// No description provided for @dashboardGreetingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to study today?'**
  String get dashboardGreetingSubtitle;

  /// No description provided for @dashboardTodayReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Today Review'**
  String get dashboardTodayReviewTitle;

  /// No description provided for @dashboardNewStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'New Study'**
  String get dashboardNewStudyTitle;

  /// No description provided for @dashboardNewStudyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add or import cards before starting a new study session.'**
  String get dashboardNewStudyEmptyMessage;

  /// No description provided for @dashboardContinueSessionAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get dashboardContinueSessionAction;

  /// No description provided for @dashboardResumeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue studying'**
  String get dashboardResumeSectionTitle;

  /// No description provided for @dashboardStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String dashboardStreakDays(int count);

  /// No description provided for @dashboardDueTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dashboardDueTodayTitle;

  /// No description provided for @dashboardDueTodayMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} cards ready to review'**
  String dashboardDueTodayMessage(int count);

  /// No description provided for @dashboardNoDueTitle.
  ///
  /// In en, this message translates to:
  /// **'No cards due now'**
  String get dashboardNoDueTitle;

  /// No description provided for @dashboardNoDueMessage.
  ///
  /// In en, this message translates to:
  /// **'Open your library to add cards or start a focused deck session.'**
  String get dashboardNoDueMessage;

  /// No description provided for @dashboardStudyTodayAction.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get dashboardStudyTodayAction;

  /// No description provided for @dashboardOpenLibraryAction.
  ///
  /// In en, this message translates to:
  /// **'View library'**
  String get dashboardOpenLibraryAction;

  /// No description provided for @progressEntryDeck.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get progressEntryDeck;

  /// No description provided for @progressEntryFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get progressEntryFolder;

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsStudySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get settingsStudySectionTitle;

  /// No description provided for @settingsAppSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsAppSectionTitle;

  /// No description provided for @settingsAboutSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSectionTitle;

  /// No description provided for @settingsOverviewFooter.
  ///
  /// In en, this message translates to:
  /// **'Made for calm learning · MemoX'**
  String get settingsOverviewFooter;

  /// No description provided for @settingsAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountTitle;

  /// No description provided for @settingsAccountLinkedOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Account & sync'**
  String get settingsAccountLinkedOverviewTitle;

  /// No description provided for @settingsAccountSignInSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in & sync'**
  String get settingsAccountSignInSyncTitle;

  /// No description provided for @settingsAccountSignInSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your progress across devices'**
  String get settingsAccountSignInSyncSubtitle;

  /// No description provided for @settingsAccountSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get settingsAccountSigningIn;

  /// No description provided for @settingsAccountOverviewSyncedMockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{email} · synced 2 min ago'**
  String settingsAccountOverviewSyncedMockSubtitle(Object email);

  /// No description provided for @settingsAccountOverviewSyncErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{email} · last synced 2 days ago'**
  String settingsAccountOverviewSyncErrorSubtitle(Object email);

  /// No description provided for @settingsOverviewSyncRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get settingsOverviewSyncRetry;

  /// No description provided for @settingsAppearanceOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light, dark, system'**
  String get settingsAppearanceOverviewSubtitle;

  /// No description provided for @settingsSoonChip.
  ///
  /// In en, this message translates to:
  /// **'SOON'**
  String get settingsSoonChip;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageOverviewSubtitle;

  /// No description provided for @settingsLearningOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get settingsLearningOverviewTitle;

  /// No description provided for @settingsLearningDailyGoalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get settingsLearningDailyGoalSectionTitle;

  /// No description provided for @settingsLearningGoalToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a daily goal'**
  String get settingsLearningGoalToggleTitle;

  /// No description provided for @settingsLearningGoalToggleSubtitleOn.
  ///
  /// In en, this message translates to:
  /// **'Track how many cards you complete each day.'**
  String get settingsLearningGoalToggleSubtitleOn;

  /// No description provided for @settingsLearningGoalToggleSubtitleOff.
  ///
  /// In en, this message translates to:
  /// **'Pause goal tracking without losing your streak.'**
  String get settingsLearningGoalToggleSubtitleOff;

  /// No description provided for @settingsLearningGoalOffHint.
  ///
  /// In en, this message translates to:
  /// **'Goal is off. Your streak is frozen — it won’t reset while paused.'**
  String get settingsLearningGoalOffHint;

  /// No description provided for @settingsLearningCardsPerDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Cards per day'**
  String get settingsLearningCardsPerDayLabel;

  /// No description provided for @settingsLearningDragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to adjust in steps of 5'**
  String get settingsLearningDragHint;

  /// No description provided for @settingsLearningStreakToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Show streak counter'**
  String get settingsLearningStreakToggleTitle;

  /// No description provided for @settingsLearningStreakToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display your current streak on Home and Stats.'**
  String get settingsLearningStreakToggleSubtitle;

  /// No description provided for @settingsLearningReminderSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get settingsLearningReminderSectionTitle;

  /// No description provided for @settingsLearningReminderHint.
  ///
  /// In en, this message translates to:
  /// **'A gentle nudge once a day. Off by default.'**
  String get settingsLearningReminderHint;

  /// No description provided for @settingsLearningReminderToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get settingsLearningReminderToggleTitle;

  /// No description provided for @settingsLearningReminderToggleSubtitleOn.
  ///
  /// In en, this message translates to:
  /// **'Nudge me to study every day.'**
  String get settingsLearningReminderToggleSubtitleOn;

  /// No description provided for @settingsLearningReminderToggleSubtitleOff.
  ///
  /// In en, this message translates to:
  /// **'You decide when to come back.'**
  String get settingsLearningReminderToggleSubtitleOff;

  /// No description provided for @settingsLearningReminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsLearningReminderTimeLabel;

  /// No description provided for @settingsLearningReminderTimeValue.
  ///
  /// In en, this message translates to:
  /// **'20:00'**
  String get settingsLearningReminderTimeValue;

  /// No description provided for @settingsLearningNotificationsBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked'**
  String get settingsLearningNotificationsBlockedTitle;

  /// No description provided for @settingsLearningNotificationsBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Allow MemoX in your phone’s notification settings to receive the reminder.'**
  String get settingsLearningNotificationsBlockedBody;

  /// No description provided for @settingsLearningOpenSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get settingsLearningOpenSystemSettings;

  /// No description provided for @settingsLearningTagsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get settingsLearningTagsSectionTitle;

  /// No description provided for @settingsLearningTagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} tags across all decks'**
  String settingsLearningTagsSubtitle(int count);

  /// No description provided for @settingsLearningFutureStudyDefaultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Study defaults'**
  String get settingsLearningFutureStudyDefaultsTitle;

  /// No description provided for @settingsLearningFutureStudyDefaultsHint.
  ///
  /// In en, this message translates to:
  /// **'Available in a future update.'**
  String get settingsLearningFutureStudyDefaultsHint;

  /// No description provided for @settingsLearningFutureDefaultShuffleTitle.
  ///
  /// In en, this message translates to:
  /// **'Default shuffle'**
  String get settingsLearningFutureDefaultShuffleTitle;

  /// No description provided for @settingsLearningFutureDefaultShuffleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Randomize card order in every session'**
  String get settingsLearningFutureDefaultShuffleSubtitle;

  /// No description provided for @settingsLearningFutureDefaultStudyModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Default study mode'**
  String get settingsLearningFutureDefaultStudyModeTitle;

  /// No description provided for @settingsLearningFutureDefaultStudyModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review, Match, Guess, Recall, or Fill'**
  String get settingsLearningFutureDefaultStudyModeSubtitle;

  /// No description provided for @settingsLearningFutureExampleSentenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Show example sentence'**
  String get settingsLearningFutureExampleSentenceTitle;

  /// No description provided for @settingsLearningFutureExampleSentenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reveal the example with the meaning'**
  String get settingsLearningFutureExampleSentenceSubtitle;

  /// No description provided for @settingsLearningSavedChip.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get settingsLearningSavedChip;

  /// No description provided for @settingsLearningOverviewSummary.
  ///
  /// In en, this message translates to:
  /// **'20 cards / day · 5 study modes'**
  String get settingsLearningOverviewSummary;

  /// No description provided for @settingsCardsCountValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String settingsCardsCountValue(int count);

  /// No description provided for @settingsManageTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage tags'**
  String get settingsManageTagsTitle;

  /// No description provided for @settingsManageTagsOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'14 tags'**
  String get settingsManageTagsOverviewSubtitle;

  /// No description provided for @tagHashLabel.
  ///
  /// In en, this message translates to:
  /// **'#{tag}'**
  String tagHashLabel(String tag);

  /// No description provided for @settingsTagsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tags'**
  String get settingsTagsSearchHint;

  /// No description provided for @settingsTagsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tag} other{{count} tags}}'**
  String settingsTagsCount(int count);

  /// No description provided for @settingsTagsCardCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String settingsTagsCardCount(int count);

  /// No description provided for @settingsTagsSortMostCards.
  ///
  /// In en, this message translates to:
  /// **'Most cards'**
  String get settingsTagsSortMostCards;

  /// No description provided for @settingsTagsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get settingsTagsEmptyTitle;

  /// No description provided for @settingsTagsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tags are added when you create or edit flashcards. Open a card to add your first tag.'**
  String get settingsTagsEmptyMessage;

  /// No description provided for @settingsTagsEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Go to library'**
  String get settingsTagsEmptyAction;

  /// No description provided for @settingsTagsSearchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching tags'**
  String get settingsTagsSearchEmptyTitle;

  /// No description provided for @settingsTagsSearchEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No tags match your search.'**
  String get settingsTagsSearchEmptyMessage;

  /// No description provided for @settingsTagsActionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get settingsTagsActionRename;

  /// No description provided for @settingsTagsActionMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge into another tag'**
  String get settingsTagsActionMerge;

  /// No description provided for @settingsTagsActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete tag (keeps cards)'**
  String get settingsTagsActionDelete;

  /// No description provided for @settingsTagsContextSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Tag actions'**
  String get settingsTagsContextSheetTitle;

  /// No description provided for @settingsTagsMostUsedBadge.
  ///
  /// In en, this message translates to:
  /// **'Most used'**
  String get settingsTagsMostUsedBadge;

  /// No description provided for @settingsTagsRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename tag'**
  String get settingsTagsRenameTitle;

  /// No description provided for @settingsTagsRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a new name'**
  String get settingsTagsRenameHint;

  /// No description provided for @settingsTagsRenameConfirm.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get settingsTagsRenameConfirm;

  /// No description provided for @settingsTagsRenameHelper.
  ///
  /// In en, this message translates to:
  /// **'Renaming updates every card that uses {tag}.'**
  String settingsTagsRenameHelper(String tag);

  /// No description provided for @settingsTagsRenameConflictMessage.
  ///
  /// In en, this message translates to:
  /// **'A tag called {tag} already exists. Continuing will merge these two tags.'**
  String settingsTagsRenameConflictMessage(String tag);

  /// No description provided for @settingsTagsMergeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge \"{source}\" into…'**
  String settingsTagsMergeSheetTitle(String source);

  /// No description provided for @settingsTagsMergeSheetHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the destination tag.'**
  String get settingsTagsMergeSheetHint;

  /// No description provided for @settingsTagsMergeSheetSummary.
  ///
  /// In en, this message translates to:
  /// **'All {count} cards tagged {source} will be re-tagged with the destination tag. The tag {source} will be deleted.'**
  String settingsTagsMergeSheetSummary(int count, String source);

  /// No description provided for @settingsTagsMergeSuggestedSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get settingsTagsMergeSuggestedSectionTitle;

  /// No description provided for @settingsTagsMergeAllTagsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'All tags'**
  String get settingsTagsMergeAllTagsSectionTitle;

  /// No description provided for @settingsTagsMergeConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get settingsTagsMergeConfirmAction;

  /// No description provided for @settingsTagsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete tag?'**
  String get settingsTagsDeleteTitle;

  /// No description provided for @settingsTagsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{tag}\"? This removes the tag from {count, plural, =1{1 card} other{{count} cards}}. Cards are not deleted.'**
  String settingsTagsDeleteMessage(String tag, int count);

  /// No description provided for @settingsTagsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsTagsDeleteConfirm;

  /// No description provided for @settingsTagsOpErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t rename tag'**
  String get settingsTagsOpErrorTitle;

  /// No description provided for @settingsTagsOpErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing changed. Try again in a moment.'**
  String get settingsTagsOpErrorBody;

  /// No description provided for @settingsTagsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get settingsTagsRetry;

  /// No description provided for @flashcardsTagErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tag name is required.'**
  String get flashcardsTagErrorEmpty;

  /// No description provided for @flashcardsTagErrorComma.
  ///
  /// In en, this message translates to:
  /// **'Tags cannot contain commas.'**
  String get flashcardsTagErrorComma;

  /// No description provided for @flashcardsTagErrorTooLong.
  ///
  /// In en, this message translates to:
  /// **'Tag too long (max 50 chars).'**
  String get flashcardsTagErrorTooLong;

  /// No description provided for @settingsAudioSpeechTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio & speech'**
  String get settingsAudioSpeechTitle;

  /// No description provided for @settingsAudioSpeechOverviewSummary.
  ///
  /// In en, this message translates to:
  /// **'Korean voice · 0.9× speed'**
  String get settingsAudioSpeechOverviewSummary;

  /// No description provided for @settingsAudioSpeechSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get settingsAudioSpeechSaved;

  /// No description provided for @settingsAudioSpeechGeneralSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsAudioSpeechGeneralSectionTitle;

  /// No description provided for @settingsAudioSpeechAutoPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-play on reveal'**
  String get settingsAudioSpeechAutoPlayTitle;

  /// No description provided for @settingsAudioSpeechAutoPlaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak the front when a new card appears.'**
  String get settingsAudioSpeechAutoPlaySubtitle;

  /// No description provided for @settingsAudioSpeechPlayAfterGradingTitle.
  ///
  /// In en, this message translates to:
  /// **'Play after grading'**
  String get settingsAudioSpeechPlayAfterGradingTitle;

  /// No description provided for @settingsAudioSpeechPlayAfterGradingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replay the term after you rate the card.'**
  String get settingsAudioSpeechPlayAfterGradingSubtitle;

  /// No description provided for @settingsAudioSpeechLanguageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsAudioSpeechLanguageSectionTitle;

  /// No description provided for @settingsAudioSpeechKoreanTabFlag.
  ///
  /// In en, this message translates to:
  /// **'한'**
  String get settingsAudioSpeechKoreanTabFlag;

  /// No description provided for @settingsAudioSpeechKoreanTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get settingsAudioSpeechKoreanTabLabel;

  /// No description provided for @settingsAudioSpeechEnglishTabFlag.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get settingsAudioSpeechEnglishTabFlag;

  /// No description provided for @settingsAudioSpeechEnglishTabLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsAudioSpeechEnglishTabLabel;

  /// No description provided for @settingsAudioSpeechVoiceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice · {language}'**
  String settingsAudioSpeechVoiceSectionTitle(Object language);

  /// No description provided for @settingsAudioSpeechKoreanLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get settingsAudioSpeechKoreanLanguageLabel;

  /// No description provided for @settingsAudioSpeechEnglishLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsAudioSpeechEnglishLanguageLabel;

  /// No description provided for @settingsAudioSpeechKoreanSampleText.
  ///
  /// In en, this message translates to:
  /// **'오늘도 한 단어 더 외워봐요.'**
  String get settingsAudioSpeechKoreanSampleText;

  /// No description provided for @settingsAudioSpeechKoreanSampleHint.
  ///
  /// In en, this message translates to:
  /// **'Today, let’s remember one more word.'**
  String get settingsAudioSpeechKoreanSampleHint;

  /// No description provided for @settingsAudioSpeechEnglishSampleText.
  ///
  /// In en, this message translates to:
  /// **'One word a day keeps forgetting away.'**
  String get settingsAudioSpeechEnglishSampleText;

  /// No description provided for @settingsAudioSpeechKoreanSystemVoiceName.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsAudioSpeechKoreanSystemVoiceName;

  /// No description provided for @settingsAudioSpeechKoreanSystemVoiceMeta.
  ///
  /// In en, this message translates to:
  /// **'Uses your phone’s default Korean voice'**
  String get settingsAudioSpeechKoreanSystemVoiceMeta;

  /// No description provided for @settingsAudioSpeechKoreanSujiVoiceName.
  ///
  /// In en, this message translates to:
  /// **'Suji'**
  String get settingsAudioSpeechKoreanSujiVoiceName;

  /// No description provided for @settingsAudioSpeechKoreanSujiVoiceMeta.
  ///
  /// In en, this message translates to:
  /// **'Female · neural · offline'**
  String get settingsAudioSpeechKoreanSujiVoiceMeta;

  /// No description provided for @settingsAudioSpeechKoreanMinhoVoiceName.
  ///
  /// In en, this message translates to:
  /// **'Minho'**
  String get settingsAudioSpeechKoreanMinhoVoiceName;

  /// No description provided for @settingsAudioSpeechKoreanMinhoVoiceMeta.
  ///
  /// In en, this message translates to:
  /// **'Male · neural · offline'**
  String get settingsAudioSpeechKoreanMinhoVoiceMeta;

  /// No description provided for @settingsAudioSpeechKoreanEunhaVoiceName.
  ///
  /// In en, this message translates to:
  /// **'Eunha'**
  String get settingsAudioSpeechKoreanEunhaVoiceName;

  /// No description provided for @settingsAudioSpeechKoreanEunhaVoiceMeta.
  ///
  /// In en, this message translates to:
  /// **'Female · standard'**
  String get settingsAudioSpeechKoreanEunhaVoiceMeta;

  /// No description provided for @settingsAudioSpeechEnglishSystemVoiceName.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsAudioSpeechEnglishSystemVoiceName;

  /// No description provided for @settingsAudioSpeechEnglishSystemVoiceMeta.
  ///
  /// In en, this message translates to:
  /// **'Uses your phone’s default English voice'**
  String get settingsAudioSpeechEnglishSystemVoiceMeta;

  /// No description provided for @settingsAudioSpeechEnglishEmmaVoiceName.
  ///
  /// In en, this message translates to:
  /// **'Emma'**
  String get settingsAudioSpeechEnglishEmmaVoiceName;

  /// No description provided for @settingsAudioSpeechEnglishEmmaVoiceMeta.
  ///
  /// In en, this message translates to:
  /// **'Female · neural · offline'**
  String get settingsAudioSpeechEnglishEmmaVoiceMeta;

  /// No description provided for @settingsAudioSpeechEnglishRyanVoiceName.
  ///
  /// In en, this message translates to:
  /// **'Ryan'**
  String get settingsAudioSpeechEnglishRyanVoiceName;

  /// No description provided for @settingsAudioSpeechEnglishRyanVoiceMeta.
  ///
  /// In en, this message translates to:
  /// **'Male · neural · offline'**
  String get settingsAudioSpeechEnglishRyanVoiceMeta;

  /// No description provided for @settingsAudioSpeechDefaultVoiceBadge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingsAudioSpeechDefaultVoiceBadge;

  /// No description provided for @settingsAudioSpeechNoVoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'No {language} voices installed'**
  String settingsAudioSpeechNoVoicesTitle(Object language);

  /// No description provided for @settingsAudioSpeechNoVoicesBody.
  ///
  /// In en, this message translates to:
  /// **'Download a {language} voice from your phone’s speech settings to enable playback.'**
  String settingsAudioSpeechNoVoicesBody(Object language);

  /// No description provided for @settingsAudioSpeechOpenSystemSpeech.
  ///
  /// In en, this message translates to:
  /// **'Open system speech'**
  String get settingsAudioSpeechOpenSystemSpeech;

  /// No description provided for @settingsAudioSpeechSpeechRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Speech rate'**
  String get settingsAudioSpeechSpeechRateLabel;

  /// No description provided for @settingsAudioSpeechSpeechRateMinLabel.
  ///
  /// In en, this message translates to:
  /// **'0.3×'**
  String get settingsAudioSpeechSpeechRateMinLabel;

  /// No description provided for @settingsAudioSpeechSpeechRateDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingsAudioSpeechSpeechRateDefaultLabel;

  /// No description provided for @settingsAudioSpeechSpeechRateMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'0.7×'**
  String get settingsAudioSpeechSpeechRateMaxLabel;

  /// No description provided for @settingsAudioSpeechPitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get settingsAudioSpeechPitchLabel;

  /// No description provided for @settingsAudioSpeechPitchMinLabel.
  ///
  /// In en, this message translates to:
  /// **'0.70'**
  String get settingsAudioSpeechPitchMinLabel;

  /// No description provided for @settingsAudioSpeechPitchDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'1.00'**
  String get settingsAudioSpeechPitchDefaultLabel;

  /// No description provided for @settingsAudioSpeechPitchMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'1.50'**
  String get settingsAudioSpeechPitchMaxLabel;

  /// No description provided for @settingsAudioSpeechVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsAudioSpeechVolumeLabel;

  /// No description provided for @settingsAudioSpeechVolumeMinLabel.
  ///
  /// In en, this message translates to:
  /// **'0%'**
  String get settingsAudioSpeechVolumeMinLabel;

  /// No description provided for @settingsAudioSpeechVolumeMidLabel.
  ///
  /// In en, this message translates to:
  /// **'50%'**
  String get settingsAudioSpeechVolumeMidLabel;

  /// No description provided for @settingsAudioSpeechVolumeMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'100%'**
  String get settingsAudioSpeechVolumeMaxLabel;

  /// No description provided for @settingsAudioSpeechRateValueLabel.
  ///
  /// In en, this message translates to:
  /// **'{value}×'**
  String settingsAudioSpeechRateValueLabel(String value);

  /// No description provided for @settingsAudioSpeechVolumeValueLabel.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String settingsAudioSpeechVolumeValueLabel(String value);

  /// No description provided for @settingsAudioSpeechResetVoiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset {language} voice settings'**
  String settingsAudioSpeechResetVoiceSettings(Object language);

  /// No description provided for @settingsAudioSpeechResetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsAudioSpeechResetAction;

  /// No description provided for @settingsAudioSpeechPreviewSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get settingsAudioSpeechPreviewSectionTitle;

  /// No description provided for @settingsAudioSpeechPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'A short safe phrase. Only the front of cards is spoken.'**
  String get settingsAudioSpeechPreviewHint;

  /// No description provided for @settingsAudioSpeechPreviewVoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview voice'**
  String get settingsAudioSpeechPreviewVoiceLabel;

  /// No description provided for @settingsAudioSpeechPlayingLabel.
  ///
  /// In en, this message translates to:
  /// **'Playing… tap to stop'**
  String get settingsAudioSpeechPlayingLabel;

  /// No description provided for @settingsAudioSpeechSupportedLanguagesTitle.
  ///
  /// In en, this message translates to:
  /// **'About supported languages'**
  String get settingsAudioSpeechSupportedLanguagesTitle;

  /// No description provided for @settingsAudioSpeechSupportedLanguagesBody.
  ///
  /// In en, this message translates to:
  /// **'MemoX currently speaks Korean and English. Other-language cards stay silent and never read the back.'**
  String get settingsAudioSpeechSupportedLanguagesBody;

  /// No description provided for @settingsAudioSpeechChangesSavedText.
  ///
  /// In en, this message translates to:
  /// **'Changes save automatically.'**
  String get settingsAudioSpeechChangesSavedText;

  /// No description provided for @settingsAudioSpeechEngineUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Text-to-speech is unavailable'**
  String get settingsAudioSpeechEngineUnavailableTitle;

  /// No description provided for @settingsAudioSpeechEngineUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Install a TTS engine in your phone’s settings to enable voice playback.'**
  String get settingsAudioSpeechEngineUnavailableBody;

  /// No description provided for @settingsAudioSpeechOpenSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get settingsAudioSpeechOpenSystemSettings;

  /// No description provided for @settingsAboutMemoXTitle.
  ///
  /// In en, this message translates to:
  /// **'About MemoX'**
  String get settingsAboutMemoXTitle;

  /// No description provided for @settingsAboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsAboutVersion(Object version);

  /// No description provided for @settingsAboutMessage.
  ///
  /// In en, this message translates to:
  /// **'MemoX keeps flashcard learning local-first, calm, and ready to back up when you choose.'**
  String get settingsAboutMessage;

  /// No description provided for @settingsAboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'MemoX'**
  String get settingsAboutLegalese;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnexpected;

  /// No description provided for @foldersRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get foldersRenameTitle;

  /// No description provided for @foldersUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Folder updated.'**
  String get foldersUpdatedMessage;

  /// No description provided for @foldersMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move folder'**
  String get foldersMoveTitle;

  /// No description provided for @foldersMoveRootTitle.
  ///
  /// In en, this message translates to:
  /// **'Library root'**
  String get foldersMoveRootTitle;

  /// No description provided for @foldersMoveRootSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move this folder to root'**
  String get foldersMoveRootSubtitle;

  /// No description provided for @foldersMovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Folder moved.'**
  String get foldersMovedMessage;

  /// No description provided for @foldersDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Folder deleted.'**
  String get foldersDeletedMessage;

  /// No description provided for @folderDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this folder?'**
  String get folderDeleteDialogTitle;

  /// No description provided for @folderDeleteDialogReassurance.
  ///
  /// In en, this message translates to:
  /// **'Cards in those decks move to \"Unsorted\" - nothing is permanently lost.'**
  String get folderDeleteDialogReassurance;

  /// No description provided for @folderDeleteDialogConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Type to confirm'**
  String get folderDeleteDialogConfirmLabel;

  /// No description provided for @folderDeleteDialogDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get folderDeleteDialogDeleteButton;

  /// No description provided for @folderDetailDeckMeta.
  ///
  /// In en, this message translates to:
  /// **'{cardCount} cards · last {relativeTime}'**
  String folderDetailDeckMeta(int cardCount, String relativeTime);

  /// No description provided for @decksDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete deck'**
  String get decksDeleteTitle;

  /// No description provided for @decksDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete the entire deck and all flashcards inside it.'**
  String get decksDeleteMessage;

  /// No description provided for @decksDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck deleted.'**
  String get decksDeletedMessage;

  /// No description provided for @flashcardsActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flashcard actions'**
  String get flashcardsActionsTitle;

  /// No description provided for @flashcardsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search flashcards'**
  String get flashcardsSearchHint;

  /// No description provided for @flashcardsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No flashcards yet'**
  String get flashcardsEmptyTitle;

  /// No description provided for @flashcardsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add cards manually or import them into this deck.'**
  String get flashcardsEmptyMessage;

  /// No description provided for @flashcardsNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching flashcards'**
  String get flashcardsNoResultsTitle;

  /// No description provided for @flashcardsNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'No flashcards in this deck match your search.'**
  String get flashcardsNoResultsMessage;

  /// No description provided for @flashcardsClearSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get flashcardsClearSearchAction;

  /// No description provided for @flashcardEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'New flashcard'**
  String get flashcardEditorTitle;

  /// No description provided for @flashcardEditorBreadcrumbFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get flashcardEditorBreadcrumbFolder;

  /// No description provided for @flashcardEditorBreadcrumbDeck.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get flashcardEditorBreadcrumbDeck;

  /// No description provided for @flashcardEditorBreadcrumbCurrent.
  ///
  /// In en, this message translates to:
  /// **'New card'**
  String get flashcardEditorBreadcrumbCurrent;

  /// No description provided for @flashcardEditorDestinationDeckLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected deck'**
  String get flashcardEditorDestinationDeckLabel;

  /// No description provided for @flashcardEditorRequiredWord.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get flashcardEditorRequiredWord;

  /// No description provided for @flashcardEditorFrontHeading.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get flashcardEditorFrontHeading;

  /// No description provided for @flashcardEditorBackHeading.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get flashcardEditorBackHeading;

  /// No description provided for @flashcardEditorFrontPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'The term you want to remember'**
  String get flashcardEditorFrontPlaceholder;

  /// No description provided for @flashcardEditorBackPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add the meaning or translation.'**
  String get flashcardEditorBackPlaceholder;

  /// No description provided for @flashcardEditorMoreFieldsLabel.
  ///
  /// In en, this message translates to:
  /// **'Add details'**
  String get flashcardEditorMoreFieldsLabel;

  /// No description provided for @flashcardEditorMoreFieldsSummary.
  ///
  /// In en, this message translates to:
  /// **'example · hint · pronunciation'**
  String get flashcardEditorMoreFieldsSummary;

  /// No description provided for @flashcardEditorExampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get flashcardEditorExampleLabel;

  /// No description provided for @flashcardEditorPronunciationLabel.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get flashcardEditorPronunciationLabel;

  /// No description provided for @flashcardEditorHintLabel.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get flashcardEditorHintLabel;

  /// No description provided for @flashcardEditorTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'TAGS'**
  String get flashcardEditorTagsLabel;

  /// No description provided for @flashcardEditorTagsOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get flashcardEditorTagsOptionalLabel;

  /// No description provided for @flashcardEditorAddTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get flashcardEditorAddTagLabel;

  /// No description provided for @flashcardEditorSaveCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Save card'**
  String get flashcardEditorSaveCardLabel;

  /// No description provided for @flashcardEditorSaveHelperText.
  ///
  /// In en, this message translates to:
  /// **'Front and back are required to save.'**
  String get flashcardEditorSaveHelperText;

  /// No description provided for @flashcardEditorSampleExample.
  ///
  /// In en, this message translates to:
  /// **'안녕하세요, 저는 민수입니다.'**
  String get flashcardEditorSampleExample;

  /// No description provided for @flashcardEditorSamplePronunciation.
  ///
  /// In en, this message translates to:
  /// **'annyeonghaseyo'**
  String get flashcardEditorSamplePronunciation;

  /// No description provided for @flashcardEditorSampleHint.
  ///
  /// In en, this message translates to:
  /// **'Start with a casual greeting.'**
  String get flashcardEditorSampleHint;

  /// No description provided for @flashcardEditorFrontError.
  ///
  /// In en, this message translates to:
  /// **'Front is required.'**
  String get flashcardEditorFrontError;

  /// No description provided for @flashcardEditorBackError.
  ///
  /// In en, this message translates to:
  /// **'Back is required.'**
  String get flashcardEditorBackError;

  /// No description provided for @flashcardEditorSaveFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save this flashcard. Try again.'**
  String get flashcardEditorSaveFailedMessage;

  /// No description provided for @flashcardsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get flashcardsEditTitle;

  /// No description provided for @flashcardsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this card'**
  String get flashcardsLoadErrorTitle;

  /// No description provided for @flashcardsLoadErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data is safe on this device. Try again in a moment.'**
  String get flashcardsLoadErrorMessage;

  /// No description provided for @flashcardsLoadErrorBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back to deck'**
  String get flashcardsLoadErrorBackAction;

  /// No description provided for @flashcardsEditDangerZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get flashcardsEditDangerZoneLabel;

  /// No description provided for @flashcardsEditSaveHelperText.
  ///
  /// In en, this message translates to:
  /// **'Changes save to this device only.'**
  String get flashcardsEditSaveHelperText;

  /// No description provided for @flashcardsEditSaveFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save changes. Nothing was lost. Tap Save to try again.'**
  String get flashcardsEditSaveFailedMessage;

  /// No description provided for @flashcardsDeleteCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this flashcard?'**
  String get flashcardsDeleteCardTitle;

  /// No description provided for @flashcardsDeleteCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Removes the card and its {reviewCount} reviews of history. Other cards in this deck are unaffected.'**
  String flashcardsDeleteCardMessage(int reviewCount);

  /// No description provided for @flashcardsDeleteCardAction.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get flashcardsDeleteCardAction;

  /// No description provided for @flashcardsFieldTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get flashcardsFieldTagsLabel;

  /// No description provided for @flashcardsTagsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get flashcardsTagsSheetTitle;

  /// No description provided for @flashcardsTagsConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get flashcardsTagsConfirmAction;

  /// No description provided for @flashcardsSaveAndAddNextTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save and add another'**
  String get flashcardsSaveAndAddNextTooltip;

  /// No description provided for @flashcardsSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Flashcard saved.'**
  String get flashcardsSavedMessage;

  /// No description provided for @flashcardsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get flashcardsSaveChanges;

  /// No description provided for @flashcardsLearningContentChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'You changed the learning content.'**
  String get flashcardsLearningContentChangedTitle;

  /// No description provided for @flashcardsLearningContentChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep existing progress or reset this card?'**
  String get flashcardsLearningContentChangedMessage;

  /// No description provided for @flashcardsKeepProgressAction.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get flashcardsKeepProgressAction;

  /// No description provided for @flashcardsResetProgressAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get flashcardsResetProgressAction;

  /// No description provided for @flashcardsUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Flashcard updated.'**
  String get flashcardsUpdatedMessage;

  /// No description provided for @flashcardsCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Flashcard created.'**
  String get flashcardsCreatedMessage;

  /// No description provided for @flashcardsDiscardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get flashcardsDiscardChangesTitle;

  /// No description provided for @flashcardsDiscardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved flashcard changes will be lost.'**
  String get flashcardsDiscardChangesMessage;

  /// No description provided for @flashcardsDiscardChangesAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get flashcardsDiscardChangesAction;

  /// No description provided for @flashcardsKeepEditingAction.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get flashcardsKeepEditingAction;

  /// No description provided for @studyEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get studyEntryTitle;

  /// No description provided for @studyEntryPreparingTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing study session'**
  String get studyEntryPreparingTitle;

  /// No description provided for @studyEntryPreparingMessage.
  ///
  /// In en, this message translates to:
  /// **'Validating scope and loading study state.'**
  String get studyEntryPreparingMessage;

  /// Title shown when Study Entry finds a resumable session but the resume dialog is not implemented yet.
  ///
  /// In en, this message translates to:
  /// **'Study session already in progress'**
  String get studyEntryResumeRequiredTitle;

  /// Message shown when Study Entry finds a resumable session and asks the user to choose an action.
  ///
  /// In en, this message translates to:
  /// **'We found an existing study session for this scope. Choose how to continue.'**
  String get studyEntryResumeRequiredMessage;

  /// No description provided for @studyEntryResumeRequiredHeader.
  ///
  /// In en, this message translates to:
  /// **'Choose an action'**
  String get studyEntryResumeRequiredHeader;

  /// No description provided for @studyEntryResumeRequiredResumeAction.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get studyEntryResumeRequiredResumeAction;

  /// No description provided for @studyEntryResumeRequiredStartOverAction.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get studyEntryResumeRequiredStartOverAction;

  /// No description provided for @studyEntryResumeRequiredStartOverConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start over and discard the current session?'**
  String get studyEntryResumeRequiredStartOverConfirmTitle;

  /// No description provided for @studyEntryResumeRequiredStartOverConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will cancel the existing session and create a new one for the same study scope.'**
  String get studyEntryResumeRequiredStartOverConfirmMessage;

  /// No description provided for @studyEntryResumeRequiredStartOverConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get studyEntryResumeRequiredStartOverConfirmAction;

  /// No description provided for @studyEntryResumeRequiredStartOverFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start over. Try again.'**
  String get studyEntryResumeRequiredStartOverFailed;

  /// No description provided for @studyEntryInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t open study'**
  String get studyEntryInvalidTitle;

  /// No description provided for @studyEntryInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'The study route parameters are invalid.'**
  String get studyEntryInvalidMessage;

  /// No description provided for @studySessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Study session'**
  String get studySessionTitle;

  /// No description provided for @studySessionProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String studySessionProgressLabel(int current, int total);

  /// No description provided for @studySessionFrontLabel.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get studySessionFrontLabel;

  /// No description provided for @studySessionBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get studySessionBackLabel;

  /// No description provided for @studyPreviousAction.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get studyPreviousAction;

  /// No description provided for @studySessionShowAction.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get studySessionShowAction;

  /// No description provided for @studySessionHideAction.
  ///
  /// In en, this message translates to:
  /// **'Hide answer'**
  String get studySessionHideAction;

  /// No description provided for @studySessionSavingAnswerMessage.
  ///
  /// In en, this message translates to:
  /// **'Saving your answer...'**
  String get studySessionSavingAnswerMessage;

  /// No description provided for @studySessionRecordFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save this answer. Please try again.'**
  String get studySessionRecordFailedMessage;

  /// No description provided for @studySessionAllAnsweredMessage.
  ///
  /// In en, this message translates to:
  /// **'All cards are answered. Finish the session to save your progress.'**
  String get studySessionAllAnsweredMessage;

  /// No description provided for @studySessionFinalizingMessage.
  ///
  /// In en, this message translates to:
  /// **'Finalizing your session...'**
  String get studySessionFinalizingMessage;

  /// No description provided for @studySessionFinalizeFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t finish this session. Please try again.'**
  String get studySessionFinalizeFailedMessage;

  /// No description provided for @studySessionNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get studySessionNotFoundTitle;

  /// No description provided for @studySessionNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This study session no longer exists.'**
  String get studySessionNotFoundMessage;

  /// No description provided for @studySessionLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load session'**
  String get studySessionLoadFailedTitle;

  /// No description provided for @studySessionLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this session. Please try again.'**
  String get studySessionLoadFailedMessage;

  /// No description provided for @studySessionExitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this session?'**
  String get studySessionExitConfirmTitle;

  /// No description provided for @studySessionExitConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved and you can resume later.'**
  String get studySessionExitConfirmMessage;

  /// No description provided for @studySessionExitConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Leave session'**
  String get studySessionExitConfirmAction;

  /// No description provided for @studySessionExitKeepStudyingAction.
  ///
  /// In en, this message translates to:
  /// **'Keep studying'**
  String get studySessionExitKeepStudyingAction;

  /// No description provided for @studyFinalizeAction.
  ///
  /// In en, this message translates to:
  /// **'Finish session'**
  String get studyFinalizeAction;

  /// No description provided for @studyResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Study result'**
  String get studyResultTitle;

  /// No description provided for @studyResultCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get studyResultCards;

  /// No description provided for @studyResultAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get studyResultAnswered;

  /// No description provided for @studyResultCardsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} cards completed'**
  String studyResultCardsCompleted(int completed, int total);

  /// No description provided for @studyResultBackToLibraryAction.
  ///
  /// In en, this message translates to:
  /// **'Back to Library'**
  String get studyResultBackToLibraryAction;

  /// No description provided for @studyResultBackToHomeAction.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get studyResultBackToHomeAction;

  /// No description provided for @studyResultCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get studyResultCompleted;

  /// No description provided for @studyResultCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get studyResultCancelled;

  /// No description provided for @studyResultFailedFinalize.
  ///
  /// In en, this message translates to:
  /// **'Finalize failed. Retry when ready.'**
  String get studyResultFailedFinalize;

  /// No description provided for @studyResultInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get studyResultInProgress;

  /// No description provided for @studyResultDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get studyResultDraft;

  /// No description provided for @studyResultBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get studyResultBreakdownTitle;

  /// No description provided for @studyResultPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get studyResultPassed;

  /// No description provided for @studyResultForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot'**
  String get studyResultForgot;

  /// No description provided for @studyResultInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t open result'**
  String get studyResultInvalidTitle;

  /// No description provided for @studyResultInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'The study result route parameters are invalid.'**
  String get studyResultInvalidMessage;

  /// No description provided for @studyResultNotCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Result unavailable'**
  String get studyResultNotCompleteTitle;

  /// No description provided for @studyResultNotCompleteMessageWithStatus.
  ///
  /// In en, this message translates to:
  /// **'This study session has not been completed yet. Current status: {status}.'**
  String studyResultNotCompleteMessageWithStatus(String status);

  /// No description provided for @relativeTimeAgo.
  ///
  /// In en, this message translates to:
  /// **'{unit, select, justNow{just now} minutes{{count, plural, =1{1 minute ago} other{{count} minutes ago}}} hours{{count, plural, =1{1 hour ago} other{{count} hours ago}}} days{{count, plural, =1{1 day ago} other{{count} days ago}}} weeks{{count, plural, =1{1 week ago} other{{count} weeks ago}}} months{{count, plural, =1{1 month ago} other{{count} months ago}}} years{{count, plural, =1{1 year ago} other{{count} years ago}}} other{just now}}'**
  String relativeTimeAgo(String unit, int count);

  /// No description provided for @studyForgotAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot'**
  String get studyForgotAction;

  /// No description provided for @studyNextAction.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get studyNextAction;

  /// No description provided for @studyGotItAction.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get studyGotItAction;

  /// Empty-scope title shown when a user opens Study on a deck with zero flashcards. P0-1 Tier 1; copy pending product review.
  ///
  /// In en, this message translates to:
  /// **'No flashcards in this deck'**
  String get studyEmpty_deck_noCards_title;

  /// Empty-scope CTA that pushes the flashcard-create screen for the current deck.
  ///
  /// In en, this message translates to:
  /// **'Add flashcards'**
  String get studyEmpty_deck_noCards_cta;

  /// Empty-scope title when a deck has cards but none are due for SRS review. P0-1 Tier 1.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get studyEmpty_deck_noDueCards_title;

  /// Empty-scope CTA that restarts study on the deck as a New Study session.
  ///
  /// In en, this message translates to:
  /// **'Study new instead'**
  String get studyEmpty_deck_noDueCards_cta;

  /// Empty-scope title when a folder subtree has zero flashcards. P0-1 Tier 1.
  ///
  /// In en, this message translates to:
  /// **'No cards in this folder'**
  String get studyEmpty_folder_noCards_title;

  /// Empty-scope CTA that returns to the folder so the user can add a deck.
  ///
  /// In en, this message translates to:
  /// **'Add a deck'**
  String get studyEmpty_folder_noCards_cta;

  /// Empty-scope title when a folder subtree has cards but none are due for SRS review. P0-1 Tier 1.
  ///
  /// In en, this message translates to:
  /// **'All caught up for this folder'**
  String get studyEmpty_folder_noDueCards_title;

  /// Empty-scope CTA that restarts study on the folder as a New Study session.
  ///
  /// In en, this message translates to:
  /// **'Study new instead'**
  String get studyEmpty_folder_noDueCards_cta;

  /// Empty-scope title when today's SRS review queue is empty but the user has cards. P0-1 Tier 1.
  ///
  /// In en, this message translates to:
  /// **'All done for today!'**
  String get studyEmpty_today_allDone_title;

  /// Empty-scope motivational message shown when today's review queue is clear.
  ///
  /// In en, this message translates to:
  /// **'Great work. Check back tomorrow for your next review.'**
  String get studyEmpty_today_allDone_message;

  /// Empty-scope CTA that returns to the dashboard when today's review queue is clear.
  ///
  /// In en, this message translates to:
  /// **'Back to dashboard'**
  String get studyEmpty_today_allDone_cta;

  /// Empty-scope title when the user has zero flashcards anywhere. P0-1 Tier 1.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any flashcards yet'**
  String get studyEmpty_today_noContent_title;

  /// Empty-scope CTA that opens the library so the user can create their first deck.
  ///
  /// In en, this message translates to:
  /// **'Create your first deck'**
  String get studyEmpty_today_noContent_cta;

  /// Relative time fragment for the next-due hint, in days.
  ///
  /// In en, this message translates to:
  /// **'in {count, plural, =1{1 day} other{{count} days}}'**
  String studyEmptyNextDueInDays(int count);

  /// Relative time fragment for the next-due hint, in hours.
  ///
  /// In en, this message translates to:
  /// **'in {count, plural, =1{1 hour} other{{count} hours}}'**
  String studyEmptyNextDueInHours(int count);

  /// Relative time fragment for the next-due hint when the next card is due in under an hour.
  ///
  /// In en, this message translates to:
  /// **'soon'**
  String get studyEmptyNextDueSoon;

  /// Empty-scope title when every card in scope is buried for today. P0-2 Tier 3.
  ///
  /// In en, this message translates to:
  /// **'All cards buried'**
  String get studyEmpty_allBuried_title;

  /// Empty-scope message for the all-buried state.
  ///
  /// In en, this message translates to:
  /// **'You buried every card for now. They\'ll return tomorrow.'**
  String get studyEmpty_allBuried_message;

  /// Empty-scope CTA that restarts study as a New Study session when all cards are buried.
  ///
  /// In en, this message translates to:
  /// **'Study new instead'**
  String get studyEmpty_allBuried_cta;

  /// Empty-scope title when every card in scope is suspended. P0-2 Tier 3.
  ///
  /// In en, this message translates to:
  /// **'All cards suspended'**
  String get studyEmpty_allSuspended_title;

  /// Empty-scope message for the all-suspended state.
  ///
  /// In en, this message translates to:
  /// **'Resume some cards to study them again.'**
  String get studyEmpty_allSuspended_message;

  /// Empty-scope CTA that opens the flashcard list so the user can unsuspend cards.
  ///
  /// In en, this message translates to:
  /// **'View flashcards'**
  String get studyEmpty_allSuspended_cta;

  /// No description provided for @flashcardsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import flashcards'**
  String get flashcardsImportTitle;

  /// No description provided for @flashcardsImportRouteIntroMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck import V1 now supports CSV paste preview and transactional commit. File picker, Excel, and structured text stay deferred.'**
  String get flashcardsImportRouteIntroMessage;

  /// No description provided for @flashcardsImportMissingDeckMessage.
  ///
  /// In en, this message translates to:
  /// **'This import route needs a deck ID. Go back and open import from a deck.'**
  String get flashcardsImportMissingDeckMessage;

  /// No description provided for @importSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from'**
  String get importSourceTitle;

  /// No description provided for @importCsvContentLabel.
  ///
  /// In en, this message translates to:
  /// **'CSV content'**
  String get importCsvContentLabel;

  /// No description provided for @importCsvHint.
  ///
  /// In en, this message translates to:
  /// **'front,back'**
  String get importCsvHint;

  /// No description provided for @importCsvRulesText.
  ///
  /// In en, this message translates to:
  /// **'Use front and back columns. Optional extra columns are ignored in V1.'**
  String get importCsvRulesText;

  /// No description provided for @importPreviewAction.
  ///
  /// In en, this message translates to:
  /// **'Preview import'**
  String get importPreviewAction;

  /// No description provided for @importCommitCardsAction.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 card} other{Import {count} cards}}'**
  String importCommitCardsAction(int count);

  /// No description provided for @importSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} flashcards.'**
  String importSuccessMessage(int count);

  /// No description provided for @importValidationIssuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Validation issues'**
  String get importValidationIssuesTitle;

  /// No description provided for @importValidationIssuesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fix every issue before importing.'**
  String get importValidationIssuesSubtitle;

  /// No description provided for @importValidationIssueLine.
  ///
  /// In en, this message translates to:
  /// **'Line {line}'**
  String importValidationIssueLine(int line);

  /// No description provided for @importPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get importPreviewTitle;

  /// No description provided for @importPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} flashcards ready to create'**
  String importPreviewSubtitle(int count);

  /// No description provided for @importPreviewSummary.
  ///
  /// In en, this message translates to:
  /// **'{valid} valid · {invalid} issues'**
  String importPreviewSummary(int valid, int invalid);

  /// No description provided for @importPreviewRowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Valid rows'**
  String get importPreviewRowsTitle;

  /// No description provided for @importPreviewCommitReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Preview is clean. You can import these cards now.'**
  String get importPreviewCommitReadyMessage;

  /// No description provided for @importCommittingMessage.
  ///
  /// In en, this message translates to:
  /// **'Importing cards...'**
  String get importCommittingMessage;

  /// No description provided for @importFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Try again.'**
  String get importFailedMessage;

  /// No description provided for @importCsvEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Paste CSV content before previewing.'**
  String get importCsvEmptyMessage;

  /// No description provided for @importCsvFrontAndBackRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Front and back are required.'**
  String get importCsvFrontAndBackRequiredMessage;

  /// No description provided for @importNothingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to import'**
  String get importNothingTitle;

  /// No description provided for @importNothingMessage.
  ///
  /// In en, this message translates to:
  /// **'No valid rows or blocks were produced from the source.'**
  String get importNothingMessage;

  /// No description provided for @sharedErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get sharedErrorTitle;

  /// No description provided for @sharedStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get sharedStreakLabel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @libraryFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get libraryFilterTooltip;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search folders'**
  String get librarySearchHint;

  /// No description provided for @librarySearchClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get librarySearchClearTooltip;

  /// No description provided for @librarySearchShortcutLabel.
  ///
  /// In en, this message translates to:
  /// **'K'**
  String get librarySearchShortcutLabel;

  /// No description provided for @libraryNewFolderLabel.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get libraryNewFolderLabel;

  /// No description provided for @libraryLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your library'**
  String get libraryLoadFailedTitle;

  /// No description provided for @libraryLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading your folders.'**
  String get libraryLoadFailedMessage;

  /// No description provided for @libraryLoadingFoldersLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading folders'**
  String get libraryLoadingFoldersLabel;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your library'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Folders keep related decks together. Add one to organize your decks.'**
  String get libraryEmptyMessage;

  /// No description provided for @librarySearchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No folders found'**
  String get librarySearchNoResultsTitle;

  /// No description provided for @librarySearchNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'No folder matches your search.'**
  String get librarySearchNoResultsMessage;

  /// No description provided for @folderCreateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get folderCreateDialogTitle;

  /// No description provided for @folderCreateDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Group related decks together.'**
  String get folderCreateDialogDescription;

  /// No description provided for @folderCreateFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderCreateFieldLabel;

  /// No description provided for @folderCreateColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get folderCreateColorLabel;

  /// No description provided for @folderCreateIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get folderCreateIconLabel;

  /// No description provided for @libraryFolderDuplicateError.
  ///
  /// In en, this message translates to:
  /// **'A folder with this name already exists.'**
  String get libraryFolderDuplicateError;

  /// No description provided for @libraryCreateFolderError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the folder. Please try again.'**
  String get libraryCreateFolderError;

  /// No description provided for @libraryFolderCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} folders'**
  String libraryFolderCountLabel(int count);

  /// No description provided for @libraryDueSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card due today} other{{count} cards due today}}'**
  String libraryDueSummaryTitle(int count);

  /// No description provided for @libraryDueSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Across {folderCount, plural, =1{1 folder} other{{folderCount} folders}} · ~{minutes} min'**
  String libraryDueSummarySubtitle(int folderCount, int minutes);

  /// No description provided for @librarySortRecentLabel.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get librarySortRecentLabel;

  /// No description provided for @libraryFolderDecksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No decks} =1{1 deck} other{{count} decks}}'**
  String libraryFolderDecksCount(int count);

  /// No description provided for @libraryFolderSubfoldersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No subfolders} =1{1 subfolder} other{{count} subfolders}}'**
  String libraryFolderSubfoldersCount(int count);

  /// No description provided for @libraryFolderCardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No cards} =1{1 card} other{{count} cards}}'**
  String libraryFolderCardsCount(int count);

  /// No description provided for @libraryFolderNewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String libraryFolderNewCount(int count);

  /// No description provided for @libraryFolderDueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} due'**
  String libraryFolderDueCount(int count);

  /// No description provided for @libraryOverflowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Folder actions'**
  String get libraryOverflowTooltip;

  /// No description provided for @folderDetailSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search this folder'**
  String get folderDetailSearchHint;

  /// No description provided for @folderDetailSearchSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Search this folder'**
  String get folderDetailSearchSheetTitle;

  /// No description provided for @folderDetailMasteryUnavailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Mastery unavailable'**
  String get folderDetailMasteryUnavailableLabel;

  /// No description provided for @folderDetailStartStudyLabel.
  ///
  /// In en, this message translates to:
  /// **'Start study'**
  String get folderDetailStartStudyLabel;

  /// No description provided for @folderDetailSortSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort folder'**
  String get folderDetailSortSheetTitle;

  /// No description provided for @folderDetailSortManualLabel.
  ///
  /// In en, this message translates to:
  /// **'Manual order'**
  String get folderDetailSortManualLabel;

  /// No description provided for @folderDetailSortNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get folderDetailSortNameLabel;

  /// No description provided for @folderDetailSortNewestLabel.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get folderDetailSortNewestLabel;

  /// No description provided for @folderDetailSortLastStudiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last studied'**
  String get folderDetailSortLastStudiedLabel;

  /// No description provided for @folderDetailMostDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Most due'**
  String get folderDetailMostDueLabel;

  /// No description provided for @folderDetailEmptyFolderChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Empty folder'**
  String get folderDetailEmptyFolderChipLabel;

  /// No description provided for @folderDetailEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'What goes in here?'**
  String get folderDetailEmptyTitle;

  /// No description provided for @folderDetailEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add decks to study cards directly, or nest subfolders to keep things organized. Folders hold one or the other once you start.'**
  String get folderDetailEmptyMessage;

  /// No description provided for @folderDetailEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Once this folder holds decks or subfolders, the other option moves into the overflow menu.'**
  String get folderDetailEmptyHint;

  /// No description provided for @folderDetailNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No items match \"{query}\"'**
  String folderDetailNoResultsTitle(String query);

  /// No description provided for @folderDetailNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different spelling or clear the search to see everything.'**
  String get folderDetailNoResultsMessage;

  /// No description provided for @folderNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Folder not found'**
  String get folderNotFoundTitle;

  /// No description provided for @folderNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This folder may have been moved or deleted.'**
  String get folderNotFoundMessage;

  /// No description provided for @folderEmptyLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'This folder is empty'**
  String get folderEmptyLockedTitle;

  /// No description provided for @folderEmptyLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Use the button below to add to it.'**
  String get folderEmptyLockedMessage;

  /// No description provided for @folderUnlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'This folder is empty'**
  String get folderUnlockedTitle;

  /// No description provided for @folderUnlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose how to fill it:'**
  String get folderUnlockedMessage;

  /// No description provided for @folderModeLockHint.
  ///
  /// In en, this message translates to:
  /// **'A folder can hold subfolders or decks — not both.'**
  String get folderModeLockHint;

  /// No description provided for @folderNewSubfolderLabel.
  ///
  /// In en, this message translates to:
  /// **'New subfolder'**
  String get folderNewSubfolderLabel;

  /// No description provided for @folderNewDeckLabel.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get folderNewDeckLabel;

  /// No description provided for @folderDeleteDialogRemovalMessage.
  ///
  /// In en, this message translates to:
  /// **' and its {summaryText} will be removed from your library.'**
  String folderDeleteDialogRemovalMessage(String summaryText);

  /// No description provided for @subfolderCreateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New subfolder'**
  String get subfolderCreateDialogTitle;

  /// No description provided for @subfolderCreateFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Subfolder name'**
  String get subfolderCreateFieldLabel;

  /// No description provided for @deckCreateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get deckCreateDialogTitle;

  /// No description provided for @deckCreateFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get deckCreateFieldLabel;

  /// No description provided for @folderRenameDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Only the folder name changes — every deck and card inside stays put.'**
  String get folderRenameDialogDescription;

  /// No description provided for @folderRenameDialogFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get folderRenameDialogFieldLabel;

  /// No description provided for @folderRenameDialogHelper.
  ///
  /// In en, this message translates to:
  /// **'{summary} will keep this folder as their home.'**
  String folderRenameDialogHelper(String summary);

  /// No description provided for @folderDeckDuplicateError.
  ///
  /// In en, this message translates to:
  /// **'A deck with this name already exists.'**
  String get folderDeckDuplicateError;

  /// No description provided for @folderChildCreateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create that. Please try again.'**
  String get folderChildCreateError;

  /// No description provided for @libraryFolderActionsRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get libraryFolderActionsRename;

  /// No description provided for @libraryFolderActionsMove.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get libraryFolderActionsMove;

  /// No description provided for @libraryFolderActionsImport.
  ///
  /// In en, this message translates to:
  /// **'Import flashcards'**
  String get libraryFolderActionsImport;

  /// No description provided for @libraryFolderActionsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get libraryFolderActionsDelete;

  /// No description provided for @libraryFolderActionError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t complete that action. Please try again.'**
  String get libraryFolderActionError;

  /// No description provided for @folderMovePickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search folders'**
  String get folderMovePickerSearchHint;

  /// No description provided for @folderMovePickerCycleReason.
  ///
  /// In en, this message translates to:
  /// **'Can\'t move a folder into itself or its subfolders.'**
  String get folderMovePickerCycleReason;

  /// No description provided for @folderMovePickerLockedReason.
  ///
  /// In en, this message translates to:
  /// **'Locked to decks — can\'t hold folders.'**
  String get folderMovePickerLockedReason;

  /// No description provided for @folderSummaryAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get folderSummaryAllCaughtUp;

  /// No description provided for @folderSummarySubfoldersStat.
  ///
  /// In en, this message translates to:
  /// **'subfolders'**
  String get folderSummarySubfoldersStat;

  /// No description provided for @folderSummaryCardsStat.
  ///
  /// In en, this message translates to:
  /// **'cards'**
  String get folderSummaryCardsStat;

  /// No description provided for @folderSummaryDueStat.
  ///
  /// In en, this message translates to:
  /// **'due total'**
  String get folderSummaryDueStat;

  /// No description provided for @searchFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Search folders, decks, cards'**
  String get searchFieldHint;

  /// No description provided for @searchClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClearTooltip;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search your library'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to find folders, decks, and cards.'**
  String get searchEmptyMessage;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing in your library matches that search.'**
  String get searchNoResultsMessage;

  /// No description provided for @searchErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchErrorTitle;

  /// No description provided for @searchErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while searching. Please try again.'**
  String get searchErrorMessage;

  /// No description provided for @searchRetryLabel.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get searchRetryLabel;

  /// No description provided for @searchSectionFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get searchSectionFolders;

  /// No description provided for @searchSectionDecks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get searchSectionDecks;

  /// No description provided for @searchSectionFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get searchSectionFlashcards;

  /// No description provided for @searchResultFolderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get searchResultFolderSubtitle;

  /// No description provided for @searchResultDeckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get searchResultDeckSubtitle;

  /// No description provided for @searchMoreCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 more} other{+{count} more}}'**
  String searchMoreCount(int count);

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @flashcardListAddCardAction.
  ///
  /// In en, this message translates to:
  /// **'Add flashcard'**
  String get flashcardListAddCardAction;

  /// No description provided for @flashcardListErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck unavailable'**
  String get flashcardListErrorTitle;

  /// No description provided for @flashcardListErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open this deck. Please try again.'**
  String get flashcardListErrorMessage;

  /// No description provided for @flashcardListActionError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get flashcardListActionError;

  /// No description provided for @flashcardListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card · {language}} other{{count} cards · {language}}}'**
  String flashcardListSubtitle(int count, String language);

  /// No description provided for @flashcardListLanguageKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get flashcardListLanguageKorean;

  /// No description provided for @flashcardListLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get flashcardListLanguageEnglish;

  /// No description provided for @flashcardListLanguageOther.
  ///
  /// In en, this message translates to:
  /// **'Other language'**
  String get flashcardListLanguageOther;

  /// No description provided for @flashcardDeckReorderAction.
  ///
  /// In en, this message translates to:
  /// **'Reorder cards'**
  String get flashcardDeckReorderAction;

  /// No description provided for @flashcardDeleteOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this flashcard?'**
  String get flashcardDeleteOneTitle;

  /// No description provided for @flashcardDeleteOneMessage.
  ///
  /// In en, this message translates to:
  /// **'Review history for this card will be removed. Other cards in this deck are unaffected.'**
  String get flashcardDeleteOneMessage;

  /// No description provided for @flashcardDeletedOneMessage.
  ///
  /// In en, this message translates to:
  /// **'Flashcard deleted.'**
  String get flashcardDeletedOneMessage;

  /// No description provided for @flashcardReorderError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the new order.'**
  String get flashcardReorderError;

  /// No description provided for @progressRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get progressRangeWeek;

  /// No description provided for @progressRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get progressRangeMonth;

  /// No description provided for @progressRangeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get progressRangeAllTime;

  /// No description provided for @progressCardsStudiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cards studied'**
  String get progressCardsStudiedTitle;

  /// No description provided for @progressCardsStudiedCaptionWeek.
  ///
  /// In en, this message translates to:
  /// **'over the past 7 days'**
  String get progressCardsStudiedCaptionWeek;

  /// No description provided for @progressCardsStudiedCaptionMonth.
  ///
  /// In en, this message translates to:
  /// **'over the past 28 days'**
  String get progressCardsStudiedCaptionMonth;

  /// No description provided for @progressCardsStudiedCaptionAllTime.
  ///
  /// In en, this message translates to:
  /// **'all time'**
  String get progressCardsStudiedCaptionAllTime;

  /// No description provided for @progressAccuracyTitle.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get progressAccuracyTitle;

  /// No description provided for @progressVsPreviousWeek.
  ///
  /// In en, this message translates to:
  /// **'vs previous week'**
  String get progressVsPreviousWeek;

  /// No description provided for @progressVsPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'vs previous month'**
  String get progressVsPreviousMonth;

  /// No description provided for @progressBoxDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Box distribution'**
  String get progressBoxDistributionTitle;

  /// No description provided for @progressBoxTotalCaption.
  ///
  /// In en, this message translates to:
  /// **'total cards across boxes'**
  String get progressBoxTotalCaption;

  /// No description provided for @progressBoxLabel.
  ///
  /// In en, this message translates to:
  /// **'B{box}'**
  String progressBoxLabel(int box);

  /// No description provided for @progressBoxLegendLeast.
  ///
  /// In en, this message translates to:
  /// **'B1 · least known'**
  String get progressBoxLegendLeast;

  /// No description provided for @progressBoxLegendBest.
  ///
  /// In en, this message translates to:
  /// **'B8 · best known'**
  String get progressBoxLegendBest;

  /// No description provided for @progressStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get progressStreakTitle;

  /// No description provided for @progressStreakCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get progressStreakCurrent;

  /// No description provided for @progressStreakLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest'**
  String get progressStreakLongest;

  /// No description provided for @progressStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String progressStreakDays(int count);

  /// No description provided for @progressCardStatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Card states'**
  String get progressCardStatesTitle;

  /// No description provided for @progressSuspendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get progressSuspendedTitle;

  /// No description provided for @progressSuspendedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Out of rotation until you resume them'**
  String get progressSuspendedSubtitle;

  /// No description provided for @progressSuspendedCaption.
  ///
  /// In en, this message translates to:
  /// **'in your library'**
  String get progressSuspendedCaption;

  /// No description provided for @progressBuriedTitle.
  ///
  /// In en, this message translates to:
  /// **'Buried today'**
  String get progressBuriedTitle;

  /// No description provided for @progressBuriedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Skipped until tomorrow'**
  String get progressBuriedSubtitle;

  /// No description provided for @progressBuriedCaption.
  ///
  /// In en, this message translates to:
  /// **'today only'**
  String get progressBuriedCaption;

  /// No description provided for @progressFooterWeek.
  ///
  /// In en, this message translates to:
  /// **'Read-only summary · last 7 days'**
  String get progressFooterWeek;

  /// No description provided for @progressFooterMonth.
  ///
  /// In en, this message translates to:
  /// **'Read-only summary · last 28 days'**
  String get progressFooterMonth;

  /// No description provided for @progressFooterAllTime.
  ///
  /// In en, this message translates to:
  /// **'Read-only summary · all time'**
  String get progressFooterAllTime;

  /// No description provided for @progressChartEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No study sessions in this range yet. Start any deck to begin tracking trends.'**
  String get progressChartEmptyHint;

  /// No description provided for @progressChartInsufficientHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Only 1 day of data so far.} other{Only {count} days of data so far.}}'**
  String progressChartInsufficientHint(int count);

  /// No description provided for @progressTrendBanner.
  ///
  /// In en, this message translates to:
  /// **'Trend appears after {days} days of data.'**
  String progressTrendBanner(int days);

  /// No description provided for @progressAccuracyEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Accuracy appears once you\'ve answered cards.'**
  String get progressAccuracyEmptyHint;

  /// No description provided for @progressBoxEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Cards spread across boxes as you study them.'**
  String get progressBoxEmptyHint;

  /// No description provided for @progressStreakEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'A streak starts after one study session.'**
  String get progressStreakEmptyHint;

  /// No description provided for @progressErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t summarise your progress'**
  String get progressErrorTitle;

  /// No description provided for @progressErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Your study history is safe on this device. Try again in a moment.'**
  String get progressErrorMessage;

  /// No description provided for @flashcardListCountHeader.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 CARD} other{{count} CARDS}}'**
  String flashcardListCountHeader(int count);

  /// No description provided for @flashcardListReorderHeader.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 CARD · DRAG TO REORDER} other{{count} CARDS · DRAG TO REORDER}}'**
  String flashcardListReorderHeader(int count);

  /// No description provided for @flashcardsEmptyAddFirstAction.
  ///
  /// In en, this message translates to:
  /// **'Add first flashcard'**
  String get flashcardsEmptyAddFirstAction;

  /// No description provided for @flashcardsEmptyImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import cards (CSV, TSV, Anki)'**
  String get flashcardsEmptyImportAction;

  /// No description provided for @flashcardEditorSavingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get flashcardEditorSavingLabel;

  /// No description provided for @flashcardEditorSavingHelperText.
  ///
  /// In en, this message translates to:
  /// **'Saving to this device…'**
  String get flashcardEditorSavingHelperText;

  /// No description provided for @flashcardEditorRetrySaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry save'**
  String get flashcardEditorRetrySaveLabel;

  /// No description provided for @flashcardEditorOptionalDetailsHeading.
  ///
  /// In en, this message translates to:
  /// **'Optional details'**
  String get flashcardEditorOptionalDetailsHeading;

  /// No description provided for @flashcardsEditMeta.
  ///
  /// In en, this message translates to:
  /// **'{reviewCount, plural, =0{Last edited {relativeTime}} =1{Last edited {relativeTime} · 1 review} other{Last edited {relativeTime} · {reviewCount} reviews}}'**
  String flashcardsEditMeta(int reviewCount, String relativeTime);

  /// No description provided for @cardHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Card history'**
  String get cardHistoryTitle;

  /// No description provided for @cardHistoryStateSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get cardHistoryStateSuspended;

  /// No description provided for @relativeTimeUntil.
  ///
  /// In en, this message translates to:
  /// **'{unit, select, justNow{now} minutes{{count, plural, =1{in 1 minute} other{in {count} minutes}}} hours{{count, plural, =1{in 1 hour} other{in {count} hours}}} days{{count, plural, =1{in 1 day} other{in {count} days}}} weeks{{count, plural, =1{in 1 week} other{in {count} weeks}}} months{{count, plural, =1{in 1 month} other{in {count} months}}} years{{count, plural, =1{in 1 year} other{in {count} years}}} other{now}}'**
  String relativeTimeUntil(String unit, int count);

  /// No description provided for @cardHistoryResetSubLabel.
  ///
  /// In en, this message translates to:
  /// **'Includes attempts before last reset on {date}.'**
  String cardHistoryResetSubLabel(String date);

  /// No description provided for @cardHistoryResultPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get cardHistoryResultPerfect;

  /// No description provided for @cardHistoryResultPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get cardHistoryResultPassed;

  /// No description provided for @cardHistoryResultRecovered.
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get cardHistoryResultRecovered;

  /// No description provided for @cardHistoryResultForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot'**
  String get cardHistoryResultForgot;

  /// No description provided for @cardHistoryBoxUnknown.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get cardHistoryBoxUnknown;

  /// No description provided for @cardHistoryModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode: {mode, select, review{Review} match{Match} guess{Guess} recall{Recall} fill{Fill} other{Study}}'**
  String cardHistoryModeLabel(String mode);

  /// No description provided for @cardHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get cardHistoryEmptyTitle;

  /// No description provided for @cardHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'History appears here after you study this card.'**
  String get cardHistoryEmptyMessage;

  /// No description provided for @cardHistoryEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Study this card now'**
  String get cardHistoryEmptyAction;

  /// No description provided for @cardHistoryErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load history'**
  String get cardHistoryErrorTitle;

  /// No description provided for @cardHistoryErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data is safe on this device. Try again in a moment.'**
  String get cardHistoryErrorMessage;

  /// No description provided for @cardHistoryNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Card no longer exists'**
  String get cardHistoryNotFoundTitle;

  /// No description provided for @cardHistoryNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This flashcard has been deleted.'**
  String get cardHistoryNotFoundMessage;

  /// No description provided for @cardHistoryResetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get cardHistoryResetAction;

  /// No description provided for @cardHistoryResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset progress?'**
  String get cardHistoryResetConfirmTitle;

  /// No description provided for @cardHistoryResetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Attempts history is kept; only SRS state is reset.'**
  String get cardHistoryResetConfirmMessage;

  /// No description provided for @cardHistoryResetDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Progress reset'**
  String get cardHistoryResetDoneMessage;

  /// No description provided for @cardHistoryActionError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get cardHistoryActionError;

  /// No description provided for @cardHistoryViewAction.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get cardHistoryViewAction;

  /// No description provided for @cardHistoryBreadcrumbCurrent.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get cardHistoryBreadcrumbCurrent;

  /// No description provided for @cardHistoryBoxChip.
  ///
  /// In en, this message translates to:
  /// **'Box {box} / {total}'**
  String cardHistoryBoxChip(int box, int total);

  /// No description provided for @cardHistoryProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Current progress'**
  String get cardHistoryProgressTitle;

  /// No description provided for @cardHistoryBoxStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Box {box}'**
  String cardHistoryBoxStepLabel(int box);

  /// No description provided for @cardHistoryStatDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get cardHistoryStatDue;

  /// No description provided for @cardHistoryStatReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get cardHistoryStatReviews;

  /// No description provided for @cardHistoryStatRecall.
  ///
  /// In en, this message translates to:
  /// **'Recall rate'**
  String get cardHistoryStatRecall;

  /// No description provided for @cardHistoryStatLapses.
  ///
  /// In en, this message translates to:
  /// **'Lapses'**
  String get cardHistoryStatLapses;

  /// No description provided for @cardHistoryStatStreak.
  ///
  /// In en, this message translates to:
  /// **'Correct streak'**
  String get cardHistoryStatStreak;

  /// No description provided for @cardHistoryStatSinceAdded.
  ///
  /// In en, this message translates to:
  /// **'Since added'**
  String get cardHistoryStatSinceAdded;

  /// No description provided for @cardHistoryPercentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String cardHistoryPercentValue(int percent);

  /// No description provided for @cardHistoryStreakValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 in a row} other{{count} in a row}}'**
  String cardHistoryStreakValue(int count);

  /// No description provided for @cardHistorySinceAddedValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{today} =1{1 day} other{{count} days}}'**
  String cardHistorySinceAddedValue(int count);

  /// No description provided for @cardHistoryTimelineHeader.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Timeline · 1 event} other{Timeline · {count} events}}'**
  String cardHistoryTimelineHeader(int count);

  /// No description provided for @cardHistoryChipCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get cardHistoryChipCorrect;

  /// No description provided for @cardHistoryChipRecovered.
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get cardHistoryChipRecovered;

  /// No description provided for @cardHistoryChipForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot'**
  String get cardHistoryChipForgot;

  /// No description provided for @cardHistoryDescCorrect.
  ///
  /// In en, this message translates to:
  /// **'Answered correctly'**
  String get cardHistoryDescCorrect;

  /// No description provided for @cardHistoryDescRecovered.
  ///
  /// In en, this message translates to:
  /// **'Got it back after a slip'**
  String get cardHistoryDescRecovered;

  /// No description provided for @cardHistoryDescForgot.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t recall — reset to box 1'**
  String get cardHistoryDescForgot;

  /// No description provided for @cardHistoryPartialDescription.
  ///
  /// In en, this message translates to:
  /// **'Logged with missing details'**
  String get cardHistoryPartialDescription;

  /// No description provided for @cardHistoryDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String cardHistoryDurationValue(String seconds);

  /// No description provided for @cardHistoryDurationMissing.
  ///
  /// In en, this message translates to:
  /// **'duration not logged'**
  String get cardHistoryDurationMissing;

  /// No description provided for @cardHistoryEventCreatedChip.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get cardHistoryEventCreatedChip;

  /// No description provided for @cardHistoryEventEditedChip.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get cardHistoryEventEditedChip;

  /// No description provided for @cardHistoryEventAudioChip.
  ///
  /// In en, this message translates to:
  /// **'Audio added'**
  String get cardHistoryEventAudioChip;

  /// No description provided for @cardHistoryEventCreatedDescription.
  ///
  /// In en, this message translates to:
  /// **'Card added to {deck}'**
  String cardHistoryEventCreatedDescription(String deck);

  /// No description provided for @cardHistoryEventEditedDescription.
  ///
  /// In en, this message translates to:
  /// **'Card edited'**
  String get cardHistoryEventEditedDescription;

  /// No description provided for @cardHistoryEventAudioDescription.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation recorded'**
  String get cardHistoryEventAudioDescription;

  /// No description provided for @cardHistoryEventResetChip.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get cardHistoryEventResetChip;

  /// No description provided for @cardHistoryEventResetDescription.
  ///
  /// In en, this message translates to:
  /// **'Progress reset to box 1'**
  String get cardHistoryEventResetDescription;

  /// No description provided for @cardHistoryBeginning.
  ///
  /// In en, this message translates to:
  /// **'Beginning of history'**
  String get cardHistoryBeginning;

  /// No description provided for @cardHistoryFilterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter timeline'**
  String get cardHistoryFilterSheetTitle;

  /// No description provided for @cardHistoryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All events'**
  String get cardHistoryFilterAll;

  /// No description provided for @cardHistoryFilterReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews only'**
  String get cardHistoryFilterReviews;

  /// No description provided for @cardHistoryFilterLifecycle.
  ///
  /// In en, this message translates to:
  /// **'Card changes'**
  String get cardHistoryFilterLifecycle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
