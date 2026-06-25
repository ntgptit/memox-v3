import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/box_distribution.dart';
import 'package:memox/domain/models/due_summary.dart';
import 'package:memox/domain/models/progress_engagement.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/models/stats_overview.dart';
import 'package:memox/domain/models/study_statistics.dart';

/// Read port for SRS progress aggregates (WBS 7.1.1 slice).
///
/// V1 exposes only the due-summary read model; box distribution, attempt
/// aggregates, and the progress mutations described in
/// `docs/contracts/repository-contracts/progress-repository.md` grow this port in
/// later Progress slices (WBS 7.2.x+). Follows the repository `Result<T>` pattern
/// (the `Either` shape in the contract is the target architecture — see the
/// contract header); the clock is injected by the caller.
abstract interface class ProgressRepository {
  /// Aggregates due-card counts as of [now] (epoch ms): the global total plus the
  /// per-deck breakdown (only decks with due cards), excluding suspended and
  /// currently-buried cards (`docs/business/study-actions/bury-suspend.md`). A
  /// read error maps to a `StorageFailure`.
  Future<Result<DueSummary>> loadDueSummary({required int now});

  /// Card counts per Leitner box from `flashcard_progress` (WBS 7.2.1), zero-
  /// filled across boxes `SrsBox.min..SrsBox.max` (1..8). Fails fast with a
  /// `ValidationFailure` if any persisted `box_number` is out of range
  /// (`docs/decision-tables/progress-history.md` P9); a read error maps to a
  /// `StorageFailure`.
  Future<Result<BoxDistribution>> loadBoxDistribution();

  /// Session/attempt-based study statistics (WBS 7.3.1): completed-session count,
  /// total attempts, correct/forgot outcomes, and the last-studied timestamp — a
  /// pure read, no mutation (`docs/decision-tables/progress-history.md` P10). A
  /// read error maps to a `StorageFailure`.
  Future<Result<StudyStatistics>> loadStudyStatistics();

  /// Composes the full Progress read model as of [now] (epoch ms): due summary +
  /// box distribution + study statistics in one call (WBS 7.4.1; decision row
  /// P11). The first failing part short-circuits and propagates its failure; an
  /// empty database yields zero-safe parts.
  Future<Result<ProgressReadModel>> loadProgressReadModel({required int now});

  /// Composes the Stats screen read model as of [now] (epoch ms): the current
  /// local week's review activity (Monday→Sunday, zero-filled) plus per-deck
  /// mastery (Stats, screen 18; decision rows P20/P21). Weekly buckets are
  /// computed by local day in Dart, never SQL. An empty database yields a
  /// zero-filled week and an empty deck list. A read error maps to a
  /// `StorageFailure`.
  Future<Result<StatsOverview>> loadStatsOverview({required int now});

  /// Attempt-derived study-day activity as of [now] (epoch ms) for the Progress
  /// detail engagement read (kit 19, WBS 7.4.3): today's answered count + the
  /// current/longest study-day streak, bucketed by local day in Dart (never SQL).
  /// An empty database yields all-zero activity. A read error maps to a
  /// `StorageFailure`.
  Future<Result<StudyDayActivity>> loadStudyActivity({required int now});
}
