---
last_updated: 2026-05-28
status: contract
---

# Study Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. If the project has not yet adopted `fpdart`, do not add it during
> ordinary feature implementation. First run an approved dependency/API migration task, or use the
> existing repository error/result pattern until that migration is approved.

Session lifecycle, scope resolution, grading, finalization.

## ResolveScopeUseCase

```dart
Future<Either<Failure, ResolvedScope>> call({
  required EntryType entryType,
  required EntryRefId entryRefId,
  required StudyType studyType,
});
```

**Returns:** list of candidate flashcards in scope, post-filter (excludes suspended, excludes buried
if `buried_until > now`), and the empty-scope variant code if list is empty.

**Errors:** `NotFoundFailure` (deck/folder doesn't exist), `ValidationFailure` (invalid entry_ref_id
for tag type), `StorageFailure`.

**V1 implementation (WBS 4.1.1 — eligibility slice):** the entry gate first resolves *eligibility*
(counts, not the card list) via `ResolveStudyEntryEligibilityUseCase`
(`lib/domain/usecases/study/resolve_study_entry_eligibility_usecase.dart` → `StudyEntryRepository`
→ `StudyEntryDao` over `study_entry_queries.drift`). It returns a `StudyEntryEligibility`
(`lib/domain/models/study_entry_eligibility.dart`): either `eligibleCount > 0` (proceed to session
creation, WBS 4.2.1) or a `StudyScopeEmptyReason` (the empty-scope matrix branch, decision rows
`S4`/`S4b`/`S4c`/`S4d`/`S4e`/`S4j`/`S4f`/`S4g`). New study counts every active non-buried card; SRS
review counts only due cards. The use case owns the `now` clock and follows the `Result<T>` pattern
(not `Either`, per the header note). A `deck`/`folder` scope with a missing `entryRefId` is a
`ValidationFailure(field: entryRefId)`. The candidate-list load + `maxSessionItems` batching land
with session creation (WBS 4.2.1); `EntryType.tag` is deferred (not in the core enum).

## FindResumableSessionUseCase

```dart
Future<Either<Failure, ResumableSession?>> call({required StudyScope scope});
```

**Rules:**

- Match `study_sessions` where `(entry_type, entry_ref_id)` equals scope AND
  `status IN (draft, in_progress)` AND `updated_at > now - 30 days`.
- Return most recent match (or null).

**Errors:** `StorageFailure`.

**V1 implementation (WBS 4.2.2):** `StudyRepository.findResumable({scope, now})`
(`lib/data/repositories/study_repository_impl.dart` → `StudySessionDao
.findResumableSession`, a NULL-safe `entry_ref_id` match ordered by `updated_at`
DESC, limit 1, within `resumeWindow`) returns the resumable `StudySession` header
or `null`. The **no-silent-resume gate** `ResolveStudyEntryStartUseCase`
(`lib/domain/usecases/study/resolve_study_entry_start_usecase.dart`) owns the
clock and composes it with eligibility (WBS 4.1.1) into a controlled
`StudyEntryStartResult` (`lib/domain/study/study_entry_start_result.dart`):
`resumeRequired(session)` when a resumable session exists (decision row S28 —
never resumed silently), else `canStart(eligibility)` or `blocked(reason,
nextDueAt)`. The richer `ResumableSession` projection (progress, last-active) is
deferred to the Dashboard Continue-Studying summary (WBS 5.1.1).

## CreateSessionUseCase

```dart
Future<Either<Failure, Session>> call({
  required StudyScope scope,
  required List<FlashcardId> flashcardIds,
});
```

**Rules:**

- Atomic insert session + per-card session_items (order preserved). See
  `docs/contracts/repository-contracts/study-repository.md`.

**Errors:** `StorageFailure`.

**V1 implementation (WBS 4.2.1):** `CreateStudySessionUseCase`
(`lib/domain/usecases/study/create_study_session_usecase.dart`) owns the `now`
clock and delegates to `StudyRepository.createSession({scope, flashcardIds, now})`
(`lib/data/repositories/study_repository_impl.dart`). The repo generates the
session + item ids (`IdGenerator`), maps the scope/status enums to storage tokens
(`StudySessionMapper`), and inserts the `study_sessions` row + ordered
`study_session_items` rows in one `StudySessionDao.createSessionWithItems`
transaction (rolls back as a unit on failure → `StorageFailure(transaction)`).
Per `docs/business/study/study-flow.md` §Session lifecycle, V1 persists the new
session directly as `in_progress` (not `draft`). An empty `flashcardIds` list is
a `ValidationFailure(insufficientContent)` (the eligibility gate, WBS 4.1.1, runs
first). The `maxSessionItems` cap (default 20, `CreateStudySessionUseCase.maxSessionItems`)
is applied **inside the use case** (WBS 4.2.4): when the resolved list is larger,
only the first `maxSessionItems` (in the caller's resolved order — due-date for
review, sort order for new) become session items. Ordered-eligible-id resolution
is a separate read, **implemented (WBS 4.11.1)** as
`StudyEntryRepository.resolveEligibleCardIds({scope, now})` /
`ResolveEligibleStudyCardsUseCase`
(`lib/data/datasources/local/drift/study_scope_queries.drift`): it returns the
ordered eligible flashcard ids — `srs_review` → due cards by `due_at`, `new_cards`
→ every active card by `sort_order` — with suspended and currently-buried cards
excluded, mirroring the eligibility counts (WBS 4.1.1).

## ResumeSessionUseCase

```dart
Future<Either<Failure, Session>> call({required SessionId id});
```

**Rules:**

- LOAD session. Validate `status IN (draft, in_progress)`. Else `UnsupportedActionFailure`.
- Return session + remaining items.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure`, `StorageFailure`.

## LoadStudySessionReviewUseCase

```dart
Future<Either<Failure, StudySessionReview>> call({required SessionId sessionId});
```

**Rules:**

- LOAD session by id.
- LOAD ordered `study_session_items` joined with `flashcards`.
- Return the persisted session header and ordered joined items for the review screen.
- Missing session returns `NotFoundFailure`.
- Empty item list is treated as a storage/integrity error and surfaces as a controlled error state.

**Errors:** `NotFoundFailure`, `ValidationFailure`, `StorageFailure`.

**V1 implementation (WBS 4.3.1):** `LoadStudySessionReviewUseCase`
(`lib/domain/usecases/study/load_study_session_review_usecase.dart`) delegates to
`StudyRepository.loadStudySessionReview({id})`, which composes three single-table
reads: `StudySessionDao.sessionById` (missing → `NotFoundFailure`),
`StudySessionDao.itemsForSession` (ordered by `sort_order`), and
`StudySessionDao.flashcardsByIds` (one `IN` query); the repository pairs the
ordered items with their flashcards via a `cardById` map (avoiding the
loosely-typed drift builder join). An empty item list →
`ValidationFailure(insufficientContent)`; a read error → `StorageFailure(read)`.
Returns `StudySessionReview` (`lib/domain/entities/study_session_review.dart`):
the `StudySession` header + ordered `StudySessionReviewItem`s (flashcard content +
`answeredAt`), with `total` / `answeredCount` / `isComplete` /
`firstUnansweredIndex` convenience getters the review controller (WBS 4.3.2) uses
to resume at the first unanswered item.

## LoadStudySessionResultUseCase

```dart
Future<Either<Failure, StudySessionResult>> call({required SessionId sessionId});
```

**Rules:**

- LOAD session by id.
- LOAD ordered `study_session_items` joined with `flashcards`.
- LOAD `study_attempts` for the session and derive the final per-item result summary used by the
  result screen.
- Return the persisted session header plus total / answered / forgot / passed counts.
- Missing session returns `NotFoundFailure`.
- Empty item list is treated as a storage/integrity error and surfaces as a controlled error state.

**Errors:** `NotFoundFailure`, `ValidationFailure`, `StorageFailure`.

**Implemented (WBS 4.7.1)** as `Future<Result<StudySessionResult>> call({required SessionId sessionId})`
(the project `Result<T>` record, not `Either` — see the header parity note). Returns
`StudySessionResult` (`lib/domain/models/study_session_result.dart`): the `StudySession` header plus
ordered, flashcard-joined `StudySessionResultItem`s, each carrying the terminal `AttemptResult?`
derived from its `study_attempts` via the **same V1 last-attempt classifier finalization uses**
(`_terminalResult`), so the result screen and the persisted SRS outcome never disagree; an
unanswered item carries a `null` result. The aggregate `total` / `answeredCount` / `forgotCount` /
`passedCount` are getters on the model. A missing session is a `NotFoundFailure`; an item-less
session is a controlled `ValidationFailure(insufficientContent)`; a read error is a
`StorageFailure(read)`.

## RecordStudySessionAnswerUseCase

```dart
Future<Either<Failure, Unit>> call({
  required SessionId sessionId,
  required String sessionItemId,
  required AttemptResult result,
  required StudyMode studyMode,
});
```

**Rules:**

- LOAD session. Validate status=`draft` or `in_progress`.
- LOAD ordered session items for the session and locate the current session item.
- LOAD the linked flashcard's current progress row to derive `box_before` / `box_after`.
- Atomic: insert `study_attempts`, update `study_session_items.answered_at`, and touch
  `study_sessions.updated_at` in one transaction.
- Do **not** update `flashcard_progress`.
- `Forgot` persists as `AttemptResult.forgot`.
- `Got it` persists as the passing path used by the current recall/review/guess V1 flows (`AttemptResult.perfect`).
- Fill V1 also uses this one-terminal-attempt path: the caller precomputes
  `AttemptResult.perfect` / `AttemptResult.recovered` / `AttemptResult.forgot`
  from the strict typed-answer evaluator, then records that terminal result.
- If the session item is already answered, return `UnsupportedActionFailure`.
- If the last unanswered item is answered, leave the session open; do not finalize or navigate to result.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure`, `StorageFailure`.

**V1 implementation (WBS 4.4.1):** `RecordStudySessionAnswerUseCase`
(`lib/domain/usecases/study/record_study_session_answer_usecase.dart`) owns the
`now` clock and delegates to `StudyRepository.recordStudySessionAnswer`
(`lib/data/repositories/study_repository_impl.dart`). It loads the session
(missing → `NotFoundFailure`; terminal status → `UnsupportedActionFailure`),
the item (missing / wrong session → `NotFoundFailure`; already answered →
`UnsupportedActionFailure`), and the flashcard's current box from
`flashcard_progress` (`box_before`; a card with no progress row is a new card at
box 1). `box_after = SrsBox.nextBox(box_before, result)`
(`lib/domain/srs/srs_box.dart`: perfect → +1 cap 8, recovered → stay, forgot →
1). Then `StudySessionDao.recordAnswer` inserts the `study_attempts` row (result
+ study_mode storage tokens, box_before/box_after) + marks
`study_session_items.answered_at` + touches `study_sessions.updated_at`, all in
one transaction; `flashcard_progress` is **not** written (box changes are
finalization-owned, WBS 4.6.x). A write error → `StorageFailure(transaction)`.

## RecordMatchEvaluationUseCase

```dart
Future<Either<Failure, Unit>> call({
  required SessionId sessionId,
  required String sessionItemId,
  required int boardIndex,
  required String pairId,
  required String selectedFrontCellId,
  required String selectedBackCellId,
  required String expectedFrontFlashcardId,
  required String expectedBackFlashcardId,
  required bool isCorrect,
  required StudyMode studyMode,
});
```

**Rules:**

- LOAD session. Validate status=`draft` or `in_progress`.
- LOAD the target session item and verify it belongs to the session.
- Validate the session is in Match mode.
- Atomic: insert a single append-only `study_match_evaluations` row with a per-session-item
  attempt order and touch `study_sessions.updated_at`.
- Do **not** update `study_session_items.answered_at`.
- Do **not** update `flashcard_progress`.
- Do **not** call `recordStudySessionAnswer`.
- `isCorrect=true` is the clean Match evaluation path; `isCorrect=false` is the wrong path.
- The `studyMode` argument must be `StudyMode.match`; other modes return `UnsupportedActionFailure`.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure`, `StorageFailure`.

## CancelSessionUseCase

```dart
Future<Either<Failure, Unit>> call({required SessionId id});
```

**Rules:**

- UPDATE `study_sessions.status = cancelled` for a resumable (`draft`/
  `in_progress`) session only — terminal sessions are a forbidden transition
  (§Constraints in `docs/contracts/repository-contracts/study-repository.md`).
- Already-recorded `study_attempts` preserved.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure` (session in a terminal
state), `StorageFailure`.

**V1 implementation (WBS 4.10.1):** `CancelStudySessionUseCase`
(`lib/domain/usecases/study/cancel_study_session_usecase.dart`) delegates to
`StudyRepository.cancelSession({id})` → `StudySessionDao.markCancelled(id)` (a
single `study_sessions` UPDATE to `cancelled` guarded by
`status IN (draft, in_progress)`; the row is never deleted and
`study_session_items` / `study_attempts` are untouched). The UPDATE's
affected-row count drives the result: `1` row → success; `0` rows → a follow-up
`sessionById` read distinguishes `NotFoundFailure(study_session)` (no such
session) from `UnsupportedActionFailure` (session exists but is terminal —
`completed`/`cancelled`/`failed_to_finalize`). A write error maps to
`StorageFailure(write)`. Used by the transactional start-over flow (WBS 4.2.3),
which only ever cancels a resumable session.

## GradeAttemptUseCase

```dart
Future<Either<Failure, FlashcardProgress>> call({
  required SessionId sessionId,
  required FlashcardId flashcardId,
  required AttemptResult result,
  required StudyMode studyMode,
  String? userInput,  // for fill mode only (recall in v1 has no input)
  bool overrideApplied = false,
});
```

**Rules:**

- LOAD session. Validate status=`in_progress` or transitioning from `draft` → `in_progress`.
- LOAD current `flashcard_progress`. Compute `box_before = current_box`, `box_after` per SRS rules:
    - `perfect` / `initialPassed` → `min(current+1, 8)`
    - `recovered` → `current` (stay)
    - `forgot` → `1`
- Compute `due_at` from the box-interval table for `box_after` (current runtime helper:
  `_intervalForBox` in `lib/data/repositories/study_repo_impl_mapping_helpers.dart`; see
  `docs/business/srs/srs-review.md` §Interval table for the pending ladder decision).
- Atomic: insert `study_attempts` (sessionId, flashcardId, result, studyMode, box_before, box_after,
  attempted_at=now, optional userInput) + update `flashcard_progress` (current_box=box_after,
  due_at, review_count++, lapse_count++ if forgot, last_studied_at=now, last_result=result) +
  advance session status `draft → in_progress` if needed. See
  `docs/contracts/repository-contracts/progress-repository.md`.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure` (session completed), `StorageFailure`.

**Test refs:** GA1-GA10, SRS rows.

## FinalizeStudySessionUseCase

```dart
Future<Either<Failure, Unit>> call({required SessionId sessionId});
```

**Rules:**

- LOAD session. For one-terminal-attempt flows, validate all
  `study_session_items` answered. Else return `FinalizationFailure`.
- LOAD persisted attempts for each answered item.
- For Match sessions, LOAD append-only Match evaluations, derive one terminal
  result per session item, and insert the terminal `study_attempts` rows in the
  same transaction before applying SRS transitions.
- Repair missing `flashcard_progress` rows during finalization if needed.
- Atomic: update progress rows, insert Match-derived terminal attempts when
  applicable, and mark session completed in one transaction.
- On failure, preserve existing data and keep the session open.

**Errors:** `NotFoundFailure`, `FinalizationFailure`, `StorageFailure`.

**V1 implementation (WBS 4.6.1/4.6.2/4.6.4):** `FinalizeStudySessionUseCase`
(`lib/domain/usecases/study/finalize_study_session_usecase.dart`) owns the `now`
clock and delegates to `StudyRepository.finalizeStudySession`
(`lib/data/repositories/study_repository_impl.dart`). It loads the session
(missing → `NotFoundFailure`; terminal status → `UnsupportedActionFailure` per the
allowed-transition constraint), validates every `study_session_items.answered_at`
is set (any unanswered → `FinalizationFailure`, session stays `in_progress`), then
for each item derives the terminal result (`_terminalResult`, the V1
last-attempt classifier), computes `box_after = SrsBox.nextBox(box_before, result)`
(`lib/domain/srs/srs_box.dart`), `due_at = localMidnight(studyDay + BoxIntervals.daysFor(box_after))`
(`lib/domain/srs/box_intervals.dart`, computed in Dart local time — never SQL
`localtime`), and the new `review_count` (+1) / `lapse_count` (+1 on `forgot`).
A new card with no `flashcard_progress` row finalizes from box 1 (the row is
created); existing rows preserve their suspend/bury state. `StudySessionDao
.finalizeSession` upserts all progress rows + marks the session `completed` in one
transaction (rolls back as a unit on failure). Match-derived terminal attempts are
deferred to the Match mode BE (WBS 4.5.x).

## RetryFinalizationUseCase

Future proposal; no live V1 implementation in this slice.

## BuryStudySessionCardUseCase

```dart
Future<Either<Failure, Unit>> call({
  required SessionId sessionId,
  required FlashcardId flashcardId,
});
```

**Rules:**

- Validate the session exists and is `in_progress`.
- Validate the flashcard is part of that session and not already answered.
- UPDATE `flashcard_progress.buried_until = tomorrow local midnight + 1 second`.
- Remove the matching `study_session_items` row from the active session queue.
- Do **not** insert `study_attempts`.
- Keep `current_box`, `due_at`, `review_count`, and `lapse_count` unchanged.
- Touch `study_sessions.updated_at`.

**Errors:** `NotFoundFailure`, `StorageFailure`.

**Test refs:** BS1, BS2, BS10, BS12, BS15.

## SuspendStudySessionCardUseCase

```dart
Future<Either<Failure, Unit>> call({
  required SessionId sessionId,
  required FlashcardId flashcardId,
});
```

**Rules:**

- Validate the session exists and is `in_progress`.
- Validate the flashcard is part of that session and not already answered.
- UPDATE `flashcard_progress.is_suspended = true`.
- Remove the matching `study_session_items` row from the active session queue.
- Do **not** insert `study_attempts`.
- Keep `current_box`, `due_at`, `review_count`, and `lapse_count` unchanged.
- Touch `study_sessions.updated_at`.

**Errors:** `NotFoundFailure`, `StorageFailure`.

**Test refs:** BS4, BS5, BS11, BS12, BS13, BS16.

## GetSessionStateUseCase

```dart
Future<Either<Failure, SessionState>> call({required SessionId id});
```

Returns session + answered count + total + next pending item.

## WatchDueCountsUseCase

```dart
Stream<Either<Failure, DueCounts>> call();
```

Returns due counts grouped (all / per deck / per folder) — used by Dashboard Today CTA and Library
row badges.

## Forbidden patterns

- ❌ Update `current_box` outside `FinalizeStudySessionUseCase`, `GradeAttemptUseCase`, or `ResetFlashcardProgressUseCase`. In V1 the self-grade path (`RecordStudySessionAnswerUseCase`, WBS 4.4.1) records `study_attempts.box_after` only and leaves `flashcard_progress.box_number` for finalization.
- ❌ Compute `due_at` outside the interval table.
- ❌ Finalize a session with unanswered items.
- ❌ Allow grade on a `completed`/`cancelled` session.
- ❌ Bury/suspend modify `current_box` or `due_at`.
- ❌ Delete `study_attempts` on cancel.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types),
`docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business specs:** `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md`,
`docs/business/study-actions/bury-suspend.md`, `docs/business/resume/resume-session.md`
**Repository:** `docs/contracts/repository-contracts/study-repository.md`,
`docs/contracts/repository-contracts/progress-repository.md`
**Wireframes:** `docs/wireframes/12-study-entry-gate.md` through
`docs/wireframes/18-study-result.md`
**Decision table:** rows S*, BS*, GA*, H3, F4*
**Code paths (verified 2026-06-09):** `lib/domain/study/usecases/study_usecases.dart` (current
V1 entry gate use case: `StartStudySessionUseCase`, plus `LoadStudySessionReviewUseCase` and
`LoadStudySessionResultUseCase`);
`lib/data/repositories/study_repo_impl.dart` (scope resolution, empty-state decision, session
insert, session review load, result summary load); `lib/data/datasources/local/daos/study_session_dao.dart`
(scope reads + session/item inserts + review join). The `lib/domain/usecases/study/**` and
`lib/domain/srs/**` directories do NOT exist in the current codebase.
