import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/preferences/learning_settings_store.dart';
import 'package:memox/data/repositories/learning_settings_repository_impl.dart';
import 'package:memox/domain/models/learning_settings.dart';

class _FakeLearningSettingsStore implements LearningSettingsStore {
  _FakeLearningSettingsStore({LearningSettings? initial})
    : settings = initial ?? LearningSettings.defaults;

  LearningSettings settings;
  Exception? loadError;
  Exception? saveError;

  @override
  Future<LearningSettings> load() async {
    if (loadError != null) {
      throw loadError!;
    }
    return settings;
  }

  @override
  Future<void> save(LearningSettings value) async {
    if (saveError != null) {
      throw saveError!;
    }
    settings = value;
  }
}

void main() {
  test('load returns stored settings', () async {
    final _FakeLearningSettingsStore store = _FakeLearningSettingsStore(
      initial: const LearningSettings(
        dailyNewLimit: 35,
        goalDisabledSince: null,
      ),
    );
    final LearningSettingsRepositoryImpl repository =
        LearningSettingsRepositoryImpl(store);

    final Result<LearningSettings> result = await repository.load();

    expect(result, isA<Ok<LearningSettings>>());
    expect((result as Ok<LearningSettings>).value.dailyNewLimit, 35);
  });

  test('save persists settings through the store', () async {
    final _FakeLearningSettingsStore store = _FakeLearningSettingsStore();
    final LearningSettingsRepositoryImpl repository =
        LearningSettingsRepositoryImpl(store);
    final LearningSettings settings = LearningSettings(
      dailyNewLimit: 40,
      goalDisabledSince: DateTime(2026, 6, 12),
    );

    final Result<void> result = await repository.save(settings);

    expect(result, isA<Ok<void>>());
    expect(store.settings.dailyNewLimit, 40);
    expect(store.settings.goalDisabledSince, isNotNull);
  });

  test('load maps store failure to StorageFailure', () async {
    final _FakeLearningSettingsStore store = _FakeLearningSettingsStore()
      ..loadError = Exception('boom');
    final LearningSettingsRepositoryImpl repository =
        LearningSettingsRepositoryImpl(store);

    final Result<LearningSettings> result = await repository.load();

    expect(result, isA<Err<LearningSettings>>());
    expect((result as Err<LearningSettings>).failure, isA<StorageFailure>());
  });

  test('save maps store failure to StorageFailure', () async {
    final _FakeLearningSettingsStore store = _FakeLearningSettingsStore()
      ..saveError = Exception('boom');
    final LearningSettingsRepositoryImpl repository =
        LearningSettingsRepositoryImpl(store);

    final Result<void> result = await repository.save(
      LearningSettings.defaults,
    );

    expect(result, isA<Err<void>>());
    expect((result as Err<void>).failure, isA<StorageFailure>());
  });
}
