import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/preferences/learning_settings_store.dart';
import 'package:memox/data/repositories/learning_settings_repository_impl.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // WBS 8.2.1. SharedPreferences persistence contract:
  // docs/contracts/repository-contracts/learning-settings-repository.md.
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LearningSettingsRepositoryImpl> repoWith(
    Map<String, Object> initial,
  ) async {
    SharedPreferences.setMockInitialValues(initial);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return LearningSettingsRepositoryImpl(store: LearningSettingsStore(prefs));
  }

  test('load returns defaults when no keys are persisted', () async {
    final repo = await repoWith(<String, Object>{});

    final result = await repo.load();

    expect(result.isSuccess, isTrue);
    expect(result.data!.dailyNewLimit, LearningSettings.defaultDailyNewLimit);
    expect(result.data!.goalDisabledSince, isNull);
  });

  test('load returns a valid persisted dailyNewLimit', () async {
    final repo = await repoWith(<String, Object>{
      LearningSettingsStore.dailyNewLimitKey: 35,
    });

    final result = await repo.load();

    expect(result.data!.dailyNewLimit, 35);
  });

  test(
    'load recovers a corrupt/invalid dailyNewLimit to the default',
    () async {
      // 7 is off-step, 999 is out of range, and a string is the wrong type.
      for (final Object bad in <Object>[7, 999, 'oops']) {
        final repo = await repoWith(<String, Object>{
          LearningSettingsStore.dailyNewLimitKey: bad,
        });

        final result = await repo.load();

        expect(
          result.data!.dailyNewLimit,
          LearningSettings.defaultDailyNewLimit,
        );
      }
    },
  );

  test(
    'save then load round-trips goalDisabledSince as a local date',
    () async {
      final repo = await repoWith(<String, Object>{});

      final saved = await repo.save(
        LearningSettings(
          dailyNewLimit: 15,
          goalDisabledSince: DateTime(2026, 6, 20),
        ),
      );
      expect(saved.isSuccess, isTrue);

      final result = await repo.load();
      expect(result.data!.dailyNewLimit, 15);
      expect(result.data!.goalDisabledSince, DateTime(2026, 6, 20));
    },
  );

  test('saving a null goalDisabledSince clears the persisted value', () async {
    final repo = await repoWith(<String, Object>{
      LearningSettingsStore.goalDisabledSinceKey: '2026-01-01',
    });

    await repo.save(const LearningSettings());

    final result = await repo.load();
    expect(result.data!.goalDisabledSince, isNull);
  });

  test('load treats a corrupt goalDisabledSince string as null', () async {
    // Unparseable, impossible calendar day (Feb 30 would silently roll over),
    // and out-of-range month all recover to null.
    for (final String bad in <String>[
      'not-a-date',
      '2026-02-30',
      '2026-13-01',
    ]) {
      final repo = await repoWith(<String, Object>{
        LearningSettingsStore.goalDisabledSinceKey: bad,
      });

      final result = await repo.load();

      expect(result.data!.goalDisabledSince, isNull, reason: bad);
    }
  });
}
