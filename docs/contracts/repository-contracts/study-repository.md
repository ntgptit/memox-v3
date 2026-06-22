---
last_updated: 2026-06-10
status: contract
---

# Study Repository Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. If the project has not yet adopted `fpdart`, do not add it during
> ordinary feature implementation. First run an approved dependency/API migration task, or use the
> existing repository error/result pattern until that migration is approved.

Sessions + session items. Attempts and progress live in
`docs/contracts/repository-contracts/progress-repository.md`.

## Methods

```dart
// Queries
Stream<Session?> watchSessionById(SessionId id);
Stream<List<ResumableSession>> watchResumableSessions();
Future<Either<Failure, ResumableSession?>> findResumable(StudyScope scope);
Future<Either<Failure, Session>> findById(SessionId id);
Future<Either<Failure, StudySessionReview>> loadStudySessionReview(SessionId sessionId);
Future<Either<Failure, StudySessionResult>> loadStudySessionResult(SessionId sessionId);
Future<Either<Failure, List<SessionItem>>> getItemsForSession(SessionId id);
Future<Either<Failure, SessionAggregate>> computeAggregate(SessionId id);

// Mutations
Future<Either<Failure, Session>> createSession({
  required StudyScope scope,
  required List<FlashcardId> flashcardIds,
});
Future<Either<Failure, Unit>> recordStudySessionAnswer({
  required SessionId sessionId,
  required String sessionItemId,
  required AttemptResult result,
  required StudyMode studyMode,
});
Future<Either<Failure, Unit>> recordMatchEvaluation({
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
Future<Either<Failure, List<MatchEvaluation>>> loadMatchEvaluations(
  SessionId sessionId,
);
Future<Either<Failure, Unit>> finalizeStudySession({required SessionId sessionId});
Future<Either<Failure, Unit>> buryStudySessionCard({
  required SessionId sessionId,
  required FlashcardId flashcardId,
});
Future<Either<Failure, Unit>> suspendStudySessionCard({
  required SessionId sessionId,
  required FlashcardId flashcardId,
});
Future<Either<Failure, Unit>> markInProgress(SessionId id);
Future<Either<Failure, Unit>> markCompleted(SessionId id);
Future<Either<Failure, Unit>> markCancelled(SessionId id);
Future<Either<Failure, Unit>> markFailedToFinalize(SessionId id);
Future<Either<Failure, Unit>> markItemAnswered(SessionId id, FlashcardId flashcardId);
Future<Either<Failure, int>> expireOldSessions();  // cancel sessions > 30 days old
// Implemented (4.0.1 skeleton) as `Future<Result<int>> expireOldSessions({required int now})`:
// the project `Result<T>` record (not `Either`, per the header parity note) with the clock
// injected by the caller. `resumeWindow` (30 days) is a static const on `StudyRepository`.
```

## Transaction requirements

| Operation           | Tables touched                                                                    |
|---------------------|-----------------------------------------------------------------------------------|
| `createSession`     | `study_sessions` INSERT + `study_session_items` INSERTs                           |
| `recordStudySessionAnswer` | `study_attempts` INSERT + `study_session_items` UPDATE (`answered_at`) + `study_sessions` UPDATE (`updated_at`) |
| `recordMatchEvaluation` | `study_match_evaluations` INSERT + `study_sessions` UPDATE (`updated_at`)          |
| `loadStudySessionResult` | read `study_sessions` + `study_session_items` + `study_attempts` aggregate     |
| `finalizeStudySession` | One-terminal-attempt flows: `flashcard_progress` UPDATE/INSERT + `study_sessions` UPDATE; Match branch: `study_match_evaluations` read + `study_attempts` INSERT + `flashcard_progress` UPDATE/INSERT + `study_sessions` UPDATE |
| `buryStudySessionCard` | `flashcard_progress` UPDATE/INSERT + `study_session_items` DELETE + `study_sessions` UPDATE |
| `suspendStudySessionCard` | `flashcard_progress` UPDATE/INSERT + `study_session_items` DELETE + `study_sessions` UPDATE |
| `markCompleted`     | `study_sessions` UPDATE + optional engagement update (handled by caller use case) |
| `expireOldSessions` | `study_sessions` UPDATE batch                                                     |

## Resumable matching rules

`findResumable(scope)` matches:

- `entry_type` equals scope.entryType
- `entry_ref_id` equals scope.entryRefId (NULL-safe)
- `status` is resumable/active according to the DAO query
- `updated_at` > now - 30 days

Order by `updated_at DESC`, return first.

Study type and flow are not part of the conflict key. A paused session for the
same scope blocks starting another session even when the requested mode/flow is
different; the Study Entry gate must offer Resume or Start over.

If loading the resume-candidate snapshot fails because the stored session is
stale or corrupt, candidate discovery logs the failure and returns null so the
user can start a new valid session. Explicit `loadSession(sessionId)` remains
strict and must surface the corruption instead of hiding it.

## Constraints

- **V1 create status (WBS 4.2.1):** `createSession` persists the new session
  directly as `in_progress` (not `draft`), per `docs/business/study/study-flow.md`
  §Session lifecycle. `draft` stays in the enum and is treated as resumable if
  encountered. Item rows are inserted in one transaction with the session header
  (`StudySessionDao.createSessionWithItems`); the whole unit rolls back on failure.
- Session `status` transitions allowed:
    - `draft` → `in_progress` (on first attempt)
    - `draft` / `in_progress` → `completed` (on finalize)
- `draft` / `in_progress` → `cancelled` (on user action OR auto-expire)
- Any other transition is `UnsupportedActionFailure` at use case layer.
- New Study batch loading treats flashcards with missing `flashcard_progress`
  rows as new active cards. This keeps repaired or legacy local databases from
  failing Study Entry after the scope count has already found cards; progress is
  upserted when the session finalizes.
- In-session self-grade V1 records attempts and marks `study_session_items.answered_at`
  only. It does not update `flashcard_progress`; box changes remain finalization-owned.
- Match evaluation rows are append-only and do not mark session items answered; they still
  refresh `study_sessions.updated_at` so the active session remains resumable.
- Match finalization derives one terminal `study_attempts` row per session item,
  then applies the normal SRS transition logic in the same transaction.
- In-session bury/suspend is transactional and scoped to the active session:
  it requires `status = in_progress`, validates that the flashcard is still in
  the session and unanswered, removes the matching `study_session_items` row,
  updates only `buried_until` or `is_suspended`, and touches
  `study_sessions.updated_at`.

## Forbidden

- ❌ DELETE a session row. Use status=cancelled.
- ❌ Allow concurrent in_progress sessions for same scope (enforced via resume-or-start-over flow at
  use case).
- ❌ Compute aggregate by re-scanning every time. Cache result for `completed` sessions.

## Test contract

- Create session with N items → verify rows.
- Load study session review by id → verify session header + ordered joined items.
- Record Match evaluations in order and verify append-only rows.
- Finalize Match sessions → derive one terminal attempt per item and preserve
  transactional rollback on failure.
- Resumable matching across all 4 entry types.
- Status transitions: allowed and forbidden.
- 30-day expiry.
- Aggregate computation.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`,
`docs/contracts/code-style.md`

**Business spec:** `docs/business/study/study-flow.md`, `docs/business/resume/resume-session.md`
**Use cases:** `docs/contracts/usecase-contracts/study.md`
**Schema:** `docs/database/schema-contract.md` `study_sessions`, `study_session_items`
**Code paths:**

- `lib/domain/repositories/study_repository.dart`
- `lib/data/repositories/study_repository_impl.dart`
- `lib/data/repositories/study_session_card_actions.dart` (bury/suspend collaborator)
- `lib/data/repositories/study_match_evaluations.dart` (Match-evaluation collaborator, WBS 4.5.4)
- `lib/data/datasources/local/daos/study_session_dao.dart`
- `lib/domain/entities/match_evaluation.dart`
- `lib/domain/usecases/study/record_match_evaluation_usecase.dart`
- `lib/domain/srs/srs_due.dart` (`dueAtFor` — shared by both finalize paths)
