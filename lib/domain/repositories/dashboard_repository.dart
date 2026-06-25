import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_recent_deck.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/dashboard_summary.dart';

/// Read access for the Dashboard summary (WBS 5.x — design redesign / engagement).
abstract interface class DashboardRepository {
  /// The current due snapshot (cards due + decks with due) as of [now] (epoch
  /// ms). Returns a `StorageFailure` on a read error.
  Future<Result<DashboardSummary>> loadSummary({required int now});

  /// The "Continue studying" summary — the most recently active resumable
  /// session within the 30-day window from [now] (epoch ms), or `null` when
  /// none (WBS 5.1.1). A read error maps to a `StorageFailure`.
  Future<Result<DashboardResumeSessionSummary?>> loadResumeSessionSummary({
    required int now,
  });

  /// Total number of decks — the "Decks" metric in the engagement stat strip
  /// (distinct from `decksWithDue`). A read error maps to a `StorageFailure`.
  Future<Result<int>> countDecks();

  /// Recently studied decks (most-recently-studied first), capped at [limit],
  /// with each deck's card count + current due count as of [now] (epoch ms)
  /// (engagement "Recent decks"). A read error maps to a `StorageFailure`.
  Future<Result<List<DashboardRecentDeck>>> loadRecentDecks({
    required int now,
    required int limit,
  });
}
