import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/learning_settings.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';
import 'package:memox/domain/usecases/learning_settings_usecases.dart';

class _FakeLearningSettingsRepository implements LearningSettingsRepository {
  _FakeLearningSettingsRepository(this.result);

  Result<LearningSettings> result;
  LearningSettings? lastSaved;

  @override
  Future<Result<LearningSettings>> load() async => result;

  @override
  Future<Result<void>> save(LearningSettings settings) async {
    lastSaved = settings;
    return const Result<void>.ok(null);
  }
}

void main() {
  test('load forwards repository result unchanged', () async {
    final _FakeLearningSettingsRepository repository =
        _FakeLearningSettingsRepository(
          const Result<LearningSettings>.ok(
            LearningSettings(dailyNewLimit: 35, goalDisabledSince: null),
          ),
        );
    final LoadLearningSettingsUseCase useCase = LoadLearningSettingsUseCase(
      repository,
    );

    final Result<LearningSettings> result = await useCase();

    expect(result, isA<Ok<LearningSettings>>());
    expect((result as Ok<LearningSettings>).value.dailyNewLimit, 35);
  });

  test('update rejects dailyNewLimit outside the documented range', () async {
    final _FakeLearningSettingsRepository repository =
        _FakeLearningSettingsRepository(
          const Result<LearningSettings>.ok(LearningSettings.defaults),
        );
    final UpdateLearningSettingsUseCase useCase = UpdateLearningSettingsUseCase(
      repository,
    );

    final Result<void> result = await useCase(
      settings: const LearningSettings(
        dailyNewLimit: 21,
        goalDisabledSince: null,
      ),
    );

    expect(result, isA<Err<void>>());
    expect((result as Err<void>).failure, isA<ValidationFailure>());
  });

  test('update forwards valid settings to the repository', () async {
    final _FakeLearningSettingsRepository repository =
        _FakeLearningSettingsRepository(
          const Result<LearningSettings>.ok(LearningSettings.defaults),
        );
    final UpdateLearningSettingsUseCase useCase = UpdateLearningSettingsUseCase(
      repository,
    );
    final DateTime disabledSince = DateTime(2026, 6, 12);

    final Result<void> result = await useCase(
      settings: LearningSettings(
        dailyNewLimit: 35,
        goalDisabledSince: disabledSince,
      ),
    );

    expect(result, isA<Ok<void>>());
    expect(repository.lastSaved, isNotNull);
    expect(repository.lastSaved!.dailyNewLimit, 35);
    expect(repository.lastSaved!.goalDisabledSince, disabledSince);
  });
}
