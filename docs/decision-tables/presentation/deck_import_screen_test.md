# Decision Tables: deck_import_screen_test

Test file: `test/presentation/features/flashcards/deck_import_screen_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | valid deck id renders shell | the route opens with a real deck id | render the import screen | show the import title, route intro copy, and the CSV / Excel / Structured text shell cards; do not render `RoutePlaceholder` | C0+C1 |
| DT2 | missing deck id renders invalid state | the screen is built without a deck id | render the import screen | show the danger callout and Back action; do not show the import shell cards | C0+C1 |
