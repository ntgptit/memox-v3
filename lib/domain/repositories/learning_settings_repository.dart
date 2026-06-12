import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/learning_settings.dart';

/// Learning settings persistence boundary.
///
/// Implemented over SharedPreferences in the data layer. The repository owns
/// the persistence contract; use cases perform validation and orchestration.
abstract interface class LearningSettingsRepository {
  Future<Result<LearningSettings>> load();

  Future<Result<void>> save(LearningSettings settings);
}
