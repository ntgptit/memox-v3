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
| C1 | Create card | Valid front/back + optional example/hint/pronunciation/tags | Persist card + initial progress row; save becomes enabled once required fields are present | C0+C1 | TBD |
| C2 | Create card | Blank front | Save stays disabled until the required fields are present | C1 | TBD |
| C3 | Create card | Blank back | Save stays disabled until the required fields are present | C1 | TBD |
| C4 | Edit card | Existing card opens through shared editor | Load deck/card context, prefill the form, and show the danger zone | C0+C1 | TBD |
| C5 | Edit card | Learned front/back changed on a progressed card | Show progress-policy dialog, then update with keep/reset choice | C0+C1 | TBD |
| C6 | Delete card | Confirmed from flashcard list row/bulk action | Delete card and dependent data | C0+C1 | TBD |
| C7 | Import CSV preview | Valid front/back rows + optional extra columns | Trim front/back and preview the valid rows without writing to DB | C0+C1 | TBD |
| C8 | Create card | Whitespace-only front | Reject after trim; repository returns validation failure | C1 | TBD |
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
| C30 | Import CSV preview | Empty front or empty back | Surface a row-level validation message with the line number | C1 | TBD |
| C31 | Import CSV preview | Preview action on CSV text | Do not call repository create/insert/commit logic; keep deferred CTA disabled | C0+C1 | TBD |
| C32 | Import CSV preview | Quoted CSV values | Parse quoted commas and escaped quotes correctly | C0+C1 | TBD |
| C33 | Reorder cards | Full sibling list in same deck | Persist deterministic `sort_order` transactionally | C0+C1 | TBD |
| C34 | Reorder cards | Duplicate/missing/cross-deck/partial list | Reject and preserve the previous order | C1 | TBD |
| C35 | Flashcard list filters | No filter / compatibility / unknown deck | Default list still returns all cards; `statusFilter=all` matches default; existing no-arg callers stay valid; missing deck still yields `NotFoundFailure` | C0+C1 | TBD |
| C36 | Flashcard list filters | Status = active / due / suspended / buried | `active` excludes suspended/currently-buried and keeps expired-buried; `due` includes past-due and due-now, excludes future-due/suspended/buried; `suspended` returns suspended only; `buried` returns currently buried only | C0+C1 | TBD |
| C37 | Flashcard list filters | Status/search composition and deterministic order | Search composes with status filter; filtered rows keep stable deck order | C0+C1 | TBD |
| C38 | Flashcard list filters | Tag empty / single / multi / normalization / scope | Empty selected tags return all cards; single normalized tag filter stays deck-scoped; multi-tag filter uses AND semantics and keeps stable order | C0+C1 | TBD |
| C39 | Flashcard list filters | Tag composition / no-results | Tag filter composes with search + status; no-results keeps `totalCount` at the full deck total | C0+C1 | TBD |
| C40 | Manual duplicate check | Create/edit save with same-deck duplicate front/back | Return `hasDuplicate=true` without blocking save; edit mode ignores the current card; missing deck/card and blank fields return typed failures | C0+C1 | TBD |

## Import

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| I1 | Open deck import route | Deck id present | Render the real `DeckImportScreen` shell with the route title, shell copy, and source-format cards; do not render `RoutePlaceholder` | C0+C1 | TBD |
| I2 | Open deck import route | Deck id missing | Show a controlled danger callout with Back; do not start parsing, file loading, preview, or commit work | C0+C1 | TBD |
| I3 | Open deck import route | Deck id present + clean preview | Enable the commit CTA, show the ready-to-import callout, and commit the valid preview rows transactionally before popping | C0+C1 | TBD |
| I4 | Open deck import route | Deck id present + validation issues | Keep commit disabled and show the validation issues callout; do not write anything | C1 | TBD |
| I5 | Open deck import route | Commit tapped while already committing | Ignore the duplicate submit so the repository runs once and the preview stays on screen until the first commit finishes | C1 | TBD |
| I6 | Open deck import route | Repository transaction fails | Keep the preview state, surface the localized failure message, and do not pop | C1 | TBD |
| I7 | Prepare deck import | Duplicate rows in batch or existing target deck | Skip duplicate preview rows before commit, keep duplicate detection deck-scoped, and expose duplicate counts/sources without silently importing them | C0+C1 | TBD |
| I8 | Prepare deck import | Structured text source with documented separators | Parse structured text through the same preview/validation/duplicate pipeline as CSV, using auto/tab/comma/colon/slash/semicolon/pipe and failing closed on ambiguous auto-detect | C0+C1 | TBD |
