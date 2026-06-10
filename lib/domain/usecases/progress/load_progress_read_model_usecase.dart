import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

class LoadProgressReadModelUseCase {
  const LoadProgressReadModelUseCase(this._repository);

  final ProgressRepository _repository;

  Future<Result<ProgressReadModel>> call({required DateTime now}) =>
      _repository.loadProgressReadModel(now: now);
}
