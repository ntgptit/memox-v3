/// Represents a TTS voice available on the current platform.
/// See `docs/business/tts/tts-settings.md` §Voice selection.
class TtsVoice {
  const TtsVoice({
    required this.name,
    required this.displayName,
    required this.lang,
  });

  /// Platform identifier used when calling the TTS engine.
  final String name;

  /// Human-readable label for UI.
  final String displayName;

  /// BCP-47 locale tag, e.g. 'ko-KR'.
  final String lang;

  /// Sentinel that means "let the engine pick the voice".
  static const TtsVoice systemDefault = TtsVoice(
    name: '',
    displayName: 'System default',
    lang: '',
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtsVoice &&
          other.name == name &&
          other.displayName == displayName &&
          other.lang == lang;

  @override
  int get hashCode => Object.hash(name, displayName, lang);

  @override
  String toString() =>
      'TtsVoice(name: $name, displayName: $displayName, lang: $lang)';
}
