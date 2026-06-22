---
last_updated: 2026-06-22
object: Study — Recall mode (object 9 of 10)
loop_order: 9 of 10 (after object 8 Guess, DONE)
route: /library/study/session/:sessionId?mode=recall
status: WP-RC1 DONE (flip-card self-grade end-to-end); WP-RC2/RC3 deferred
---

# Loop plan — Object 9: Study — Recall

Recall = active-recall **flip card** (Anki-style), **not** typed free-recall. Show the front, the learner
recalls the meaning silently, taps **Show answer** to reveal the back, then **self-grades** binary
(Missed → `forgot` / Got it → `perfect`). Per-card flow (like Review/Guess), no board. Wireframe
`16-study-session-recall.md`; shots `15-study-recall--hidden` / `--revealed` (offset numbering).

## AUDIT (2026-06-22 — corrected a wrong cursor assumption)

The prior loop-state cursor guessed Recall was "typed free-recall (`TypedAnswerStudyModeStrategy`)". The
BE evidence says otherwise — **audit-first caught it**:

- **`RecallStudyModeStrategy extends BinaryGradeStudyModeStrategy`** (`study_mode_strategy.dart`) — "flip
  card reveal + self-grade (binary)". `mapGotItAction()` → `perfect`, `mapForgotAction()` → `forgot`. No
  option builder, no normalization, no typed input. **Implemented** (WBS 4.5.2).
- The **typed / normalization** family is **Fill** (`FillStudyModeStrategy extends
  TypedAnswerStudyModeStrategy`, `evaluate(input, expected, hintUsed, markCorrect)`), object 10 — not Recall.
- study-flow.md §study modes + the **adopted decision (2026-06-10)**: recall is binary Forgot/Got-it, "no
  text input in v1"; typed-answer recall is a Future Proposal.
- No phantom-FE collision: the wireframe's `study_session_recall_mode_view.dart` / `..._viewmodel.dart`
  paths do **not** exist (same phantom pattern as Match/Guess).

→ No BE slice. Object 9 is an FE build over the ready binary BE, reusing the session shell + SR5 result.

## Mock ↔ doc CONFLICT (flagged for owner — built binary)

The revealed mock (`shots/15-study-recall--revealed`) shows a **three-way** self-grade — **Missed /
Partial / Got it** — but the V1 contract is **binary**:

- Decision **S66**: recall "records `forgot` or `perfect`". `recovered` is **Fill-only** (hint-taint /
  mark-correct), per study-flow.md + srs-review.md.
- `RecallStudyModeStrategy` exposes only `mapGotItAction` / `mapForgotAction` (2 outcomes).

Per **PRECEDENCE #1** (business docs + decision tables win over the mock for BEHAVIOR), WP-RC1 ships
**binary** (Missed / Got it), styled per the mock (red Missed / green Got it). The mock's **Partial**
is **not** implemented — it would need a recall-grade extension + a decision-table change (an owner
decision), so it is flagged here + in `wireframe-16` rather than guessed in.

## CHẺ — slices (FE; depends-on order; 1 per iteration)

- [x] **WP-RC1 — flip-card self-grade end-to-end.** `85a2c67`: `?mode=recall` → `RecallSessionScreen`
      (S94); `RecallSessionController` (`@riverpod`): front prompt card (overline + front + reading) +
      hidden "say it in your head" hint → **Show answer** reveals the green ANSWER card → binary
      **Missed**(`forgot`)/**Got it**(`perfect`) via `RecallStudyModeStrategy` + `RecordStudySessionAnswerUseCase`
      → advance → last card finalizes → SR5 result (S66). ✕/exit-confirm + blue progress + count + states.
      ARB +7; 12 tests + hidden/revealed goldens. 4-reviewer fan-out folded (full-width ANSWER card,
      `selfMissed`/`selfGot` tokens, doc parity). **Recall playable end-to-end.**
- [ ] **WP-RC2 — Show-answer countdown + auto-reveal-on-timeout (S63/S64).** Add a `recallAnswerTimeout`
      constant (~20s; a study-behavior duration, not an `AppMotion` motion token). The Show-answer CTA
      gains a trailing "· {seconds}s" countdown; at 0s auto-reveal the back + show a "Time's up — grade
      yourself" caption (no auto-record). Mirrors Guess's countdown timer pattern (timer re-guarded +
      cancelled on reveal/dispose). Tests for the timeout-reveal branch + a timed-out golden.
- [ ] **WP-RC3 — Edit ✎ + TTS 🔊 affordances + edit-pause (S65).** The front card's edit icon (push to
      edit, pause/resume the countdown — depends on WP-RC2) + the TTS speak icon. Edit needs the deckId
      (shared blocker with Review's deferred Edit, WP-SR4b-2). These are **wireframe-only** (absent from
      the mock shots), so lowest priority.

## PRECEDENCE / rules

- Grade interaction: tap **Show answer** (reveal), then tap **Missed**/**Got it** (binary self-grade —
  no swipe, no typing). Missed → `forgot`, Got it → `perfect` (decision S66 / the binary strategy).
- Mock wins VISUAL: no mode pill, **blue** progress (the wireframe's "green family" is superseded by the
  mock — PRECEDENCE #2), green ANSWER card, red Missed / green Got it grade chips.
- Behavior wins from docs: binary grade (S66), the typed/`recovered` path stays Fill-only.
- Copy → ARB (en+vi); route → RouteNames/RoutePaths; the SR5 finalize→result is reused as-is.

## Reuse from objects 6/7/8

The immersive session shell + `_confirmExit` (`MxConfirmDialog` §exit-session), `MxLinearProgress`, the
`?mode=` dispatch (`RouteParams.modeQueryParam`), and the **SR5 finalize→result** route + screen are all
built and directly reusable. The grade → record → advance → finalize loop mirrors Guess WP-SG2.
