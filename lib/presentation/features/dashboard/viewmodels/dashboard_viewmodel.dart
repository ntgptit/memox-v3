import 'dart:async';

import 'package:memox/app/di/progress_providers.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_deck_highlights.dart';
import 'package:memox/domain/models/dashboard_progress_summary.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_viewmodel.g.dart';

class DashboardVisualChrome {
  const DashboardVisualChrome({
    this.showOfflineBanner = false,
    this.showStreakBrokenBanner = false,
    this.streakBrokenDays = 0,
    this.pausedSessionCount = 0,
  });

  final bool showOfflineBanner;
  final bool showStreakBrokenBanner;
  final int streakBrokenDays;
  final int pausedSessionCount;
}

@riverpod
DashboardVisualChrome dashboardVisualChrome(Ref ref) =>
    const DashboardVisualChrome();

@riverpod
Future<DashboardResumeSessionSummary?> dashboardResumeSessionQuery(Ref ref) {
  final useCase = ref.watch(loadDashboardResumeSessionSummaryUseCaseProvider);
  return useCase.call().then(
    (Result<DashboardResumeSessionSummary?> result) => result.fold((
      Failure failure,
    ) {
      // ignore: only_throw_errors -- reason: Riverpod query must surface repository Failure as AsyncError.
      throw failure;
    }, (DashboardResumeSessionSummary? summary) => summary),
  );
}

/// Streak + daily-goal summary for the Dashboard stats row.
@riverpod
Future<DashboardProgressSummary> dashboardProgressSummaryQuery(Ref ref) {
  final useCase = ref.watch(loadDashboardProgressSummaryUseCaseProvider);
  return useCase
      .call(now: DateTime.now())
      .then(
        (Result<DashboardProgressSummary> result) => result.fold((
          Failure failure,
        ) {
          // ignore: only_throw_errors -- reason: Riverpod query must surface repository Failure as AsyncError.
          throw failure;
        }, (DashboardProgressSummary summary) => summary),
      );
}

/// Due-card summary (total + per-deck) for the Today's review card.
@riverpod
Future<ProgressDueSummary> dashboardDueSummaryQuery(Ref ref) {
  final useCase = ref.watch(loadDashboardDueSummaryUseCaseProvider);
  return useCase
      .call(now: DateTime.now())
      .then(
        (Result<ProgressDueSummary> result) => result.fold((Failure failure) {
          // ignore: only_throw_errors -- reason: Riverpod query must surface repository Failure as AsyncError.
          throw failure;
        }, (ProgressDueSummary summary) => summary),
      );
}

/// Recent decks + never-studied card count for the Dashboard deck surfaces.
@riverpod
Future<DashboardDeckHighlights> dashboardDeckHighlightsQuery(Ref ref) {
  final useCase = ref.watch(loadDashboardDeckHighlightsUseCaseProvider);
  return useCase
      .call(now: DateTime.now())
      .then(
        (Result<DashboardDeckHighlights> result) => result.fold((
          Failure failure,
        ) {
          // ignore: only_throw_errors -- reason: Riverpod query must surface repository Failure as AsyncError.
          throw failure;
        }, (DashboardDeckHighlights highlights) => highlights),
      );
}
