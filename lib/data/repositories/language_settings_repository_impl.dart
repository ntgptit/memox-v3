import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/preferences/language_settings_store.dart';
import 'package:memox/domain/repositories/language_settings_repository.dart';
import 'package:memox/domain/types/app_language.dart';

/// SharedPreferences-backed [LanguageSettingsRepository].
///
/// Persistence only: a missing or unrecognized key recovers to
/// [AppLanguage.system] (via [AppLanguage.fromStorage]).
class LanguageSettingsRepositoryImpl implements LanguageSettingsRepository {
  LanguageSettingsRepositoryImpl({required LanguageSettingsStore store})
    : _store = store;

  final LanguageSettingsStore _store;

  @override
  Future<Result<AppLanguage>> load() async {
    try {
      return (
        failure: null,
        data: AppLanguage.fromStorage(_store.readAppLanguage()),
      );
    } catch (error) {
      return (failure: _storage(StorageOp.read, error), data: null);
    }
  }

  @override
  Future<Result<void>> save(AppLanguage language) async {
    try {
      await _store.writeAppLanguage(language.storageValue);
      return (failure: null, data: null);
    } catch (error) {
      return (failure: _storage(StorageOp.write, error), data: null);
    }
  }

  Failure _storage(StorageOp op, Object error) => Failure.storage(
    operation: op,
    table: 'language_settings',
    cause: error.toString(),
  );
}
