import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/due_summary.dart';

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
}
