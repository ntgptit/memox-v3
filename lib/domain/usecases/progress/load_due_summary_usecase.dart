import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/due_summary.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

/// Loads the library-wide due-card summary (WBS 7.1.1).
///
/// Owns the `now` clock (epoch ms) for the due/buried cutoffs and delegates to
/// [ProgressRepository.loadDueSummary]. Backs the dashboard due-today snapshot
/// and the Progress due summary; a read error propagates as `StorageFailure`.
class LoadDueSummaryUseCase {
  const LoadDueSummaryUseCase({required this.repository});

  final ProgressRepository repository;

  Future<Result<DueSummary>> call() =>
      repository.loadDueSummary(now: DateTime.now().millisecondsSinceEpoch);
}
