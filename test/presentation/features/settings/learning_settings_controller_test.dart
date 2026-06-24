import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/learning_settings_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';
import 'package:memox/domain/usecases/learning_settings_usecases.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_controller.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_view.dart';

class _FakeRepo implements LearningSettingsRepository {
  _FakeRepo(this.current);
  LearningSettings current;
  LearningSettings? lastSaved;
  bool failSave = false;

  @override
  Future<Result<LearningSettings>> load() async =>
      (failure: null, data: current);

  @override
  Future<Result<void>> save(LearningSettings settings) async {
    if (failSave) {
      return (
        failure: const Failure.storage(operation: StorageOp.write, cause: 'x'),
        data: null,
      );
    }
    lastSaved = settings;
    current = settings;
    return (failure: null, data: null);
  }
}

ProviderContainer _container(_FakeRepo repo) {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      loadLearningSettingsUseCaseProvider.overrideWith(
        (ref) async => LoadLearningSettingsUseCase(repository: repo),
      ),
      updateLearningSettingsUseCaseProvider.overrideWith(
        (ref) async => UpdateLearningSettingsUseCase(repository: repo),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('LearningSettingsController', () {
    test('loads the persisted settings', () async {
      final _FakeRepo repo = _FakeRepo(
        const LearningSettings(dailyNewLimit: 30),
      );
      final ProviderContainer container = _container(repo);
      final LearningSettingsView view = await container.read(
        learningSettingsControllerProvider.future,
      );
      expect(view.settings.dailyNewLimit, 30);
      expect(view.goalEnabled, isTrue);
    });

    test(
      'setGoalEnabled(false) stamps goalDisabledSince and persists',
      () async {
        final _FakeRepo repo = _FakeRepo(const LearningSettings());
        final ProviderContainer container = _container(repo);
        await container.read(learningSettingsControllerProvider.future);

        await container
            .read(learningSettingsControllerProvider.notifier)
            .setGoalEnabled(false);

        expect(repo.lastSaved?.goalDisabledSince, isNotNull);
        final LearningSettingsView view = container
            .read(learningSettingsControllerProvider)
            .requireValue;
        expect(view.goalEnabled, isFalse);
        expect(view.saving, isFalse);
      },
    );

    test('setGoalEnabled(true) clears goalDisabledSince', () async {
      final _FakeRepo repo = _FakeRepo(
        LearningSettings(goalDisabledSince: DateTime(2026, 1, 1)),
      );
      final ProviderContainer container = _container(repo);
      await container.read(learningSettingsControllerProvider.future);

      await container
          .read(learningSettingsControllerProvider.notifier)
          .setGoalEnabled(true);

      expect(repo.lastSaved?.goalDisabledSince, isNull);
    });

    test('setDailyLimit persists a valid value', () async {
      final _FakeRepo repo = _FakeRepo(const LearningSettings());
      final ProviderContainer container = _container(repo);
      await container.read(learningSettingsControllerProvider.future);

      await container
          .read(learningSettingsControllerProvider.notifier)
          .setDailyLimit(30);

      expect(repo.lastSaved?.dailyNewLimit, 30);
    });

    test('setDailyLimit rejects an invalid (off-step) value', () async {
      final _FakeRepo repo = _FakeRepo(const LearningSettings());
      final ProviderContainer container = _container(repo);
      await container.read(learningSettingsControllerProvider.future);

      await container
          .read(learningSettingsControllerProvider.notifier)
          .setDailyLimit(7);

      expect(repo.lastSaved, isNull);
      expect(
        container
            .read(learningSettingsControllerProvider)
            .requireValue
            .settings
            .dailyNewLimit,
        LearningSettings.defaultDailyNewLimit,
      );
    });

    test('a save failure reverts the optimistic change', () async {
      final _FakeRepo repo = _FakeRepo(
        const LearningSettings(dailyNewLimit: 20),
      )..failSave = true;
      final ProviderContainer container = _container(repo);
      await container.read(learningSettingsControllerProvider.future);

      await container
          .read(learningSettingsControllerProvider.notifier)
          .setDailyLimit(50);

      final LearningSettingsView view = container
          .read(learningSettingsControllerProvider)
          .requireValue;
      expect(view.settings.dailyNewLimit, 20); // reverted
      expect(view.saving, isFalse);
    });
  });
}
