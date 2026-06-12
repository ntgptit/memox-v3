import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/learning_settings_providers.dart';
import 'package:memox/data/repositories/learning_settings_repository_impl.dart';
import 'package:memox/domain/usecases/learning_settings_usecases.dart';

void main() {
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
