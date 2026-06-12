import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/preferences/learning_settings_store.dart';
import 'package:memox/domain/models/learning_settings.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';

/// SharedPreferences-backed [LearningSettingsRepository].
class LearningSettingsRepositoryImpl implements LearningSettingsRepository {
  LearningSettingsRepositoryImpl(this._store);

  final LearningSettingsStore _store;

  @override
  Future<Result<LearningSettings>> load() async {
    try {
      return Result<LearningSettings>.ok(await _store.load());
    } catch (error) {
      return Result<LearningSettings>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'shared_preferences',
        ),
      );
    }
  }

  @override
  Future<Result<void>> save(LearningSettings settings) async {
    try {
      await _store.save(settings);
      return const Result<void>.ok(null);
    } catch (error) {
      return Result<void>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'shared_preferences',
        ),
      );
    }
  }
}
