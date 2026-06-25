import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/models/dashboard_recent_deck.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';

part 'dashboard_engagement.freezed.dart';

/// The Dashboard "today overview" aggregate read model (engagement; WBS 5.x —
/// restored 2026-06-25 by owner ruling, reversing the quiet redesign).
///
/// Composes, in one snapshot, the engagement surface the kit shows:
/// - the stat strip — `cardsDue`, `totalDecks`, `accuracyPercent`, `currentStreak`;
/// - the optional continue-studying session (`resume`, null when none);
/// - the due snapshot (`cardsDue` / `decksWithDue` for the `DueSummary` card);
/// - the `recentDecks` list.
///
/// Assembled by `LoadDashboardEngagementUseCase` from the EXISTING summary / resume
/// / study-statistics / progress-engagement read models plus the recent-decks
/// query — no new SRS maths. `accuracyPercent` is null until there is graded
/// activity (no fabricated 0%). See `docs/business/engagement/dashboard-engagement.md`.
@freezed
sealed class DashboardEngagement with _$DashboardEngagement {
  const factory DashboardEngagement({
    @Default(0) int cardsDue,
    @Default(0) int decksWithDue,
    @Default(0) int totalDecks,
    int? accuracyPercent,
    @Default(0) int currentStreak,
    DashboardResumeSessionSummary? resume,
    @Default(<DashboardRecentDeck>[]) List<DashboardRecentDeck> recentDecks,
  }) = _DashboardEngagement;
  const DashboardEngagement._();

  /// True when nothing is due — the due snapshot shows the all-clear.
  bool get caughtUp => cardsDue == 0;

  /// True once there is graded activity to show an accuracy figure.
  bool get hasAccuracy => accuracyPercent != null;

  /// True when there is a resumable session to surface the Continue card.
  bool get hasResume => resume != null;
}
