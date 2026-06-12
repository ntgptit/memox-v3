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

## FindResumableSessionUseCase

```dart
Future<Either<Failure, ResumableSession?>> call({required StudyScope scope});
```

**Rules:**

- Match `study_sessions` where `(entry_type, entry_ref_id)` equals scope AND
  `status IN (draft, in_progress)` AND `updated_at > now - 30 days`.
- Return most recent match (or null).

**Errors:** `StorageFailure`.

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
- `Got it` persists as the passing path used by the current recall V1 flow (`AttemptResult.perfect`).
- If the session item is already answered, return `UnsupportedActionFailure`.
- If the last unanswered item is answered, leave the session open; do not finalize or navigate to result.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure`, `StorageFailure`.

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

- UPDATE `study_sessions.status = cancelled`.
- Already-recorded `study_attempts` preserved.

**Errors:** `NotFoundFailure`, `StorageFailure`.

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

- ❌ Update `current_box` outside `GradeAttemptUseCase` or `ResetFlashcardProgressUseCase`.
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
