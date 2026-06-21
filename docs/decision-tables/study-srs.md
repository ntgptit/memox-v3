---
last_updated: 2026-06-19
source: split from memox-core-decision-table.md
applies_to: Study modes, SRS transitions, Bury/Suspend, Resume session, and Study Result behavior branches
---

# MemoX Decision Table — Study / SRS

## Convention
- `ID` is stable. Tests reference it by ID (e.g. `// decision: S1`).
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` column: `TBD` until the implementing agent writes the test.
  Tests must be derived from the Expected column, NOT from code.

## Study / SRS

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| S1 | Create session | Deck with cards | Persist session/items, capped to the first `maxSessionItems` eligible cards when the scope is larger | C0+C1 | study_repository_create_session_test.dart (BE) + create_study_session_usecase_test.dart (cap) |
| S2 | Create session | Folder with recursive cards | Persist session/items, capped to the first `maxSessionItems` eligible cards when the scope is larger | C0+C1 | study_repository_create_session_test.dart (BE) + create_study_session_usecase_test.dart (cap) |
| S3 | Create session | Today with due cards | Persist SRS session, capped to the first `maxSessionItems` due cards when the scope is larger | C0+C1 | study_repository_create_session_test.dart (BE) + create_study_session_usecase_test.dart (cap) |
| S4 | Create session | Deck with zero cards | `EmptyScopeException(deckNoCards)` → render `EmptyScopeScreen` (`studyEmpty_deck_noCards_title`) with "Add flashcards" CTA pushing `flashcardCreate`; no session persisted | C1 | study_entry_repository_impl_test.dart (BE) |
| S4b | Create session | Folder subtree with zero descendant cards | `EmptyScopeException(folderNoCards)` → `studyEmpty_folder_noCards_title` with "Add a deck" CTA returning to folder detail; no session | C1 | study_entry_repository_impl_test.dart (BE) |
| S4c | Create session | Today (srs_review) has cards but zero due | `EmptyScopeException(todayAllDone)` → `studyEmpty_today_allDone_title` + motivational message with "Back to dashboard" CTA; no session | C1 | study_entry_repository_impl_test.dart (BE) |
| S4d | Create session | Today (srs_review) with zero cards in DB | `EmptyScopeException(todayNoContent)` → `studyEmpty_today_noContent_title` with "Create your first deck" CTA opening library | C1 | study_entry_repository_impl_test.dart (BE) |
| S4e | Create session | Deck (srs_review) has cards but none due | `EmptyScopeException(deckNoDueCards, nextDueAt)` → `studyEmpty_deck_noDueCards_title` (+ "Next due in {relativeTime}" when a future due exists) with "Study new instead" CTA re-entering New Study | C1 | study_entry_repository_impl_test.dart (BE) |
| S4j | Create session | Folder (srs_review) subtree has cards but none due | `EmptyScopeException(folderNoDueCards, nextDueAt)` → `studyEmpty_folder_noDueCards_title` (+ next-due hint) with "Study new instead" CTA re-entering New Study | C1 | study_entry_repository_impl_test.dart (BE) |
| S4f | Create session | All cards buried for today | Empty state `studyEmpty_allBuried` | C1 | study_entry_repository_impl_test.dart (BE) |
| S4g | Create session | All cards suspended | Empty state `studyEmpty_allSuspended` | C1 | study_entry_repository_impl_test.dart (BE) |
| S4h | Create session | `entry_type=tag` with zero matching cards | Empty state `studyEmpty_tag_noCards`, no session | C1 | TBD |
| S4i | Create session | `entry_type=tag` matches cards but none due (srs_review) | Empty state `studyEmpty_tag_noDueCards` with "Study new instead" CTA | C1 | TBD |
| S5 | Validate flow | Invalid type/flow pair | Reject | C1 | TBD |
| S6 | Answer | Correct | Persist attempt and advance | C0+C1 | study_repository_record_answer_test.dart |
| S7 | Answer | Incorrect | Persist attempt and retry when required | C0+C1 | TBD |
| S8 | Exit | In progress | Show confirmation; cancel stays on Study Session, confirm leaves the screen without canceling or mutating the session, and falls back to Library when the route cannot pop | C0+C1 | TBD |
| S9 | Finalize | Success | Finish Session commits all answered items transactionally, updates progress, completes the session, and navigates to the real result screen | C0+C1 | study_repository_finalize_test.dart |
| S10 | Finalize | Failure | Keep the user on Study Session, preserve progress, and show a controlled finalize error | C1 | study_repository_finalize_test.dart |
| S11 | Box transition | result=perfect, box<8 | Next box = current+1; due_at = localMidnight(studyDay + interval[next]) | C0+C1 | study_srs_transition_test.dart |
| S12 | Box transition | result=forgot | Next box = 1; due_at = localMidnight(studyDay + interval[1]) | C0+C1 | study_srs_transition_test.dart |
| S13 | Box transition | result=recovered | Next box = current (stay); due_at = localMidnight(studyDay + interval[current]) | C0+C1 | study_srs_transition_test.dart |
| S14 | Box transition | result=perfect, box=8 | Next box = 8 (stay); due_at = localMidnight(studyDay + interval[8]) | C1 | study_srs_transition_test.dart |
| S15 | Lapse counter | result=forgot | Increment lapse_count | C1 | study_srs_transition_test.dart |
| S16 | Due query | Filter due_at <= now AND not suspended/buried | Return only due active cards | C0+C1 | TBD |
| S17 | Interval table | Box 1..5 | Linear 1..5 day intervals | C0 | study_srs_transition_test.dart |
| S18 | Interval table | Box 6, 7, 8 | 12, 30, 60 days | C0 | study_srs_transition_test.dart |
| S19 | Attempt result mapper | result=`recovered` | Storage codec accepts `recovered`; result is passing but not perfect-eligible | C0+C1 | TBD |
| S20 | SRS Review finalize | Persisted attempts contain a `forgot` followed by a passing attempt | Finalized result `recovered`, current box unchanged, no lapse | C0+C1 | TBD |
| S21 | Schema migration | (Not Applicable in this repo) legacy v12 CHECK rebuild for `recovered` | Current v4 `study_attempts` accepts `recovered` from the start; no CHECK migration exists or is needed | C1 | N/A — see `docs/database/schema-contract.md` §V1 migration gate |
| S22 | Start study | Invalid entryType or malformed study query | Show the gate's controlled error state; do not call the repository | C1 | study_entry_repository_impl_test.dart (BE) |
| S23 | Start study | Flashcards exist in scope but some `flashcard_progress` rows are missing | Treat missing-progress cards as new active cards for New Study and create a session instead of failing Study Entry with an empty eligible batch | C1 | study_entry_repository_impl_test.dart (BE) |
| S24 | Start study | Deck scope has eligible cards | Create a session and redirect with `pushReplacement` to the session route | C0+C1 | TBD |
| S25 | Start study | Folder scope has eligible cards | Create a session and redirect with `pushReplacement` to the session route | C0+C1 | TBD |
| S26 | Start study | Today scope has zero due cards | Render today all-done empty state and do not create a session | C1 | TBD |
| S27 | Start study | Session/result deep-link routes exist | `/library/study/session/:sessionId` opens the persisted Study Session Review Screen V1; `?mode=review` opens the swipe-grade review surface; no-mode deep links keep the recall shell; `/library/study/session/:sessionId/result` opens the real result screen behind the nested result route | C0+C1 | TBD |
| S28 | Start study | Scope has a resumable session | Return controlled `resumeRequired` and render explicit Resume / Start over / Back actions; Resume opens the existing session, Start over confirms then restarts the scope through one transactional repository operation, and no duplicate session is created silently | C0+C1 | resolve_study_entry_start_usecase_test.dart + study_repository_find_resumable_test.dart |
| S29 | Study session card | First item | Show current item 1 / total, keep Previous disabled, and allow reveal without advancing | C1 | TBD |
| S30 | Study session card | Middle item, tap Next | Advance to the next item, reset reveal to hidden, and update progress | C0+C1 | TBD |
| S31 | Study session card | Middle item, tap Previous | Move back to the previous item, reset reveal to hidden, and update progress | C0+C1 | TBD |
| S32 | Study session card | First/last item | Previous disabled on the first item; Next disabled on the last item | C1 | TBD |
| S33 | Study session card | Any navigation | Reveal resets to hidden after moving between cards | C1 | TBD |
| S34 | Study session grade | Reveal shown on an unanswered item | Forgot / Got it actions appear only after reveal and stay hidden before reveal | C0+C1 | TBD |
| S35 | Study session grade | Tap Got it | Insert one attempt, mark the session item answered, advance to the next unanswered item, reset reveal, and keep `flashcard_progress` unchanged | C0+C1 | study_repository_record_answer_test.dart |
| S36 | Study session grade | Tap Forgot | Insert one attempt, mark the session item answered, advance to the next unanswered item, reset reveal, and keep `flashcard_progress` unchanged | C0+C1 | study_repository_record_answer_test.dart |
| S37 | Study session grade | Last unanswered item answered | Show ready-to-finish copy and Finish Session CTA, stay on the session screen, and do not auto-navigate to result | C1 | TBD |
| S38 | Study session grade | Attempt transaction fails | Keep the current card visible and show a controlled save-failed message | C1 | TBD |
| S39 | Study session finish | All items answered; Finish Session tapped | Finalize transactionally, update SRS progress, mark the session completed, and navigate to the real result screen | C0+C1 | TBD |
| S40 | Study session finish | Any item unanswered | Reject finalization and keep the session open | C1 | TBD |
| S41 | Study session finish | Answered item has no persisted attempt | Reject finalization and keep the session open | C1 | TBD |
| S42 | Study session finish | Progress or session write fails during transaction | Roll back writes, keep the user on the study session, and show a controlled finalize error | C1 | TBD |
| S43 | Study session finish | Finish tapped after successful finalization | Push-replace to the study result route while the real result screen loads | C1 | TBD |
| S44 | Study session shell | CTA availability before completion | Show Finish Session CTA only after all items are answered | C1 | TBD |
| S45 | Study mode strategy | Session mode not persisted yet | Resolve `StudyMode.recall` through `StudyModeStrategyFactory.resolve()` as the documented V1 fallback; preserve the current reveal/self-grade flow | C1 | TBD |
| S46 | Study mode strategy | `StudyMode.review` resolved | Return `ReviewStudyModeStrategy` with `perfect` / `forgot` grading and no reveal/self-grade flow | C1 | study_mode_strategy_factory_test.dart |
| S47 | Study mode strategy | `StudyMode.guess` resolved | Return `GuessStudyModeStrategy` with deterministic option builder and `perfect` / `forgot` grading | C1 | study_mode_strategy_factory_test.dart (resolution+grading; option builder→4.5.6) |
| S48 | Study mode strategy | `StudyMode.match` resolved | Return `MatchStudyModeStrategy` (Board family: exposes no per-card grading API); Match uses append-only evaluation persistence, derives terminal attempts at finalization, and never emits `initial_passed` | C1 | study_mode_strategy_factory_test.dart |
| S49 | Study mode strategy | `StudyMode.fill` resolved | Return `FillStudyModeStrategy` (TypedAnswer family: evaluator-graded, no Forgot/Got-it API) with strict trim-only matching, one terminal persisted attempt, and no reveal/self-grade flow | C1 | study_mode_strategy_factory_test.dart |
| S50 | Match board builder | 5 unique session cards available | Build a deterministic 5-pair board with 10 cells, preserving pair identity by flashcard id and cell ownership by session item id | C0+C1 | TBD |
| S51 | Match board builder | Duplicate front/back text appears across cards | Keep pair identity keyed by id; do not dedupe by text when the ids are unique and the board is otherwise available | C0+C1 | TBD |
| S52 | Match board builder | Same session seed and input cards | Produce stable cell order for the same session id and board index; different board index changes order | C0+C1 | TBD |
| S53 | Match board builder | Fewer than 5 unique cards | Throw `UnsupportedError` and do not create a partial board | C0+C1 | TBD |
| S54 | Match evaluation | Correct pair selected | Persist an append-only `study_match_evaluations` row with `is_correct=true`, do not mark the session item answered, and keep `flashcard_progress` unchanged until finalization | C1 | TBD |
| S55 | Match evaluation | Wrong pair selected | Persist an append-only `study_match_evaluations` row with `is_correct=false`, do not mark the session item answered, and keep `flashcard_progress` unchanged until finalization | C1 | TBD |
| S56 | Match finalization | Card has a correct evaluation with no prior wrong | Derive a single terminal `study_attempts` row with `result=perfect`, then apply the normal SRS transition and mark the session completed transactionally | C1 | TBD |
| S57 | Match finalization | Card has any wrong evaluation before the correct one or never gets a correct evaluation before finalization | Derive a single terminal `study_attempts` row with `result=forgot`, then apply the normal SRS transition and mark the session completed transactionally | C1 | TBD |
| S58 | Study mode strategy | Any `StudyMode` value resolved | Every resolved strategy belongs to exactly one sealed interaction family (`BinaryGradeStudyModeStrategy` / `TypedAnswerStudyModeStrategy` / `BoardStudyModeStrategy`) and reports the resolved mode | C1 | study_mode_strategy_factory_test.dart |
| S59 | Study session review | Long-press the current review card | Open the card-actions sheet, allow Edit / Bury until tomorrow / Suspend card, persist bury or suspend before refreshing the review queue, and keep TTS out of the current V1 sheet | C1 | TBD |
| S60 | Study session guess | Guess mode opens on a valid session | Render the blue guess chrome, prompt card, and 5 real option cards; long-press opens the shared card-actions sheet for that card, and option cards never show a TTS button | C1 | TBD |
| S61 | Study session guess | Wrong option selected | Persist `forgot` immediately, reveal the selected red option plus the correct green option, dim the other options, and keep the skip footer active until the countdown advances | C1 | TBD |
| S62 | Study session guess | Correct option selected | Persist `perfect` immediately, reveal the selected green option, dim the others, and auto-finalize to the real result screen after the last card countdown completes | C1 | TBD |
| S63 | Study session recall | Hidden countdown state | Render the green recall chrome with stacked front/back cards, front-only edit/speak affordances, a hidden back placeholder, and a full-width `Show answer · {seconds}s` CTA driven by `DurationTokens.recallAnswerTimeout`; no attempt is recorded yet | C1 | TBD |
| S64 | Study session recall | Timeout reveal | When the countdown reaches 0, auto-reveal the back, show the timeout caption, and keep the user on the card until they self-grade; no auto-advance or auto-grade | C1 | TBD |
| S65 | Study session recall | Edit pause / resume | Tapping edit pauses the countdown while the edit route is open, refreshes the current card on return, and resumes from the remaining seconds instead of restarting the timer | C1 | TBD |
| S66 | Study session recall | Manual grade / finalize | Reveal before timeout or grade after timeout records `forgot` or `perfect`, advances to the next unanswered card, and auto-finalizes to the real result screen after the last grade | C1 | TBD |
| S67 | Study session fill | Typing state on open with an eligible front | Render the green fill chrome with the hint card, centered raw text input, Hint / Check actions, and no TTS button before feedback | C0+C1 | TBD |
| S68 | Study session fill | Exact match without hint | Persist `perfect`, show correct feedback with the TTS button, and auto-advance after the 0.8s countdown | C1 | TBD |
| S69 | Study session fill | Exact match after hint | Persist `recovered`, keep the TTS button visible after feedback, and auto-advance after the countdown | C1 | TBD |
| S70 | Study session fill | Wrong answer on first check | Show local wrong feedback, keep the attempt unpersisted, show Mark correct / Try again, and do not auto-advance | C1 | TBD |
| S71 | Study session fill | Retry tapped from wrong feedback | Clear the typed input, retain the hint-taint, return to typing, and keep the retry budget local only | C0+C1 | TBD |
| S72 | Study session fill | Mark correct tapped from wrong feedback | Persist `recovered` from the wrong branch, show the correct feedback state, and expose the TTS button afterward | C1 | TBD |
| S73 | Study session fill | Last card answered | Show the ready-to-finish callout and Finish Session CTA instead of the normal next-card flow | C1 | TBD |
| S74 | Study session fill | Finish tapped after the final answer | Finalize the session and push-replace to the real result screen on success | C0+C1 | TBD |
| S75 | Study session fill | Finalize fails | Keep the session open, show the controlled finalize error, and leave Finish Session available for retry | C1 | TBD |
| S76 | Answer | Flashcard has no `flashcard_progress` row (new card) | Record `box_before = 1` (new-card default), `box_after = SrsBox.nextBox(1, result)`; keep `flashcard_progress` unchanged (no row created at answer time) | C1 | study_repository_record_answer_test.dart |

## Bury / Suspend

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| BS1 | Bury current session card | During study session | Set `buried_until` to tomorrow local midnight + 1 second, remove current session item, touch session updated_at | C0+C1 | TBD |
| BS2 | Bury current session card | Progress row missing | Create progress with buried_until/default SRS-safe fields; do not mutate current_box/due_at/counters | C1 | TBD |
| BS3 | Auto-unbury | `buried_until <= now` | Card returns to due queue | C0+C1 | TBD |
| BS4 | Suspend current session card | During study session | Set `is_suspended=true`, remove current session item, touch session updated_at | C0+C1 | TBD |
| BS5 | Suspend current session card | Progress row missing | Create progress with is_suspended/default SRS-safe fields; do not mutate current_box/due_at/counters | C1 | TBD |
| BS6 | Unsuspend | Past `due_at` | Card immediately due | C0+C1 | TBD |
| BS7 | Toast undo | Within 5s | Revert state | C1 | TBD |
| BS8 | Filter | "Suspended" | Show only suspended cards | C0+C1 | TBD |
| BS9 | Filter | "Active" | Hide suspended and buried | C0+C1 | TBD |
| BS10 | Bury exclusion | Fresh deck new entry | Suspended deck card excluded from study entry | C0+C1 | TBD |
| BS11 | Bury exclusion | Fresh deck new entry | Currently buried deck card excluded from study entry | C0+C1 | TBD |
| BS12 | Bury exclusion | `buried_until` past | Card becomes eligible again | C0+C1 | TBD |
| BS13 | Suspend exclusion | Fresh today entry | Suspended due card excluded from today study | C0+C1 | TBD |
| BS14 | Suspend exclusion | Fresh today entry | Currently buried due card excluded from today study | C0+C1 | TBD |
| BS15 | Fresh entry after bury | Session cancelled | In-session buried card stays excluded from fresh deck study entry | C0+C1 | TBD |
| BS16 | Fresh entry after suspend | Session cancelled | In-session suspended card stays excluded from fresh deck study entry | C0+C1 | TBD |

## Resume Session

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| R1 | Dashboard load | One in_progress session exists | Show "Continue studying" card with scope, answered/total progress, last active, and a Continue CTA; no discard action | C0+C1 | TBD |
| R2 | Dashboard load | Multiple in_progress sessions | Show the most recent session only; V1 does not show a paused-session count note because the summary model does not expose remaining count metadata | C1 | TBD |
| R3 | Dashboard load | No in_progress sessions | Hide resume card | C0 | TBD |
| R3a | Dashboard load | Resume summary query fails | Show controlled localized error state with retry; keep the rest of the dashboard stable | C0+C1 | TBD |
| R3b | Dashboard continue tap | One resumable session card is visible | Open `/library/study/session/:sessionId` through the route helper; do not call dashboard repository mutation methods | C0+C1 | TBD |
| R4 | Open deck/folder | Has resumable session for scope | Show banner | C0+C1 | TBD |
| R5 | Start study | Scope has resumable session, regardless of study flow | Study Entry V1 returns controlled `resumeRequired`; do not silently create a second active session. The screen now shows Resume / Start over / Back actions, and Start over confirms before canceling and re-entering the same scope | C0+C1 | TBD |
| R6 | Start over | Confirmed twice | Start requested flow with `previousSessionId`; repository `restartStudySession` atomically validates scope/status, cancels the previous session, and creates the replacement session and items in one transaction | C1 | TBD |
| R7 | Resume | Tap continue | Open the existing persisted session at the correct item and keep the loaded session state intact; do not create, cancel, or restart a session | C0+C1 | TBD |
| R7a | Resume metadata touch | Tap continue | Touch `updated_at` on resume so the pause timer restarts | Future | Future |
| R8 | Auto-expiry | Session updated_at > 30 days old | Auto-cancel on app open with notice | C1 | TBD |
| R9 | Resume race | Entity (deck) deleted | Cancel session, show notice | C1 | TBD |
| R10 | Restart session | Previous session belongs to a different entry scope | Reject before loading a new batch; do not cancel or create | C1 | TBD |
| R11 | Restart session | Previous session is not restartable | Reject before loading a new batch; do not cancel or create | C1 | TBD |
| R12 | Restart session | Eligible batch is empty | Reject; do not cancel previous session or create a new session | C1 | TBD |
| R13 | Resume candidate lookup | Most recent active scope candidate references missing flashcard data | Future / deferred: if candidate corruption handling is promoted, log the failure, ignore the corrupt candidate, and allow start-new to create a valid session | Future | Future |
| R14 | Explicit resume/load | Caller opens the corrupt session by id | Future / deferred: if explicit corrupt-load handling is promoted, surface the load failure and do not hide corruption outside candidate discovery | Future | Future |
| R15 | Explicit resume/load | Persisted in-progress session with mixed answered/unanswered items | `loadStudySessionReview` returns ordered items and preserves `answeredAt` flags after reload | C0+C1 | TBD |
| R16 | Review state init | Persisted review has an unanswered item | `StudySessionReviewState.fromReview(...)` selects the first unanswered item as the current card | C0+C1 | TBD |
| R17 | Review state init | Persisted review is fully answered | `StudySessionReviewState.fromReview(...)` falls back to index 0 so reload stays safe and can show Finish Session CTA | C1 | TBD |
| R18 | Dashboard continue tap | Continue CTA opens a persisted session with loaded progress | Open the existing session screen, show the persisted item state, and do not call start/restart/cancel | C0+C1 | TBD |

## Study Result

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| RES1 | Open result route | Session completed/finalized | Render real `StudyResultScreen` with total / answered / passed / forgot summary, not `RoutePlaceholder` | C0+C1 | TBD |
| RES2 | Open result route | Session id missing or invalid | Render controlled invalid state with localized message and safe return to Library | C1 | TBD |
| RES3 | Open result route | Session not found | Render controlled not-found state with localized message and safe return to Library | C1 | TBD |
| RES4 | Open result route | Session not completed / finalized yet | Render controlled not-completed state, not fake success, and do not show completion summary | C1 | TBD |
| RES5 | Result CTA | Tap Back to Library / Home | Navigate through existing route constants (`RouteNames.library` / `RouteNames.home`), no raw route strings | C0+C1 | TBD |
