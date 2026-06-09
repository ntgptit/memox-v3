# Decision Tables: deck_import_screen_test

Test file: `test/presentation/features/flashcards/deck_import_screen_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | valid deck id renders preview shell | the route opens with a real deck id | render the import screen | show the import title, route intro copy, CSV paste area, preview action, and deferred commit CTA; do not render `RoutePlaceholder` | C0+C1 |
| DT2 | missing deck id renders invalid state | the screen is built without a deck id | render the import screen | show the danger callout and Back action; do not show the CSV preview shell | C0+C1 |
| DT3 | empty CSV validation | the paste box contains only whitespace | tap Preview | show the localized empty-input validation and keep the preview hidden | C1 |
| DT4 | valid CSV preview | the paste box contains `front,back` header + valid rows | tap Preview | show the preview summary and the valid rows list | C0+C1 |
| DT5 | quoted CSV parsing | the paste box contains quoted commas and escaped quotes | tap Preview | show the parsed front/back values with quotes unescaped | C0+C1 |
| DT6 | invalid row validation | a row has empty front or back | tap Preview | show row-level validation with the line number and localized reason | C1 |
| DT7 | deferred commit CTA | previewing any CSV | tap Preview | keep the commit CTA disabled / deferred and do not navigate away | C0+C1 |
