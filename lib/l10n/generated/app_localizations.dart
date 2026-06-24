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

  /// Label above the tag chips in the card editor Details section.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get cardTagsLabel;

  /// The card-editor chip / field that adds a new tag to the card.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get cardAddTagLabel;

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

  /// Title of the study entry gate empty state when a scope has cards but none are due (deck/folder, srs_review).
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get studyEmptyCaughtUpTitle;

  /// Empty-scope title — the deck has zero flashcards.
  ///
  /// In en, this message translates to:
  /// **'No cards in this deck'**
  String get studyEmptyDeckNoCardsTitle;

  /// Empty-scope body — the deck has zero flashcards.
  ///
  /// In en, this message translates to:
  /// **'Add flashcards to start studying.'**
  String get studyEmptyDeckNoCardsMessage;

  /// Empty-scope body — the deck has cards but none due.
  ///
  /// In en, this message translates to:
  /// **'No cards are due in this deck right now.'**
  String get studyEmptyDeckNoDueMessage;

  /// Empty-scope title — the folder subtree has zero flashcards.
  ///
  /// In en, this message translates to:
  /// **'No cards in this folder'**
  String get studyEmptyFolderNoCardsTitle;

  /// Empty-scope body — the folder subtree has zero flashcards.
  ///
  /// In en, this message translates to:
  /// **'Add a deck and some cards to start studying.'**
  String get studyEmptyFolderNoCardsMessage;

  /// Empty-scope body — the folder subtree has cards but none due.
  ///
  /// In en, this message translates to:
  /// **'No cards are due in this folder right now.'**
  String get studyEmptyFolderNoDueMessage;

  /// Empty-scope title — today's due cards are all reviewed.
  ///
  /// In en, this message translates to:
  /// **'All done for today!'**
  String get studyEmptyTodayAllDoneTitle;

  /// Empty-scope body — today's review is complete.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow to keep your streak going.'**
  String get studyEmptyTodayAllDoneMessage;

  /// Empty-scope title — the user has no flashcards at all.
  ///
  /// In en, this message translates to:
  /// **'No flashcards yet'**
  String get studyEmptyTodayNoContentTitle;

  /// Empty-scope body — the user has no flashcards at all.
  ///
  /// In en, this message translates to:
  /// **'Create a deck and add cards to start studying.'**
  String get studyEmptyTodayNoContentMessage;

  /// Empty-scope title — every eligible card in scope is buried.
  ///
  /// In en, this message translates to:
  /// **'All cards buried for today'**
  String get studyEmptyAllBuriedTitle;

  /// Empty-scope body — buried cards return next day.
  ///
  /// In en, this message translates to:
  /// **'They\'ll return tomorrow.'**
  String get studyEmptyAllBuriedMessage;

  /// Empty-scope title — every card in scope is suspended.
  ///
  /// In en, this message translates to:
  /// **'All cards are suspended'**
  String get studyEmptyAllSuspendedTitle;

  /// Empty-scope body — all cards suspended.
  ///
  /// In en, this message translates to:
  /// **'Resume some cards to start studying.'**
  String get studyEmptyAllSuspendedMessage;

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

  /// Title of the start-over confirm dialog at the study entry gate.
  ///
  /// In en, this message translates to:
  /// **'Start over?'**
  String get studyStartOverTitle;

  /// Body of the start-over confirm dialog.
  ///
  /// In en, this message translates to:
  /// **'This discards your current progress for this session and starts fresh.'**
  String get studyStartOverMessage;

  /// Empty-scope CTA that re-enters the gate as a new-learning session.
  ///
  /// In en, this message translates to:
  /// **'Study new instead'**
  String get studyActionStudyNew;

  /// Caption above the front side of a review card (fallback when the deck language is unknown).
  ///
  /// In en, this message translates to:
  /// **'FRONT'**
  String get studyReviewFrontLabel;

  /// Caption above the back side of a review card.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get studyReviewBackLabel;

  /// Title shown when a study session has no cards.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review'**
  String get studyReviewEmptyTitle;

  /// Body shown when a study session has no cards.
  ///
  /// In en, this message translates to:
  /// **'This session has no cards.'**
  String get studyReviewEmptyMessage;

  /// Title of the study session load-error state.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the session'**
  String get studyReviewLoadFailedTitle;

  /// Body of the study session load-error state.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this study session.'**
  String get studyReviewLoadFailedMessage;

  /// Hint under the review card explaining the swipe-grade gesture (shown for the first few cards).
  ///
  /// In en, this message translates to:
  /// **'Swipe right if you knew it, left if you didn\'t'**
  String get studyReviewSwipeHint;

  /// Title of the end-of-session surface when every card is graded.
  ///
  /// In en, this message translates to:
  /// **'Review complete'**
  String get studyReviewFinishTitle;

  /// Body of the end-of-session surface.
  ///
  /// In en, this message translates to:
  /// **'You\'ve gone through every card in this session.'**
  String get studyReviewFinishMessage;

  /// Action that finalizes the session and shows the result.
  ///
  /// In en, this message translates to:
  /// **'Finish session'**
  String get studyReviewFinishAction;

  /// Title of the mid-session exit-confirm dialog (§exit-session).
  ///
  /// In en, this message translates to:
  /// **'Exit study session?'**
  String get studyExitTitle;

  /// Body of the exit-confirm dialog reassuring the user progress is kept.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved and you can resume later. Leave this session?'**
  String get studyExitMessage;

  /// Confirm action that leaves the study session.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get studyExitConfirm;

  /// Cancel action that stays in the study session.
  ///
  /// In en, this message translates to:
  /// **'Keep studying'**
  String get studyExitCancel;

  /// Card-actions sheet: bury the current card until tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Bury until tomorrow'**
  String get studyActionBury;

  /// Card-actions sheet: suspend the current card.
  ///
  /// In en, this message translates to:
  /// **'Suspend card'**
  String get studyActionSuspend;

  /// App-bar title of the study result screen.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get studyResultTitle;

  /// Loading message while the result summary loads.
  ///
  /// In en, this message translates to:
  /// **'Saving your results…'**
  String get studyResultLoading;

  /// Celebratory headline on the result screen.
  ///
  /// In en, this message translates to:
  /// **'Nice work!'**
  String get studyResultHeroTitle;

  /// Reviewed-count subtitle on the result hero.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card reviewed} other{{count} cards reviewed}}'**
  String studyResultCardsReviewed(int count);

  /// Label for the passed-count stat.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get studyResultCorrect;

  /// Label for the forgot-count stat.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get studyResultWrong;

  /// Label for the answered/total stat.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get studyResultAnswered;

  /// Primary action that leaves the result screen.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get studyResultDone;

  /// Error title when the result summary fails to load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your results'**
  String get studyResultLoadFailedTitle;

  /// Error body when the result summary fails to load.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading this session\'s summary.'**
  String get studyResultLoadFailedMessage;

  /// Banner shown when the session summary failed to finalize.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your results. Your progress is kept locally.'**
  String get studyResultSaveFailedBanner;

  /// Action that re-runs finalize on the save-failed result.
  ///
  /// In en, this message translates to:
  /// **'Retry save'**
  String get studyResultRetry;

  /// Title of the defensive zero-answers result state.
  ///
  /// In en, this message translates to:
  /// **'No cards answered'**
  String get studyResultDefensiveTitle;

  /// Body of the defensive zero-answers result state.
  ///
  /// In en, this message translates to:
  /// **'This session has no recorded answers.'**
  String get studyResultDefensiveMessage;

  /// Headline on the Match board surface.
  ///
  /// In en, this message translates to:
  /// **'Match the pairs'**
  String get studyMatchTitle;

  /// Prompt subtitle under the Match title.
  ///
  /// In en, this message translates to:
  /// **'Tap a term, then its meaning.'**
  String get studyMatchSubtitle;

  /// Match board status line below the grid.
  ///
  /// In en, this message translates to:
  /// **'{matched} matched · {left} left'**
  String studyMatchProgress(int matched, int left);

  /// Overline prompt above the term on the Guess screen.
  ///
  /// In en, this message translates to:
  /// **'What does this mean?'**
  String get studyGuessPrompt;

  /// Hint under the auto-advance countdown bar on the Guess screen — tap to skip the wait.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue'**
  String get studyGuessTapToContinue;

  /// Overline prompt above the term on the Recall screen.
  ///
  /// In en, this message translates to:
  /// **'Recall the meaning'**
  String get studyRecallPrompt;

  /// Calm hint shown before the back is revealed on the Recall screen.
  ///
  /// In en, this message translates to:
  /// **'Say it in your head, then reveal.'**
  String get studyRecallHint;

  /// Primary CTA on the Recall screen that reveals the back.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get studyRecallShowAnswer;

  /// Overline on the revealed answer card on the Recall screen.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get studyRecallAnswerLabel;

  /// Caption above the self-grade row on the Recall screen.
  ///
  /// In en, this message translates to:
  /// **'How well did you know it?'**
  String get studyRecallGradePrompt;

  /// Self-grade button on the Recall screen — the learner did not recall the card (records forgot).
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get studyRecallMissed;

  /// Self-grade button on the Recall screen — the learner recalled the card (records perfect).
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get studyRecallGotIt;

  /// Overline prompt above the hint on the Fill screen.
  ///
  /// In en, this message translates to:
  /// **'Type the answer'**
  String get studyFillPrompt;

  /// Overline above the answer field on the Fill screen.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get studyFillAnswerLabel;

  /// Primary CTA on the Fill screen that grades the typed answer.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get studyFillCheck;

  /// Wrong-answer feedback line on the Fill screen.
  ///
  /// In en, this message translates to:
  /// **'Not quite — see the answer below.'**
  String get studyFillWrongMessage;

  /// Overline on the revealed correct-answer card after a wrong Fill answer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get studyFillCorrectLabel;

  /// Button on Fill wrong-feedback that clears the input and returns to typing.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get studyFillRetry;

  /// Button on the Fill screen that records the grade and advances to the next card.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get studyFillNext;

  /// Link on Fill wrong-feedback that overrides the answer to a recovered grade.
  ///
  /// In en, this message translates to:
  /// **'Mark correct'**
  String get studyFillMarkCorrect;

  /// Button on the Fill screen that reveals one more leading character of the answer (caps the grade at recovered).
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get studyFillHint;

  /// Title for the Stats screen and its bottom-nav tab (screen 18).
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// Overline (all-caps) label above the weekly review-activity column chart on the Stats screen.
  ///
  /// In en, this message translates to:
  /// **'CARDS THIS WEEK'**
  String get statsCardsThisWeekLabel;

  /// Section header above the per-deck mastery list on the Stats screen.
  ///
  /// In en, this message translates to:
  /// **'Per-deck mastery'**
  String get statsPerDeckMasteryTitle;

  /// Trailing mastery percent on a per-deck mastery row.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String statsMasteryPercent(int percent);

  /// Card count used in the Stats weekly-chart accessibility label.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String statsCardsCount(int count);

  /// Empty hint inside the per-deck mastery card when no deck has cards yet.
  ///
  /// In en, this message translates to:
  /// **'No decks to show yet'**
  String get statsNoDecksHint;

  /// Stats screen error-state title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your stats'**
  String get statsLoadFailedTitle;

  /// Stats screen error-state body.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading your stats.'**
  String get statsLoadFailedMessage;

  /// App-bar title + breadcrumb leaf for the Card History screen (screen 09).
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get cardHistoryTitle;

  /// Overline (all-caps) above the Card History activity feed.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY'**
  String get cardHistoryActivityLabel;

  /// Header stat label: lifetime review count.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get cardHistoryReviewsLabel;

  /// Header stat label: lifetime accuracy/retention percent.
  ///
  /// In en, this message translates to:
  /// **'Retention'**
  String get cardHistoryRetentionLabel;

  /// Header stat label: average measured time per attempt.
  ///
  /// In en, this message translates to:
  /// **'Avg time'**
  String get cardHistoryAvgTimeLabel;

  /// Placeholder for a Card History header stat with no data yet (em dash).
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get cardHistoryStatEmpty;

  /// Leitner box chip on the Card History header.
  ///
  /// In en, this message translates to:
  /// **'Box {box}'**
  String cardHistoryBoxChip(int box);

  /// Per-attempt / average duration in seconds (value already formatted, e.g. 5.4).
  ///
  /// In en, this message translates to:
  /// **'{value}s'**
  String cardHistoryDurationSeconds(String value);

  /// Activity-row meta line combining a relative day and a 24h time.
  ///
  /// In en, this message translates to:
  /// **'{relative} · {time}'**
  String cardHistoryRowMeta(String relative, String time);

  /// Relative day label for an event that occurred today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get cardHistoryToday;

  /// Relative day label for an event that occurred yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get cardHistoryYesterday;

  /// Relative day label for an event within the past week.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day ago} other{{days} days ago}}'**
  String cardHistoryDaysAgo(int days);

  /// Activity row title for a perfect attempt (box advanced).
  ///
  /// In en, this message translates to:
  /// **'Reviewed · Correct'**
  String get cardHistoryAttemptCorrect;

  /// Activity row title for a recovered attempt (corrected after a slip; box held).
  ///
  /// In en, this message translates to:
  /// **'Reviewed · Recovered'**
  String get cardHistoryAttemptRecovered;

  /// Activity row title for a forgot attempt (box reset to 1).
  ///
  /// In en, this message translates to:
  /// **'Reviewed · Forgot'**
  String get cardHistoryAttemptForgot;

  /// Activity row title for the card-created lifecycle event.
  ///
  /// In en, this message translates to:
  /// **'Card created'**
  String get cardHistoryEventCreated;

  /// Activity row title for the card-edited lifecycle event.
  ///
  /// In en, this message translates to:
  /// **'Card edited'**
  String get cardHistoryEventEdited;

  /// Activity row title for the progress-reset lifecycle event.
  ///
  /// In en, this message translates to:
  /// **'Progress reset'**
  String get cardHistoryEventReset;

  /// Activity row title for the audio-added lifecycle event (reserved).
  ///
  /// In en, this message translates to:
  /// **'Audio added'**
  String get cardHistoryEventAudio;

  /// Empty-state title when a card has no reviews yet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get cardHistoryEmptyTitle;

  /// Empty-state body when a card has no reviews yet.
  ///
  /// In en, this message translates to:
  /// **'Study this card and your reviews will show up here.'**
  String get cardHistoryEmptyMessage;

  /// Card History error-state title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load history'**
  String get cardHistoryLoadFailedTitle;

  /// Card History error-state body.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t fetch this card\'s activity.'**
  String get cardHistoryLoadFailedMessage;

  /// Shared retry action on an operation-failed dialog.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// Shared dismiss action on an operation-failed dialog.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// App-bar title for the Tag Management screen (screen 11).
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagManagementTitle;

  /// Overline (all-caps) showing the total tag count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 TAG} other{{count} TAGS}}'**
  String tagManagementCountLabel(int count);

  /// Card count under a tag name.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String tagManagementCardCount(int count);

  /// Tooltip for the per-tag overflow (kebab) button.
  ///
  /// In en, this message translates to:
  /// **'Tag actions'**
  String get tagManagementActionsTooltip;

  /// Header of the per-tag action sheet.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count, plural, =1{1 card} other{{count} cards}}'**
  String tagManagementSheetHeader(String name, int count);

  /// Rename action in the per-tag sheet.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get tagManagementRenameAction;

  /// Merge action in the per-tag sheet.
  ///
  /// In en, this message translates to:
  /// **'Merge into…'**
  String get tagManagementMergeAction;

  /// Delete action in the per-tag sheet.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tagManagementDeleteAction;

  /// Title of the rename-tag dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename tag'**
  String get tagManagementRenameTitle;

  /// Field label in the rename-tag dialog.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagManagementRenameFieldLabel;

  /// Confirm button in the rename-tag dialog.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tagManagementRenameConfirm;

  /// Confirm button when a rename collides with an existing tag (becomes a merge).
  ///
  /// In en, this message translates to:
  /// **'Merge tags'**
  String get tagManagementMergeConfirm;

  /// Inline prompt shown when a typed rename collides with an existing tag.
  ///
  /// In en, this message translates to:
  /// **'A tag “{name}” already exists. Merge them?'**
  String tagManagementMergePrompt(String name);

  /// Title of the merge-target picker sheet.
  ///
  /// In en, this message translates to:
  /// **'Merge “{name}” into'**
  String tagManagementMergeSheetTitle(String name);

  /// Placeholder of the bottom tag search dock.
  ///
  /// In en, this message translates to:
  /// **'Search tags'**
  String get tagManagementSearchHint;

  /// Empty-state title when no tags exist.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get tagManagementEmptyTitle;

  /// Empty-state body when no tags exist.
  ///
  /// In en, this message translates to:
  /// **'Add tags to your cards and they\'ll appear here to manage.'**
  String get tagManagementEmptyMessage;

  /// No-results title when a search matches no tags.
  ///
  /// In en, this message translates to:
  /// **'No tags found'**
  String get tagManagementSearchEmptyTitle;

  /// No-results body when a search matches no tags.
  ///
  /// In en, this message translates to:
  /// **'No tags match your search.'**
  String get tagManagementSearchEmptyMessage;

  /// Tag-list load-error title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load tags'**
  String get tagManagementLoadFailedTitle;

  /// Tag-list load-error body.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading your tags.'**
  String get tagManagementLoadFailedMessage;

  /// Title of the delete-tag confirm dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete tag “{name}”?'**
  String tagManagementDeleteTitle(String name);

  /// Body of the delete-tag confirm dialog.
  ///
  /// In en, this message translates to:
  /// **'The tag is removed from {count, plural, =1{1 card} other{{count} cards}}. The cards themselves stay. This can\'t be undone.'**
  String tagManagementDeleteMessage(int count);

  /// Confirm button in the delete-tag dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tagManagementDeleteConfirm;

  /// Busy overlay label while renaming a tag.
  ///
  /// In en, this message translates to:
  /// **'Renaming…'**
  String get tagManagementBusyRenaming;

  /// Busy overlay label while merging tags.
  ///
  /// In en, this message translates to:
  /// **'Merging tags…'**
  String get tagManagementBusyMerging;

  /// Busy overlay label while deleting a tag.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get tagManagementBusyDeleting;

  /// Op-error title when a rename fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t rename tag'**
  String get tagManagementRenameFailedTitle;

  /// Op-error body when a rename fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong updating this tag. Your tags are unchanged.'**
  String get tagManagementRenameFailedMessage;

  /// Op-error title when a merge fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t merge tags'**
  String get tagManagementMergeFailedTitle;

  /// Op-error body when a merge fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong merging these tags. Your tags are unchanged.'**
  String get tagManagementMergeFailedMessage;

  /// Op-error title when a delete fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete tag'**
  String get tagManagementDeleteFailedTitle;

  /// Op-error body when a delete fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong deleting this tag. Your tags are unchanged.'**
  String get tagManagementDeleteFailedMessage;
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
