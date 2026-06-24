import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/language_settings_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/language_settings_repository.dart';
import 'package:memox/domain/types/app_language.dart';
import 'package:memox/domain/usecases/language_settings_usecases.dart';
import 'package:memox/presentation/features/settings/controllers/language_controller.dart';

class _FakeRepo implements LanguageSettingsRepository {
  _FakeRepo(this.current);
  AppLanguage current;
  AppLanguage? lastSaved;
  bool failSave = false;

  @override
  Future<Result<AppLanguage>> load() async => (failure: null, data: current);

  @override
  Future<Result<void>> save(AppLanguage language) async {
    if (failSave) {
      return (
        failure: const Failure.storage(operation: StorageOp.write, cause: 'x'),
        data: null,
      );
    }
    lastSaved = language;
    current = language;
    return (failure: null, data: null);
  }
}

ProviderContainer _container(_FakeRepo repo) {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      loadLanguageSettingsUseCaseProvider.overrideWith(
        (ref) async => LoadLanguageSettingsUseCase(repository: repo),
      ),
      updateLanguageSettingsUseCaseProvider.overrideWith(
        (ref) async => UpdateLanguageSettingsUseCase(repository: repo),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('AppLanguage', () {
    test('fromStorage parses known values, falls back to system', () {
      expect(AppLanguage.fromStorage('en'), AppLanguage.english);
      expect(AppLanguage.fromStorage('vi'), AppLanguage.vietnamese);
      expect(AppLanguage.fromStorage('system'), AppLanguage.system);
      expect(AppLanguage.fromStorage(null), AppLanguage.system);
      expect(AppLanguage.fromStorage('bogus'), AppLanguage.system);
    });

    test('locale maps system→null and en/vi→Locale', () {
      expect(AppLanguage.system.locale, isNull);
      expect(AppLanguage.english.locale, const Locale('en'));
      expect(AppLanguage.vietnamese.locale, const Locale('vi'));
    });
  });

  group('LanguageController', () {
    test('loads the persisted language', () async {
      final _FakeRepo repo = _FakeRepo(AppLanguage.vietnamese);
      final ProviderContainer container = _container(repo);
      final AppLanguage language = await container.read(
        languageControllerProvider.future,
      );
      expect(language, AppLanguage.vietnamese);
    });

    test('setLanguage persists the chosen language', () async {
      final _FakeRepo repo = _FakeRepo(AppLanguage.system);
      final ProviderContainer container = _container(repo);
      await container.read(languageControllerProvider.future);

      await container
          .read(languageControllerProvider.notifier)
          .setLanguage(AppLanguage.vietnamese);

      expect(repo.lastSaved, AppLanguage.vietnamese);
      expect(
        container.read(languageControllerProvider).requireValue,
        AppLanguage.vietnamese,
      );
    });

    test('setLanguage to the current language is a no-op', () async {
      final _FakeRepo repo = _FakeRepo(AppLanguage.english);
      final ProviderContainer container = _container(repo);
      await container.read(languageControllerProvider.future);

      await container
          .read(languageControllerProvider.notifier)
          .setLanguage(AppLanguage.english);

      expect(repo.lastSaved, isNull);
    });

    test('a save failure reverts the optimistic change', () async {
      final _FakeRepo repo = _FakeRepo(AppLanguage.system)..failSave = true;
      final ProviderContainer container = _container(repo);
      await container.read(languageControllerProvider.future);

      await container
          .read(languageControllerProvider.notifier)
          .setLanguage(AppLanguage.vietnamese);

      expect(
        container.read(languageControllerProvider).requireValue,
        AppLanguage.system, // reverted
      );
    });
  });
}
