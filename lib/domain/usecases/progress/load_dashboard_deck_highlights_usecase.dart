import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_deck_highlights.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

/// Loads the Dashboard "Recent decks" list and the never-studied card count
/// that backs the "Start new learning" badge
/// (`docs/contracts/usecase-contracts/engagement.md` §GetRecentDecksUseCase).
class LoadDashboardDeckHighlightsUseCase {
  const LoadDashboardDeckHighlightsUseCase(this._progressRepository);

  /// Recent decks shown on the Dashboard is fixed at 3
  /// (`docs/wireframes/01-dashboard.md` §Agent rule).
  static const int recentDeckLimit = 3;

  final ProgressRepository _progressRepository;

  Future<Result<DashboardDeckHighlights>> call({required DateTime now}) =>
      _progressRepository.loadDashboardDeckHighlights(
        now: now,
        limit: recentDeckLimit,
      );
}
