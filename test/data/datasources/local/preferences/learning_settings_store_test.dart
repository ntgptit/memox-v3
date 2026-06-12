// ignore_for_file: depend_on_referenced_packages -- reason: test-only SharedPreferencesAsync platform helpers live in the transitive platform_interface package.

import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/preferences/learning_settings_store.dart';
import 'package:memox/domain/models/learning_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late SharedPreferencesAsyncPlatform? previousPlatform;

  setUp(() {
    previousPlatform = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = previousPlatform;
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
