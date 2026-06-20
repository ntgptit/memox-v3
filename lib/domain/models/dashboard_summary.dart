import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_summary.freezed.dart';

/// The Dashboard "today snapshot" read model (WBS 5.x — design redesign).
///
/// Deliberately small: the redesign Dashboard is a quiet "refer to work" surface
/// (daily goal + streak live on Progress, not here). Carries only what the kit
/// `DueSummary` needs — how many cards are due and across how many decks.
@freezed
sealed class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    @Default(0) int cardsDue,
    @Default(0) int decksWithDue,
  }) = _DashboardSummary;
  const DashboardSummary._();

  /// True when nothing is due — the Dashboard shows the all-clear.
  bool get caughtUp => cardsDue == 0;
}
