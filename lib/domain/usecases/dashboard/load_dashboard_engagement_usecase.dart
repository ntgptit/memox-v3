import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_engagement.dart';
import 'package:memox/domain/models/dashboard_recent_deck.dart';
import 'package:memox/domain/repositories/dashboard_repository.dart';
import 'package:memox/domain/usecases/progress/load_progress_engagement_usecase.dart';
import 'package:memox/domain/usecases/progress/load_study_statistics_usecase.dart';

/// Loads the Dashboard engagement overview (WBS 5.x — engagement restored
/// 2026-06-25 by owner ruling).
///
/// Owns the `now` clock. Composes the kit's overview into one snapshot by REUSING
/// existing read models — no new SRS maths:
/// - due snapshot + total deck count + recent decks (dashboard repository);
/// - the continue-studying session (dashboard repository);
/// - accuracy = correct / attempts (study statistics);
/// - current streak (progress engagement).
///
/// The core due summary is FATAL — its failure surfaces the screen's error state.
/// Every enrichment degrades to a safe default on failure (accuracy null, streak
/// 0, recent decks empty, resume null) so a stats read hiccup never blanks the
/// dashboard. `accuracyPercent` stays null until there is graded activity (no
/// fabricated 0%). See `docs/business/engagement/dashboard-engagement.md`.
class LoadDashboardEngagementUseCase {
  const LoadDashboardEngagementUseCase({
    required this.repository,
    required this.loadStudyStatistics,
    required this.loadProgressEngagement,
  });

  final DashboardRepository repository;
  final LoadStudyStatisticsUseCase loadStudyStatistics;
  final LoadProgressEngagementUseCase loadProgressEngagement;

  /// How many recent decks the overview shows.
  static const int recentDeckLimit = 5;

  Future<Result<DashboardEngagement>> call() async {
    final int now = DateTime.now().millisecondsSinceEpoch;

    final summaryResult = await repository.loadSummary(now: now);
    final summary = summaryResult.data;
    if (summaryResult.failure != null || summary == null) {
      return (failure: summaryResult.failure, data: null);
    }

    // Enrichments: a failure here degrades to a safe default, never the error state.
    final int totalDecks = (await repository.countDecks()).data ?? 0;
    final resume = (await repository.loadResumeSessionSummary(now: now)).data;
    final List<DashboardRecentDeck> recentDecks =
        (await repository.loadRecentDecks(
          now: now,
          limit: recentDeckLimit,
        )).data ??
        const <DashboardRecentDeck>[];
    final stats = (await loadStudyStatistics.call()).data;
    final int currentStreak =
        (await loadProgressEngagement.call()).data?.currentStreak ?? 0;

    final int? accuracyPercent = (stats != null && stats.totalAttempts > 0)
        ? ((100 * stats.correctCount) / stats.totalAttempts).round()
        : null;

    return (
      failure: null,
      data: DashboardEngagement(
        cardsDue: summary.cardsDue,
        decksWithDue: summary.decksWithDue,
        totalDecks: totalDecks,
        accuracyPercent: accuracyPercent,
        currentStreak: currentStreak,
        resume: resume,
        recentDecks: recentDecks,
      ),
    );
  }
}
