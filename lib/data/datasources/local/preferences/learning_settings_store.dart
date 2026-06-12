import 'package:memox/domain/models/learning_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage boundary for learning settings.
abstract interface class LearningSettingsStore {
  Future<LearningSettings> load();

  Future<void> save(LearningSettings settings);
}

/// SharedPreferences-backed [LearningSettingsStore].
class SharedPreferencesLearningSettingsStore implements LearningSettingsStore {
  SharedPreferencesLearningSettingsStore(this._prefs);

  static const String _dailyNewLimitKey = 'learning.dailyNewLimit';
  static const String _goalDisabledSinceKey = 'learning.goalDisabledSince';

  final SharedPreferencesAsync _prefs;

  @override
  Future<LearningSettings> load() async {
    final int dailyNewLimit = _normalizeDailyNewLimit(
      await _readInt(_dailyNewLimitKey),
    );
    final DateTime? goalDisabledSince = _decodeGoalDisabledSince(
      await _readString(_goalDisabledSinceKey),
    );

    return LearningSettings(
      dailyNewLimit: dailyNewLimit,
      goalDisabledSince: goalDisabledSince,
    );
  }

  @override
  Future<void> save(LearningSettings settings) async {
    await _prefs.setInt(_dailyNewLimitKey, settings.dailyNewLimit);
    final DateTime? disabledSince = _normalizeLocalDate(
      settings.goalDisabledSince,
    );
    if (disabledSince == null) {
      await _prefs.remove(_goalDisabledSinceKey);
      return;
    }
    await _prefs.setString(
      _goalDisabledSinceKey,
      _encodeLocalDate(disabledSince),
    );
  }

  Future<int?> _readInt(String key) async {
    try {
      return await _prefs.getInt(key);
    } on Object catch (error) {
      if (error is TypeError) {
        return null;
      }
      return null;
    }
  }

  Future<String?> _readString(String key) async {
    try {
      return await _prefs.getString(key);
    } on Object catch (error) {
      if (error is TypeError) {
        return null;
      }
      return null;
    }
  }

  static int _normalizeDailyNewLimit(int? value) {
    if (value == null || !LearningSettings.isValidDailyNewLimit(value)) {
      return LearningSettings.defaultDailyNewLimit;
    }
    return value;
  }

  static DateTime? _decodeGoalDisabledSince(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final List<String> parts = value.split('-');
    if (parts.length != 3) {
      return null;
    }
    final int? year = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
  }

  static DateTime? _normalizeLocalDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    final DateTime local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static String _encodeLocalDate(DateTime value) {
    final DateTime local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
