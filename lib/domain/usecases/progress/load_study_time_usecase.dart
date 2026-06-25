import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

/// Total on-card study time (ms) for attempts at or after [since] (epoch ms) —
/// the kit-19 Progress detail "Time" stat (WBS 7.5.x). Thin delegation; the
/// caller supplies the window start (e.g. the local week's Monday midnight).
/// Unlogged attempts (`duration_ms` NULL) contribute 0; an empty range → 0.
class LoadStudyTimeUseCase {
  const LoadStudyTimeUseCase({required this.repository});

  final ProgressRepository repository;

  Future<Result<int>> call({required int since}) =>
      repository.loadStudyTimeMs(since: since);
}
