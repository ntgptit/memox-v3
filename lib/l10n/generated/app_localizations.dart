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

  /// Application name shown as the OS task/window title. Brand name; keep untranslated.
  ///
  /// In en, this message translates to:
  /// **'MemoX'**
  String get appTitle;

  /// One-line description of the app for about/store contexts.
  ///
  /// In en, this message translates to:
  /// **'Local-first flashcard app'**
  String get appDescription;

  /// Bottom-navigation label and title for the Home/dashboard tab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Bottom-navigation label and title for the Library tab (folders/decks).
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// Bottom-navigation label and title for the Progress/stats tab.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// Bottom-navigation label and title for the Settings tab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Hint text for the Library inline folder search field.
  ///
  /// In en, this message translates to:
  /// **'Search folders'**
  String get librarySearchHint;

  /// Section header counting the top-level folders.
  ///
  /// In en, this message translates to:
  /// **'{count} folders'**
  String libraryFolderCountHeader(int count);

  /// Shown while the Library folders are loading.
  ///
  /// In en, this message translates to:
  /// **'Loading folders'**
  String get libraryLoadingLabel;

  /// Title of the true-empty Library state.
  ///
  /// In en, this message translates to:
  /// **'Start your library'**
  String get libraryEmptyTitle;

  /// Body of the true-empty Library state.
  ///
  /// In en, this message translates to:
  /// **'Folders keep related decks together. Add one to organize your decks.'**
  String get libraryEmptyMessage;

  /// Title of the Library error state.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your library'**
  String get libraryLoadFailedTitle;

  /// Body of the Library error state.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading your folders.'**
  String get libraryLoadFailedMessage;

  /// Shared Retry action across error / failure surfaces (library, lists, editor save-failed).
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetryLabel;

  /// Title when a search matches no folders.
  ///
  /// In en, this message translates to:
  /// **'No folders found'**
  String get librarySearchNoResultsTitle;

  /// Body when a search matches no folders.
  ///
  /// In en, this message translates to:
  /// **'No folders match \"{term}\".'**
  String librarySearchNoResultsMessage(String term);

  /// Clears the active Library search.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get librarySearchClearLabel;

  /// Tooltip for the folder-row kebab button.
  ///
  /// In en, this message translates to:
  /// **'Folder actions'**
  String get libraryOverflowTooltip;

  /// Folder metadata: direct deck count.
  ///
  /// In en, this message translates to:
  /// **'{count} decks'**
  String folderMetaDecks(int count);

  /// Folder metadata: direct subfolder count.
  ///
  /// In en, this message translates to:
  /// **'{count} subfolders'**
  String folderMetaSubfolders(int count);

  /// Folder metadata: recursive card count.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String folderMetaCards(int count);

  /// Folder due-card badge.
  ///
  /// In en, this message translates to:
  /// **'{count} due'**
  String folderDueBadge(int count);

  /// Folder action-sheet row: rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get folderActionRename;

  /// Folder action-sheet row: move.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get folderActionMove;

  /// Folder action-sheet row: delete.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get folderActionDelete;

  /// Generic cancel action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Title of the rename-folder dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get folderRenameTitle;

  /// Name field label in the rename-folder dialog.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderRenameFieldLabel;

  /// Confirm action in the rename-folder dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get folderRenameConfirm;

  /// Snackbar after a successful rename.
  ///
  /// In en, this message translates to:
  /// **'Folder renamed'**
  String get folderRenamedSnack;

  /// Title of the delete-folder confirm dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete this folder?'**
  String get folderDeleteTitle;

  /// Delete-folder confirm body stating the blast radius.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes this folder, {decks} decks and {cards} cards, plus all study progress. This can\'t be undone.'**
  String folderDeleteBlastRadius(int decks, int cards);

  /// Confirm action in the delete-folder dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get folderDeleteConfirm;

  /// Snackbar after a successful delete.
  ///
  /// In en, this message translates to:
  /// **'Folder deleted'**
  String get folderDeletedSnack;

  /// Title of the move-folder destination picker.
  ///
  /// In en, this message translates to:
  /// **'Move folder'**
  String get folderMoveTitle;

  /// The Library root row in the move picker.
  ///
  /// In en, this message translates to:
  /// **'Library (root)'**
  String get folderMoveRootLabel;

  /// Move picker: blocked because it would create a cycle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t move into itself or a subfolder'**
  String get folderMoveBlockCycle;

  /// Move picker: blocked because the destination is decks-locked.
  ///
  /// In en, this message translates to:
  /// **'This folder holds decks'**
  String get folderMoveBlockLockedDecks;

  /// Snackbar after a successful move.
  ///
  /// In en, this message translates to:
  /// **'Folder moved'**
  String get folderMovedSnack;

  /// Validation error: empty folder name.
  ///
  /// In en, this message translates to:
  /// **'Enter a folder name.'**
  String get folderErrorNameEmpty;

  /// Validation error: duplicate sibling name.
  ///
  /// In en, this message translates to:
  /// **'A folder with this name already exists here.'**
  String get folderErrorNameDuplicate;

  /// Error: the folder was not found.
  ///
  /// In en, this message translates to:
  /// **'That folder no longer exists.'**
  String get folderErrorNotFound;

  /// Error: move would create a cycle.
  ///
  /// In en, this message translates to:
  /// **'You can\'t move a folder into itself or one of its subfolders.'**
  String get folderErrorMoveCycle;

  /// Error: destination is decks-locked.
  ///
  /// In en, this message translates to:
  /// **'That folder holds decks, so it can\'t take a subfolder.'**
  String get folderErrorMoveLockedDecks;

  /// Generic fallback error for a folder action.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get folderActionGenericError;

  /// Folder metadata when the folder has no decks or subfolders yet.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get folderMetaEmpty;

  /// Tooltip for the Library app-bar search icon that opens search mode.
  ///
  /// In en, this message translates to:
  /// **'Search folders'**
  String get librarySearchTooltip;

  /// Tooltip for the Library create-folder FAB.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get libraryCreateFolderTooltip;

  /// Label of the create-folder CTA on the true-empty Library state.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get libraryCreateFolderLabel;

  /// Title of the create-folder dialog.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get folderCreateTitle;

  /// Name field label in the create-folder dialog.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderCreateNameLabel;

  /// Color picker label in the create-folder dialog.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get folderCreateColorLabel;

  /// Icon picker label in the create-folder dialog.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get folderCreateIconLabel;

  /// Confirm action in the create-folder dialog.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get folderCreateConfirm;

  /// Snackbar after a successful folder create.
  ///
  /// In en, this message translates to:
  /// **'Folder created'**
  String get folderCreatedSnack;

  /// Tooltip for the folder-detail search icon.
  ///
  /// In en, this message translates to:
  /// **'Search this folder'**
  String get folderDetailSearchTooltip;

  /// Hint for the folder-detail search field.
  ///
  /// In en, this message translates to:
  /// **'Search this folder'**
  String get folderDetailSearchHint;

  /// Folder-detail error title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load folder'**
  String get folderDetailLoadFailedTitle;

  /// Folder-detail error body.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach this folder. Check your connection and try again.'**
  String get folderDetailLoadFailedMessage;

  /// Title of the empty (unlocked) folder state.
  ///
  /// In en, this message translates to:
  /// **'Empty folder'**
  String get folderDetailEmptyTitle;

  /// Body of the empty folder state.
  ///
  /// In en, this message translates to:
  /// **'Add a deck of cards, or nest a subfolder to keep things organized.'**
  String get folderDetailEmptyMessage;

  /// Create-deck CTA / FAB tooltip on folder detail.
  ///
  /// In en, this message translates to:
  /// **'Create deck'**
  String get folderDetailCreateDeck;

  /// Create-subfolder CTA / FAB tooltip on folder detail.
  ///
  /// In en, this message translates to:
  /// **'Create subfolder'**
  String get folderDetailCreateSubfolder;

  /// Folder-detail section header counting decks.
  ///
  /// In en, this message translates to:
  /// **'{count} decks'**
  String folderDetailDecksHeader(int count);

  /// Folder-detail section header counting subfolders.
  ///
  /// In en, this message translates to:
  /// **'{count} folders'**
  String folderDetailFoldersHeader(int count);

  /// Folder-detail stat label: decks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get folderStatDecks;

  /// Folder-detail stat label: cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get folderStatCards;

  /// Folder-detail stat label: due cards.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get folderStatDue;

  /// Folder-detail stat label: subfolders.
  ///
  /// In en, this message translates to:
  /// **'Subfolders'**
  String get folderStatSubfolders;

  /// Title of the create-deck dialog.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get deckCreateTitle;

  /// Name field label in the create-deck dialog.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get deckCreateNameLabel;

  /// Language picker label in the create-deck dialog.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get deckCreateLanguageLabel;

  /// Confirm action in the create-deck dialog.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get deckCreateConfirm;

  /// Deck target-language choice: Korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get deckLanguageKorean;

  /// Deck target-language choice: English.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get deckLanguageEnglish;

  /// Deck action-sheet row: rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get deckActionRename;

  /// Deck action-sheet row: delete.
  ///
  /// In en, this message translates to:
  /// **'Delete deck'**
  String get deckActionDelete;

  /// Tooltip for the deck overflow action.
  ///
  /// In en, this message translates to:
  /// **'Deck options'**
  String get deckOverflowTooltip;

  /// Snackbar after a successful deck create.
  ///
  /// In en, this message translates to:
  /// **'Deck created'**
  String get deckCreatedSnack;

  /// Snackbar after a successful deck rename.
  ///
  /// In en, this message translates to:
  /// **'Deck renamed'**
  String get deckRenamedSnack;

  /// Snackbar after a successful deck delete.
  ///
  /// In en, this message translates to:
  /// **'Deck deleted'**
  String get deckDeletedSnack;

  /// Delete-deck confirm title.
  ///
  /// In en, this message translates to:
  /// **'Delete this deck?'**
  String get deckDeleteTitle;

  /// Delete-deck confirm body.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes this deck and its {count} cards, plus all study progress. This can\'t be undone.'**
  String deckDeleteMessage(int count);

  /// Confirm action in the delete-deck dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deckDeleteConfirm;

  /// Tooltip for the flashcard-list search icon.
  ///
  /// In en, this message translates to:
  /// **'Search cards'**
  String get flashcardSearchTooltip;

  /// Hint for the flashcard-list search field.
  ///
  /// In en, this message translates to:
  /// **'Search cards'**
  String get flashcardSearchHint;

  /// Flashcard-list error title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load cards'**
  String get flashcardLoadFailedTitle;

  /// Flashcard-list error body.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach this deck. Check your connection and try again.'**
  String get flashcardLoadFailedMessage;

  /// Title of the empty-deck state.
  ///
  /// In en, this message translates to:
  /// **'No cards yet'**
  String get flashcardEmptyTitle;

  /// Body of the empty-deck state.
  ///
  /// In en, this message translates to:
  /// **'Add your first flashcard to start studying.'**
  String get flashcardEmptyMessage;

  /// Add-card CTA / FAB tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get flashcardAddCardLabel;

  /// Flashcard-list section header counting cards.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String flashcardCountHeader(int count);

  /// Validation error: empty front/back.
  ///
  /// In en, this message translates to:
  /// **'Front and back are both required.'**
  String get flashcardErrorEmpty;

  /// Validation error: duplicate card.
  ///
  /// In en, this message translates to:
  /// **'A card with this front and back already exists.'**
  String get flashcardErrorDuplicate;

  /// Error: card/deck not found.
  ///
  /// In en, this message translates to:
  /// **'That card no longer exists.'**
  String get flashcardErrorNotFound;

  /// Generic fallback error for a flashcard action.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get flashcardActionGenericError;

  /// Title of the add-card dialog.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get cardCreateTitle;

  /// Title of the edit-card dialog.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get cardEditTitle;

  /// Front field label in the card dialog.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get cardFrontLabel;

  /// Back field label in the card dialog.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cardBackLabel;

  /// Confirm action in the add-card dialog.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get cardCreateConfirm;

  /// Confirm action in the edit-card dialog.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get cardEditConfirm;

  /// Snackbar after a successful card create.
  ///
  /// In en, this message translates to:
  /// **'Card added'**
  String get cardCreatedSnack;

  /// Snackbar after a successful card edit.
  ///
  /// In en, this message translates to:
  /// **'Card saved'**
  String get cardSavedSnack;

  /// Delete-card confirm title.
  ///
  /// In en, this message translates to:
  /// **'Delete this card?'**
  String get cardDeleteTitle;

  /// Delete-card confirm body.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes this card and its study progress. This can\'t be undone.'**
  String get cardDeleteMessage;

  /// Confirm action in the delete-card dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cardDeleteConfirm;

  /// Snackbar after a successful card delete.
  ///
  /// In en, this message translates to:
  /// **'Card deleted'**
  String get cardDeletedSnack;

  /// Title/label for the top-level global Search destination (bottom-nav tab).
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// Placeholder in the bottom global-search field.
  ///
  /// In en, this message translates to:
  /// **'Search everything'**
  String get searchDockHint;

  /// Title of the global-search idle/empty prompt before a query is entered.
  ///
  /// In en, this message translates to:
  /// **'Search your library'**
  String get searchIdleTitle;

  /// Body of the global-search idle/empty prompt.
  ///
  /// In en, this message translates to:
  /// **'Find folders, decks, and cards.'**
  String get searchIdleMessage;

  /// Title when a global search returns nothing.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get searchNoResultsTitle;

  /// Body when a global search returns nothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”. Try a different word or check the spelling.'**
  String searchNoResultsMessage(String query);

  /// Title of the global-search error state.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailedTitle;

  /// Body of the global-search error state.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t run that search just now.'**
  String get searchFailedMessage;

  /// Retry action on the global-search error state.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get searchRetry;

  /// Global-search results section header for folder matches.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get searchSectionFolders;

  /// Global-search results section header for deck matches.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get searchSectionDecks;

  /// Global-search results section header for flashcard matches.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get searchSectionFlashcards;

  /// Affordance shown when a section has more matches than the per-section cap.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String searchMoreCount(int count);

  /// Dashboard due-summary title — count of cards due.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card due} other{{count} cards due}}'**
  String dashboardCardsDue(int count);

  /// Dashboard due-summary subtitle — number of decks holding due cards.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 deck} other{{count} decks}}'**
  String dashboardDecksWithDue(int count);

  /// Dashboard due-summary title when nothing is due.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get dashboardCaughtUpTitle;

  /// Dashboard due-summary subtitle when nothing is due.
  ///
  /// In en, this message translates to:
  /// **'Nothing due right now.'**
  String get dashboardCaughtUpMessage;

  /// Subtitle of the Dashboard shortcut to the Progress screen.
  ///
  /// In en, this message translates to:
  /// **'Goal, streak & accuracy'**
  String get dashboardProgressShortcutSub;

  /// Subtitle of the Dashboard shortcut to the Library.
  ///
  /// In en, this message translates to:
  /// **'Browse folders & decks'**
  String get dashboardLibraryShortcutSub;

  /// Dashboard error-state title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your dashboard'**
  String get dashboardLoadFailedTitle;

  /// Dashboard error-state body.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading today\'s summary.'**
  String get dashboardLoadFailedMessage;

  /// Label of the Library Overview root anchor (the top of the folder hierarchy), shown with a home icon under the app bar.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get libraryRootLabel;

  /// Tooltip for the sort icon that opens the sort sheet on content screens.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// Title of the content sort bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortSheetTitle;

  /// Sort option: the user-controlled manual order (sort_order).
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get sortModeManual;

  /// Sort option: by name, ascending.
  ///
  /// In en, this message translates to:
  /// **'Name (A–Z)'**
  String get sortModeName;

  /// Sort option: most recently created first.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortModeNewest;

  /// Deck action-sheet row: move the deck to another folder.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get deckActionMove;

  /// Title of the move-deck destination picker.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get deckMoveTitle;

  /// Deck move picker: blocked because the destination holds subfolders and cannot take a deck.
  ///
  /// In en, this message translates to:
  /// **'This folder holds subfolders'**
  String get deckMoveBlockSubfolders;

  /// Snackbar after a successful deck move.
  ///
  /// In en, this message translates to:
  /// **'Deck moved'**
  String get deckMovedSnack;

  /// Snackbar when there is no other folder a deck can move into.
  ///
  /// In en, this message translates to:
  /// **'No other folder can hold this deck yet.'**
  String get deckMoveNoTargets;

  /// Deck row: studied less than a minute ago (reads as '{n} cards · just now').
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get deckLastStudiedJustNow;

  /// Deck row: last studied n minutes ago (compact).
  ///
  /// In en, this message translates to:
  /// **'last {count}m ago'**
  String deckLastStudiedMinutes(int count);

  /// Deck row: last studied n hours ago (compact).
  ///
  /// In en, this message translates to:
  /// **'last {count}h ago'**
  String deckLastStudiedHours(int count);

  /// Deck row: last studied n days ago (compact).
  ///
  /// In en, this message translates to:
  /// **'last {count}d ago'**
  String deckLastStudiedDays(int count);

  /// Deck row: last studied n weeks ago (compact).
  ///
  /// In en, this message translates to:
  /// **'last {count}w ago'**
  String deckLastStudiedWeeks(int count);

  /// Generic done/confirm action that exits a mode.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Deck overflow sheet: enter card reorder mode.
  ///
  /// In en, this message translates to:
  /// **'Reorder cards'**
  String get flashcardReorderCardsAction;

  /// App-bar title in card reorder mode.
  ///
  /// In en, this message translates to:
  /// **'Reorder · {deck}'**
  String flashcardReorderTitle(String deck);

  /// Instruction shown above the list in card reorder mode.
  ///
  /// In en, this message translates to:
  /// **'Drag the handles to reorder cards.'**
  String get flashcardReorderHint;

  /// Count overline in card reorder mode.
  ///
  /// In en, this message translates to:
  /// **'{count} cards · drag to reorder'**
  String flashcardReorderCountHeader(int count);

  /// Flashcard-row SRS subtitle for a never-studied (NEW) card.
  ///
  /// In en, this message translates to:
  /// **'New · not studied'**
  String get flashcardStateNew;

  /// Flashcard-row SRS subtitle: SRS box + days until the card is next due.
  ///
  /// In en, this message translates to:
  /// **'Box {box} · due in {days}d'**
  String flashcardStateBoxDueIn(int box, int days);

  /// Flashcard-row SRS subtitle: SRS box, card due today or overdue.
  ///
  /// In en, this message translates to:
  /// **'Box {box} · due today'**
  String flashcardStateBoxDueToday(int box);

  /// Title of the discard-changes confirm when closing the card editor with unsaved edits.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get cardDiscardTitle;

  /// Message of the card-editor discard-changes confirm.
  ///
  /// In en, this message translates to:
  /// **'Your edits to this card haven\'t been saved.'**
  String get cardDiscardMessage;

  /// Destructive confirm action of the card-editor discard-changes dialog.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get cardDiscardConfirm;

  /// Tooltip for the trash/delete icon in the edit-mode card editor app bar.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get cardDeleteTooltip;

  /// Header of the optional-fields expander in the card editor.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get cardDetailsLabel;

  /// Muted hint beside the card-editor Details expander header when collapsed.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get cardDetailsOptional;

  /// Muted field summary beside the card-editor Details expander header when expanded.
  ///
  /// In en, this message translates to:
  /// **'example · pronunciation · hint'**
  String get cardDetailsSummary;

  /// Optional example-sentence field label in the card editor.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get cardExampleLabel;

  /// Optional pronunciation field label in the card editor.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get cardPronunciationLabel;

  /// Optional hint field label in the card editor.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get cardHintLabel;

  /// Inline banner message when saving a card fails in the editor.
  ///
  /// In en, this message translates to:
  /// **'Changes couldn\'t be saved.'**
  String get cardSaveFailedMessage;

  /// Title of the card editor load-error state when the card can't be fetched.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load card'**
  String get cardLoadFailedTitle;

  /// Body of the card editor load-error state.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t fetch this card to edit.'**
  String get cardLoadFailedMessage;

  /// Generic back navigation action.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// App-bar title of the study entry gate.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get studyEntryTitle;

  /// App-bar title of the active study session.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get studySessionTitle;

  /// Placeholder body of the study session shell (WP-SR1a).
  ///
  /// In en, this message translates to:
  /// **'Review session — coming soon.'**
  String get studySessionPlaceholder;

  /// Loading caption while the study entry gate resolves the scope.
  ///
  /// In en, this message translates to:
  /// **'Preparing study…'**
  String get studyPreparing;

  /// Title of the study entry gate error state.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start study'**
  String get studyEntryErrorTitle;

  /// Body of the study entry gate error state.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t prepare this study session. Please try again.'**
  String get studyEntryErrorMessage;

  /// Generic empty-scope title at the study entry gate (WP-SR1a; per-reason matrix is WP-SR1b).
  ///
  /// In en, this message translates to:
  /// **'Nothing to study right now'**
  String get studyEmptyGenericTitle;

  /// Generic empty-scope body at the study entry gate.
  ///
  /// In en, this message translates to:
  /// **'There are no cards to study in this scope yet.'**
  String get studyEmptyGenericMessage;

  /// Title of the resume-or-start-over choice at the study entry gate.
  ///
  /// In en, this message translates to:
  /// **'Resume your session?'**
  String get studyResumeTitle;

  /// Body of the resume-or-start-over choice.
  ///
  /// In en, this message translates to:
  /// **'You have an unfinished study session for this scope.'**
  String get studyResumeMessage;

  /// Resume the existing study session.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get studyResumeAction;

  /// Discard the resumable session and start a fresh one.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get studyStartOverAction;
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
