# Decision Tables: folder_detail_test

Test file: `test/presentation/features/folders/folder_detail_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | deck row has `lastStudiedAt` and `dueCount > 0` | deck read model includes `lastStudiedAt`, cards, and due count | Folder Detail renders a loaded deck row | Row shows due badge, cards + relative last-studied meta, compact progress bar, and chevron | C0+C1 |
| DT2 | deck row has no `lastStudiedAt` | deck read model omits `lastStudiedAt` and has `dueCount == 0` | Folder Detail renders a loaded deck row | Row collapses to cards-only meta, still shows progress bar, and hides the due badge and relative last-studied copy | C0+C1 |
