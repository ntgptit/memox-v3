# Decision Tables: flashcard_editor_screen_test

Test file: `test/presentation/features/flashcards/flashcard_editor_screen_test.dart`

## Decision table

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | initial render | create screen opens on a deck | render the screen | front/back are present, save is disabled, the optional section is collapsed, and the tags row is visible | C0+C1 |
| DT2 | optional fields | create screen is open | tap More fields | example, hint, and pronunciation inputs become visible inline | C0+C1 |
| DT3 | clean close | draft is empty | tap close | the screen pops immediately without a dialog | C0+C1 |
| DT4 | dirty close | front text is entered | tap close, then cancel discard | the discard dialog appears and cancel keeps the editor open | C0+C1 |
| DT5 | save success | front/back/example/hint/pronunciation/tags are filled with trimmed input | tap Save | the repository receives trimmed values, a success snackbar appears, and the screen pops | C0+C1 |
| DT6 | tag chips | a tag chip is present in the draft | tap the chip | the chip is removed from the draft | C0+C1 |
| DT7 | save and add another | checkbox under Tags is checked and front/back/example/hint/pronunciation/tags are filled with trimmed input | tap Save card | the repository receives trimmed values, a success snackbar appears, the draft resets, and focus returns to Front | C0+C1 |
