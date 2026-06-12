# Decision Tables: folder_detail_test

Test file: `test/presentation/features/folders/folder_detail_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | deck row has `lastStudiedAt` and `dueCount > 0` | deck read model includes `lastStudiedAt`, cards, and due count | Folder Detail renders a loaded deck row | Row shows due badge, cards + relative last-studied meta, compact progress bar, and chevron | C0+C1 |
| DT2 | deck row has no `lastStudiedAt` | deck read model omits `lastStudiedAt` and has `dueCount == 0` | Folder Detail renders a loaded deck row | Row collapses to cards-only meta, still shows progress bar, and hides the due badge and relative last-studied copy | C0+C1 |
| DT3 | subfolder row has `dueCount > 0` | folder read model includes subfolder aggregates with due cards | Folder Detail renders a loaded subfolder row | Row shows due badge, decks + cards metadata, compact progress bar, and chevron | C0+C1 |
| DT4 | subfolder row has `dueCount == 0` | folder read model includes subfolder aggregates without due cards | Folder Detail renders a loaded subfolder row | Row collapses to decks + cards metadata, still shows progress bar, and hides the due badge | C0+C1 |
| DT5 | decks summary shell is shown | deck read model includes counts and due totals | Folder Detail renders the decks summary card | Summary shows mastery-unavailable copy, counts line, real due line, and the Start study CTA shell without a fake new-count value | C0+C1 |
| DT6 | subfolders summary strip is shown | folder read model includes subfolder aggregates | Folder Detail renders the subfolders summary strip | Summary shows the subfolder / cards / due stat strip and the search/sort header that follows it | C0+C1 |
| DT7 | unlocked empty state is shown | folder read model has `contentMode == unlocked` | Folder Detail renders the unlocked empty body | Empty chip, info card, dual creation buttons, and info banner are visible | C0+C1 |
| DT8 | search sheet updates the toolbar state | user taps the Folder Detail search icon | Folder Detail opens the controlled search sheet | Search sheet shows a working `MxSearchField`; typing updates `folderDetailToolbar.searchTerm` and clear resets it | C0+C1 |
| DT9 | sort sheet updates the toolbar state | user taps the Folder Detail sort pill | Folder Detail opens the controlled sort sheet | Sort sheet shows only supported `ContentSortMode` options (`manual`, `name`, `newest`); choosing one updates `folderDetailToolbar.sort` | C0+C1 |
| DT10 | search yields no matches | toolbar search term hides all children | Folder Detail renders the search-empty branch | Search empty state shows the query-aware title and clear action | C0+C1 |

## Decision table: row actions

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT11 | subfolder row long-pressed | subfolder read model and `onShowSubfolderActions` are wired | User long-presses a subfolder row | Shared folder action sheet opens with Rename / Move / Delete and optional Import when the child folder is deck-mode | C0+C1 |
| DT12 | deck row long-pressed | deck read model and `onShowDeckActions` are wired | User long-presses a deck row | Shared deck action sheet opens with Import flashcards / Reorder cards / Delete deck | C0+C1 |
