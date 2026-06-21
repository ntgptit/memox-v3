# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration.

last_updated: 2026-06-22

## Cursor

- **Active object:** none — loop is at its **TERMINAL stopping point**.
- **Current work-package:** none eligible.
- **Branch:** `main` (last loop work merged via `feat/fe-loop-library`, commit `f2863aa`).
- **Last verify:** PASS (docs-only marker; last code-chain work-package was WP-FL3 `e6e6024`).

## Object status (outer → inner)

| # | Object | Status |
|---|---|---|
| 1 | Library overview | **DONE** (mock-parity verified; enrichments not in rebuilt mock → DEFERred) |
| 2 | Folder detail | **DONE** (deck move + last-studied shipped; new-vs-due not in mock → DEFERred) |
| 3 | Sub-folder (nested) | **DONE** (breadcrumb render) |
| 4 | Deck detail | **DONE** (overline due badge) |
| 5 | Flashcard (list + editor) | **DONE** (reorder + delete shipped; SRS-state + editor screen → DEFERred owner decisions) |
| 6 | Study — Review | **DEFER** (mock↔docs conflict + wireframe drift + greenfield) |
| 7 | Study — Match | **DEFER** (blocked on object 6 anchor) |
| 8 | Study — Guess | **DEFER** (blocked on object 6 anchor) |
| 9 | Study — Recall | **DEFER** (blocked on object 6 anchor) |
| 10 | Study — Fill | **DEFER** (blocked on object 6 anchor) |

## Why the loop is stopped (not idle — blocked)

Objects 1-5 are DONE; every remaining object (6-10) is the **Study session FE**, which is DEFERred on
owner decisions that cannot be auto-resolved or retried the same night:

1. **mock-doc-conflict** — `shots/12-study-review` shows a **flip card** (TAP TO FLIP → Flip/Next),
   but wireframe 13 + `docs/business/study/study-flow.md` specify **both-sides + swipe-to-grade**.
   Review is the anchor whose grammar modes 7-10 reuse → blocks all five.
2. **drift** — wireframes 13-18 falsely claim the study screens are "shipped/Current" while
   `lib/presentation/features/study/` does not exist (wiped in the 2026-06 reset). Needs an
   owner docs-correction pass before any rebuild.
3. **greenfield** — rebuilding routes + entry gate + shared session shell + 5 mode surfaces +
   result is a large multi-slice feature, not a safe unattended overnight slice.

Study **BE** (entry/create/load/answer/finalize/resume/mode-strategies/result) is built and ready.

See `docs/project-management/loop-deferred.md` (objects 6-10 entry) and
`docs/project-management/loop-plan/study-review.md` for the full decision list.

## Next action

Loop is terminal until an owner resolves the Study DEFER (decision 1 + docs pass 2). When unblocked,
re-enter at object 6 (`loop-plan/study-review.md`) for the greenfield study FE build.
