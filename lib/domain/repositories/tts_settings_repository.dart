import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/tts_settings.dart';

abstract interface class TtsSettingsRepository {
  Future<Result<TtsSettings>> load();
  Future<Result<void>> save(TtsSettings settings);
}
