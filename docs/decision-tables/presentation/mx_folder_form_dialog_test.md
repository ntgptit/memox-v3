# Decision Tables: mx_folder_form_dialog_test

Test file: `test/presentation/shared/dialogs/mx_folder_form_dialog_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | create mode | dialog opened from create-folder entry point | dialog renders | shows preview tile, description, folder name label, color swatches, icon choices, and Create folder CTA | C0+C1 |
| DT2 | rename mode with prefilled value | dialog opened from rename entry point | dialog renders | shows rename title, helper copy, new name label, and the initial text fully selected | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT3 | create confirm after trim | create dialog open with blank name | user types a name with leading/trailing spaces and taps Create | returned value is trimmed and dialog closes | C0+C1 |
| DT4 | rename confirm after trim | rename dialog open with prefilled name | user overwrites with a name that has leading/trailing spaces and taps Rename | returned value is trimmed and dialog closes | C0+C1 |
| DT5 | locked dismiss behavior | rename dialog open | user taps outside or presses system back | dialog stays open until Cancel is tapped | C0+C1 |
| DT6 | locked dismiss behavior | create dialog open | user taps outside or presses system back | dialog stays open until Cancel is tapped | C0+C1 |
