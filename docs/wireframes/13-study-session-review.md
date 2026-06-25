---
last_updated: 2026-06-22
route: /library/study/session/:sessionId
study_mode: review
source_specs:
  - docs/business/study/study-flow.md
  - docs/business/srs/srs-review.md
  - docs/business/study-actions/bury-suspend.md
  - docs/business/tts/tts-settings.md
---

# 13 — Study Session: Review Mode

> **Status (2026-06-22): being rebuilt slice-by-slice (WP-SR1..SR5).** Built so far:
> `lib/presentation/features/study/screens/study_session_screen.dart` (+ `controllers/
> study_session_review_provider.dart` + `controllers/study_session_controller.dart`) renders the
> **shell + card (WP-SR2)** — the `✕` exit + a blue `MxLinearProgress` + `{answered}/{total}` count,
> and the card showing **both sides at once** (front-side label → front → divider → back-side label →
> back → example pill) via `LoadStudySessionReviewUseCase`, with loading/error/empty states — **plus
> swipe-grade (WP-SR3):** `StudySessionController` grades by swipe (right → `perfect`, left → `forgot`
> via `RecordStudySessionAnswerUseCase`), advances optimistically, shows the swipe hint for the first
> 3 cards, and renders a Finish surface after the last card — **plus the exit-confirm (WP-SR4a):**
> `✕` mid-session with `answeredCount > 0` shows the §exit-session `MxConfirmDialog` ("Exit study
> session? … Keep studying / Exit", modal-locked) before popping; nothing answered → pop directly —
> **plus the card-actions sheet (WP-SR4b):** long-press the card → `showStudyCardActionsSheet` (Bury
> until tomorrow / Suspend card → the `Bury`/`Suspend` use cases + re-queue). **Not yet built:** the
> sheet's **Edit** action (WP-SR4b-2 — needs the card's deck id), the 5s undo toast (§undo-toast / WBS
> 4.11.3), finalize→result (WP-SR5 — the Finish action pops for now). The
> front/back labels fall back to FRONT/BACK — the language-specific labels (KOREAN/MEANING from
> `deck.target_language`) need the read model to carry the language (WP-SR2b). Any other
> `lib/presentation/features/study/**` path below is **target structure** until its slice lands. The
> mock `12-study-review--default` flip card is a documented visual gap — behaviour follows §Rules
> (swipe, no reveal) per PRECEDENCE #1.

## Purpose

Front + back shown together on a single card. User reads, self-evaluates whether they knew it, then
advances by swipe. Lightest mode in the 5-mode cycle; serves as the **anchor screen** that
establishes the visual grammar reused by modes 14-17 (top app bar, progress bar, mode pill
convention).

> **Target V1 behaviour (full slice; shell+card built in WP-SR2, the rest WP-SR3..SR5).** The review
> surface at `/library/study/session/:sessionId` loads the persisted session + ordered
> session items, renders **both sides on one card**, grades by **swipe** (right =
> `perfect`, left = `forgot`), shows the blue progress bar + exit confirmation,
> and exposes the long-press card-actions sheet (Edit / Bury until tomorrow /
> Suspend). `flashcard_progress` is not updated until Finish Session (finalize)
> succeeds. The mock `12-study-review--default` flip card is a documented visual
> gap — behaviour follows §Rules (swipe, no reveal) per PRECEDENCE #1.

> **Mode pill / progress-bar color convention (applies to wireframes 13-17).** Modes split into two
> visual families:
>
> - **Blue family** (recognition modes): Review, Match, Guess. Progress bar fills with the primary
    blue token. Mode pill (when shown) uses blue.
> - **Green family** (production modes): Recall, Fill. Progress bar fills with the secondary green
    token. Mode pill uses green.
>
> This visual cue tells the user at a glance whether the current mode tests recognition (passive) or
> production (active). Review mode does NOT show a mode pill in the top bar (it is the default mode
> and uses the bare progress bar); modes 14-17 do show the pill.

## Layout — single state (front + back both visible)

```
┌─────────────────────────────────────────┐
│ ✕   ━━━━━━━━━━━━━━━━━━━━━━     14 / 23 │  ← Exit · progress bar (blue) · count
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │                                     │ │
│ │ KOREAN                              │ │  ← Front-side label (deck.target_language)
│ │                                     │ │
│ │                                     │ │
│ │              먹다                    │ │  ← Front, large centered
│ │                                     │ │
│ │                                     │ │
│ │  ─────────────────────────────────  │ │  ← Divider
│ │                                     │ │
│ │ MEANING                             │ │  ← Back-side label
│ │                                     │ │
│ │                                     │ │
│ │             to eat                  │ │  ← Back, large centered
│ │                                     │ │
│ │       ┌───────────────────┐         │ │
│ │       │ 아침을 먹었어요.    │         │ │  ← Example pill, iff present
│ │       └───────────────────┘         │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│   »  Swipe left for the next card       │  ← Swipe hint footer
└─────────────────────────────────────────┘
```

Both sides render together — there is no "Show answer" tap step in this mode. The user advances by
swiping (gesture is the primary input).

## Inputs

| Param                             | Source | Notes                             |
|-----------------------------------|--------|-----------------------------------|
| `sessionId` (required path param) | URL    | active session id from entry gate |

## Data to load

| Data                                                                 | Source                                             | Refresh trigger       |
|----------------------------------------------------------------------|----------------------------------------------------|-----------------------|
| Session detail (total, answered count)                               | `study_sessions` + `study_session_items` aggregate | watch                 |
| Current card front, back, optional `example`, deck `target_language` | `flashcards` joined via session_items              | next-card load        |
| Card progress (`current_box` for `box_before`)                       | `flashcard_progress`                               | next-card load        |
| Front-side / back-side label copy (e.g., `KOREAN` / `MEANING`)       | derived from `deck.target_language` + l10n keys    | once per card         |
| Pre-fetched next card                                                | repository call during current grade               | parallel with persist |

## Forbidden

- ❌ Add a "Show answer" intermediate step. Review mode shows both sides at once.
- ❌ Hide the `example` field when present. Render it as a pill below the back.
- ❌ Show `note`, `pronunciation`, or `hint` inline (Phase 1; only `example` surfaces here).
- ❌ Use the green progress-bar color in this mode. Review is in the blue family.
- ❌ 4-button "Hard / Easy" grading.
- ❌ Auto-play `back` via TTS. Front-only policy.
- ❌ TTS auto-play when `deck.target_language = unsupported`.
- ❌ Persist grade BEFORE loading next card visually. Order: gesture → persist (background) → next
  card UI.
- ❌ Allow exit without confirmation when answered > 0.
- ❌ Make swipe optional. In this mode swipe is the **primary** input; tap fallback exists but is
  secondary.
- ❌ Add a TTS icon inline on the card.
- ❌ Update SRS box outside `GradeAttemptUseCase`.

## Components

| Component         | Spec                                                                                                                                                                                                           |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Top app bar       | `✕` (exit) on the left; progress bar fills the middle; "{answered} / {total}" count on the right. No scope label, no overflow `⋮` in this mode (overflow accessible via long-press on the card — see Actions). |
| Progress bar      | Filled bar showing `answered / total`. Color: primary blue (review = blue family).                                                                                                                             |
| Card              | One card occupying most of the viewport. Contains both front and back regions separated by a thin divider.                                                                                                     |
| Front-side label  | Caption-sized, uppercase, top-left of card. Copy: `KOREAN` / `ENGLISH` / etc., derived from `deck.target_language`. Falls back to `FRONT` when language unsupported.                                           |
| Speaker button    | `StudySpeakButton` (WBS 8.4.3) on the right of the front-side label row — speaks the front; auto-plays on reveal when `autoPlay` is on. Hidden when `deck.target_language = unsupported`. Additive (not in the kit mock; authorized by `docs/business/tts/tts-settings.md`). |
| Front             | Display-large size, centered horizontally. Wraps to two lines max; shrinks if longer.                                                                                                                          |
| Divider           | Thin horizontal line between front and back regions, indented left/right.                                                                                                                                      |
| Back-side label   | Caption-sized, uppercase. Copy: `MEANING`. Falls back to `BACK`.                                                                                                                                               |
| Back              | Body-large size, centered.                                                                                                                                                                                     |
| Example pill      | Optional. Rounded surface around `flashcards.example`. Only renders when example is non-empty. Center-aligned.                                                                                                 |
| Swipe hint footer | Caption-sized. Copy (`studyReviewSwipeHint`): "Swipe right if you knew it, left if you didn't" — conveys the **grade** meaning (right = perfect, left = forgot), clearer than the original "next card" wording. Shown for the first 3 cards of the session, then hidden. |

## States

| State                      | Trigger                                    | Behavior                                                                                    |
|----------------------------|--------------------------------------------|---------------------------------------------------------------------------------------------|
| Card visible               | Card opened                                | Front + back both rendered. Swipe hint shown for first 3 cards of the session, then hidden. |
| Swiping                    | Drag begins                                | Card follows finger; releasing past the threshold commits a grade.                          |
| Grading                    | Swipe committed (or tap on grade fallback) | Persist attempt + SRS update; advance to next card with horizontal slide.                   |
| Buried via long-press menu | Long-press the card                        | Bottom-sheet with Edit / Bury until tomorrow / Suspend card. Bury or suspend refreshes the queue after persistence. |
| Last card answered         | Final answer committed                     | Show Finish Session CTA; do not auto-finalize.                                               |
| Finish Session             | CTA tapped after all cards are answered    | Commit progress transactionally and transition to the placeholder study result via `pushReplacement`. |
| Exit confirm               | ✕ tapped mid-session                       | Show a confirmation dialog that says progress is saved and can be resumed later.                                                                |

## Actions

| Action          | Trigger                   | Result                                                                      |
|-----------------|---------------------------|-----------------------------------------------------------------------------|
| Swipe right     | Drag right past threshold | `result = perfect`; persist; next card.                                     |
| Swipe left      | Drag left past threshold  | `result = forgot`; persist; next card.                                      |
| Tap card        | Tap (fallback)            | Future Proposal. Swipe is the current review-mode input.                    |
| Long-press card | Long-press                | Open card actions bottom-sheet (Edit / Bury until tomorrow / Suspend card). |
| Tap ✕           | Tap                       | Show exit confirm dialog.                                                   |

## Target V1 controls

- Swipe is the review-mode interaction (both sides shown; right = perfect, left = forgot).
- Long-press opens the card-actions sheet.
- Review state refreshes after a buried or suspended card is removed from the queue.
- The swipe-based grading table below is the interaction contract for the review surface.

## Dialogs and bottom-sheets used

- Exit session confirm — `docs/wireframes/24-shared-dialogs.md` §exit-session.
- Card actions sheet — `docs/wireframes/25-shared-bottom-sheets.md` §card-actions.
- Bury/suspend undo toast — `docs/wireframes/25-shared-bottom-sheets.md` §undo-toast.

## SRS handling on answer

Review grades by swipe (no reveal step); the attempt is recorded in-session and the SRS box
transition is applied at finalize (Finish Session), not per-answer.

Per `docs/business/srs/srs-review.md`:

- result=`perfect` (swipe right): `box_before = current`, `box_after = min(current+1, 8)`.
- result=`forgot` (swipe left): `box_before = current`, `box_after = 1`. `lapse_count++`.

Insert `study_attempts` row with `box_before`, `box_after`, `result`, `study_mode = 'review'`,
`attempted_at = now`. See `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase.

## TTS behavior (per `docs/business/tts/tts-settings.md`)

Review mode has **no inline TTS button** in the current V1 shell. The long-press card-actions
sheet currently exposes Edit / Bury until tomorrow / Suspend card only; TTS remains a separate
settings surface and is not surfaced from this review screen yet.

## Navigation in

- Auto-redirect from study entry gate.
- Resume from Dashboard / banner.
- Deep link from notification.

## Navigation out

- Last card answered → study result (`pushReplacement`).
- Exit confirmed → pop to caller when possible, otherwise go Library through the route helper.
- History action (from sheet) → flashcard history (push, returnable).
- Audio settings (from sheet) → audio-speech settings (push, returnable).

## Responsive

- ≥600dp: card centered with max-width ~520dp; vertical spacing increased between front and back
  regions.
- ≥1024dp: card stays centered; surrounding viewport color matches scaffold background, no extra
  chrome.
- Landscape: card occupies viewport vertically; swipe gesture unchanged.

## Performance

- Pre-fetch next card on swipe-commit (parallel with persistence).
- Swipe animation runs at 60fps; physics-based simulation, not linear interpolation.
- TTS init at session start; reuse engine across cards.

## Accessibility

- Card announces front and back in sequence on focus.
- Swipe gestures are the primary review interaction.
- Reduced-motion users see a cross-fade instead of the horizontal slide on card advance.
- The swipe card region carries `Semantics(hint: studyReviewSwipeHint)` so the grade gesture is announced.

## Rules

- Card MUST render both sides at once. No reveal step.
- Swipe MUST be the primary input. Tap fallback is for accessibility only.
- TTS button is NOT inline in review mode. The current card-actions sheet does not surface TTS.
- Exit confirmation MUST appear before pop.
- `box_before` and `box_after` MUST be recorded on every attempt.
- `example` field MUST render as a pill below the back when non-empty. `note`, `pronunciation`,
  `hint` are NOT shown in this mode (Phase 1).

## Agent rule

- Do NOT introduce a "Show answer" CTA in this mode. Both sides are visible from the start.
- Do NOT add a TTS icon to the card body. TTS lives in the actions sheet.
- Swipe gestures are MANDATORY (not optional).
- Render `example` as a pill below the back. Do not render `note` / `pronunciation` / `hint` here —
  those surface in card detail, not study session.
- Use blue progress-bar color token. Mismatching family color = bug.

## Implementation refs

**Business specs:**

- `docs/business/study/study-flow.md` (review mode)
- `docs/business/srs/srs-review.md` (perfect / forgot transitions)
- `docs/business/study-actions/bury-suspend.md` (overflow actions via sheet)
- `docs/business/tts/tts-settings.md` (front-only playback)

**Decision rows:**

- S section (review mode), SRS section (perfect/forgot transitions)

**Schema / storage:**

- INSERT `study_attempts` (box_before, box_after, result, study_mode='review', attempted_at)
- UPDATE `flashcard_progress` (current_box, due_at, review_count, lapse_count, last_studied_at)

**Contracts:** `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase,
`docs/contracts/usecase-contracts/srs.md`, `docs/contracts/usecase-contracts/tts.md`

**Code paths (rebuilt; verified 2026-06-22 — WP-SR2/SR3):**

- Screen: `lib/presentation/features/study/screens/study_session_screen.dart` (shell: `✕` +
  `MxLinearProgress` + count; the both-sides `_ReviewCard`; the `Dismissible` swipe + swipe-hint +
  Finish surface). NOT the prior iteration's `widgets/study_session/review/**` files — those were
  wiped and do not exist.
- State: `lib/presentation/features/study/controllers/study_session_review_provider.dart`
  (`@riverpod` future → `LoadStudySessionReviewUseCase`) + `controllers/study_session_controller.dart`
  (`@riverpod` `StudySessionController` over `StudySessionView{review, currentIndex}`; `grade` →
  `RecordStudySessionAnswerUseCase`).
- Grading use case: `lib/domain/usecases/study/record_study_session_answer_usecase.dart`
  (`recordStudySessionAnswerUseCaseProvider`) — the only in-session answer path. No standalone
  `grade_attempt_usecase.dart` / `box_transition.dart`; the SRS box transition is applied at
  **finalize** (`FinalizeStudySessionUseCase`, WP-SR5), not per-answer.
- TTS: not surfaced in the review screen (separate settings; WP-SR4+ may add the actions sheet).

**Related wireframes:**

- `docs/wireframes/14-study-session-match.md`, `docs/wireframes/15-study-session-guess.md`,
  `docs/wireframes/16-study-session-recall.md`, `docs/wireframes/17-study-session-fill.md` (other
  modes; shared shell + progress-bar color convention)
- `docs/wireframes/18-study-result.md` (next after last card)
- `docs/wireframes/25-shared-bottom-sheets.md` §card-actions, §undo-toast
- `docs/wireframes/24-shared-dialogs.md` §exit-session
