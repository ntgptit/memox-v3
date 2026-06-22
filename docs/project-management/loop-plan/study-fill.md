---
last_updated: 2026-06-22
object: Study — Fill mode (object 10 of 10 — the LAST study mode)
loop_order: 10 of 10 (after object 9 Recall, DONE)
route: /library/study/session/:sessionId?mode=fill
status: WP-FI1 DONE; WP-FI2a+b+c DONE (Mark-correct + Hint → recovered, auto-advance countdown); WP-FI2d-e remain
---

# Loop plan — Object 10: Study — Fill

Fill = typed **production**: show the back (definition / hint), type the **front** in a free-text field,
**Check** grades a strict trim-only match. The highest-effort + only TypedAnswer mode (the only one that
can emit `recovered`). Per-card flow (like Recall/Guess). Wireframe `17-study-session-fill.md`; shots
`16-study-fill--input` / `--wrong` (offset numbering).

## AUDIT (2026-06-22 — clean BE, two mock↔doc conflicts)

- **`FillStudyModeStrategy extends TypedAnswerStudyModeStrategy`** (`study_mode_strategy.dart`) —
  Implemented (WBS 4.5.8). `evaluate({input, expected, hintUsed=false, markCorrect=false})` → strict
  trim-only match: clean match → `perfect` (or `recovered` if `hintUsed`); mismatch → `forgot` (or
  `recovered` if `markCorrect`). Pure domain; tested by `test/domain/study/modes/fill_evaluator_test.dart`.
- **`RecordStudySessionAnswerUseCase`** takes the evaluated `AttemptResult` directly → FE computes
  `evaluate(...)` then records. **`MxTextField`** + **`useMxTextSubmitState`** hook exist for the input.
- No phantom-FE collision: the wireframe's `study_session_fill_mode_view.dart` / `..._viewmodel.dart`
  paths do **not** exist (same phantom pattern as the other modes).

→ No BE slice. Object 10 is an FE build over the ready evaluator, reusing the session shell + SR5 result.

## Mock ↔ doc CONFLICTS (built per PRECEDENCE #1; flagged for owner)

The mock (`shots/16-study-fill`) is **simpler** than the wireframe AND diverges on behavior:

1. **What you type / grade.** Mock: shows the front (山) + an "English: …" gloss, overline "TYPE THE
   READING", grades the **reading** (romaji "yama"). Docs (study-flow "type the front", wireframe-17
   matching-rules "user input equals trimmed **front**", decision S68): grade the **front**. → Built
   **front-graded** (PRECEDENCE #1 behavior wins) with a neutral "Type the answer" prompt + hint = back.
   The reading-based variant + the two-tier hint card need a decision update.
2. **Grade flow.** Mock wrong state: **Retry / Next** (perfect/forgot only — no Hint, no Mark correct).
   Wireframe: Hint char-reveal + Mark correct (both → `recovered`) + a 0.8s auto-advance countdown +
   a last-card Finish callout. → Built the **mock's** simpler V1 (Retry/Next, perfect/forgot); the
   `recovered` path + countdown + Finish callout are WP-FI2. The evaluator already supports `recovered`
   (WP-FI1 passes `hintUsed/markCorrect` = false), so nothing is mis-recorded.

Visual follows the mock (PRECEDENCE #2): no mode pill, **blue** progress (the wireframe's "green family"
is superseded), real text field, full-width Check, CORRECT ANSWER card, Retry/Next.

## CHẺ — slices (FE; depends-on order; 1 per iteration)

- [x] **WP-FI1 — typed check/grade end-to-end.** `a6f37b5`: `?mode=fill` → `FillSessionScreen` (S94,
      `HookConsumerWidget` + `useMxTextSubmitState`); hint card (back) → free-text field → **Check**
      (disabled until non-empty) → `FillStudyModeStrategy.evaluate(input, expected: front)` → `perfect`
      (✓ + Next) / `forgot` (CORRECT ANSWER card + Retry/Next) → record (`studyMode: fill`) + advance →
      last card finalizes → SR5 (S67/S68/S70/S71/S74). ✕/exit-confirm + blue progress + count + states.
      ARB +7; 16 tests + typing/wrong/correct goldens. 4-reviewer fan-out folded (Check disable,
      alert-circle, correct golden, `recovered` doc caveat). **Fill playable end-to-end → ALL 5 STUDY
      MODES COMPLETE.**
- [~] **WP-FI2 — the richer wireframe flow (`recovered` + polish).** Split into slices:
  - [x] **WP-FI2a — Mark correct** (`f1625b1`, S72): a discreet accent link under the wrong-feedback
        Retry/Next row overrides to `recovered` (`evaluate(markCorrect:true)` outcome) + flips to the
        correct-feedback state; recorded on advance. Mock variance flagged (mock = Retry/Next only).
  - [x] **WP-FI2b — Hint** (`3466204`, S69): a discreet accent link below Check reveals one leading front
        char at a time (max half the length) as a `·`-masked prefix; any reveal taints → a clean match
        caps at `recovered` via `evaluate(hintUsed: true)`; retained across Retry. (Mock = Check only;
        variance flagged. code-reviewer caught + fixed a retry-drops-taint bug.)
  - [x] **WP-FI2c** — the 0.8s auto-advance countdown on correct (`42104ce`, S68): a depleting
        `MxLinearProgress` over Next (`AppMotion.fillAutoAdvance` + `TweenAnimationBuilder.onEnd` →
        `next()`; tap Next to skip). Widget-driven (no controller Timer). Area widgets extracted to
        `widgets/fill_session_areas.dart` for file-length.
  - [x] **WP-FI2d** — **finalize-fail (S75) covered-by-design**: Fill inherits the shared route-to-SR5 +
        save-failed banner (WP-SR5b) like every mode. The last-card **Finish callout (S73) is REJECTED**
        (mock-authoritative ruling 2026-06-22 — the mock auto-finalizes; the Finish-callout was a
        wireframe-only affordance the redesign cut).
  - [x] **WP-FI2e — REJECTED** (mock-authoritative ruling 2026-06-22): the Edit ✎ / TTS 🔊 affordances
        are not in the mock; out-of-scope.

  **FINAL (2026-06-22, owner ruling — mock authoritative):** Fill is **DONE**. Built: WP-FI1 +
  FI2a (Mark-correct) + FI2b (Hint) + FI2c (auto-advance) → the full `recovered` path + countdown.
  Front-graded (mock's "reading" copy not adopted). FI2d Finish-callout (S73) + FI2e Edit/TTS **Rejected**
  as redesign-cut. See [[fe-loop-complete-mock-authoritative]] + loop-state.

## PRECEDENCE / rules

- Grade: strict **trim-only** match of the typed front (no case-fold, no diacritic strip, no auto-correct
  — wireframe-17 §Forbidden). `perfect` clean / `forgot` mismatch; `recovered` only via Hint/Mark-correct
  (WP-FI2). One terminal attempt per card (study-flow); Retry is a local re-type (no record).
- Copy → ARB (en+vi); route → RouteNames/RoutePaths; behavior → study-flow.md + wireframe 17 + S68 win
  over the mock; mock wins VISUAL.

## Reuse from objects 6/7/8/9

The session shell + `_confirmExit`, `MxLinearProgress`, the `?mode=` dispatch, `MxTextField` +
`useMxTextSubmitState`, and the **SR5 finalize→result** are all built and directly reused. The grade →
record → advance → finalize loop mirrors Recall/Guess.
