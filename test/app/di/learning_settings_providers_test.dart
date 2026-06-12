// ignore_for_file: depend_on_referenced_packages -- reason: test-only SharedPreferencesAsync platform helpers live in the transitive platform_interface package.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/learning_settings_providers.dart';
import 'package:memox/data/repositories/learning_settings_repository_impl.dart';
import 'package:memox/domain/usecases/learning_settings_usecases.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late SharedPreferencesAsyncPlatform? previousPlatform;

  setUp(() {
    previousPlatform = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = previousPlatform;
  });

  test('creates the learning-settings providers', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(learningSettingsRepositoryProvider),
      isA<LearningSettingsRepositoryImpl>(),
    );
    expect(
      container.read(loadLearningSettingsUseCaseProvider),
      isA<LoadLearningSettingsUseCase>(),
    );
    expect(
      container.read(updateLearningSettingsUseCaseProvider),
      isA<UpdateLearningSettingsUseCase>(),
    );
  });
}
