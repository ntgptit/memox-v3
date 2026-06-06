---
last_updated: 2026-06-06
route: /library/deck/:deckId/flashcards
source_specs:
  - docs/business/flashcard/flashcard-management.md
  - docs/business/deck/deck-management.md
  - docs/business/study-actions/bury-suspend.md
  - docs/business/tags/tag-system.md
  - docs/business/bulk/bulk-operations.md
  - docs/business/resume/resume-session.md
---

# 06 — Flashcard List

## V1 verification status (2026-06-06)

This screen is **partially Current**. The aspects below are implemented in code and
verified by tests (`test/presentation/features/flashcards/flashcard_list_test.dart`,
`test/data/repositories/flashcard_repository_impl_test.dart`); everything else is
**Future** and intentionally not exposed in V1. Do NOT mark the whole screen Current.

> **Drift correction (2026-06-06):** prior versions of this section described the
> deck-level study-entry section (Prompt 46), the Resume-Discard flow (Prompt 47),
> bulk/selection, state badges, and a §Components 1-1 widget mapping as Current. **None
> of that existed in code** — the entire `lib/presentation/features/flashcards/**`,
> `FlashcardRepository`, `FlashcardDao`, and the flashcard use cases were unbuilt; the
> route was a `RoutePlaceholder`. The list below replaces those over-claims with the
> behaviour actually shipped.

**Verified Current (behaviour + tests):**

- Route `/library/deck/:deckId/flashcards` opens `FlashcardListScreen`. Invalid/missing
  `deckId` → `NotFoundFailure` surfaced through `MxRetainedAsyncState` (error + Retry),
  no crash, no raw exception text.
- States: Loading skeleton (`flashcard_list_skeleton`), error+retry, **empty deck**
  (`totalCount == 0`, regardless of any active search term →
  `FlashcardEmptyStateSection`), and **no-results-on-search** (`cards.isEmpty &&
  searchTerm.isNotEmpty && totalCount > 0` → `ValueKey('flashcard_no_results')` with a
  Clear CTA) — distinct.
- In-deck search: scope-local toolbar term filtering front / back / example_sentence;
  never routes to global search; clearing restores cards. `totalCount` is search-independent.
- Manual reorder: deck overflow → **Reorder cards** enters reorder mode
  (`ReorderableListView`, `ValueKey('flashcard_reorder_list')`, drag handles); drop
  persists `sort_order` via `ReorderFlashcardsUseCase`; X / Done exits.
- Single-card row actions (long-press / kebab → `flashcard_row_actions_sheet`): **Edit**
  → `flashcardEdit` route, **Delete** → single-card confirm dialog → `DeleteFlashcardUseCase`.
  No Move / Export / Select / History / Bury / Suspend.
- Deck overflow (app-bar kebab → `deck_actions_sheet`): **Import flashcards** →
  `deckImport` route, **Reorder cards**, **Delete deck** → confirm dialog →
  `DeleteDeckUseCase` (via `FolderRepository.deleteDeck`; cascades cards, reverts an
  emptied parent folder to `unlocked`, then pops back).
- FAB + empty-state CTAs: **Add flashcard** → `flashcardCreate` route; **Import** →
  `deckImport` route.
- Breadcrumb: `Library / {folder chain}` + subtitle `{n} cards · {target language}`.

> `flashcardCreate`, `flashcardEdit`, and `deckImport` resolve to `RoutePlaceholder`
> (screens 07 / 08 / 10 not built). The Flashcard List owns the navigation only.

**Future (not exposed in V1):**

- Deck-level study-entry section (resume banner, Today CTA, Study-deck CTA) — the study
  layer is not built. The §Components order 4-7 (study-entry / deck summary / study modes
  / progress) describe the target, not current behaviour.
- Status filter dropdown + multi-tag chip filter (`?filter=`/`?tag=` round-trip) and the
  toolbar sort UI.
- State badges (Suspended / Buried / Due) per row, and the shared `CardStateComputer`.
- Selection mode + bulk action bar (delete / move / tag± / suspend / unsuspend / reset).
- Move card (destination picker), Export, Flashcard History (screen 09, Future Proposal).
- Long-press → enter selection mode (V1 long-press opens the row action sheet). The
  §Forbidden / §Agent-rule items requiring long-press-to-select describe the Future target.
- Flashcard create / edit / import screens (07 / 08 / 10) — routes are placeholders.
- ≥600dp 2-col / ≥1024dp 3-col responsive grid (V1 is a single-column list).

## Purpose

Manage flashcards in one deck: browse, filter, edit, multi-select for bulk operations. Primary launch point for deck-level study.

## Layout — normal mode

```
┌───────────────────────────────────────┐
│ ← Korean N5                    🔍  ⋮  │
├───────────────────────────────────────┤
│ Library / Korean / N5                 │
│ 42 cards · Korean target language     │  ← Subtitle = total + lang
├───────────────────────────────────────┤
│                                       │
│ ⚠ You have a paused study session     │  ← RESUME BANNER (when applicable)
│   for this deck.                      │
│   [Resume]  [Discard]                 │
├───────────────────────────────────────┤
│                                       │
│ ┌─────────────────┐  ┌─────────────┐ │
│ │ Study deck      │  │ Today (12)  │ │  ← Deck-level study CTAs
│ │ ▸               │  │ ▸           │ │
│ └─────────────────┘  └─────────────┘ │
│                                       │
│ ┌──────────────────────────────────┐  │
│ │ Filter: All ▾   Tag: + Add tag▾  │  │  ← Filter row (status + tag)
│ └──────────────────────────────────┘  │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 안녕하세요             #greet     │ │  ← Card row: front + tags + state
│ │ Hello                             │ │     back as subtitle
│ ├───────────────────────────────────┤ │
│ │ 감사합니다            #greet      │ │
│ │ Thank you                         │ │
│ ├───────────────────────────────────┤ │
│ │ 미안합니다     🔇 SUSPENDED       │ │  ← Suspended badge
│ │ Sorry                             │ │
│ ├───────────────────────────────────┤ │
│ │ 사랑해요       🌙 BURIED TODAY    │ │  ← Buried badge
│ │ I love you                        │ │
│ └───────────────────────────────────┘ │
│                                       │
│                            ┌───┐      │
│                            │ + │      │  ← FAB
│                            └───┘      │
└───────────────────────────────────────┘
```

## Layout — selection mode

```
┌───────────────────────────────────────┐
│ ✕   3 selected             [Select all]│  ← Selection app bar
├───────────────────────────────────────┤
│                                       │
│ ☑ 안녕하세요          #greet         │  ← Checkbox replaces leading
│ ☑ 감사합니다          #greet         │
│ ☐ 미안합니다          🔇             │
│ ☑ 사랑해요            🌙             │
│ ☐ ...                                 │
│                                       │
├───────────────────────────────────────┤
│ 🗑  📦   🏷+   🏷-   ⏸    ⏯    ↻      │  ← Bulk action bar
│ del move tag+ tag- susp unsusp reset  │
└───────────────────────────────────────┘
```

## Layout — empty state (no flashcards)

```
┌───────────────────────────────────────┐
│ ← Korean N5                    🔍  ⋮  │
├───────────────────────────────────────┤
│ Library / Korean / N5                 │
├───────────────────────────────────────┤
│                                       │
│              🃏                        │
│                                       │
│      No flashcards yet                │
│                                       │
│   Add cards manually or import from   │
│   a file.                             │
│                                       │
│   ┌──────────────────────────────┐   │
│   │ + Add flashcard              │   │
│   └──────────────────────────────┘   │
│   ┌──────────────────────────────┐   │
│   │ ⬇ Import from CSV / Excel    │   │
│   └──────────────────────────────┘   │
│                                       │
└───────────────────────────────────────┘
```

## Layout — filtered empty state

```
┌───────────────────────────────────────┐
│ ← Korean N5                    🔍  ⋮  │
├───────────────────────────────────────┤
│ Filter: Suspended ▾   Tag: #weak ▾   │
├───────────────────────────────────────┤
│                                       │
│              🃏                        │
│                                       │
│   No cards match these filters.       │
│                                       │
│   [Clear filters]                     │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `deckId` (required path param) | URL | resolves to `decks.id`; 404 if invalid |
| `filter` (optional query) | URL | one of: `all`, `active`, `due`, `suspended`, `buried`. Default `all`. |
| `tag[]` (optional, repeatable) | URL | multi-select AND filter |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Deck detail (name, target_language, count, parent path) | `decks` + folder chain | watch |
| Flashcards filtered | `flashcards JOIN flashcard_progress JOIN flashcard_tags` with WHERE clause matching filters | stream |
| Tag list for current deck (for filter chip) | distinct tags in deck | watch |
| Resumable session for this deck | **Current (Prompt 46).** `StudyRepo.findResumeCandidate` for `entry_type='deck', entry_ref_id=:deckId` (status IN draft/in_progress) | re-resolves on content/session revision |
| Today's due count for deck (for Today CTA) | **Current (Prompt 46).** `StudyRepo.countDueCardsInScope` over the deck (`entry_type=deck`) | re-resolves on content/session revision |
| Per-row computed `CardState` (Suspended > Buried > Due > Active) | derived from flashcard_progress | watch |
| Selection state (mode + selected IDs) | in-memory (NotifierState) | local |

## Forbidden

- ❌ Show note/example/pronunciation/hint inline in row.
- ❌ Display "Today (0)" — hide the Today CTA when 0 due (Current rule, Prompt 46).
- ❌ Use `?type=srs_review` — the query param is `study_type` (`RoutePaths.studyTypeQueryParam`).
- ❌ Use global `entry_type=today` for the deck Today CTA — it is `entry_type=deck` filtered to due via `study_type=srs_review`.
- ❌ Start a session directly from Flashcard List — Study deck / Today / Resume must go through the Study Entry Gate (or resume the existing session); the gate owns empty-scope validation and session creation (Current rule, Prompt 46).
- ❌ Remove the resume banner after one view. It persists until session resumed or discarded.
- ❌ Long-press → open context sheet directly. Long-press MUST enter selection mode. **(Future target — see V1 verification status. V1 long-press opens the row action sheet; selection is entered via the "Select" action or the per-row star toggle.)**
- ❌ Bulk action applies to filtered-out cards. Snapshot selected IDs at confirmation time.
- ❌ "Select all" select beyond filtered set.
- ❌ Persist selection across navigation. Selection is ephemeral.
- ❌ Compute `CardState` on render. Use repository or use case.
- ❌ Hardcode the priority rule in widget. Use shared `CardStateComputer`.

## Components

Listed in **render order top-to-bottom** as they appear in `lib/presentation/features/flashcards/screens/flashcard_list_screen.dart`. Each row maps 1-1 to a `*_section.dart` widget — keep this mapping intact when refactoring; reviewers verify by spec ↔ widget filename.

| Order | Component | Code widget | Spec |
| --- | --- | --- | --- |
| 1 | App bar | (inline in screen scaffold) | Title = deck name. Back. Search (in-deck). Overflow ⋮. |
| 2 | Header section | `flashcard_header_section.dart` | Renders title + overflow + search. Replaces app bar inline when needed (responsive). |
| 3 | Breadcrumb subtitle | `flashcard_breadcrumb_section.dart` | "Library / {folderPath} / {deckName}". 2nd line "{n} cards · {targetLanguage}". |
| 4 | Deck study-entry section | `flashcard_study_entry_section.dart` | **Current (Prompt 46).** Resume banner (`deck_resume_banner`) + deck-level study card (`deck_study_card`) with Today (`deck_study_today_action`, `study_type=srs_review`) and Study-deck (`deck_study_deck_action`, default new study) CTAs. Fed by `deckStudyEntryProvider`. Today hidden at 0 due; whole section hidden when no cards and no resume. Renders above the deck summary. Never starts a session directly. |
| 5 | Deck summary | `flashcard_deck_summary_section.dart` | Total cards · due-today badge · mastery progress chip. Single row above the study CTAs. |
| 6 | Study modes | `flashcard_study_modes_section.dart` | Per-mode study tiles (Review / Match / Guess / Recall / Fill) + the Mix card; all route through the Study Entry Gate (`entry_type=deck`, default new study). Disabled on empty deck. The deck-level "Study deck" / "Today" CTA pair lives in the study-entry section (order 4). |
| 7 | Progress section | `flashcard_progress_section.dart` | Optional in-deck progress widget (e.g., box distribution or due timeline). Rendered only when `state.progress != null`. |
| 8 | Toolbar / filter | `flashcard_toolbar_section.dart` | Status filter dropdown ("All" / "Active" / "Due" / "Suspended" / "Buried") + multi-tag chip picker + sort menu. Compose with AND. |
| 9 | Bulk action bar | `flashcard_bulk_action_section.dart` | Sticky bottom bar with 7 icons (per `docs/business/bulk/bulk-operations.md`): delete, move, tag+, tag-, suspend, unsuspend, reset. Visible only in selection mode. |
| 10 | List body | `flashcard_items_section.dart` + `flashcard_detail_card_row.dart` + `flashcard_card_list_header.dart` | Card rows: Front (large), Back (subtitle), tag chips (small, overflow truncated), state badge ("🔇 SUSPENDED" / "🌙 BURIED TODAY"). |
| 10' | Reorder body | `flashcard_reorder_list.dart` | Replaces the list body when "Reorder" mode is active. Same row content with drag handles. |
| 11 | Empty state | `flashcard_empty_state_section.dart` | Replaces list body when zero cards in deck. Renders "Add flashcard" + "Import" CTAs. |
| 12 | Skeleton | `flashcard_list_skeleton.dart` | Shown during initial fetch before first frame of real data. |
| 13 | Card preview | `flashcard_preview_section.dart` | Optional preview surface for editor sandbox (used by linked flashcard-edit context). May be hidden in pure list mode. |
| — | Selection app bar | (inline) | Replaces normal app bar in selection mode. Shows count, X cancel, Select all. |
| — | FAB | (inline) | Plus → opens action sheet (Add card / Import). |
| — | Bulk add controls | `bulk_add_controls.dart` + `bulk_add_file_section.dart` + `bulk_add_widgets.dart` | Bulk-add UI path (paste many lines at once → preview → commit). Reached via FAB → "Bulk add"; lives on the same screen scaffold but is a sub-mode, not a separate row in the list. |

Render order is enforced by reviewer checklist — see "Pre-commit parity check" in `CLAUDE.md`. When introducing a new section, place it in this table at the correct order index and update the code widget column with the file path.

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Initial fetch | Skeleton rows. |
| Populated | Normal | List visible. |
| Empty (zero cards in deck) | `totalCount == 0` (deck holds no cards, **regardless of any active search term**) | Show empty layout with "Add" CTA (`FlashcardEmptyStateSection`). Import CTA lives in the cards toolbar above. **Current.** |
| No results (search filters every row) | **Deck has cards** (`totalCount > 0`) but the active search term matches none (`items.isEmpty && searchTerm.isNotEmpty`) | Show `FlashcardNoResultsSection` (`ValueKey('flashcard_no_results')`) with "Clear" CTA that resets the toolbar search term. Distinct from empty-deck. **Current (Prompt 16, classification corrected Prompt 16B).** |
| Filtered empty (status/tag filters) | Status/tag filters applied, no match | Show filtered empty with "Clear filters" CTA. **Future** — status/tag filter chips are not yet implemented (see V1 verification status). |
| Selection mode | Row "Select" action or per-row star toggle. Long-press opens the row action sheet; long-press-to-select is a Future target only. | App bar swaps; checkboxes show; bulk bar appears. |
| Resume present | **Current (Prompt 46).** Deck has resumable session | Show Resume banner above the study card. Resume opens that session; no new session created. |
| Today present | **Current (Prompt 46).** Deck `dueCount > 0` | Show Today CTA in the study card (`study_type=srs_review`). Hidden at zero. |
| Loading bulk action | After confirm | Disable bulk bar; show progress indicator if > 1s. |
| Bulk error | Transaction failed | Toast error; restore selection state. |

## Actions

### Normal mode

| Action | Trigger | Result |
| --- | --- | --- |
| Tap card | Tap | Navigate to flashcard edit. |
| Long-press card | Long-press | **Current (V1):** open the row action sheet (Edit / Move / Export / Select / Delete). Selection mode is entered via the sheet's "Select" action or the per-row star toggle, NOT by long-press. (Long-press-to-select is a **Future** target — see V1 verification status / §Forbidden.) |
| Tap filter dropdown | Tap | Open filter picker bottom-sheet. **(Future** — status filter chips not yet implemented.) |
| Tap tag chip filter | Tap | Open tag picker bottom-sheet (multi-select, AND). **(Future** — tag filter chips not yet implemented; tag-scoped study remains Future/Blocked.) |
| Tap "Study deck" | Tap | **Current (Prompt 46).** Navigate to study entry gate `/library/study/deck/:deckId` (no explicit `study_type` → default new study). |
| Tap "Today (n)" | Tap | **Current (Prompt 46).** Navigate to study entry gate `/library/study/deck/:deckId?study_type=srs_review` (deck-scoped review of due cards). NOT `entry_type=today` (which is global) and NOT `?type=`. |
| Tap resume banner Resume | Tap | **Current (Prompt 46).** Open the existing session (`context.goStudySession`); never creates a new session. |
| Tap resume banner Discard | Tap | **Current (Prompt 47).** Show danger discard confirmation; on confirm cancel the paused session (shared `confirmAndDiscardResumeSession` → `CancelStudySessionUseCase`), refresh banner away. Cancel does nothing. Never creates a session. |
| Tap FAB | Tap | Action sheet: New flashcard / Import. |
| Tap overflow ⋮ | Tap | Menu: Edit deck / Move deck / Delete deck / Export / Sort by / Select. |
| Pull to refresh | Pull | Re-run query. |
| Tap search icon | Tap | **Current (V1):** open/focus the inline, scope-local deck search (toolbar search term → `ContentQuery`); filters cards within this deck only. Does NOT navigate anywhere. Navigation to a Library/Global Search pre-filtered to this deck is **Future / not exposed** (no live V1 route). |

### Selection mode

| Action | Trigger | Result |
| --- | --- | --- |
| Tap card | Tap | Toggle selection. |
| Tap Select all | Tap | Select every card matching current filter. |
| Tap X cancel | Tap | Exit selection mode. |
| Tap 🗑 delete | Tap | Show bulk delete confirm dialog. |
| Tap 📦 move | Tap | Open destination deck picker bottom-sheet. |
| Tap 🏷+ add tag | Tap | Open tag picker bottom-sheet (add mode). |
| Tap 🏷- remove tag | Tap | Open tag picker bottom-sheet (remove mode, tags limited to those present on selection). |
| Tap ⏸ suspend | Tap | Apply bulk suspend; show toast with undo. |
| Tap ⏯ unsuspend | Tap | Apply bulk unsuspend; show toast with undo. |
| Tap ↻ reset progress | Tap | Show reset confirm dialog. |
| System back | Back | Exit selection mode. |

## Dialogs and bottom-sheets used

- Resume discard dialog — **Current (Prompt 47).** `MxConfirmationDialog` (danger) composed via the shared discard flow: `docs/wireframes/24-shared-dialogs.md` §discard-session.
- New flashcard create flow — see screen 07.
- Import flow — see screen 10.
- Filter picker bottom-sheet — `docs/wireframes/25-shared-bottom-sheets.md` §filter-status.
- Tag picker bottom-sheet — `docs/wireframes/25-shared-bottom-sheets.md` §tag-picker.
- Deck destination picker — `docs/wireframes/25-shared-bottom-sheets.md` §deck-picker.
- Bulk delete confirm — `docs/wireframes/24-shared-dialogs.md` §bulk-delete.
- Bulk reset confirm — `docs/wireframes/24-shared-dialogs.md` §reset-progress.
- Card context (single long-press alternative) — `docs/wireframes/25-shared-bottom-sheets.md` §card-context.
- Single delete confirm — `docs/wireframes/24-shared-dialogs.md` §delete-confirm.

## Card row display rules

- Front: line 1, large, ellipsis after 1-2 lines.
- Back: line 2, smaller, ellipsis.
- Tags: up to 3 small chips on the right side. "+N" chip if more.
- State badge: only one badge per row, in this priority — Suspended > Buried > Due > Active. Active doesn't render a badge.
- Note/example/pronunciation/hint NOT shown in row (per spec; reserved for future).

## Filter interaction

| Filter combo | Result |
| --- | --- |
| Status = All, Tag = none | Show all cards in deck. |
| Status = Active, Tag = #weak | Show non-suspended, non-buried cards tagged #weak. |
| Status = Suspended, Tag = #weak | Show only suspended cards tagged #weak. |
| Filter changes | URL updates with `?filter=...&tag=...` so refresh restores. |

## Navigation in

- Tap deck row in Library or Folder detail.
- Search result tap on deck (**Future** — Global/Library Search has no live V1 route).
- Deep link from notification (rare).
- Back from Flashcard create/edit/import. Flashcard History is Future Proposal and has no live V1 route.

## Navigation out

- Card tap → flashcard edit.
- "Study deck" → study entry gate.
- "Today" → study entry gate (deck-scoped review).
- Resume → session.
- FAB → create or import.
- Card history remains Future Proposal; no live V1 context-sheet action.

## Responsive

- ≥600dp: 2-col grid for card rows. Bulk bar stays full-width.
- ≥1024dp: 3-col grid. Filter row inline on top.

## Performance

- Stream-based filtered query. SQLite handles status + tag filters efficiently with proposed indexes (see schema-contract.md).
- Selection state in-memory; doesn't persist across navigation.
- Bulk action: single transaction. Show indeterminate progress if > 1s.
- Tag chip list cached per deck for 60s.

## Accessibility

- Card row announces "{front}, {back}, {n} tags{, suspended|buried}".
- Selection toggle announces state change.
- Bulk bar buttons all labeled.
- Long-press alternative: a dedicated "Select" overflow item for users who cannot long-press.

## Rules

- Selection mode is ephemeral; navigating away clears it.
- Filter URL params MUST round-trip correctly.
- State badge priority MUST be: Suspended > Buried > Due > Active.
- Bulk action MUST run as single transaction.
- "Select all" selects only cards matching the CURRENT filter, not all in deck.

## Agent rule

- Do NOT show note/example/pronunciation/hint inline in row.
- Do NOT remove the resume banner after one view; it persists until session is resumed or discarded.
- Long-press card MUST default to entering selection mode, NOT opening a context sheet. **(Future target — V1 long-press opens the row action sheet; see V1 verification status.)**
- Bulk operation snapshots selected IDs at action confirmation time, not action execution time (per bulk spec).

## Implementation refs

**Business specs:**

- `docs/business/flashcard/flashcard-management.md`
- `docs/business/bulk/bulk-operations.md`
- `docs/business/study-actions/bury-suspend.md` (state badge priority)
- `docs/business/tags/tag-system.md` (tag filter)
- `docs/business/resume/resume-session.md` (banner)

**Decision rows:**

- Flashcard management, Bulk operations, Bury/Suspend (badge priority), Tags (TG filter)

**Schema / storage:**

- `flashcards`, `flashcard_progress.is_suspended`, `flashcard_progress.buried_until`, `flashcard_progress.due_at`, `flashcard_tags`
- URL params for filter/tag state

**Contracts:** `docs/contracts/usecase-contracts/flashcard.md`, `docs/contracts/usecase-contracts/bulk.md`, `docs/contracts/usecase-contracts/study.md` (bury/suspend), `docs/contracts/repository-contracts/flashcard-repository.md`

**Code paths (verified 2026-06-06):**

- Screen: `lib/presentation/features/flashcards/screens/flashcard_list_screen.dart`.
- Viewmodel: `lib/presentation/features/flashcards/viewmodels/flashcard_list_viewmodel.dart` (Riverpod annotation) — `FlashcardListToolbar` (search / sort / reorder state), `flashcardListQuery`, `FlashcardListController` (delete card, reorder, delete deck).
- Widgets actually built (V1 reduced set; the §Components 1-1 table describes the full Future target): `flashcard_list_body.dart`, `flashcard_detail_card_row.dart`, `flashcard_empty_state_section.dart`, `flashcard_list_skeleton.dart`, `deck_actions_sheet.dart`, `flashcard_row_actions_sheet.dart`. The study-entry / deck-summary / study-modes / progress / bulk / toolbar-filter / preview section widgets are **not built** (Future).
- Domain: entity `lib/domain/entities/flashcard.dart`; read model `lib/domain/models/flashcard_list_detail.dart`; contract `lib/domain/repositories/flashcard_repository.dart`; use cases `lib/domain/usecases/flashcard/{watch_flashcard_list,delete_flashcard,reorder_flashcards}_usecase.dart` and `lib/domain/usecases/deck/delete_deck_usecase.dart`.
- Data: `lib/data/datasources/local/drift/flashcard_queries.drift`, `lib/data/datasources/local/daos/flashcard_dao.dart`, `lib/data/mappers/flashcard_mapper.dart`, `lib/data/repositories/flashcard_repository_impl.dart`. Deck delete lives on `FolderRepository.deleteDeck` (`folder_repo_impl_mutation_helpers.dart::deleteDeckTxn`, reverts an emptied parent folder to `unlocked`).
- DI: `lib/app/di/flashcard_providers.dart` (+ `deleteDeckUseCaseProvider` in `folder_providers.dart`).
- Routes: `RouteNames.flashcardList` → real screen in `folder_routes.dart`; `flashcardCreate` / `flashcardEdit` / `deckImport` remain `RoutePlaceholder` in `app_router.dart`.
- Bulk / suspend / unsuspend / reset / move / tag operations: **not implemented** (block on the bury/suspend + bulk epics).

**Related wireframes:**

- `docs/wireframes/07-flashcard-create.md`, `docs/wireframes/08-flashcard-edit.md`, `docs/wireframes/09-flashcard-history.md` (Future Proposal), `docs/wireframes/10-deck-import.md`
- `docs/wireframes/24-shared-dialogs.md` §bulk-delete, §reset-progress, §discard-session
- `docs/wireframes/25-shared-bottom-sheets.md` §tag-picker, §deck-picker, §filter-status, §undo-toast, §card-context
