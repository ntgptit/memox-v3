---
last_updated: 2026-06-12
status: contract
---

# Engagement Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. If the project has not yet adopted `fpdart`, do not add it during
> ordinary feature implementation. First run an approved dependency/API migration task, or use the
> existing repository error/result pattern until that migration is approved.

Daily goal, streak, reminder, recent decks, dashboard aggregate.

## LoadDashboardResumeSummaryUseCase

```dart
Future<Result<DashboardResumeSessionSummary?>> call();
```

**V1 implementation (WBS 5.1.1):** the Dashboard "Continue studying" read model.
`LoadDashboardResumeSummaryUseCase`
(`lib/domain/usecases/dashboard/load_dashboard_resume_summary_usecase.dart`) owns
the `now` clock and delegates to `DashboardRepository.loadResumeSessionSummary`
(`DashboardDao.resumeSession` over the `dashboardResumeSession` `.drift` query):
the single most recently active resumable session across **all** scopes (status
`draft`/`in_progress`, `updated_at` within the 30-day resume window), with its
`answered`/`total` item progress. Returns `null` when there is no resumable
session (the FE hides the Continue card, WBS 5.1.2). Maps to
`DashboardResumeSessionSummary` (`lib/domain/models/dashboard_resume_session_summary.dart`):
`sessionId`, `scope`, `answeredCount`, `totalCount`, `lastActiveAt`, with a
`progress` (0..1) getter. A read error → `StorageFailure(read)`.

## LoadDashboardProgressSummaryUseCase

```dart
Future<Either<Failure, DashboardProgressSummary>> call({required DateTime now});
```

Aggregates dashboard-ready progress data without wiring Dashboard UI:

- `dueTodayCount` reuses the existing Progress due-summary contract.
- `todayAttemptCount` comes from `study_attempts` grouped by the device's current local day.
- `dailyGoal` comes from persisted learning settings.
- `currentStreak` is computed from persisted attempt history while the goal is enabled.

**Rules:**

- Do not fabricate streak or goal values.
- If the goal is disabled, return a controlled disabled goal state and an unknown streak state.
- Due-count exclusions must match Progress/Library rules (suspended and currently buried excluded).
- Empty database returns zero-safe dashboard progress values.

**Errors:** `StorageFailure`.

## GetDashboardStateUseCase

```dart
Future<Either<Failure, DashboardState>> call();
```

Aggregates: resumable session, streak, daily goal progress, today's due, recent decks (top 3),
onboarding flag.

In practice, this is a coordinator that fires sub-use-cases in parallel via Riverpod providers. Use
case form documented here as the conceptual unit.

## GetDailyGoalUseCase

```dart
Future<DailyGoalSettings> call();
```

Reads SharedPreferences. Returns `{ enabled, target (5-200), streakEnabled }`.

## UpdateDailyGoalUseCase

```dart
Future<Either<Failure, Unit>> call({bool? enabled, int? target, bool? streakEnabled});
```

**Rules:**

- If `target` provided: assert 5 ≤ target ≤ 200 AND target % 5 == 0. Else
  `ValidationFailure(code: outOfRange)`.
- Persist to SharedPreferences.
- Side effect: if `enabled` toggled off → freeze streak (do NOT reset).

**Errors:** `ValidationFailure`, `StorageFailure`.

## ComputeStreakUseCase

```dart
Future<StreakInfo> call();
```

**Rules:**

- READ `lastGoalMetDate`, `currentStreak`, `longestStreak` from SharedPreferences.
- If `lastGoalMetDate < today - 1 day` AND `goalEnabled` AND `currentStreak > 0`:
    - Detect broken streak. Return
      `StreakInfo { currentStreak: 0, brokenStreakInfo: { previousStreak: N, brokenDate } }`.
    - Side effect: update SharedPreferences (reset currentStreak to 0). One-time banner shown by UI.
- Else return current streak as-is.

## LoadProgressEngagementUseCase (Current — Q5, read-only)

```dart
Future<Result<ProgressEngagement>> call();
```

**V1 implementation (Q5 / kit 19 Progress detail).** The realized, **read-only** engagement read for
the Progress detail's goal ring + streak chip. `LoadProgressEngagementUseCase`
(`lib/domain/usecases/progress/load_progress_engagement_usecase.dart`) owns the `now` clock and
composes two sources:

- the daily goal from `LearningSettings` (`LoadLearningSettingsUseCase`'s repository):
  `dailyGoalTarget = dailyNewLimit`, `goalEnabled = goalDisabledSince == null`;
- attempt-derived `StudyDayActivity` from `ProgressRepository.loadStudyActivity({now})`:
  `todayAnsweredCount` + `currentStreak`/`longestStreak`, bucketed by **local** day in Dart over
  `study_attempts` (decision rows P16/P18).

Returns `ProgressEngagement` (`lib/domain/models/progress_engagement.dart`):
`goalEnabled`, `dailyGoalTarget`, `todayAnsweredCount`, `currentStreak`, `longestStreak`, with
`goalMetToday` / `goalProgress` (0..1) getters. Values are never fabricated — empty DB → zeros, a
disabled goal → `goalEnabled = false` + `goalProgress = 0`. First failing read → `StorageFailure`.

This is the **read-only** path the contract explicitly permits ("Read-only dashboard summaries may
derive streak from persisted attempt history for display") — it does **not** persist or mutate the
streak. The settings-backed `lastGoalMetDate` streak (`ComputeStreakUseCase` /
`RecordGoalProgressUseCase` below) remains Future.

**Errors:** `StorageFailure`.

## RecordGoalProgressUseCase

```dart
Future<Either<Failure, GoalProgress>> call({required int cardsAnsweredToday});
```

Called by `FinalizeSessionUseCase` and any other point where attempts complete.

**Rules:**

- If `cardsAnsweredToday >= dailyGoal` AND today != `lastGoalMetDate`:
    - Increment `currentStreak`. Update `lastGoalMetDate = today`. Update
      `longestStreak = max(longest, current)`.

**Errors:** `StorageFailure`.

## ScheduleReminderUseCase

```dart
Future<Either<Failure, Unit>> call({required TimeOfDay time});
```

**Rules:**

- Request OS notification permission if not granted.
- Schedule daily local notification at `time` in user's local timezone.
- Cancel previous reminder before scheduling new.

**Errors:** `AuthFailure` (permission denied), platform error → `StorageFailure`.

## CancelReminderUseCase

```dart
Future<Either<Failure, Unit>> call();
```

Cancels any scheduled reminder.

## LoadDashboardDeckHighlightsUseCase (was GetRecentDecksUseCase)

```dart
Future<Result<DashboardDeckHighlights>> call({required DateTime now});
```

Implemented at `lib/domain/usecases/progress/load_dashboard_deck_highlights_usecase.dart`,
backed by `ProgressRepository.loadDashboardDeckHighlights`. Returns the Dashboard "Recent decks"
list **and** the library-wide never-studied card count (for the "Start new learning" badge) in one
read:

- `recentDecks`: `decks ORDER BY updated_at DESC LIMIT 3`, each with `cardCount`, `dueCount`
  (same suspended/buried exclusions as Progress/Library), and `lastStudiedAt`
  (`MAX(flashcard_progress.last_studied_at)`, null = never studied).
- `newCardCount`: flashcards with no recorded `last_studied_at` and not suspended.

The recent-deck limit is fixed at 3 (`docs/wireframes/01-dashboard.md` §Agent rule).

**Errors:** `StorageFailure`.

## MarkFirstLaunchCompletedUseCase

```dart
Future<void> call();
```

Set SharedPreferences `firstLaunchCompletedAt = now`.

## Forbidden patterns

- ❌ Daily goal outside 5-200 or not multiple of 5.
- ❌ Reset streak on goal-off. Freeze instead.
- ❌ Schedule reminder before permission granted.
- ❌ Multiple reminders per day. Cancel previous on reschedule.
- ❌ Stateful streak persistence/mutation based on `study_attempts` scan. Use `lastGoalMetDate`
  flag for the settings-backed streak use case. Read-only dashboard summaries may derive streak
  from persisted attempt history for display.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types),
`docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Repositories used:** `docs/contracts/repository-contracts/study-repository.md` (read attempts for
goal progress), `docs/contracts/repository-contracts/deck-repository.md` (recent decks). Engagement
preferences live in SharedPreferences (not a Drift repository); see
`docs/database/storage-boundaries.md`.

**Business spec:** `docs/business/engagement/dashboard-engagement.md`
**Wireframes:** `docs/wireframes/01-dashboard.md`, `docs/wireframes/20-settings-learning.md`,
`docs/wireframes/18-study-result.md`
**Decision table:** rows under "Dashboard engagement"
**Code paths:** `lib/domain/usecases/engagement/**`,
`lib/domain/usecases/progress/load_progress_engagement_usecase.dart` (Current, Q5 read-only),
`lib/domain/models/progress_engagement.dart`,
`lib/domain/usecases/progress/load_dashboard_progress_summary_usecase.dart`,
`lib/data/datasources/local/preferences/engagement_preferences.dart`,
`lib/core/notifications/reminder_scheduler.dart`
