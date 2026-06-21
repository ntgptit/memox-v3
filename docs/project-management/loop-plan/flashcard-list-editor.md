---
last_updated: 2026-06-21
object: Flashcard (list + editor)
loop_order: 5 of 10 (outer→inner)
routes: /library/deck/:deckId/flashcards (rows), card create/edit (dialog today)
status: DONE (reorder + delete Implemented; SRS-state + editor DEFERred — owner decisions)
---

# Loop plan — Object 5: Flashcard (list + editor)

The **card-level** surface inside the deck container (object 4): the card rows' SRS enrichment, the
card create (`07`) / edit (`08`) editor, card delete, and card reorder (`06` Reorder state).
Sources: `shots/06-flashcard-list--*`, `shots/07-flashcard-create--*`, `shots/08-flashcard-edit--*`,
WBS 2.11.2 / 2.12.2 / 2.13.2 / 2.14.2 (all `Specified`), `docs/wireframes/06-flashcard-list.md`.

## Audit — current vs mock

| Concern | As-built | Mock | Verdict |
|---|---|---|---|
| Card row | `flashcard_tile` = icon + front + back + chevron | icon + front—back + **`Box N · due in Xd` / `New · not studied` / `Box 6 · mastered`** + **status chip** (Review/Learning/New/Mastered) + chevron | **Missing (spec-blocked)** |
| Card create / edit | `flashcard_card_dialog` = a **dialog**, FRONT + BACK only | full **screen** (`07`/`08`): X/Save app bar, breadcrumb, FRONT/BACK, **Details** expander (deck selector + tags + note) | **Missing-FE (large)** |
| Card delete | `runDeleteCard` (long-press → confirm) | `06` delete-card state | likely built — verify |
| Card reorder | none | `06` Reorder mode: X/Done app bar, "Drag the handles…", rows with drag handles | **Missing-FE (eligible)** |

## Gap-checklist (work-package queue)

- [ ] **WP-FL1 — Card-row SRS state (subtitle + status chip)** — **DEFER (spec-unclear).** The mock
      rows show `Box N · due in Xd` / `New · not studied` / `Box 6 · mastered` + a
      New/Learning/Review/Mastered status chip. The **box → state mapping is undocumented** (the mock
      implies New=unstudied, Learning=low box, Review=mid, Mastered=box 6+, but no thresholds are in
      `docs/business/**` or the decision tables). It drives BOTH the subtitle's `mastered`/`due in Xd`
      text AND the chip, so the row enrichment can't be split cleanly. Needs a documented state-mapping
      decision (box thresholds + chip tokens) + a per-card progress read model (the repo already loads
      `progressById` after WP-D1, and `relativeTimeFrom` exists). Build once the mapping is specced.
- [ ] **WP-FL2 — Card editor full screen (`07`/`08`)** — **DEFER (needs-decision / large).** Shipped
      V1 is a front/back **dialog** (`flashcard_card_dialog`); the mock is a full **screen** with an
      X/Save app bar, breadcrumb, FRONT/BACK, and a **Details** expander (deck selector + tags + note —
      the BE already supports `tags`/`exampleSentence`/`pronunciation`/`hint`). Rebuilding dialog→screen
      + adding the Details fields + the `07` (empty/valid/details-open/validation/saving/save-failed)
      and `08` (loaded/loading/load-error/validation/saving/save-failed/delete) states is a multi-slice
      effort and a pattern decision (is the dialog an accepted V1, or rebuild to the screen?). Flag for
      owner; do not unilaterally rebuild a shipped surface overnight.
- [x] **WP-FL3 — Card reorder mode (WBS 2.14.2)** — **Implemented (2026-06-21).** Deck overflow kebab
      → new `flashcard_deck_overflow_sheet` (Reorder cards / Delete deck); Reorder cards →
      `FlashcardReorderActive.enter()`. Reorder mode: X/Done `MxAppBar`, `{n} CARDS · DRAG TO REORDER`
      overline, `ReorderableListView` (`ValueKey('flashcard_reorder_list')`, `buildDefaultDragHandles:
      false` + trailing `ReorderableDragStartListener` handles); a drop persists via
      `ReorderFlashcardsUseCase` (`runReorderCards`). 4 ARB keys (en+vi). Widget test
      (enter/handles/Done/exit) + reorder golden (light+dark). Corrected the wireframe's "leading"
      handle note → trailing (matches the mock). verify PASS.
- [x] **WP-FL4 — Card delete FE (WBS 2.13.2)** — **Implemented (2026-06-21).** `runDeleteCard`
      (card long-press → `MxConfirmDialog` destructive → `FlashcardActionController.delete` →
      `cardDeletedSnack`) was already built; added the missing FE affordance widget test (long-press
      → confirm shown → cancel keeps the card) and flipped 2.13.2 Specified→Implemented (BE cascade
      tested by C6). Corrected the phantom `features/flashcards/...` WBS source paths → `features/decks/`.

## Conclusion

Object 5 is **DONE** (2026-06-21): WP-FL4 (card delete) + WP-FL3 (card reorder mode) Implemented;
WP-FL1 (card-row SRS state — box→state mapping undocumented) and WP-FL2 (editor dialog→screen
rebuild) are **DEFERred owner decisions** (logged in `loop-deferred.md`). Next object (outer→inner):
**Study — Review mode** (object 6).
