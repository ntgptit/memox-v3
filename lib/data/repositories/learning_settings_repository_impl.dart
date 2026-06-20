import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/preferences/learning_settings_store.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';

/// SharedPreferences-backed [LearningSettingsRepository].
///
/// Persistence only: applies defaults for missing keys, recovers a corrupt
/// `dailyNewLimit` to [LearningSettings.defaultDailyNewLimit], and serializes
/// `goalDisabledSince` to/from a local `YYYY-MM-DD` string. Range/step
/// validation stays in `UpdateLearningSettingsUseCase`.
class LearningSettingsRepositoryImpl implements LearningSettingsRepository {
  LearningSettingsRepositoryImpl({required LearningSettingsStore store})
    : _store = store;

  final LearningSettingsStore _store;

  @override
  Future<Result<LearningSettings>> load() async {
    try {
      final int? storedLimit = _store.readDailyNewLimit();
      final int dailyNewLimit =
          storedLimit != null &&
              LearningSettings.isValidDailyNewLimit(storedLimit)
          ? storedLimit
          : LearningSettings.defaultDailyNewLimit;

      final DateTime? goalDisabledSince = _parseLocalDate(
        _store.readGoalDisabledSince(),
      );

      return (
        failure: null,
        data: LearningSettings(
          dailyNewLimit: dailyNewLimit,
          goalDisabledSince: goalDisabledSince,
        ),
      );
    } catch (error) {
      return (failure: _storage(StorageOp.read, error), data: null);
    }
  }

  @override
  Future<Result<void>> save(LearningSettings settings) async {
    try {
      await _store.writeDailyNewLimit(settings.dailyNewLimit);
      final DateTime? since = settings.goalDisabledSince;
      await (since == null
          ? _store.clearGoalDisabledSince()
          : _store.writeGoalDisabledSince(_formatLocalDate(since)));
      return (failure: null, data: null);
    } catch (error) {
      return (failure: _storage(StorageOp.write, error), data: null);
    }
  }

  /// Parse a stored `YYYY-MM-DD` string into a local-midnight [DateTime].
  /// Returns `null` for a missing or unparseable (corrupt) value.
  DateTime? _parseLocalDate(String? raw) {
    if (raw == null) return null;
    final List<String> parts = raw.split('-');
    if (parts.length != 3) return null;
    final int? year = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final DateTime date = DateTime(year, month, day);
    // DateTime() silently rolls over impossible days (e.g. 2026-02-30 →
    // 2026-03-02); reject those as corrupt by round-tripping the components.
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  /// Format a [DateTime] as a local `YYYY-MM-DD` string (time stripped).
  String _formatLocalDate(DateTime date) {
    final String mm = date.month.toString().padLeft(2, '0');
    final String dd = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$mm-$dd';
  }

  Failure _storage(StorageOp op, Object error) => Failure.storage(
    operation: op,
    table: 'learning_settings',
    cause: error.toString(),
  );
}
