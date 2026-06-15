import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/types/tts_language_code.dart';

/// Persisted TTS playback settings (single-row, id = 'default').
/// See `docs/business/tts/tts-settings.md`.
class TtsSettings {
  const TtsSettings({
    required this.autoPlay,
    required this.frontLanguage,
    required this.rate,
    required this.pitch,
    required this.volume,
    this.frontVoiceName,
  });

  // ── Range constants ──────────────────────────────────────────────────────
  static const double minRate = 0.3;
  static const double maxRate = 0.7;
  static const double defaultRate = 0.5;

  static const double minPitch = 0.7;
  static const double maxPitch = 1.5;
  static const double defaultPitch = 1.0;

  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  static const double defaultVolume = 1.0;

  static const TtsSettings defaults = TtsSettings(
    autoPlay: false,
    frontLanguage: TtsLanguageCode.koKR,
    rate: defaultRate,
    pitch: defaultPitch,
    volume: defaultVolume,
  );

  // ── Fields ───────────────────────────────────────────────────────────────
  final bool autoPlay;
  final TtsLanguageCode frontLanguage;
  final double rate;
  final double pitch;
  final double volume;
  final String? frontVoiceName;

  // ── Normalization (clamp only — no validation failure) ───────────────────
  static double normalizeRate(double value) => value.clamp(minRate, maxRate);
  static double normalizePitch(double value) => value.clamp(minPitch, maxPitch);
  static double normalizeVolume(double value) =>
      value.clamp(minVolume, maxVolume);

  // ── Semantic mutators ────────────────────────────────────────────────────

  /// Returns a copy with [lang] and clears [frontVoiceName] (voice is
  /// engine-specific; changing language invalidates the stored voice).
  TtsSettings withLanguage(TtsLanguageCode lang) => TtsSettings(
    autoPlay: autoPlay,
    frontLanguage: lang,
    rate: rate,
    pitch: pitch,
    volume: volume,
    frontVoiceName: null,
  );

  /// Returns a copy with [voiceName] trimmed; empty string is stored as null.
  TtsSettings withVoice(String? voiceName) {
    final String? trimmed =
        voiceName != null ? StringUtils.trimmed(voiceName) : null;
    return TtsSettings(
      autoPlay: autoPlay,
      frontLanguage: frontLanguage,
      rate: rate,
      pitch: pitch,
      volume: volume,
      frontVoiceName: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    );
  }

  // ── copyWith ─────────────────────────────────────────────────────────────
  static const Object _sentinel = Object();

  TtsSettings copyWith({
    bool? autoPlay,
    TtsLanguageCode? frontLanguage,
    double? rate,
    double? pitch,
    double? volume,
    Object? frontVoiceName = _sentinel,
  }) => TtsSettings(
    autoPlay: autoPlay ?? this.autoPlay,
    frontLanguage: frontLanguage ?? this.frontLanguage,
    rate: rate ?? this.rate,
    pitch: pitch ?? this.pitch,
    volume: volume ?? this.volume,
    frontVoiceName: identical(frontVoiceName, _sentinel)
        ? this.frontVoiceName
        : frontVoiceName as String?,
  );

  // ── Equality ─────────────────────────────────────────────────────────────
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtsSettings &&
          other.autoPlay == autoPlay &&
          other.frontLanguage == frontLanguage &&
          other.rate == rate &&
          other.pitch == pitch &&
          other.volume == volume &&
          other.frontVoiceName == frontVoiceName;

  @override
  int get hashCode =>
      Object.hash(autoPlay, frontLanguage, rate, pitch, volume, frontVoiceName);

  @override
  String toString() => 'TtsSettings('
      'autoPlay: $autoPlay, '
      'frontLanguage: $frontLanguage, '
      'rate: $rate, '
      'pitch: $pitch, '
      'volume: $volume, '
      'frontVoiceName: $frontVoiceName)';
}
