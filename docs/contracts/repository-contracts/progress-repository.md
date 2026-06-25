---
last_updated: 2026-06-21
status: contract
---

# Progress Repository Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. If the project has not yet adopted `fpdart`, do not add it during
> ordinary feature implementation. First run an approved dependency/API migration task, or use the
> existing repository error/result pattern until that migration is approved.

`flashcard_progress` + `study_attempts`. The SRS heart of the data layer.

## Methods

```dart
// Queries
Stream<FlashcardProgress?> watchProgress(FlashcardId id);
Future<Either<Failure, FlashcardProgress>> getProgress(FlashcardId id);
Future<Either<Failure, List<FlashcardProgress>>> getDueInScope(StudyScope scope, {DateTime? asOf});
Future<Either<Failure, int>> countSuspended();
Future<Either<Failure, int>> countBuriedToday();
Future<Either<Failure, Map<BoxNumber, int>>> getBoxDistribution();
Future<Either<Failure, Map<DateTime, int>>> loadAttemptCountsByDay();
// Dashboard "Recent decks" + never-studied "new" count (one read).
// decks ORDER BY updated_at DESC LIMIT :limit, each with cardCount, dueCount,
// lastStudiedAt; plus library-wide newCardCount (never-studied, not suspended).
Future<Either<Failure, DashboardDeckHighlights>> loadDashboardDeckHighlights({required DateTime now, int limit});

// Attempts
Stream<List<StudyAttempt>> watchAttemptsByCard(FlashcardId id, {DateTime? before, int limit = 50});
Future<Either<Failure, List<StudyAttempt>>> getAttemptsBySession(SessionId id);
Future<Either<Failure, Map<DateTime, int>>> getAttemptCountsByDay(DateTime start, DateTime end);
Future<Either<Failure, Map<DateTime, double>>> getAccuracyByDay(DateTime start, DateTime end);
Future<Either<Failure, int>> getAttemptCountToday();

// Mutations
Future<Either<Failure, FlashcardProgress>> recordAttemptAndUpdateProgress({
  required SessionId sessionId,
  required FlashcardId flashcardId,
  required AttemptResult result,
  required StudyMode studyMode,
  required BoxNumber boxBefore,
  required BoxNumber boxAfter,
  required DateTime dueAt,
  String? userInput,
});
Future<Either<Failure, FlashcardProgress>> bury(FlashcardId id, DateTime until);
Future<Either<Failure, FlashcardProgress>> setSuspended(FlashcardId id, bool value);
Future<Either<Failure, FlashcardProgress>> resetProgress(FlashcardId id);
Future<Either<Failure, int>> bulkResetProgress(List<FlashcardId> ids);
```

## Implemented (WBS 7.1.1 — due-summary slice)

The first Progress slice ships a focused `ProgressRepository`
(`lib/domain/repositories/progress_repository.dart`) exposing only:

```dart
Future<Result<DueSummary>> loadDueSummary({required int now});
```

(the project `Result<T>` record, not `Either` — see the header parity note). It
returns `DueSummary` (`lib/domain/models/due_summary.dart`): the global
`totalDueCount` plus per-deck `DeckDueCount` rows (only decks with due cards). A
card is "due" when `due_at IS NOT NULL AND due_at <= now`, with suspended and
currently-buried cards excluded — the **same predicate** as the study queue (WBS
4.11.1) and eligibility counts (WBS 4.1.1) so every due surface agrees. The
global total is the sum of the per-deck counts (every flashcard has exactly one
deck). Query: `lib/data/datasources/local/drift/progress_queries.drift`
(`dueCountsByDeck`); DAO `ProgressDao`; use case `LoadDueSummaryUseCase`. The
remaining methods below are the target surface for later Progress slices
(WBS 7.2.x+).

**WBS 7.2.1 (box distribution)** adds
`Future<Result<BoxDistribution>> loadBoxDistribution()`
(`lib/domain/models/box_distribution.dart`): card counts per Leitner box from
`flashcard_progress` (`boxDistribution` query), zero-filled across
`SrsBox.min..SrsBox.max` (1..8), failing fast with an `IntegrityFailure` on any
persisted `box_number` outside 1..8 (a data-invariant violation, not user input —
decision row P9). Use case `LoadBoxDistributionUseCase`.

**WBS 7.3.1 (study statistics)** adds
`Future<Result<StudyStatistics>> loadStudyStatistics()`
(`lib/domain/models/study_statistics.dart`): completed-session count + attempt
rollup (`totalAttempts`, `forgotCount`, `correctCount = total − forgot`,
`lastStudiedAt`) — a pure read, no mutation (decision row P10). Queries
`completedSessionCount` / `attemptStatistics` / `lastAttemptTime`; use case
`LoadStudyStatisticsUseCase`.

**WBS 7.4.1 (combined read model)** adds
`Future<Result<ProgressReadModel>> loadProgressReadModel({required int now})`
(`lib/domain/models/progress_read_model.dart`): composes the due summary, box
distribution, and study statistics in one call — the first failing part
short-circuits and propagates; an empty database yields zero-safe parts
(decision row P11). Use case `LoadProgressReadModelUseCase`.

**WBS 7.5.1 (Stats screen, screen 18)** adds
`Future<Result<StatsOverview>> loadStatsOverview({required int now})`
(`lib/domain/models/stats_overview.dart`): the current local week's review
activity (`WeekActivity` — seven Mon→Sun day buckets counted from `study_attempts`
via `attemptsSince`, bucketed by **local** day in Dart; decision row P20) plus
per-deck mastery (`List<DeckMastery>` — average Leitner box per deck via
`deckMastery`, mapped to a 0..1 fraction; decision row P21). An empty database
yields a zero-filled week and an empty deck list; a read error → `StorageFailure`.
Use case `LoadStatsOverviewUseCase`. Local-day grouping is in Dart, never SQL
`'localtime'`.

**WBS 7.4.3 (engagement read, Q5)** adds
`Future<Result<StudyDayActivity>> loadStudyActivity({required int now})`
(`lib/domain/models/progress_engagement.dart`): attempt-derived study-day activity
as of `now` (epoch ms) — today's answered count plus the current/longest
consecutive **study-day** streak (any day with ≥1 attempt), bucketed by **local**
day in Dart over `study_attempts` via the existing `attemptsSince(0)` query
(decision rows P16/P18). The current streak counts back from yesterday when today
has no attempt yet. An empty database yields all-zero activity; a read error →
`StorageFailure`. No new schema, no migration. Composed with the daily goal
(`LearningSettings`) by `LoadProgressEngagementUseCase` into `ProgressEngagement`
for the kit-19 Progress detail (read-only; the settings-backed goal-met streak
stays Future).

## Transaction requirements

| Operation                        | Tables touched                                                                                                                                     |
|----------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| `recordAttemptAndUpdateProgress` | `study_attempts` INSERT + `flashcard_progress` UPDATE (current_box, due_at, review_count++, lapse_count++ if forgot, last_studied_at, last_result) |
| `resetProgress`                  | `flashcard_progress` UPDATE: current_box=1, due_at=now, last_reset_at=now (counters UNCHANGED, attempts UNCHANGED)                                 |
| `bulkResetProgress`              | Single transaction across N rows                                                                                                                   |

## Index dependencies

These methods rely on indexes (recommend in `docs/database/schema-contract.md`):

- `getDueInScope` → `flashcard_progress(is_suspended, buried_until, due_at)`
- `watchAttemptsByCard` → `study_attempts(flashcard_id, attempted_at DESC)`
- `getBoxDistribution` → cheap aggregate, no special index
- `countSuspended` / `countBuriedToday` → `flashcard_progress(is_suspended, buried_until, due_at)`
- `loadAttemptCountsByDay` → `study_attempts(attempted_at)` grouped by device-local calendar day

## Constraints

- `current_box` ∈ 1..8.
- `box_before` and `box_after` in `study_attempts` MUST be populated (pending migration default 0;
  mapper handles pre-migration rows).
- `due_at` always reflects `current_box`.

## Forbidden

- ❌ Update `current_box` without inserting an attempt (unless via `resetProgress`).
- ❌ Insert attempt without updating progress.
- ❌ Delete attempts (history is permanent).
- ❌ Compute lifetime stats by scanning attempts when counters are sufficient.
- ❌ Use OFFSET for attempt pagination. Cursor only.

## Test contract

- `recordAttemptAndUpdateProgress` for each result type.
- Verify lapse_count increment only on `forgot`.
- Verify cap at 8.
- Reset progress → counters unchanged, last_reset_at set, attempts preserved.
- Bulk reset.
- Bury → due_at unchanged, buried_until set.
- Suspend toggle → SRS state unchanged.
- Box distribution aggregate.
- Time-range attempt count aggregate.
- Local-day attempt count aggregate for dashboard progress summary / streak computation.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`,
`docs/contracts/code-style.md`

**Business specs:** `docs/business/srs/srs-review.md`, `docs/business/history/card-history.md`,
`docs/business/study-actions/bury-suspend.md`
**Use cases:** `docs/contracts/usecase-contracts/study.md`,
`docs/contracts/usecase-contracts/history.md`, `docs/contracts/usecase-contracts/srs.md`
**Schema:** `docs/database/schema-contract.md` `flashcard_progress`, `study_attempts`
**Code paths:**

- `lib/domain/repositories/flashcard_progress_repository.dart`
- `lib/domain/repositories/study_attempt_repository.dart` (may be split or unified)
- `lib/data/repositories/progress_repository_impl.dart`
- `lib/data/datasources/local/daos/flashcard_progress_dao.dart`
- `lib/data/datasources/local/daos/progress_dao.dart`
