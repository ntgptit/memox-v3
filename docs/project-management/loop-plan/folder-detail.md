---
last_updated: 2026-06-21
object: Folder (detail)
loop_order: 2 of 10 (outer→inner)
route: /library/folder/:id
status: DONE — re-audit-confirmed 2026-06-22 (FD1–FD5, FD9, FD10 search-dock, FD11 move-goldens Implemented; FD6/FD7/FD8 DEFERred — not in rebuilt mock)
---

# Loop plan — Object 2: Folder (detail)

FE-completion loop plan. Sources audited:
`docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md`,
`docs/wireframes/05-folder-detail.md`,
`docs/system-design/MemoX Design System/ui_kits/mobile/shots/INDEX.md` §`04 — Folder detail`,
WBS rows 3.2.x / 2.7.2 / 2.8.2 / 2.9.2 / 2.19.2 / 2.5.2 / 2.10.2 / 3.2.3.

## Objective

Bring Folder Detail to full FE parity with the kit `04` mock and complete the deck/folder
management surface it hosts. The screen shell + 6 states + create/rename/delete are built;
the open FE work is **deck move** and **manual reorder** (both have Implemented BE).

## Audit — current implementation

| Area | As-built | Verdict |
|---|---|---|
| Screen shell + app bar (search / sort / overflow) | `folder_detail_screen.dart` | Implemented |
| Breadcrumb ancestry dock | `MxBreadcrumb` + `buildLibraryBreadcrumb` | Implemented |
| States body (decks / subfolders / empty-unlocked / search-empty / loading / error) | `folder_detail_body.dart` | Implemented |
| Stats summary card | `folder_stats_card.dart` | Implemented |
| Content-aware create FAB (deck / subfolder / none) | `folder_detail_screen._fab` | Implemented |
| Create deck (FAB → dialog) | `deck_create_dialog.dart` (WBS 2.7.2) | Implemented |
| Create subfolder | `runCreateSubfolder` | Implemented |
| Deck row + tap → flashcard list | `deck_tile.dart` | Implemented |
| Deck actions sheet — Rename / Delete | `deck_actions_sheet.dart`, `folder_detail_actions.dart` (WBS 2.8.2 / 2.9.2) | Implemented |
| Folder actions (Rename / Move / Delete) | `folder_detail_actions.dart` → shared sheet + picker | Implemented |
| Per-scope sort sheet | `content_sort_sheet.dart` (WBS 2.23.1) | Implemented |
| Delete-folder auto-pop on viewed-folder removal | `folder_detail_screen` `ref.listen` | Implemented |
| Goldens (kit-04 states × light+dark) | `test/presentation/features/folders/folder_detail_test.dart` | Implemented |

## MAP — kit `04` states (`shots/INDEX.md` §04)

| Mock state | Component / behavior | Scope |
|---|---|---|
| Decks | `folder_detail_body` decks-mode list of `deck_tile` | Current |
| Subfolders | `folder_detail_body` subfolders-mode list | Current |
| Empty / unlocked | empty state w/ both create CTAs | Current |
| Search empty | `folder_detail_search` no-results | Current |
| Loading | skeleton | Current |
| Error | `MxErrorState` + Retry | Current |
| Delete confirm | `MxConfirmDialog` destructive (shared-dialog golden) | Current |
| Move sheet | deck + folder move picker (`deck_move_picker_sheet.dart`, `folder_move_picker_sheet.dart`); goldened (WP-FD11) | Current |

## Gap-checklist (work-package queue, Depends-on order)

- [x] WP-FD1 — Folder detail screen + 6 states + nav (WBS 3.2.2) — **Implemented**
- [x] WP-FD2 — Deck create FE (FAB → dialog) (WBS 2.7.2) — **Implemented**
- [x] WP-FD3 — Deck rename FE (sheet → dialog → BE) (WBS 2.8.2) — **Implemented**
- [x] WP-FD4 — Deck delete FE (sheet → confirm → BE) (WBS 2.9.2) — **Implemented**
- [x] **WP-FD5a — Deck move-targets BE (WBS 2.19.2, vertical slice)** — **Implemented (2026-06-21).**
      Verified deck move IS in the kit mock (`04-folder-detail--move-sheet` lists the deck's current
      parent as a selectable destination → it's a deck move, not a folder move). Built the read path:
      `DeckMoveTarget` model + `DeckMoveBlock.lockedToSubfolders` enum, `FolderRepository
      .getDeckMoveTargets(deckId)` (all folders, no Library-root; annotated `isCurrentParent` +
      `block` when content_mode == subfolders, mirroring `_deckParentGuard` / `getFolderMoveTargets`),
      `GetDeckMoveTargetsUseCase` + DI. BE tests (repo: not-found + current-parent/decks/unlocked/
      subfolders-locked annotation; use case forwarding). Contract `deck.md` §GetDeckMoveTargetsUseCase.
      verify PASS.
- [x] **WP-FD5b — Deck move FE (WBS 2.19.2)** — **Implemented (2026-06-21).** Added
      `DeckAction.move` + a Move row to `deck_actions_sheet.dart`; `runDeckActions` loads targets via
      `LibraryActionController.deckMoveTargets` → `showDeckMovePicker` (new
      `deck_move_picker_sheet.dart`, blocked/current rows disabled with reason) → `moveDeck` →
      localized snackbar. 4 ARB keys (en+vi). Behavior widget tests (sheet Move row + picker
      selectable/blocked/current/move). verify PASS. **Variance:** the picker reuses the established
      **tap-to-select** `folder_move_picker_sheet` pattern, not the kit's radio + "Move here" confirm
      styling — keeping one picker paradigm app-wide; the radio+confirm restyle is a deferred
      refinement that should apply to BOTH pickers together (documented in wireframe 25).
- [ ] WP-FD6 — Deck reorder FE (WBS 2.10.2) — **DEFER (spec-unclear: no UI design).** Reorder
      *behavior* is specified (`reorderDecksUseCaseProvider` wired), but the kit ships only the 8
      folder-detail states (no reorder/drag shot), the wireframe as-built banner explicitly defers
      reorder, the business docs give no drag-handle/affordance spec, and the app has no reorderable-
      list pattern. Building it means inventing the drag affordance + restructuring the approved
      grouped-card loaded state (regressing its goldens) with no mock/golden to validate against —
      mock-doc-conflict, a standing DEFER exception even under the vertical-slice rule. Needs an
      approved reorder-state mock + an `MxReorderableList` design decision.
- [ ] WP-FD7 — Folder (subfolder) reorder FE (WBS 2.5.2) — **DEFER (spec-unclear: no UI design).**
      Same blocker as WP-FD6.
- [ ] WP-FD8 — Folder detail new-vs-due study split (WBS 3.2.3) — **DEFER (mock-doc-conflict).**
      Audited against `shots/04-folder-detail--decks--{light,dark}.png` (2026-06-21): the rebuilt
      calm-app mock shows a **Decks / Cards / Due** stats card and deck rows with `{n} cards · last
      {time} ago` + due badge — **no `{n} new` count, no new badge, no Study-new / Review-due CTAs.**
      3.2.3's new-vs-due UI is the prior iteration the rebuild dropped (same pattern as the Library
      mastery/newCount enrichments). The `FolderSummary.newCount` field already shipped (WP-L6b) but
      stays read-model-only. Building the badges/CTAs = inventing UI not in the mock.
- [x] **WP-FD9 — Deck-row "last studied" line** — **Implemented (2026-06-21).** `folderDeckSummaries`
      gains `last_studied_at` = `MAX(study_session_items.answered_at)` over the deck's cards (a
      correlated subquery so the card/due COUNTs don't fan out); `DeckSummary.lastStudiedAt`
      (DateTime?). New pure `relativeTimeFrom` bucket (`lib/core/util/relative_time.dart`,
      justNow/minutes/hours/days/weeks) + 5 ARB keys (en+vi); `deck_tile` renders
      `{n} cards · last {time} ago` when studied (injectable `now` for golden determinism). BE
      query test (max + null + no count inflation), bucket boundary tests, tile widget tests + a
      studied-state golden (light+dark). verify PASS.

- [x] **WP-FD10 — Folder-detail search bottom-dock (kit `04` Search) — Implemented (2026-06-22).**
      **RE-AUDIT finding (TRUST POLICY):** like Library before WP-L10, folder-detail search shipped
      as an **app-bar swap** (`FolderDetailSearchAppBar` + Cancel), but the kit `04` Search-empty
      state renders the field as a flat **bottom `search-dock`** with the regular title + sort +
      overflow app bar retained (ui-parity-checker Gap #2). Per PRECEDENCE #2 (visual → mock) +
      consistency with WP-L10, rebuilt: `FolderDetailSearchDock` (surface fill + top hairline,
      hosts the provider-synced `FolderDetailSearchField`) mounted in the `bottomNavigationBar`
      slot; app-bar `Icons.search` now toggles search on/off (`_toggleSearch`, early-return);
      deleted `FolderDetailSearchAppBar`. Regenerated the 2 search-no-results goldens; added dock
      present/absent + toggle-exit widget tests. verify PASS. **Note:** kept the provider-synced
      `FolderDetailSearchField` (not the shared `MxSearchDock`, whose onChanged-only API can't host
      the external controller the body's no-results Clear CTA needs).
      **App-bar variance (documented):** the kit Decks-state app bar shows only the overflow icon;
      the search-toggle + `swap_vert` sort (WBS 2.23.1, owner-approved, shown app-wide) are kept as
      post-redesign affordances — same documented variance as Library.

- [x] **WP-FD11 — Move-sheet picker goldens (kit `04` move-sheet) — Implemented (2026-06-22).**
      **RE-AUDIT finding (ui-parity Gap #1):** the move-sheet state (`04-folder-detail--move-sheet`,
      the deck-move context per WP-FD5a) had NO golden — `deck_move_picker_sheet.dart` and
      `folder_move_picker_sheet.dart` were behavior-tested only. Added `move_picker_golden_test.dart`
      goldening both pickers (deck + folder) light+dark at 390×780, each covering the four row
      variants: selectable, nested (path subtitle), current-parent (check, not selectable), and
      blocked (disabled, reason subtitle). Closes the state-coverage gap. **Variance (documented,
      bundled DEFER):** the goldens capture the current **tap-to-select + plain-folder-icon** design;
      the kit's picker restyle — radio + "Move here" confirm button + per-destination semantic icons
      in tinted `MxIconTile` tiles — stays one deferred refinement applying to both pickers together
      (WBS 2.19.2). The icon-tile part needs the folder/deck color+icon propagated into
      `DeckMoveTarget`/`FolderMoveTarget` (deck color/icon also needs the deferred deck-schema). verify
      PASS; ui-parity-checker PASS (state-coverage closed; icon-tile divergence is the bundled DEFER).

## Notes

- WBS rows 2.7.2 / 2.8.2 / 2.9.2 are still marked `Specified` though the code + tests are
  screen-hosted and live; flip them to Implemented when the next code work-package verifies
  (avoid a status-only flip without re-running the targeted tests).
- Object 2 leaves for object 3 (Sub-folder / nested) only after every gap-checklist item is
  Implemented or DEFERred.
- **Rules updated 2026-06-21 (vertical-slice loop):** BE (incl. schema/migration) may now be added
  to unblock FE. WP-FD5 un-DEFERred (was needs-BE) and split into BE (FD5a) + FE (FD5b). FD6/FD7
  stay DEFER — their blocker is mock-doc-conflict (no reorder design), still an exception.

## Conclusion

Object 2 is **DONE** — re-audit-confirmed 2026-06-22 (evidence: code + 25 folder tests + goldens
PASS via `tool/verify`; ui-parity-checker PASS). Implemented: FD1–FD4 (screen + create/rename/
delete), FD5a/FD5b (deck move BE+FE, WBS 2.19.2), FD9 (deck "last studied" line, WBS 3.2.2/3.7.1),
**FD10 (search bottom-dock, WBS 3.2.2)**, **FD11 (move-sheet picker goldens)** + WP-L6a (F13
due-count fix). DEFERred: FD6/FD7 (reorder — no UI mock), FD8 (new-vs-due — not in rebuilt mock).
Pre-existing cross-cutting gaps logged in `loop-deferred.md` (deck color/icon schema, due-badge
fill, SRS persistent-`last_studied_at` drift). Next object (outer→inner): **Sub-folder (nested)**
— see `loop-plan/sub-folder-nested.md`.
