# Decision Tables: study_entry_screen_test

Test file: `test/presentation/features/study/study_entry_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | today route opens | `/library/study/today` | render the route | route builds `StudyEntryScreen`, not `RoutePlaceholder`, and shows the preparing state first | C0+C1 |
| DT2 | scoped deck route opens | `/library/study/deck/:entryRefId` | render the route | route builds `StudyEntryScreen`, not `RoutePlaceholder`, and reaches the unsupported gate state | C0+C1 |
| DT3 | invalid entryType | unknown `entryType` path param | render the route | show the invalid-route error state with back action | C1 |
| DT4 | blank entryRefId | scoped screen created with an empty ref id | render the screen | show the invalid-route error state | C1 |
| DT5 | invalid study_type query | supported route with malformed `study_type` | render the route | show the invalid-route error state | C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT6 | initial async frame | valid today route | first frame renders | show the preparing state with loading indicator and copy before the unsupported fallback resolves | C0+C1 |
