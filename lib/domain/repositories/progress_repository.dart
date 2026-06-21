import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/box_distribution.dart';
import 'package:memox/domain/models/due_summary.dart';
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
}
