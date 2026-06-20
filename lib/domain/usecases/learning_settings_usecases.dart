import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';

/// Load the persisted learning settings for the study-entry and engagement
/// surfaces. Defaults/corrupt-recovery live in
/// [LearningSettingsRepository.load].
///
/// Contract: `docs/contracts/usecase-contracts/learning-settings.md`.
class LoadLearningSettingsUseCase {
  const LoadLearningSettingsUseCase({required this.repository});

  final LearningSettingsRepository repository;

  Future<Result<LearningSettings>> call() => repository.load();
}

/// Validate and persist learning settings.
///
/// Rules (`docs/contracts/usecase-contracts/learning-settings.md`):
/// - `dailyNewLimit` must be within `5..200` and on a step of `5`
///   ([ValidationCode.outOfRange] on `dailyNewLimit` otherwise).
/// - `goalDisabledSince` is normalized to a local date (midnight, time
///   stripped) before being passed to storage.
class UpdateLearningSettingsUseCase {
  const UpdateLearningSettingsUseCase({required this.repository});

  final LearningSettingsRepository repository;

  Future<Result<void>> call({required LearningSettings settings}) {
    if (!LearningSettings.isValidDailyNewLimit(settings.dailyNewLimit)) {
      return Future<Result<void>>.value((
        failure: const Failure.validation(
          field: 'dailyNewLimit',
          code: ValidationCode.outOfRange,
        ),
        data: null,
      ));
    }

    final DateTime? since = settings.goalDisabledSince;
    final LearningSettings normalized = since == null
        ? settings
        : settings.copyWith(
            goalDisabledSince: DateTime(since.year, since.month, since.day),
          );

    return repository.save(normalized);
  }
}
