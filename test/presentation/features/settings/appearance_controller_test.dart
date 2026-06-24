import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/appearance_settings_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/appearance_settings_repository.dart';
import 'package:memox/domain/types/app_theme_mode.dart';
import 'package:memox/domain/usecases/appearance_settings_usecases.dart';
import 'package:memox/presentation/features/settings/controllers/appearance_controller.dart';

class _FakeRepo implements AppearanceSettingsRepository {
  _FakeRepo(this.current);
  AppThemeMode current;
  AppThemeMode? lastSaved;
  bool failSave = false;

  @override
  Future<Result<AppThemeMode>> load() async => (failure: null, data: current);

  @override
  Future<Result<void>> save(AppThemeMode mode) async {
    if (failSave) {
      return (
        failure: const Failure.storage(operation: StorageOp.write, cause: 'x'),
        data: null,
      );
    }
    lastSaved = mode;
    current = mode;
    return (failure: null, data: null);
  }
}

ProviderContainer _container(_FakeRepo repo) {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      loadAppearanceSettingsUseCaseProvider.overrideWith(
        (ref) async => LoadAppearanceSettingsUseCase(repository: repo),
      ),
      updateAppearanceSettingsUseCaseProvider.overrideWith(
        (ref) async => UpdateAppearanceSettingsUseCase(repository: repo),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('AppThemeMode.fromStorage', () {
    test('parses known values, falls back to system', () {
      expect(AppThemeMode.fromStorage('light'), AppThemeMode.light);
      expect(AppThemeMode.fromStorage('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromStorage('system'), AppThemeMode.system);
      expect(AppThemeMode.fromStorage(null), AppThemeMode.system);
      expect(AppThemeMode.fromStorage('bogus'), AppThemeMode.system);
    });
  });

  group('AppearanceController', () {
    test('loads the persisted mode', () async {
      final _FakeRepo repo = _FakeRepo(AppThemeMode.dark);
      final ProviderContainer container = _container(repo);
      final AppThemeMode mode = await container.read(
        appearanceControllerProvider.future,
      );
      expect(mode, AppThemeMode.dark);
    });

    test('setMode persists the chosen mode', () async {
      final _FakeRepo repo = _FakeRepo(AppThemeMode.system);
      final ProviderContainer container = _container(repo);
      await container.read(appearanceControllerProvider.future);

      await container
          .read(appearanceControllerProvider.notifier)
          .setMode(AppThemeMode.dark);

      expect(repo.lastSaved, AppThemeMode.dark);
      expect(
        container.read(appearanceControllerProvider).requireValue,
        AppThemeMode.dark,
      );
    });

    test('setMode to the current mode is a no-op', () async {
      final _FakeRepo repo = _FakeRepo(AppThemeMode.light);
      final ProviderContainer container = _container(repo);
      await container.read(appearanceControllerProvider.future);

      await container
          .read(appearanceControllerProvider.notifier)
          .setMode(AppThemeMode.light);

      expect(repo.lastSaved, isNull);
    });

    test('a save failure reverts the optimistic change', () async {
      final _FakeRepo repo = _FakeRepo(AppThemeMode.system)..failSave = true;
      final ProviderContainer container = _container(repo);
      await container.read(appearanceControllerProvider.future);

      await container
          .read(appearanceControllerProvider.notifier)
          .setMode(AppThemeMode.dark);

      expect(
        container.read(appearanceControllerProvider).requireValue,
        AppThemeMode.system, // reverted
      );
    });
  });
}
