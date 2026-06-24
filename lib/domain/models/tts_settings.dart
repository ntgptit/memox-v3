import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/tts_front_language.dart';

part 'tts_settings.freezed.dart';

/// Global TTS (text-to-speech) settings — the single persisted row (`id =
/// 'default'`) of `tts_settings` (kit screen 23). The first slice (WBS 8.4.1) is
/// one global/front-language setting set; per-language settings are Future.
///
/// `rate`/`pitch`/`volume` are always clamped via [normalizeRate] /
/// [normalizePitch] / [normalizeVolume] on both load and save, so a corrupt
/// stored value self-heals (`docs/business/tts/tts-settings.md` §Normalization).
@freezed
sealed class TtsSettings with _$TtsSettings {
  const factory TtsSettings({
    @Default(false) bool autoPlay,
    @Default(TtsFrontLanguage.korean) TtsFrontLanguage frontLanguage,
    @Default(TtsSettings.defaultRate) double rate,
    @Default(TtsSettings.defaultPitch) double pitch,
    @Default(TtsSettings.defaultVolume) double volume,
    String? frontVoiceName,
  }) = _TtsSettings;
  const TtsSettings._();

  static const double minRate = 0.3;
  static const double maxRate = 0.7;
  static const double defaultRate = 0.5;

  static const double minPitch = 0.7;
  static const double maxPitch = 1.5;
  static const double defaultPitch = 1.0;

  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  static const double defaultVolume = 1.0;

  /// Clamp [value] into `[minRate, maxRate]`.
  static double normalizeRate(double value) => value.clamp(minRate, maxRate);

  /// Clamp [value] into `[minPitch, maxPitch]`.
  static double normalizePitch(double value) => value.clamp(minPitch, maxPitch);

  /// Clamp [value] into `[minVolume, maxVolume]`.
  static double normalizeVolume(double value) =>
      value.clamp(minVolume, maxVolume);

  /// This settings record with all sliders clamped into range (idempotent).
  TtsSettings normalized() => copyWith(
    rate: normalizeRate(rate),
    pitch: normalizePitch(pitch),
    volume: normalizeVolume(volume),
  );

  /// Switch the front language, clearing [frontVoiceName] (the stored voice
  /// belongs to the previous language). freezed `copyWith` cannot null a field,
  /// so this rebuilds the record.
  TtsSettings withFrontLanguage(TtsFrontLanguage language) => TtsSettings(
    autoPlay: autoPlay,
    frontLanguage: language,
    rate: rate,
    pitch: pitch,
    volume: volume,
  );
}
