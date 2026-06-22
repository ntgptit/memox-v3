# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 7 — Study — Match (next inner study mode) — **object 6 (Study — Review) is
  COMPLETE** (all WP-SR slices shipped; Review loop end-to-end). Objects 7-10 reuse the SR2 session
  shell + SR5 result; each adds its own grade grammar. See `loop-plan/study-review.md` (the shared
  Review anchor) + read the Match wireframe/shots before building.
- **Current work-package:** **OBJECT 6 COMPLETE — WP-SR5b SHIPPED (result variant states).** Final
  Review slice: **save-failed** (`failedToFinalize` → danger banner + Retry; Done stays) + **defensive**
  (zero answered → "No cards answered" notice) states + goldens. Full Review path now lives: launch →
  gate → session → swipe-grade → exit-confirm → Bury/Suspend → Finish → finalize → result → Done.
  **NEXT: object 7 — Study — Match.** Audit the Match BE (does a Match study mode / read model exist?
  check `StudyMode.match`, the usecases, `docs/wireframes/14-study-session-match.md` + study-flow.md)
  + the shots `14-study-session-match-*`; CHẺ into slices (mode chrome → option grid → match-grade →
  reuse SR5 finalize/result). Deferred polish: WP-SR4b-2 (Edit, needs deckId), WP-SR1b-2c (gate CTAs),
  WP-SR2b (language labels); object-5 WP-FL2b2b (Tags).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `7a9ae4a` (WP-SR5b — object 6 COMPLETE; prior
  `b426047` WP-SR5a, `0ddbd62` WP-SR4b).
- **Last verify:** PASS (code chain, guard 0 errors) — WP-SR1b-2b tree + review-fix. **Fan-out now
  complete:** docs-drift PASS; code-reviewer APPROVE + ui-parity PASS (re-ran after the 529 overload
  cleared). Folded 2 Importants: fallback-Back `fullWidth`, + a "Study new instead" navigation test
  (`_reenterWithNewCards`). ~25 gate tests + 10 goldens.

## Follow-up cleanups (logged, not blocking)

- Shared-dock dedup: `LibrarySearchDock` + `FolderDetailSearchDock` are near-identical (dock chrome
  + a provider-synced field). Extract a shared `MxScopedSearchDock({child})` once both consumers are
  stable. (`MxSearchDock` stays separate — its onChanged-only API can't host the synced field.)
- Search-mode app-bar icons: kit Decks/loaded states show only overflow (folder) / sort (library);
  the search-toggle + sort icons are kept as post-redesign affordances (documented variance). A
  future pass could hide search+sort while `searching` to match the mock exactly — apply to BOTH
  Library + folder together.
- FAB in flashcard-list **empty** state: `flashcard_list_screen.dart` shows the add-card `MxFab`
  even when `totalCount == 0`, but kit `06` empty has no FAB (the empty state has an inline Add CTA);
  Library/folder empty states correctly hide the FAB. Pre-existing (not WP-D2). Small eligible fix:
  gate the FAB on `detail != null && detail.totalCount > 0`; regen the 2 empty goldens. Fold into the
  object-5 pass (same `06` screen).

## Loop is NOT terminal — prior "terminal" stop was invalidated

The previous iteration declared terminal on three reasons now disallowed by the loop rules:
greenfield/too-large (→ must split & build), mock↔docs flip-vs-swipe (→ PRECEDENCE: business
`study-flow.md` wins), wireframe "shipped" drift (→ stale doc-status, fix one line on build). Study
(object 6) BE is ready → it is a BUILD case, not a stop. Re-auditing 1→5 by evidence first.

## Object status (outer → inner) — TRUST POLICY: confirm by evidence on the current tree

| # | Object | Status |
|---|---|---|
| 1 | Library overview | **DONE (re-audit-confirmed 2026-06-22)** — code+test+golden verified; re-audit found the Search state diverged (app-bar swap vs kit bottom dock) → fixed in WP-L10 (`LibrarySearchDock`); ui-parity PASS. |
| 2 | Folder detail | **DONE (re-audit-confirmed 2026-06-22)** — code+25 tests+goldens verified; search-state app-bar-swap → bottom dock (WP-FD10); move-sheet golden gap closed (WP-FD11); ui-parity PASS. DEFERred: reorder (no mock), new-vs-due (not in mock), picker restyle (bundled). |
| 3 | Sub-folder (nested) | **DONE (re-audit-confirmed 2026-06-22)** — same `FolderDetailScreen` at depth (no separate screen/route/mock); nested-breadcrumb + tappability + create-mode-lock + actions-at-depth all code+test-verified (`Explore` + `tool/verify`, 21 tests). No gap to build. |
| 4 | Deck detail | **DONE (re-audit-confirmed 2026-06-22)** — deck container (WBS 3.4.2) + WP-D1 due badge + WP-D2 **persistent** search dock (kit `06` dock is persistent, not toggle). ui-parity PASS. |
| 5 | Flashcard (list + editor) | IN PROGRESS — FL3/FL4 + **FL1** + **FL2a shell** + **FL2b1 delete** + **FL2b2 Details** + **FL2b3a saving+save-failed** + **FL2b3b loading+load-error (`d3aa162`)** SHIPPED (ui-parity PASS). **Only WP-FL2b2b (Tags input) remains** before DONE. |
| 6 | Study — Review | **DONE (2026-06-22).** Gate (WP-SR1a..1b-2b) + session (WP-SR2) + swipe-grade (WP-SR3) + exit-confirm (WP-SR4a) + card-actions Bury/Suspend (WP-SR4b) + finalize→result V1 incl. save-failed/defensive (WP-SR5a+5b) — **Review loop end-to-end + code+test+golden verified.** WBS 4.1.2/4.7.2 Implemented; 4.5.3 Partial (WP-SR2b language labels + WP-SR4b-2 Edit deferred polish). |
| 7 | Study — Match | **ACTIVE — BUILD next.** Reuses the SR2 session shell + SR5 finalize/result; adds the Match grade grammar (option grid; `StudyMode.match`). Audit the Match BE + wireframe `14` / shots `14-study-session-match-*` first, then CHẺ. |
| 8–10 | Study — Guess/Recall/Fill | BUILD (independent FE grammar; reuse SR2 shell + SR5 result) |

## Next action

**Start object 7 — Study — Match (AUDIT-FIRST, then CHẺ + build).** Object 6 (Review) is COMPLETE.
Match is a sibling study mode that reuses the SR2 session shell + the SR5 finalize/result, adding its
own grade grammar (an option grid — pick the matching card; per `docs/business/study/study-flow.md`
S60 mentions "5 real option cards"). **Before building, BƯỚC 1 audit (TRUST POLICY — confirm by
evidence, don't trust status):**
1. Read `docs/wireframes/14-study-session-match.md` + the shots `14-study-session-match-*`
   (`shots/INDEX.md`) + `docs/business/study/study-flow.md` (match flow) + decision rows S60/S6x.
2. Audit the **Match BE**: does `StudyMode.match` exist? Is there a match read model / use case
   (option-set generation, match-grade recording) like Review's `LoadStudySessionReviewUseCase` /
   `RecordStudySessionAnswerUseCase`? Grep `lib/domain/usecases/study/` + `study_repository*`. **If the
   BE is missing**, the first slice is BE (entity → repo contract → use case → DI + tests) per the
   vertical-slice invariant — do NOT build FE on a missing read model.
3. CHẺ into runnable slices (e.g. mode chrome/route → option grid → match-grade+advance → reuse SR5
   finalize/result), one per iteration, each verified + fan-out + 2-commit.
PRECEDENCE: behavior → study-flow.md + wireframe 14 win over the mock. Reuse `StudyMode`, the session
shell pattern, `MxLinearProgress` (green family for non-recognition modes per the PRECEDENCE note),
the card-actions sheet, and the result screen. Deferred: WP-SR4b-2 (Edit), WP-SR1b-2c (gate CTAs),
WP-SR2b (language labels); object-5 WP-FL2b2b (Tags). Do NOT defer for greenfield.
