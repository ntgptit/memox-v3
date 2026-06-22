# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 7 — Study — Match (next inner study mode) — **object 6 (Study — Review) is
  COMPLETE** (all WP-SR slices shipped; Review loop end-to-end). Objects 7-10 reuse the SR2 session
  shell + SR5 result; each adds its own grade grammar. See `loop-plan/study-review.md` (the shared
  Review anchor) + read the Match wireframe/shots before building.
- **Current work-package:** **OBJECT 7 (Match) — WP-SM1a SHIPPED (schema enabler).** The
  `study_match_evaluations` append-only table + v8 migration + schema docs landed (`a7b5cb9`),
  correcting the audited drift (the table was claimed-built but undefined). Schema-only/additive, no
  behavior yet (mirrors v6/v7 enablers). WBS 4.5.4 → Partial. **NEXT: WP-SM1b** — the evaluation
  persistence: `MatchEvaluation` entity + `study_session_mapper` rows; `recordMatchEvaluation(...)`
  (append the row; `attempt_order` = next per-session seq; `flashcard_id` = `expectedFrontFlashcardId`;
  + touch `study_sessions.updated_at`) and `loadMatchEvaluations(sessionId)` (ordered) on the domain
  repo interface + `study_repository_impl` + DAO (**reuse the existing `Result<T>` pattern, NOT fpdart**);
  `RecordMatchEvaluationUseCase` + DI; repo/DAO/use-case tests + decision rows. Then WP-SM2
  (finalization derivation) → WP-SM3/4/5 (FE board). Plan: `docs/project-management/loop-plan/study-match.md`.
  Deferred: WP-SR4b-2 (Edit), WP-SR1b-2c (gate CTAs), WP-SR2b (language labels); object-5 WP-FL2b2b (Tags).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `a7b5cb9` (WP-SM1a — Match schema v8; prior
  `7a9ae4a` WP-SR5b object 6 COMPLETE, `b426047` WP-SR5a).
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
| 7 | Study — Match | **ACTIVE — BE-first build.** Audit done (drift corrected). **WP-SM1a schema enabler SHIPPED** (`study_match_evaluations` v8); WBS 4.5.4 Partial. Next: WP-SM1b (eval persistence) → SM2 (finalization) → SM3/4/5 (FE board, reuses SR2 shell + SR5 result). Plan: `loop-plan/study-match.md`. |
| 8–10 | Study — Guess/Recall/Fill | BUILD (independent FE grammar; reuse SR2 shell + SR5 result) |

## Next action

**Build WP-SM1b — Match BE: evaluation persistence** (object 7; the schema enabler WP-SM1a shipped v8).
Read FIRST: `docs/project-management/loop-plan/study-match.md` (slice plan), `docs/contracts/
repository-contracts/study-repository.md` (§Match — the `recordMatchEvaluation` signature + the
write-effect table: INSERT + touch `study_sessions.updated_at`; append-only; does NOT mark items
answered), and `lib/data/repositories/study_session_card_actions.dart` (the existing `Result<T>` repo
pattern + how it touches `updated_at`). Build:
1. `MatchEvaluation` entity (mirror the table: id, sessionId, sessionItemId, flashcardId, boardIndex,
   pairId, selectedFront/BackCellId, expectedFront/BackFlashcardId, isCorrect, attemptOrder,
   evaluatedAt, createdAt) + `study_session_mapper` row→entity rows.
2. `recordMatchEvaluation(...)` (the full contract signature) + `loadMatchEvaluations(sessionId)` on the
   **domain** `StudyRepository` interface + `study_repository_impl` (+ a DAO method or extend
   `study_session_dao`). On record: `attempt_order` = next per-session sequence (count existing rows);
   `flashcard_id` = `expectedFrontFlashcardId`; `evaluated_at`/`created_at` = now; touch
   `study_sessions.updated_at` in the same write. Load: ordered by `attempt_order`.
   **Use the existing `Result<T>` record pattern (NOT fpdart `Either`)** per CLAUDE.md.
3. `RecordMatchEvaluationUseCase` + DI provider (mirror `BuryStudySessionCardUseCase`).
4. Repo + DAO + use-case tests (append-only insert, ordering by attempt_order, touch updated_at).
   Decision rows. (`docs/contracts/repository-contracts/study-repository.md` already specifies the API.)
Do NOT build the finalization derivation here — WP-SM2 (next). PRECEDENCE: behavior → study-repository.md
contract + study-flow.md. Deferred: WP-SR4b-2 (Edit), WP-SR1b-2c, WP-SR2b; object-5 WP-FL2b2b (Tags).
