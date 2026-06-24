import 'package:freezed_annotation/freezed_annotation.dart';

part 'week_activity.freezed.dart';

/// Cards reviewed on one local day of the current week, for the Stats
/// "Cards this week" column chart (`docs/wireframes/18-stats.md`).
///
/// [date] is local midnight of the day; [weekday] is `DateTime.weekday`
/// (1 = Monday .. 7 = Sunday) so the screen can render a localized narrow-weekday
/// label without the model carrying display copy. [count] is the number of
/// `study_attempts` whose local day is [date]. Local-day bucketing happens in
/// Dart (`toLocal()`), never in SQL — the test sqlite returns NULL for the
/// `'localtime'` modifier (`lib/data/datasources/local/drift/progress_queries.drift`).
@freezed
sealed class DayActivity with _$DayActivity {
  const factory DayActivity({
    required DateTime date,
    required int weekday,
    required int count,
  }) = _DayActivity;
}

/// The current local week's daily review activity (Monday → Sunday), for the
/// Stats "Cards this week" chart.
///
/// [days] always has exactly seven entries (Monday first), zero-filled, so the
/// chart axis is stable even with no activity. [total] is the weekly card count
/// shown beside the section header; [maxCount] backs the chart's bar scaling.
@freezed
sealed class WeekActivity with _$WeekActivity {
  const factory WeekActivity({required List<DayActivity> days}) = _WeekActivity;
  const WeekActivity._();

  /// Total cards reviewed across the week.
  int get total => days.fold<int>(0, (int sum, DayActivity d) => sum + d.count);

  /// The busiest day's count (0 when the week is empty) — the chart's full-bar
  /// reference so the tallest bar fills the plot.
  int get maxCount =>
      days.fold<int>(0, (int m, DayActivity d) => d.count > m ? d.count : m);

  /// Whether any card was reviewed this week.
  bool get hasActivity => total > 0;
}
