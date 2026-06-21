---
last_updated: 2026-06-21
object: Flashcard (list + editor)
loop_order: 5 of 10 (outer→inner)
routes: /library/deck/:deckId/flashcards (rows), card create/edit (dialog today)
status: RE-AUDIT 2026-06-22 — both prior DEFERs OVERTURNED (invalid under current rules); WP-FL1 (card-row subtitle) + WP-FL2a (editor screen shell) are BUILDABLE and queued
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

### RE-AUDIT 2026-06-22 — both DEFERs overturned (evidence: `Explore` + spec `06`/`07`/`08` + srs-review.md)

Neither prior DEFER is valid under the current loop rules (`spec-unclear` needs a TWO-business-doc
conflict; "large/greenfield/needs-decision" is never valid). Resolutions:

- [x] **WP-FL1 — Card-row SRS subtitle — Implemented (2026-06-22).** `FlashcardListDetail` now carries
      `progressById: Map<id, FlashcardProgress>` (repo reuses `FlashcardMapper.progressFromRow`,
      `due_at` int-ms → UTC DateTime; no schema). `flashcard_tile.dart` renders title `{front} — {back}`
      + SRS meta (`New · not studied` / `Box N · due in Xd` / `Box N · due today`, injected `now`); the
      status chip stays a documented mock visual gap (PRECEDENCE #1 — business model New/Due only). ARB
      `flashcardStateNew`/`flashcardStateBoxDueIn`/`flashcardStateBoxDueToday` (en+vi). BE test
      (read-model carries box+dueAt), isolated `flashcard_tile` golden (new + due-in, light+dark) +
      subtitle-variant widget tests, screen loaded golden regenerated (New cards → deterministic).
      Decision row C43. verify PASS (guard 0 errors). Original analysis below.
- [ ] WP-FL1 (original analysis) — The mock `06` `list-row`
      (spec lines 214–273) is: `icon-tile` + `list-row-main` (title `{front} — {back}` font:16/600 +
      meta `Box 4 · due in 3d` font:13/400 color:text-2) + `list-row-trail` (a **chip** `Review` +
      chevron). **PRECEDENCE #1 resolves the chip:** `srs-review.md` §Rules defines the card-state
      model as **New** (`due_at NULL`) / **Due** (`due_at <= now`) only — there is NO
      New/Learning/Review/Mastered taxonomy in `docs/business/**` or the decision tables. So the mock's
      4-state status **chip** is a **mock `06` visual gap** (business model wins) — NOT built, NOT a
      defer; recorded as a documented visual gap. The **subtitle is fully derivable** (no invention):
      `New · not studied` when no progress / `due_at == null`, else `Box {currentBox} · due in {Δd}` /
      `· due today`. **Scope:** surface the already-loaded per-card progress (repo loads
      `progressById: FlashcardProgressRow`, `flashcard_repository_impl.dart:108`) into the read model
      (`FlashcardListDetail.progressById: Map<id, FlashcardProgress>` — domain entity
      `lib/domain/entities/flashcard_progress.dart` already exists; map `due_at` int-ms → UTC DateTime);
      restructure `flashcard_tile.dart` to title `{front} — {back}` + the SRS meta; add ARB
      (`flashcardStateNew`, `flashcardStateBoxDueIn(box,days)`, `flashcardStateBoxDueToday(box)`, en+vi).
      now-dependency: mirror WP-FD9 — inject `now` into the tile + an **isolated `flashcard_tile`
      golden** for the due-in variants; the **screen** loaded golden uses New cards (deterministic).
      No schema. **mock visual gap (documented):** status chip (business model is New/Due only).
- [x] **WP-FL2a — Card editor screen shell — Implemented (2026-06-22).** New routes
      `flashcardCreate` (`new`) + `flashcardEdit` (`:flashcardId/edit`, matches navigation-flow's
      planned paths) registered as children of the deck flashcard-list route (`folder_routes.dart`).
      New `flashcard_editor_screen.dart` (async dispatcher: loading/load-error shells) +
      `flashcard_editor_body.dart` (`FlashcardEditorForm`: X/Cancel + Save app bar, deck breadcrumb,
      FRONT/BACK `MxTextField`, front+back-required Save gating, create vs edit by `cardId`; reads
      deck/card from the existing `flashcardListStreamProvider`, saves via `FlashcardActionController`
      → snackbar + pop). `runAddCard`/`runEditCard` now `pushNamed` the route; deleted the
      `flashcard_card_dialog`. Editor widget tests (create-empty/validation, edit-prefill,
      load-error) + goldens (`07` create-empty + `08` edit-loaded, light+dark). navigation-flow +
      wireframe 06 updated. verify PASS. **WP-FL2b** (below) = Details expander + full state matrix.
- WP-FL2b — Editor Details + delete + full `07`/`08` state matrix (node-split, build in slices):
  - [x] **WP-FL2b1 — Edit trash/delete-from-editor — Implemented (2026-06-22).** Edit app bar gains
        an `Icons.delete_outline` `MxIconButton` before Save (mock `08`); tap → shared destructive
        `MxConfirmDialog` (`cardDelete*`) → `FlashcardActionController.delete` → `cardDeletedSnack` +
        pop. Create mode shows no trash. Widget tests (create-none / edit-trash → confirm) + `08`
        edit-loaded golden regenerated (trash icon). verify PASS.
  - [x] **WP-FL2b2 — Details expander (example/pronunciation/hint) — Implemented (2026-06-22).** A
        `Details · Optional` row (`MxTappable` + chevron) toggles the optional **example /
        pronunciation / hint** `MxTextField`s (auto-opens in edit when the card has any). Extended
        `FlashcardActionController.create/update` to forward example/pronunciation/hint + tags;
        `save()` passes them (blank→null) and **preserves** existing tags on edit (the use case
        replaces tags wholesale). ARB ×5 (en+vi). Widget tests (toggle / edit-prefill) + `07`
        details-open golden (light+dark). Decision row C44. **PRECEDENCE #1:** the mock's deck-selector
        is Future (deck retargeting) + its single "Note" → the business example/pronunciation/hint
        fields; built business fields, not the mock layout. verify PASS.
  - [ ] **WP-FL2b2b — Tags input** (the mock `07`/`08` Tags chips + "Add tag" affordance; business
        model includes tags — `flashcard-management.md` §238). Needs a chip-display + add/remove-tag
        UX; edit currently preserves tags untouched. Build after WP-FL2b3 or as the last object-5 node.
  - [x] **WP-FL2b3a — saving + save-failed** (`6437f66`): `MxPrimaryButton.loading` spinner at the
        disabled accent fill (op:0.38) + `saving` double-submit guard; inline `_SaveErrorBanner`
        (dangerSoft, above the fields per kit `abs:[21,95]`) **replaces** the failure snackbar, keeping
        the draft. Rows C29 (reworded) + C45. Tests + saving/save-failed goldens (light+dark). ✓ verify.
  - [ ] **WP-FL2b3b — load state surfaces** (`07`/`08` loading skeleton + full load-error via a
        single-card read path, so a deep-link edit shows loading/load-error instead of the list stream's
        bare shell). The editor is usable for front/back create+edit+delete without these.
- [ ] **WP-FL2a (original analysis).** Current editor is a
      front/back **dialog** (`flashcard_card_dialog.dart`); the mock `07`/`08` is a full **screen**.
      PRECEDENCE #2 (visual → mock) makes the screen the contract; "rebuild a shipped surface" is not a
      valid defer. G1 split → minimal shell: new routes `flashcardCreate`/`flashcardEdit`
      (route_names/paths + router) + `flashcard_editor_screen.dart` (X/Cancel + Save app bar +
      breadcrumb + FRONT/BACK + front-required validation + create/update use case — **BE already
      supports all fields incl. tags/exampleSentence/pronunciation/hint**), wiring `runAddCard`/
      `runEditCard` to push the route instead of the dialog. **WP-FL2b** = Details expander
      (tags/note/example) + the full `07`/`08` state matrix + delete-from-editor.
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

Object 5 is **NOT DONE** — re-audit (2026-06-22) overturned both prior DEFERs. WP-FL3 (reorder) +
WP-FL4 (delete) remain Implemented (verified in object-4's 22-test pass). **WP-FL1 (card-row SRS
subtitle)** and **WP-FL2a (editor screen shell)** are now confirmed BUILDABLE (the chip is a
PRECEDENCE-resolved mock visual gap, not a blocker; the editor screen is mock-specified + BE-ready).
Build WP-FL1 next iteration, then WP-FL2a; object 5 is DONE only when both ship (or remaining nodes
pass the 4-gate). Then object 6 (greenfield Study build).
