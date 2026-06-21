import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

/// Loads the composed Progress-screen read model (WBS 7.4.1).
///
/// Owns the `now` clock (epoch ms) and delegates to
/// [ProgressRepository.loadProgressReadModel], which composes the due summary,
/// box distribution, and study statistics in one call (decision row P11). The
/// first failing part propagates; an empty database yields zero-safe parts.
class LoadProgressReadModelUseCase {
  const LoadProgressReadModelUseCase({required this.repository});

  final ProgressRepository repository;

  Future<Result<ProgressReadModel>> call() => repository.loadProgressReadModel(
    now: DateTime.now().millisecondsSinceEpoch,
  );
}
