import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/preferences/appearance_settings_store.dart';
import 'package:memox/domain/repositories/appearance_settings_repository.dart';
import 'package:memox/domain/types/app_theme_mode.dart';

/// SharedPreferences-backed [AppearanceSettingsRepository].
///
/// Persistence only: a missing or unrecognized key recovers to
/// [AppThemeMode.system] (via [AppThemeMode.fromStorage]).
class AppearanceSettingsRepositoryImpl implements AppearanceSettingsRepository {
  AppearanceSettingsRepositoryImpl({required AppearanceSettingsStore store})
    : _store = store;

  final AppearanceSettingsStore _store;

  @override
  Future<Result<AppThemeMode>> load() async {
    try {
      return (
        failure: null,
        data: AppThemeMode.fromStorage(_store.readThemeMode()),
      );
    } catch (error) {
      return (failure: _storage(StorageOp.read, error), data: null);
    }
  }

  @override
  Future<Result<void>> save(AppThemeMode mode) async {
    try {
      await _store.writeThemeMode(mode.storageValue);
      return (failure: null, data: null);
    } catch (error) {
      return (failure: _storage(StorageOp.write, error), data: null);
    }
  }

  Failure _storage(StorageOp op, Object error) => Failure.storage(
    operation: op,
    table: 'appearance_settings',
    cause: error.toString(),
  );
}
