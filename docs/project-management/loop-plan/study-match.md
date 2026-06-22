---
last_updated: 2026-06-22
object: Study — Match mode (object 7 of 10)
loop_order: 7 of 10 (outer→inner; after object 6 Review, COMPLETE)
route: /library/study/session/:sessionId (shared session route; mode = match)
status: AUDIT DONE → BUILD (BE-first; a real schema gap was found — see Drift)
---

# Loop plan — Object 7: Study — Match

Match = a multi-pair matching board (wireframe `14-study-session-match.md`). The user sees a 2×5
grid (10 cells = 5 fronts + 5 backs of the same 5 cards, shuffled). Tap two cells: a valid pair
(front+back of the same flashcard) locks green ✓; a wrong pair red-flashes ~600ms then deselects.
A "board" = 5 cards; clearing one reveals the next ("BOARD 2 OF 3"); last board → finalize → result.

## DRIFT FOUND (2026-06-22 audit — TRUST POLICY, confirmed by evidence)

`docs/wireframes/14-study-session-match.md` drift-note (2026-06-12) claims *"the Match backend slice
now includes the dedicated append-only evaluation path plus transactional finalization derivation"*,
and `docs/contracts/repository-contracts/study-repository.md` specifies `recordMatchEvaluation` /
`loadMatchEvaluations` + a `study_match_evaluations` table + a Match finalization-derivation branch.
**But the evidence shows the Match BE is NOT built:**

- `study_match_evaluations` table is **not defined** — `study_tables.drift:12-15` explicitly says it is
  *"target shape that lands with the mode-chain rows (WBS 4.5.x), not this enabler."*
- **Zero** code usages of `study_match_evaluations` / `MatchEvaluation` (no DAO, no repo impl, no entity).
- `MatchStudyModeStrategy` (`study_mode_strategy.dart:174`) is an **empty leaf** (Board family, no grading API).
- **WBS 4.5.4 = Specified** (accurate). The §10 "TBD"-hash entry (line ~684, 2026-06-12, "Match
  persistence backend wave") describes a *planned* wave that was never actually committed.

→ The contract doc + the wireframe drift-note are **aspirational** (target), not current. Correct the
wireframe note in the BE slice's commit. **Match is a BE-first build**, per the vertical-slice invariant.

## BE inventory (audited 2026-06-22)

| Need | Status |
|------|--------|
| `StudyMode.match` enum + token mapping (`study_session_mapper`) | **Implemented** |
| `MatchStudyModeStrategy` / `BoardStudyModeStrategy` family (factory `study_mode_strategy_factory`) | **Implemented** (leaf only, no grading API) |
| Session items (5-card batches come from here) — `LoadStudySessionReviewUseCase` → `StudySessionReview{items[]}` | **Implemented** (reuse; FE batches into boards of 5) |
| `study_match_evaluations` table + migration + schema docs | **MISSING (4.5.4)** |
| `MatchEvaluation` entity | **MISSING (4.5.4)** |
| `recordMatchEvaluation({sessionId, flashcardId, isCorrect, now})` repo + DAO (append-only INSERT + touch `updated_at`) | **MISSING (4.5.4)** — contract spec exists |
| `loadMatchEvaluations(sessionId)` repo + DAO | **MISSING (4.5.4)** — contract spec exists |
| Match **finalization derivation** (read eval rows → one terminal `study_attempts` row per item → `flashcard_progress` UPDATE; unanswered match items removed) | **MISSING (4.5.4)** — contract spec exists; `finalizeStudySession` Match branch |
| Use cases: `RecordMatchEvaluationUseCase`, (board data via existing review load) | **MISSING (4.5.4)** |
| Match board FE (the 14 board UI) | **MISSING (4.5.5)** |
| Mode selection at runtime (how the session route renders Match vs Review) | **OPEN QUESTION** — see below |

## OPEN QUESTION — mode selection (resolve in slice 0, before FE)

`StudySessionScreen` currently hardcodes Review. The session/scope carries `studyType` (new/srs), NOT
a `StudyMode`. The wireframe-14 route is the same `/library/study/session/:sessionId` with
`study_mode: match`. Per the mode-chain spec (WBS 4.5.12/4.5.13, `study-flow.md` per-phase chain:
review→match→guess→recall→fill) the session is meant to carry a `current_mode` that the screen reads
and advances. **Decide before FE:** does Match arrive via (a) a `?mode=match` query on the session
route (simple, per-mode entry — matches the deferred WP-SR1b-2c `?mode=` query), or (b) the
`current_mode` column + `AdvanceStudyPhaseUseCase` (the full chain, WBS 4.5.13 — bigger, NEW spec)?
Recommend (a) for the standalone Match slice (a `?mode=` query → the screen dispatches Review vs Match
chrome), keeping (b) (the phase chain) as a separate object. Read `study-flow.md` §mode-chain first.

## CHẺ — slices (BE-first; depends-on order; 1 per iteration)

- [x] **WP-SM1a — Match BE: `study_match_evaluations` schema enabler (WBS 4.5.4, part 1a).** `a7b5cb9`:
      the append-only table (14 cols per schema-contract: `id`, `session_id`/`session_item_id`/`flashcard_id`
      FK cascades, `board_index`, `pair_id`, `selected_/expected_front/back` ids, `is_correct`,
      `attempt_order`, `evaluated_at`, `created_at`) + `idx_..._session`/`_session_item` in
      `study_tables.drift`; `currentSchemaVersion` 7→8 + `migrateV7ToV8` + `v8_add_match_evaluations.dart`;
      schema-contract + migration-contract + drift-guide; v8 migration test + schema-assert 7→8.
      Schema-only/additive (no behavior — mirrors v6/v7 enablers). Corrected the wireframe-14 drift-note.
- [x] **WP-SM1b — Match BE: evaluation persistence (WBS 4.5.4, part 1b).** `a99cdc8`: `MatchEvaluation` entity +
      `study_session_mapper` rows; `recordMatchEvaluation(...)` (append the eval row — `attempt_order` =
      next per-session seq, `flashcard_id` = `expectedFrontFlashcardId`, `evaluated_at`/`created_at` = now
      — + touch `study_sessions.updated_at`) and `loadMatchEvaluations(sessionId)` (ordered by
      `attempt_order`) on the domain repo interface + `study_repository_impl` + a DAO (reuse the existing
      `Result<T>` pattern, NOT fpdart — the contract's `Either` is target style). `RecordMatchEvaluationUseCase`
      + DI provider. Repo + DAO + use-case tests (append-only, ordering, touch updated_at). Decision rows.
- [ ] **WP-SM2 — Match BE: finalization derivation (WBS 4.5.4, part 2).** Extend `finalizeStudySession`
      with the Match branch: read eval rows → derive one terminal `study_attempts` per session item
      (all-correct→perfect; any-wrong→forgot/recovered per the strategy) → `flashcard_progress` UPDATE +
      mark item answered; unanswered match items removed per the contract. `study-flow.md` +
      `srs-review.md` derivation rules + decision rows + transition tests. Flip 4.5.4 → Implemented.
- [ ] **WP-SM3 — mode dispatch + Match board shell (FE).** Resolve the OPEN QUESTION (recommend
      `?mode=match` query → `RouteParams`/nav-flow). `StudySessionScreen` dispatches Review vs a new
      `MatchBoardScreen`/body: the app bar (✕ + **blue** MATCH mode pill + blue progress + count) + the
      board indicator ("BOARD n OF m · k PAIRS LEFT") + a loading/error/empty shell. Reuse
      `studySessionReviewProvider` items, batched into boards of 5. Golden(s) for the fresh board.
- [ ] **WP-SM4 — board grid + tap-pair state machine (FE).** The 2×5 grid (`MxCard` cells), the
      select→match/wrong state machine (idle/selected/matched/wrong-flash ~600ms), Fisher-Yates shuffle,
      one-selection-at-a-time, lock matched. Each pair (right/wrong) → `RecordMatchEvaluationUseCase`
      (append-only, persisted immediately). Mistake counter (ICU plural) + count-up timer (M:SS).
      Widget tests per cell state + the grade→record path + goldens (mid-board, matched, wrong-flash).
- [ ] **WP-SM5 — board progression + finalize → result.** Board clear → fade → next board; last board
      → `FinalizeStudySessionUseCase` → reuse the SR5 result route/screen. Tests for multi-board
      advance + finalize-on-last. Then **object 7 COMPLETE** → object 8 (Guess) reuses this shell.

## PRECEDENCE / rules (from wireframe 14 §Forbidden + §Board composition)

- **Blue** mode pill + progress (Match is recognition-family, NOT green). Mode pill shows `MATCH`.
- Board = next 5 session cards; 10 cells = those 5 fronts + 5 backs, **Fisher-Yates shuffled**. No
  cross-card decoys (self-contained). If <5 cards remain → Match unavailable for the remainder (skip).
- **Append-only**: each pair-match (right OR wrong) is a per-card attempt persisted **immediately** —
  NOT batched at board end. Match eval rows do NOT mark items answered (finalization derives that).
- One selection at a time (no triple-tap). Matched pairs lock (non-interactive, no re-tap). Both sides
  visible from board start (no flip). No TTS on cells (leaks the answer). Count: `boards_done*5 +
  matched_in_current`.
- Copy → ARB (en+vi); tokens + `Mx*`; PRECEDENCE #1 (behavior → wireframe 14 + study-flow.md win over mock).

## Reuse from object 6 (Review)

The session shell pattern (`MxScaffold` + immersive ✕ app bar), `MxLinearProgress`, the exit-confirm
(`_confirmExit` / `MxConfirmDialog`), the card-actions sheet, and the **SR5 finalize→result** screen +
route are all built and directly reusable. Match adds only the board grade-grammar + the BE eval path.
