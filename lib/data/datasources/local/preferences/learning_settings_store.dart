import 'package:shared_preferences/shared_preferences.dart';

/// Thin SharedPreferences accessor for the learning-settings keys. Reads/writes
/// raw scalar values only — defaults, corrupt recovery, and date
/// serialization live in `LearningSettingsRepositoryImpl`, validation in the use
/// case (`docs/database/storage-boundaries.md`).
class LearningSettingsStore {
  LearningSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  /// Persisted SharedPreferences keys, per
  /// `docs/database/storage-boundaries.md` §Learning settings.
  static const String dailyNewLimitKey = 'learning.dailyNewLimit';
  static const String goalDisabledSinceKey = 'learning.goalDisabledSince';

  /// Raw stored daily new-card limit, or `null` when unset. Reading a value
  /// stored under the wrong type returns `null` (treated as missing/corrupt by
  /// the repository) instead of throwing.
  int? readDailyNewLimit() {
    final Object? value = _prefs.get(dailyNewLimitKey);
    return value is int ? value : null;
  }

  Future<void> writeDailyNewLimit(int value) =>
      _prefs.setInt(dailyNewLimitKey, value);

  /// Raw stored `YYYY-MM-DD` goal-disabled date, or `null` when unset/cleared.
  String? readGoalDisabledSince() {
    final Object? value = _prefs.get(goalDisabledSinceKey);
    return value is String ? value : null;
  }

  Future<void> writeGoalDisabledSince(String value) =>
      _prefs.setString(goalDisabledSinceKey, value);

  Future<void> clearGoalDisabledSince() => _prefs.remove(goalDisabledSinceKey);
}
