import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/learning_settings.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';

/// Loads the persisted learning settings.
///
/// Failure types: `StorageFailure`.
class LoadLearningSettingsUseCase {
  const LoadLearningSettingsUseCase(this._repository);

  final LearningSettingsRepository _repository;

  Future<Result<LearningSettings>> call() => _repository.load();
}

/// Updates the persisted learning settings.
///
/// Failure types: `ValidationFailure`, `StorageFailure`.
class UpdateLearningSettingsUseCase {
  const UpdateLearningSettingsUseCase(this._repository);

  final LearningSettingsRepository _repository;

  Future<Result<void>> call({required LearningSettings settings}) async {
    if (!LearningSettings.isValidDailyNewLimit(settings.dailyNewLimit)) {
      return const Result<void>.err(
        Failure.validation(
          field: 'dailyNewLimit',
          code: ValidationCode.outOfRange,
        ),
      );
    }
    return _repository.save(settings);
  }
}
