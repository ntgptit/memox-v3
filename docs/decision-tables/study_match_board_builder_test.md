# Decision Tables: match_board_builder_test

Test file: `test/domain/study/match/match_board_builder_test.dart`

## Decision table: onBuild

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | five unique cards available | exactly 5 unique cards in session order | board build is requested | return one board with 5 pairs and 10 cells | C0+C1 |
| DT2 | duplicate front/back text is present | 5 unique ids, with repeated text values across cards | board build is requested | pair identity stays keyed by flashcard id; no text-based dedupe occurs | C0+C1 |
| DT3 | deterministic shuffle seed | same session id, board index, and card set | board build is requested twice | cell order matches for identical seeds and changes when board index changes | C0+C1 |
| DT4 | insufficient unique cards | fewer than 5 unique cards | board build is requested | throw UnsupportedError; no partial board is returned | C0+C1 |
