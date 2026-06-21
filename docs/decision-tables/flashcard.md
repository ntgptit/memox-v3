---
last_updated: 2026-06-19
source: split from memox-core-decision-table.md
applies_to: Flashcard CRUD and Import behavior branches
---

# MemoX Decision Table — Flashcard + Import

## Convention
- `ID` is stable. Tests reference it by ID (e.g. `// decision: C1`).
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` column: `TBD` until the implementing agent writes the test.
  Tests must be derived from the Expected column, NOT from code.

## Flashcard

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| C1 | Create card | Valid front/back + optional example/hint/pronunciation/tags | Persist card + initial progress row (box 1, due_at NULL, zero counters) + normalized tag rows in one transaction; optional notes trimmed, blank → NULL | C0+C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C1) |
| C2 | Create card | Blank front (whitespace-only) | Reject after trim with `ValidationFailure(front, empty)`; nothing persisted | C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C2) |
| C3 | Create card | Blank back (whitespace-only) | Reject after trim with `ValidationFailure(back, empty)`; nothing persisted | C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C3) |
| C4 | Edit card | Existing card opens through shared editor | Load deck/card context, prefill the form, and show the danger zone | C0+C1 | TBD |
| C5 | Edit card | Learned front/back changed on a progressed card | Update content + replace tags; `keepProgress` (default) preserves the progress row, `resetProgress` returns it to box 1 / unscheduled / zero counters | C0+C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C5) |
| C6 | Delete card | Confirmed from flashcard list row/bulk action | Delete the card; its `flashcard_progress` + `flashcard_tags` rows cascade via FK; missing card → `NotFoundFailure` | C0+C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C6) |
| C7 | Import CSV preview | Valid front/back rows + optional extra columns | Trim front/back and preview the valid rows (extra columns ignored — take first two) without writing to DB | C0+C1 | `test/domain/usecases/flashcard/deck_import_usecases_test.dart` |
| C8 | Create card | Target deck missing | Repository returns `NotFoundFailure(deck)`; nothing persisted | C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C8) |
| C9 | Create editor close | Blank draft | Leave without discard dialog | C1 | TBD |
| C10 | Create editor close | Front typed but unsaved | Show discard dialog | C1 | TBD |
| C11 | Create editor discard | User cancels discard | Stay on editor and keep typed input | C1 | TBD |
| C12 | Create editor discard | User confirms discard | Leave editor for deck flashcard list | C1 | TBD |
| C18 | Create card save | Destination deck changed before normal Save | Future Proposal | — | Future |
| C19 | Create card save-and-add | Checkbox under tags checked + valid front/back + optional example/hint/pronunciation/tags | Persist card, clear the draft, keep the same deck, and focus the Front field for another entry | C0+C1 | TBD |
| C20 | Create editor tags | User adds a valid tag chip | Append the chip in draft and normalize on save | C1 | TBD |
| C21 | Create editor tags | User taps an existing chip | Remove the chip from the draft | C1 | TBD |
| C22 | Edit editor close | Loaded draft unchanged | Pop immediately without a discard dialog | C0+C1 | TBD |
| C23 | Edit editor close | Front changed | Show discard dialog and keep editing on cancel | C0+C1 | TBD |
| C24 | Edit editor close | Optional note changed | Same dirty-close discard flow as front/back edits | C0+C1 | TBD |
| C25 | Edit editor close | Tag list changed | Same dirty-close discard flow as front/back edits | C0+C1 | TBD |
| C26 | Edit editor close | Existing optional note/tags loaded but unchanged | Pop immediately without a discard dialog | C0+C1 | TBD |
| C27 | Edit editor delete | Delete confirmed from danger zone | Delete the card and pop to the deck list | C1 | TBD |
| C28 | Edit load error | Flashcard detail fails to load | Show load error state with Back to deck / Retry | C1 | TBD |
| C29 | Edit save failure | Update repository returns failure | Keep the draft open and show a save-failed banner | C1 | TBD |
| C30 | Import CSV preview | Empty front or empty back | Surface a row-level validation message with the line number (`missingFront`/`missingBack`); the row is excluded from committable rows | C1 | `test/domain/usecases/flashcard/deck_import_usecases_test.dart` |
| C31 | Import CSV preview | Preview action on CSV text | Do not call repository create/insert/commit logic; keep deferred CTA disabled | C0+C1 | TBD |
| C32 | Import CSV preview | Quoted CSV values | Parse quoted commas and escaped quotes correctly | C0+C1 | `test/domain/usecases/flashcard/deck_import_usecases_test.dart` |
| C33 | Reorder cards | Full sibling list in same deck | Persist deterministic `sort_order` (list position) transactionally | C0+C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C33) |
| C34 | Reorder cards | Duplicate/missing/cross-deck/partial list | Reject with `ValidationFailure(orderedIds, invalidFormat)` and preserve the previous order | C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C34) |
| C35 | Flashcard list load | No filter / front-back search / unknown deck | Default list returns all cards in `sort_order`; non-blank search filters cards by front/back (case-insensitive) while `totalCount` stays the full deck total; missing deck yields `NotFoundFailure` | C0+C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C35) |
| C36 | Flashcard list filters | Status = active / due / suspended / buried | `active` excludes suspended/currently-buried and keeps expired-buried; `due` includes past-due and due-now, excludes future-due/suspended/buried; `suspended` returns suspended only; `buried` returns currently buried only; a new card (no progress row) is active but never `due` | C0+C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C36) |
| C37 | Flashcard list filters | Status/search composition and deterministic order | Search composes with status filter; filtered rows keep stable deck order; `totalCount` stays the full deck total | C0+C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C37) |
| C38 | Flashcard list filters | Tag empty / single / multi / normalization / scope | Empty selected tags return all cards; single normalized tag filter stays deck-scoped; multi-tag filter uses AND semantics and keeps stable order | C0+C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C38), `test/domain/usecases/flashcard/watch_flashcard_list_usecase_test.dart` |
| C39 | Flashcard list filters | Tag composition / no-results | Tag filter composes with search and status (WBS 2.17.1); no-results keeps `totalCount` at the full deck total | C0+C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (C39) |
| C40 | Manual duplicate check | Create/edit save with same-deck duplicate front/back | Return `isDuplicate=true` (with matching ids) without blocking save; trimmed + case-insensitive `front`+`back` compare; deck-scoped; edit mode ignores the current card via `excludeId` | C0+C1 | test/data/repositories/flashcard_repository_impl_duplicate_behavior_test.dart, test/domain/usecases/flashcard/check_manual_duplicate_flashcard_usecase_test.dart |
| C42 | Deck overline due total | Flashcard-list `{m} due` badge | `FlashcardListDetail.dueCount` = active due cards over the **full deck** (`due_at <= now`, F13 suspended/currently-buried exclusion; new cards never due), independent of search/tag/status filters; badge shown only when `> 0` | C0+C1 | `test/data/repositories/flashcard_repository_impl_test.dart` (WP-D1), `test/presentation/features/decks/flashcard_list_test.dart` |
| C41 | Create/edit card | Parent deck (WBS 2.16.1) | Card cannot exist without a deck: non-null `deck_id` FK→decks ON DELETE CASCADE; create under a missing deck returns `NotFoundFailure(deck)`; update on a missing card returns `NotFoundFailure(flashcard)` | C0+C1 | test/data/repositories/flashcard_repository_impl_test.dart, test/data/migrations/app_database_schema_test.dart |

## Import

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| I1 | Open deck import route | Deck id present | Render the real `DeckImportScreen` shell with the route title, shell copy, and source-format cards; do not render `RoutePlaceholder` | C0+C1 | TBD |
| I2 | Open deck import route | Deck id missing | Show a controlled danger callout with Back; do not start parsing, file loading, preview, or commit work | C0+C1 | TBD |
| I3 | Open deck import route | Deck id present + clean preview | Enable the commit CTA, show the ready-to-import callout, and commit the valid preview rows transactionally before popping | C0+C1 | TBD |
| I4 | Open deck import route | Deck id present + validation issues | Keep commit disabled and show the validation issues callout; do not write anything | C1 | TBD |
| I5 | Open deck import route | Commit tapped while already committing | Ignore the duplicate submit so the repository runs once and the preview stays on screen until the first commit finishes | C1 | TBD |
| I6 | Open deck import route | Repository transaction fails | Keep the preview state, surface the localized failure message, and do not pop | C1 | TBD |
| I7 | Prepare deck import | Duplicate rows in batch or existing target deck | Skip duplicate preview rows before commit (trim+case-insensitive front+back), keep duplicate detection deck-scoped, and expose duplicate counts/sources (`deck` vs `importFile`, existing-deck precedence) without silently importing them | C0+C1 | `test/domain/usecases/flashcard/deck_import_usecases_test.dart` |
| I8 | Prepare deck import | Structured text source with documented separators | Parse structured text through the same preview/validation/duplicate pipeline as CSV, using auto/tab/comma/colon/slash/semicolon/pipe and failing closed on ambiguous auto-detect (tie/none → malformedRow issue, no rows) | C0+C1 | `test/domain/usecases/flashcard/deck_import_usecases_test.dart` |
