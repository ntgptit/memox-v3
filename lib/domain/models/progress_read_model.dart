import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/box_number.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/progress_range.dart';

part 'progress_read_model.freezed.dart';

@freezed
abstract class DeckDueSummary with _$DeckDueSummary {
  const factory DeckDueSummary({
    required DeckId deckId,
    required String deckName,
    required FolderId parentFolderId,
    required int dueCount,
  }) = _DeckDueSummary;
}

@freezed
abstract class ProgressDueSummary with _$ProgressDueSummary {
  const factory ProgressDueSummary({
    required int totalDueCount,
    required List<DeckDueSummary> decks,
  }) = _ProgressDueSummary;
}

@freezed
abstract class BoxDistributionItem with _$BoxDistributionItem {
  const factory BoxDistributionItem({
    required BoxNumber boxNumber,
    required int cardCount,
  }) = _BoxDistributionItem;
}

@freezed
abstract class BoxDistribution with _$BoxDistribution {
  const factory BoxDistribution({required List<BoxDistributionItem> boxes}) =
      _BoxDistribution;
}

@freezed
abstract class StudyStatistics with _$StudyStatistics {
  const factory StudyStatistics({
    required int completedSessionCount,
    required int totalAttemptCount,
    required int correctCount,
    required int forgotCount,
    required DateTime? lastStudiedAt,
  }) = _StudyStatistics;
}

@freezed
abstract class ProgressReadModel with _$ProgressReadModel {
  const factory ProgressReadModel({
    required ProgressDueSummary dueSummary,
    required BoxDistribution boxDistribution,
    required StudyStatistics studyStatistics,
  }) = _ProgressReadModel;
}

/// One local day inside a [ProgressActivity] range.
@freezed
abstract class ProgressDayActivity with _$ProgressDayActivity {
  const factory ProgressDayActivity({
    /// Local midnight of the day this bucket covers.
    required DateTime day,
    required int attemptCount,
    required int correctCount,
  }) = _ProgressDayActivity;
}

/// Range-scoped study activity for the Progress screen charts.
@freezed
abstract class ProgressActivity with _$ProgressActivity {
  const factory ProgressActivity({
    required ProgressRange range,

    /// Per-local-day buckets, oldest first; empty for [ProgressRange.allTime].
    required List<ProgressDayActivity> days,
    required int totalAttempts,
    required int correctAttempts,

    /// Totals of the equally-sized range immediately before this one
    /// (zero for [ProgressRange.allTime] — no comparison range).
    required int previousTotalAttempts,
    required int previousCorrectAttempts,

    /// Number of days in the range with at least one attempt.
    required int distinctStudyDayCount,
  }) = _ProgressActivity;
}

/// Consecutive-study-day streak ("study streak").
///
/// A study day is a local calendar day with at least one persisted attempt.
/// This is intentionally NOT the engagement goal-met streak
/// (`docs/business/engagement/dashboard-engagement.md`), which stays
/// Future/Target with its own persistence contract.
@freezed
abstract class ProgressStreak with _$ProgressStreak {
  const factory ProgressStreak({
    required int currentDays,
    required int longestDays,
  }) = _ProgressStreak;
}

/// Library-wide card state counts for the "Card states" section.
@freezed
abstract class ProgressCardStateCounts with _$ProgressCardStateCounts {
  const factory ProgressCardStateCounts({
    required int suspendedCount,
    required int buriedTodayCount,
  }) = _ProgressCardStateCounts;
}

/// Everything the Progress screen renders for one selected range.
@freezed
abstract class ProgressOverview with _$ProgressOverview {
  const factory ProgressOverview({
    required ProgressActivity activity,
    required BoxDistribution boxDistribution,
    required ProgressStreak streak,
    required ProgressCardStateCounts cardStateCounts,
  }) = _ProgressOverview;
}
