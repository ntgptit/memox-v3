import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/preferences/learning_settings_store.dart';
import 'package:memox/domain/models/learning_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('fresh storage returns defaults', () async {
    final SharedPreferencesLearningSettingsStore store =
        SharedPreferencesLearningSettingsStore(SharedPreferencesAsync());

    final LearningSettings settings = await store.load();

    expect(settings, LearningSettings.defaults);
  });

  test('save round-trips dailyNewLimit and goalDisabledSince', () async {
    final SharedPreferencesLearningSettingsStore store =
        SharedPreferencesLearningSettingsStore(SharedPreferencesAsync());
    final DateTime disabledSince = DateTime(2026, 6, 12, 15, 30);

    await store.save(
      LearningSettings(
        dailyNewLimit: 35,
        goalDisabledSince: DateTime(2026, 6, 12),
      ),
    );

    final LearningSettings loaded = await store.load();

    expect(loaded.dailyNewLimit, 35);
    expect(loaded.goalDisabledSince, isNotNull);
    expect(
      loaded.goalDisabledSince,
      DateTime(disabledSince.year, disabledSince.month, disabledSince.day),
    );
  });

  test('null goalDisabledSince persists and loads as null', () async {
    final SharedPreferencesLearningSettingsStore store =
        SharedPreferencesLearningSettingsStore(SharedPreferencesAsync());

    await store.save(
      const LearningSettings(dailyNewLimit: 25, goalDisabledSince: null),
    );

    final LearningSettings loaded = await store.load();

    expect(loaded.dailyNewLimit, 25);
    expect(loaded.goalDisabledSince, isNull);
  });

  test('invalid dailyNewLimit recovers to default', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'learning.dailyNewLimit': 999,
    });
    final SharedPreferencesLearningSettingsStore store =
        SharedPreferencesLearningSettingsStore(SharedPreferencesAsync());

    final LearningSettings loaded = await store.load();

    expect(loaded.dailyNewLimit, LearningSettings.defaultDailyNewLimit);
    expect(loaded.goalDisabledSince, isNull);
  });
}
