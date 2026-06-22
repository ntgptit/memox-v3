---
last_updated: 2026-06-22
object: Study — Guess mode (object 8 of 10)
loop_order: 8 of 10 (after object 7 Match, DONE)
route: /library/study/session/:sessionId?mode=guess
status: AUDIT DONE → BUILD (FE-only; the Guess BE is Implemented — no drift)
---

# Loop plan — Object 8: Study — Guess

Guess = recognition **multiple-choice**: a prompt card (the front) + up to 5 option cards (the correct
back + distractors); tap an option → binary grade (correct → got-it/`perfect`, wrong → `forgot`), then
auto-advance to the next card. Per-card flow (like Review), not boards (unlike Match). Wireframe
`15-study-session-guess.md`; shot `14-study-guess--default` (offset numbering — verify via `shots/INDEX.md`).

## AUDIT (2026-06-22 — clean, BE done, confirmed by evidence)

- **`StudyMode.guess`** + **`GuessStudyModeStrategy`** (`study_mode_strategy.dart`) — Implemented. The
  pure option builder `buildOptions({targetId, targetBack, pool, random?})` → `List<GuessOption>` (the
  correct back, `isCorrect: true`, + up to `optionCount`(5)−1 distinct distractor backs from the pool;
  skips the target/blank/duplicate backs; degrades on small pools; seeded shuffle for tests). **WBS
  4.5.6 = Implemented** (commit cda2bab1; 5 builder tests; decisions S47/S80–S83).
- **`GuessOption`** value object (`lib/domain/models/guess_option.dart`) — `{flashcardId, back, isCorrect}`.
- Grade reuses the binary **`RecordStudySessionAnswerUseCase`** (`studyMode: guess`); finalize + result
  reuse the SR5 path (the standard one-terminal-attempt SRS, NOT the Match eval path).
- **WBS 4.5.7 (Guess FE) = Specified.** Its WBS source paths (`study_session_guess_mode_view.dart`,
  `study_session_guess_viewmodel.dart`) are **target structure that does NOT exist** (old iteration —
  same phantom-path pattern Match had). Build the real FE under the current structure.

→ No BE slice needed. Object 8 is an FE build over a ready BE, reusing the session shell + SR5 result.

## BE inventory (all Implemented — FE has everything)

| Need | Source |
|------|--------|
| Option set for a card | `GuessStudyModeStrategy().buildOptions(targetId, targetBack, pool, random?)` → `List<GuessOption>` (pure domain; call from the controller) |
| Pool (the session's other cards' backs) | `studySessionReviewProvider` → `StudySessionReview.items` (front/back per item) |
| Record a grade | `RecordStudySessionAnswerUseCase` (`studyMode: StudyMode.guess`; correct option → `perfect`, wrong → `forgot`) |
| Resume index | `StudySessionReview.firstUnansweredIndex` |
| Finalize + result | `FinalizeStudySessionUseCase` + the SR5 `studyResult` route / `StudyResultScreen` (reused) |

## CHẺ — slices (FE; depends-on order; 1 per iteration)

- [x] **WP-SG1 — mode dispatch + Guess shell + option grid (static).** `88f906a`: `?mode=guess` →
      `GuessSessionScreen` (S94); `GuessSessionController` builds the per-card option set via
      `GuessStudyModeStrategy.buildOptions` (pool = other items' backs, seeded). Shell: ✕/exit-confirm +
      blue progress + `{answered}/{total}` count + prompt card (overline + front `displayLarge` + reading)
      + static lettered (A–E) option grid + states. ARB +1; nav-flow + wireframe-15 corrected. 7 tests +
      question goldens. (Confirmed mock = no pill / single-line options — built to match, PRECEDENCE #2.)
- [ ] **WP-SG2 — select-to-grade + advance + finalize → result.** Tap an option → `isCorrect` →
      `RecordStudySessionAnswerUseCase(studyMode: guess, result: perfect|forgot)`; reveal correct/wrong
      (correct green, wrong red + highlight the right one); auto-advance (countdown, `AppMotion.*`) to the
      next card; the last card → `FinalizeStudySessionUseCase` → `pushReplacementNamed(studyResult)`
      (reuse SR5). Tests per branch (correct/wrong grade + record + advance; last card → finalize→route)
      + goldens (answered-correct, answered-wrong). Then **object 8 COMPLETE** → object 9 (Recall).

## PRECEDENCE / rules

- Grade interaction: tap an option (no swipe). Correct → `perfect`, wrong → `forgot` (binary, study-flow.md
  S60 / the `BinaryGradeStudyModeStrategy`). Auto-advance after a brief reveal.
- **Blue** mode family (recognition), like Review/Match — no green.
- Options: exactly one correct; distractors from the session pool (never a second correct / dup text).
  No TTS on option cards (leaks the answer — wireframe `15` / S60).
- Copy → ARB (en+vi); route → RouteNames/RoutePaths; behavior → study-flow.md + wireframe 15 win over mock.

## Reuse from objects 6/7

The immersive session shell + `_confirmExit` (`MxConfirmDialog` §exit-session), `MxLinearProgress`, the
`?mode=` dispatch pattern (`RouteParams.modeQueryParam`), `AppMotion` (for the auto-advance), and the
**SR5 finalize→result** route + screen are all built and directly reusable.
