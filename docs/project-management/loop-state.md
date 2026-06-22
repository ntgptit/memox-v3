# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 7 — Study — Match (next inner study mode) — **object 6 (Study — Review) is
  COMPLETE** (all WP-SR slices shipped; Review loop end-to-end). Objects 7-10 reuse the SR2 session
  shell + SR5 result; each adds its own grade grammar. See `loop-plan/study-review.md` (the shared
  Review anchor) + read the Match wireframe/shots before building.
- **Current work-package:** **OBJECT 7 (Match) — AUDIT DONE; plan written; a real BE gap was found.**
  Object 6 (Review) is COMPLETE. The Match audit (TRUST POLICY) found a **confirmed drift**: the
  wireframe-14 drift-note + the repo contract claim the Match BE (`study_match_evaluations` table,
  `recordMatchEvaluation`/`loadMatchEvaluations`, finalization derivation) is built, but **it is NOT**
  — the table is undefined, zero code usages, `MatchStudyModeStrategy` is an empty leaf, WBS 4.5.4 =
  Specified. Wireframe-14 note corrected this iteration. **Match is a BE-first build.** Full slice plan:
  `docs/project-management/loop-plan/study-match.md` (WP-SM1 schema+eval persistence → WP-SM2
  finalization derivation → WP-SM3 mode-dispatch+board shell → WP-SM4 grid+tap-pair → WP-SM5
  progression+finalize). **NEXT: WP-SM1** — the `study_match_evaluations` schema + migration + schema
  docs + `MatchEvaluation` entity + `recordMatchEvaluation`/`loadMatchEvaluations` repo/DAO +
  `RecordMatchEvaluationUseCase` + tests (a careful schema slice). Deferred polish: WP-SR4b-2 (Edit),
  WP-SR1b-2c (gate CTAs), WP-SR2b (language labels); object-5 WP-FL2b2b (Tags).
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

**Build WP-SM1 — Match BE: schema + append-only evaluation persistence** (object 7, BE-first). The
audit (`loop-plan/study-match.md`) confirmed the Match BE is NOT built (drift corrected). This is a
**schema slice** — follow the schema hard-rule (table + migration + schema-contract + migration-contract
+ storage-boundaries + drift-guide docs + tests, all in the SAME commit). Read FIRST:
`docs/project-management/loop-plan/study-match.md` (the full slice plan + BE inventory + the OPEN
QUESTION on mode selection), `docs/contracts/repository-contracts/study-repository.md` (§Match —
`recordMatchEvaluation` / `loadMatchEvaluations` / finalization spec already written), `docs/database/
schema-contract.md` + `migration-contract.md`, `docs/business/study/study-flow.md` (match flow).
Build:
1. `study_match_evaluations` table (`session_id`, `flashcard_id`, `is_correct`, `created_at`;
   append-only) in `lib/data/datasources/local/drift/study_tables.drift` + a Drift migration (bump the
   schema version) + the 4 schema docs.
2. `MatchEvaluation` entity + `study_session_mapper` rows.
3. `recordMatchEvaluation({sessionId, flashcardId, isCorrect, now})` + `loadMatchEvaluations(sessionId)`
   on the study repository + DAO (append-only INSERT + touch `updated_at`; load ordered).
4. `RecordMatchEvaluationUseCase` + DI provider.
5. Repo + DAO + usecase tests (append-only, ordering, touch). Decision rows.
Do NOT also build the finalization derivation here — that is WP-SM2 (next slice). PRECEDENCE: behavior
→ study-repository.md contract + study-flow.md. Deferred: WP-SR4b-2 (Edit), WP-SR1b-2c, WP-SR2b;
object-5 WP-FL2b2b (Tags). Do NOT defer for greenfield.
