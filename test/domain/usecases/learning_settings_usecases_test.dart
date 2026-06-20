import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';
import 'package:memox/domain/usecases/learning_settings_usecases.dart';

class _FakeRepo implements LearningSettingsRepository {
  LearningSettings? saved;
  int saveCalls = 0;
  Result<LearningSettings> loadResponse = (
    failure: null,
    data: const LearningSettings(),
  );

  @override
  Future<Result<LearningSettings>> load() async => loadResponse;

  @override
  Future<Result<void>> save(LearningSettings settings) async {
    saveCalls++;
    saved = settings;
    return (failure: null, data: null);
  }
}

void main() {
  // WBS 8.2.1. Contract:
  // docs/contracts/usecase-contracts/learning-settings.md.
  group('LoadLearningSettingsUseCase', () {
    test('delegates to the repository', () async {
      final repo = _FakeRepo()
        ..loadResponse = (
          failure: null,
          data: const LearningSettings(dailyNewLimit: 30),
        );
      final result = await LoadLearningSettingsUseCase(repository: repo).call();

      expect(result.isSuccess, isTrue);
      expect(result.data!.dailyNewLimit, 30);
    });
  });

  group('UpdateLearningSettingsUseCase', () {
    test('persists a valid dailyNewLimit', () async {
      final repo = _FakeRepo();
      final result = await UpdateLearningSettingsUseCase(
        repository: repo,
      ).call(settings: const LearningSettings(dailyNewLimit: 25));

      expect(result.isSuccess, isTrue);
      expect(repo.saveCalls, 1);
      expect(repo.saved!.dailyNewLimit, 25);
    });

    test('rejects an out-of-range dailyNewLimit without saving', () async {
      final repo = _FakeRepo();
      for (final int invalid in <int>[0, 4, 205]) {
        final result = await UpdateLearningSettingsUseCase(
          repository: repo,
        ).call(settings: LearningSettings(dailyNewLimit: invalid));

        expect(
          result.failure,
          isA<ValidationFailure>()
              .having(
                (ValidationFailure f) => f.field,
                'field',
                'dailyNewLimit',
              )
              .having(
                (ValidationFailure f) => f.code,
                'code',
                ValidationCode.outOfRange,
              ),
        );
      }
      expect(repo.saveCalls, 0);
    });

    test('rejects an off-step dailyNewLimit', () async {
      final repo = _FakeRepo();
      final result = await UpdateLearningSettingsUseCase(
        repository: repo,
      ).call(settings: const LearningSettings(dailyNewLimit: 22));

      expect(result.isFailure, isTrue);
      expect(repo.saveCalls, 0);
    });

    test(
      'normalizes goalDisabledSince to local midnight before save',
      () async {
        final repo = _FakeRepo();
        await UpdateLearningSettingsUseCase(repository: repo).call(
          settings: LearningSettings(
            goalDisabledSince: DateTime(2026, 6, 20, 13, 45, 12),
          ),
        );

        expect(repo.saved!.goalDisabledSince, DateTime(2026, 6, 20));
      },
    );
  });
}
