import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/tts_settings.dart';

/// Port for persisting the single global [TtsSettings] row (kit screen 23,
/// `tts_settings` id `'default'`). Persistence only — slider normalization is
/// applied on both load and save (`docs/business/tts/tts-settings.md`). See
/// `docs/contracts/repository-contracts/tts-settings-repository.md`.
abstract interface class TtsSettingsRepository {
  /// Load the persisted settings, applying defaults when the row is missing and
  /// clamping (self-healing) any out-of-range slider value.
  ///
  /// Fails with [StorageFailure] on a read error.
  Future<Result<TtsSettings>> load();

  /// Persist [settings] (sliders clamped before write).
  ///
  /// Fails with [StorageFailure] on a write error.
  Future<Result<void>> save(TtsSettings settings);
}
