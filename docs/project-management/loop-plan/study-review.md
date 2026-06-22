---
last_updated: 2026-06-22
object: Study — Review mode (anchor for Match / Guess / Recall / Fill)
loop_order: 6-10 of 10 (outer→inner)
route: /library/study/session/:sessionId (to be wired — no study routes exist yet)
status: BUILD (greenfield FE over ready BE; DEFER overturned)
---

# Loop plan — Object 6: Study — Review (+ shared shell for 7-10)

## DEFER overturned (2026-06-22)

The previous revision DEFERred objects 6-10 on three reasons that the loop rules explicitly disallow:

1. **"Greenfield / too large"** → not a defer. G1: CHẺ into the smallest runnable slices (route →
   entry gate → session shell → card → grade → finalize → result). Build them one per iteration.
2. **"mock ↔ docs conflict on the Review grade interaction (flip vs swipe)"** → resolved by
   **PRECEDENCE #1** (behavior → `docs/business/study/study-flow.md` + wireframe 13 WIN over the
   mock). Review grades by **swipe** (both sides shown, right = `perfect`, left = `forgot`, no reveal
   step). The mock `12-study-review--default` flip-card is a **documented mock visual gap** (built as
   swipe per study-flow.md / wireframe 13 §Rules), NOT a blocker.
3. **wireframe 13 "shipped" drift** → stale doc-status, not running-code drift. Corrected on this
   pass (the screen does not exist yet → greenfield); the rest is fixed one line at a time as each
   slice lands.

## BE inventory (audited 2026-06-22 — all Implemented, FE has everything to call)

| Need | Use case (provider) → returns |
|------|-------------------------------|
| Entry gate outcome | `ResolveStudyEntryStartUseCase` (`resolveStudyEntryStartUseCaseProvider`) `call({scope})` → `StudyEntryStartResult` = `resumeRequired(StudySession)` \| `canStart(StudyEntryEligibility)` \| `blocked(StudyScopeEmptyReason, nextDueAt?)` |
| Eligibility detail | `ResolveStudyEntryEligibilityUseCase` → `StudyEntryEligibility{eligibleCount, emptyReason, nextDueAt, hasEligible}` |
| Create session | `CreateStudySessionUseCase` `call({scope, flashcardIds})` → `StudySession` (cap `maxSessionItems = 20`) |
| Eligible card ids | `StudyEntryRepository.resolveEligibleCardIds({scope, now})` → `List<FlashcardId>` |
| Load review queue | `LoadStudySessionReviewUseCase` → `StudySessionReview{session, items[], total, answeredCount, isComplete, firstUnansweredIndex}` |
| Current card | `StudySessionReviewItem{sessionItemId, flashcardId, front, back, exampleSentence?, pronunciation?, hint?, sortOrder, answeredAt?}` |
| Record a grade | `RecordStudySessionAnswerUseCase` `call({sessionId, sessionItemId, result: AttemptResult, studyMode: StudyMode.review})` → `Result<void>` |
| Grade enum | `AttemptResult` = `perfect` \| `recovered` \| `forgot` \| `initialPassed`(legacy) |
| Finalize (SRS) | `FinalizeStudySessionUseCase` `call({sessionId})` → applies Leitner transition + marks `completed` (rejects unanswered) |
| Result read model | `LoadStudySessionResultUseCase` → `StudySessionResult{session, items[], total, answeredCount, forgotCount, passedCount}` |

Entities: `StudySession{id, scope, status, startedAt, updatedAt}`, `StudyScope`, `SessionId`,
`SessionStatus`, `StudyMode`. No session-state notifier/controller exists yet (FE greenfield).

## PRECEDENCE resolution (record once; reuse for modes 7-10)

- **Grade interaction**: SWIPE (study-flow.md / wireframe 13). Mock-12 flip = visual gap, not built.
- **No reveal / "Show answer"** step in Review (both sides visible). Forbidden by wireframe 13.
- **Progress-bar colour**: Review = **blue family** (recognition); Recall/Fill = green. No mode pill
  in Review (it is the default). Modes 14-17 show the pill.
- **Example pill** renders below the back iff `exampleSentence` non-empty; `note`/`pronunciation`/
  `hint` are NOT shown in study session (Phase 1).
- Copy → ARB (en+vi); route → RouteNames/RoutePaths; tokens + `Mx*` shared widgets.

## STATE COVERAGE (shots/INDEX.md)

- Screen **12 — study-review** (the session card): **1 state** (`default`). Build = the card surface
  (both sides, labels, example pill) + the shell (✕ / blue progress / count) + swipe-grade + the
  last-card Finish CTA + exit-confirm + card-actions sheet.
- Screen **17 — study-result**: **6 states** (`loaded`, `loading`, `goal-off`, `save-failed`,
  `defensive`, `tough-empty`) — each = 1 render branch + 1 golden (light+dark).
- Entry gate (wireframe `12-study-entry-gate.md`): the 3 `StudyEntryStartResult` outcomes
  (canStart / resumeRequired / blocked-by-reason) — no dedicated shot; a launch surface.

## GAP-CHECKLIST (CHẺ — smallest runnable slices, depends-on order; 1 per iteration)

- [x] **WP-SR1a — study route scaffold + entry gate (core).** `c5b2a25`: top-level
      immersive study routes (`RouteNames`/`RoutePaths` `studyEntry`+`studySession`, `study_routes.dart`
      composed into `app_router.dart`); `StudyEntryController` (family on `StudyScope`) +
      `StudyEntryOutcome` (blocked/resumeRequired/ready); `StudyEntryScreen` rendering preparing /
      generic empty (blocks zero-card) / Resume-Start-over-Back / error, auto-create →
      `pushReplacement` to the `StudySessionScreen` **placeholder**. `MxIconButton.toolbar` added
      (guard `header_actions`). ARB ×13 (en+vi). Rows S84/S27/S28; WBS 4.1.2 Implemented, 4.2.3 Partial.
      7 gate tests + 4 goldens. **Launch CTA stays Future** (reachable by route/deep-link/test).
- [x] **WP-SR1b-1 — today route + `study_type` override.** `08dcb50`: the `today` literal route
      (`/library/study/today` → `StudyScope(today, null, srsReview)`) + the `?study_type=` query
      override parsed via a new canonical `StudyType.storageValue`/`fromStorage` (consolidated with the
      data mapper; `new_cards`/`srs_review`); unrecognized `study_type` → error. Rows S85; 11 gate tests.
- [x] **WP-SR1b-2a — per-reason empty matrix (icon + copy).** `427d392`: `_blockedBody` switches
      the 8 `StudyScopeEmptyReason` → tailored icon + title + message (`studyEmpty*` ARB ×15, en+vi;
      cards/check/celebration/bedtime/pause glyphs) + Back, replacing the generic surface. Row S86; per-
      reason tests + 6 representative goldens (deck-no-cards / today-all-done / all-suspended ×2).
- [x] **WP-SR1b-2b — core empty-matrix CTAs + start-over confirm.** `935e630`: **Study new
      instead** (re-enter the gate `?study_type=new_cards`) for deck/folderNoDueCards + allBuried;
      **Done** (pop) for todayAllDone + allBuried; the start-over **confirm dialog** (`MxConfirmDialog`,
      S28) before cancel+create. Rows S86 (CTA) + S87 (confirm). ARB ×3; CTA + confirm + cancel tests +
      2 new goldens (deck-no-due, all-buried). **Gate functionally complete.**
- [ ] **WP-SR1b-2c — scope-specific CTA polish (deferred).** deckNoCards → Add flashcards (push
      `flashcardCreate`, deck scope); folderNoCards → Open folder; todayNoContent → Create deck;
      allSuspended → View suspended (`?filter=suspended`, deck scope); the "Next due in {relativeTime}"
      line from `nextDueAt`; the todayAllDone streak inset (needs engagement read model); the `?mode=`
      query. Lower-value polish — **deprioritized below WP-SR2** (the review session) per build-value.
- [x] **WP-SR2 — review session shell + card.** `b69c2eb`: `StudySessionScreen` (replacing the
      placeholder) loads `studySessionReviewProvider` (`LoadStudySessionReviewUseCase`) → app bar (`✕` +
      blue `MxLinearProgress` + `{answered}/{total}`) + the both-sides card (front-side label → front →
      divider → back-side label → back → example pill) + loading/error/empty. New shared `MxLinearProgress`
      (guard `no_raw_progress_indicator`). FRONT/BACK label fallback (language labels = WP-SR2b). No
      grading (WP-SR3). Row S88; 7 widget tests + card goldens (light+dark).
- [ ] **WP-SR2b — language side-labels (deferred polish).** KOREAN/MEANING from `deck.target_language`
      — needs the review read model (`StudySessionReview`/`LoadStudySessionReviewUseCase`) to carry the
      deck's `target_language`; until then the card uses the FRONT/BACK fallback.
- [x] **WP-SR3 — swipe-grade + advance.** `8549fb6`: `StudySessionController` (`@riverpod`
      AsyncNotifier over `StudySessionView{review, currentIndex}`) — swipe right → `perfect`, left →
      `forgot` (Dismissible) → `RecordStudySessionAnswerUseCase(studyMode: review)`; advances the card
      first (optimistic) then persists (`unawaited`); swipe-hint footer (first 3 cards); last card →
      Finish surface (`MxEmptyState` + Finish action; finalize→result = WP-SR5, pops for now). Row S89;
      swipe right/left/advance/finish/hint tests; regen card golden.
- [x] **WP-SR4a — exit-confirm.** `2983088`: `✕` mid-session with `answeredCount > 0` →
      `MxConfirmDialog` ("progress is saved — resume later") before pop; pops directly when nothing is
      answered yet (wireframe `13` Rule). Row S90; ARB ×3 (en+vi); confirm/cancel/pop tests.
- [x] **WP-SR4b — card-actions sheet (Bury / Suspend).** `<this commit>`: long-press the card →
      `showStudyCardActionsSheet` (`study_card_actions_sheet.dart`, reusing `showMxBottomSheet`): **Bury
      until tomorrow** → `BuryStudySessionCardUseCase`, **Suspend card** → `SuspendStudySessionCardUseCase`
      → re-queue (`ref.invalidate(studySessionReviewProvider)`; the use case removed the session item, so
      the reload excludes it). Canonical row **S59** (the appended S91 dup was dropped); WBS 4.11.3 →
      Partial; ARB ×2; long-press/bury/suspend tests; §25 + phantom-path drift corrected. Undo toast
      (§undo-toast) deferred.
- [ ] **WP-SR4b-2 — Edit card action (deferred).** The sheet's **Edit** → push the flashcard editor —
      needs the card's `deckId`, which `StudySessionReviewItem` does not carry. Either add `deckId` to
      the review read model (`LoadStudySessionReviewUseCase`) or derive it from a deck-scope session
      (`scope.entryRefId`). Then add Edit to the sheet + a navigation test.
- [ ] **WP-SR5 — finalize → result (screen 17).** Finish → `FinalizeStudySessionUseCase` →
      `pushReplacement` to the result screen rendering `StudySessionResult`; cover all **6** states
      (loaded/loading/goal-off/save-failed/defensive/tough-empty) with goldens.
- [ ] **Objects 7-10 (Match/Guess/Recall/Fill)** — reuse the WP-SR2 shell + WP-SR5 result; each adds
      its own grade grammar (independent; not blocked by Review's grade question — shared only at
      BE finalization/result).

## Notes / traps

- Wireframe 13 still carries stale "shipped (verified 2026-05-28)" code-path refs to
  `lib/presentation/features/study/**` files that do **not** exist — treat as TARGET structure, fix
  the doc-status line in the slice that builds each. The screen is greenfield.
- `RecordStudySessionAnswerUseCase` is the ONLY in-session answer path (no `GradeAttemptUseCase` /
  `AnswerFlashcardUseCase` despite older doc refs). SRS box transition happens at **finalize**, not
  per-answer (V1 keeps `flashcard_progress` untouched until Finish succeeds).
