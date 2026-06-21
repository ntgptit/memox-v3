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
  String get libraryRetryLabel => 'Retry';

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
}
