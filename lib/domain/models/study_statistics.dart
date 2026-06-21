import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_statistics.freezed.dart';

/// Session/attempt-based study statistics (WBS 7.3.1), for the Progress screen
/// (`docs/decision-tables/progress-history.md` P10). A pure read aggregate — no
/// mutation. [lastStudiedAt] is the epoch-ms timestamp of the most recent
/// attempt, or `null` when nothing has been studied.
@freezed
sealed class StudyStatistics with _$StudyStatistics {
  const factory StudyStatistics({
    required int completedSessions,
    required int totalAttempts,
    required int correctCount,
    required int forgotCount,
    required int? lastStudiedAt,
  }) = _StudyStatistics;
  const StudyStatistics._();

  /// Whether any attempt has been recorded.
  bool get hasActivity => totalAttempts > 0;
}
