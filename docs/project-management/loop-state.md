# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 7 — Study — Match (next inner study mode) — **object 6 (Study — Review) is
  COMPLETE** (all WP-SR slices shipped; Review loop end-to-end). Objects 7-10 reuse the SR2 session
  shell + SR5 result; each adds its own grade grammar. See `loop-plan/study-review.md` (the shared
  Review anchor) + read the Match wireframe/shots before building.
- **Current work-package:** **OBJECT 7 (Match) — WP-SM1b SHIPPED (eval persistence).** `MatchEvaluation`
  entity + mapper; `recordMatchEvaluation` (append-only INSERT + touch `updated_at`; validates
  in_progress + item-in-session + mode==match; `attempt_order` = per-session COUNT) / `loadMatchEvaluations`
  (ordered) on the repo + DAO via the `StudyMatchEvaluationActions` collaborator; `RecordMatchEvaluationUseCase`
  + DI (`a99cdc8`). S54/S55 tested. WBS 4.5.4 → Partial (SM1a+1b). **NEXT: WP-SM2** — the Match
  **finalization derivation** (the last BE slice): extend `finalizeStudySession` with a Match branch that
  reads the eval rows → derives **one terminal `study_attempts` per session item** (all-correct→perfect;
  any-wrong→forgot, per the strategy) → applies the normal SRS transition + marks the item answered, in
  one transaction (decision **S56/S57**). This is **NEW SRS spec** — define the derivation rules in
  `study-flow.md` + `srs-review.md` FIRST, then code + transition tests. Flip 4.5.4 → Implemented. Then
  WP-SM3/4/5 (FE board). Plan: `docs/project-management/loop-plan/study-match.md`. Deferred: WP-SR4b-2
  (Edit), WP-SR1b-2c (gate CTAs), WP-SR2b (language labels); object-5 WP-FL2b2b (Tags).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `a99cdc8` (WP-SM1b — Match eval persistence;
  prior `a7b5cb9` WP-SM1a schema v8, `7a9ae4a` WP-SR5b object 6 COMPLETE).
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
| 7 | Study — Match | **ACTIVE — BE-first build.** Audit done (drift corrected). **WP-SM1a schema v8 + WP-SM1b eval persistence SHIPPED** (`study_match_evaluations`, `record/loadMatchEvaluations`, `RecordMatchEvaluationUseCase`; S54/S55); WBS 4.5.4 Partial. Next: **WP-SM2 (finalization derivation — NEW SRS spec, S56/S57)** → SM3/4/5 (FE board, reuses SR2 shell + SR5 result). Plan: `loop-plan/study-match.md`. |
| 8–10 | Study — Guess/Recall/Fill | BUILD (independent FE grammar; reuse SR2 shell + SR5 result) |

## Next action

**Build WP-SM2 — Match BE: finalization derivation** (object 7; the last Match BE slice — WP-SM1a/1b
shipped the schema + record/load). This is **NEW SRS spec** — DEFINE the derivation rules in
`docs/business/study/study-flow.md` + `docs/business/srs/srs-review.md` FIRST (decision **S56/S57**),
then code. Read FIRST: `docs/contracts/repository-contracts/study-repository.md` (§Match finalization:
"read `study_match_evaluations` + INSERT `study_attempts` + UPDATE `flashcard_progress` + UPDATE
`study_sessions`"; the Notes "derives one terminal `study_attempts` row per session item, then applies
the normal SRS transition in the same transaction" + "unanswered match items removed"), the existing
`finalizeStudySession` impl in `study_repository_impl.dart`, and `lib/domain/srs/srs_box.dart`
(`nextBox`). Build:
1. The derivation rule (S56/S57): per session item, read its `study_match_evaluations` rows →
   **all-correct (no wrong before the correct) → `perfect`; any wrong (or never correct) → `forgot`**
   (confirm exact mapping against the `MatchStudyModeStrategy` / study-flow.md before coding).
2. Extend `finalizeStudySession` (or a `StudyMatchFinalization` collaborator to stay under budget) with
   a Match branch: in ONE transaction, derive one terminal `study_attempts` per item (box_before/after
   via `nextBox`), mark items answered, UPSERT `flashcard_progress`, mark session completed. Reuse the
   one-terminal-attempt + first-attempt-decides-SRS contract from `srs-review.md`.
3. How does finalize know a session is "Match"? (Currently sessions carry `studyType`, not mode.)
   Resolve: if there are any `study_match_evaluations` rows for the session, run the Match branch;
   else the existing recordAnswer-based branch. Document this in study-flow.md.
4. Transition tests (mirror `study_srs_transition_test.dart`) + decision rows. Flip 4.5.4 → Implemented.
Then WP-SM3/4/5 (FE board). PRECEDENCE: behavior → srs-review.md + study-flow.md. Deferred: WP-SR4b-2
(Edit), WP-SR1b-2c, WP-SR2b; object-5 WP-FL2b2b (Tags).
