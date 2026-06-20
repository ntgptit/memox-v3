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

  /// Retry action on the Library error state.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get libraryRetryLabel;

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
