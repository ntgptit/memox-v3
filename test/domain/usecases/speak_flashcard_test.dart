import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/domain/usecases/tts_usecases.dart';

class _FakeTtsService implements TtsService {
  String? lastSpokenText;
  String? lastLanguageCode;
  bool stopped = false;

  @override
  Stream<TtsState> get stateStream => const Stream<TtsState>.empty();

  @override
  TtsState get currentState => TtsState.idle;

  @override
  Future<List<TtsVoice>> availableVoices(String lang) async =>
      <TtsVoice>[];

  @override
  void dispose() {}

  @override
  Future<void> speak(
    String text, {
    required String languageCode,
    String? voiceName,
    required double rate,
    required double pitch,
    required double volume,
  }) async {
    lastSpokenText = text;
    lastLanguageCode = languageCode;
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }
}

class _FakeTtsSettingsRepository implements TtsSettingsRepository {
  @override
  Future<Result<TtsSettings>> load() async =>
      Result<TtsSettings>.ok(TtsSettings.defaults);

  @override
  Future<Result<void>> save(TtsSettings s) async =>
      const Result<void>.ok(null);
}

void main() {
  late _FakeTtsService ttsService;
  late SpeakFlashcardUseCase useCase;

  setUp(() {
    ttsService = _FakeTtsService();
    useCase = SpeakFlashcardUseCase(ttsService, _FakeTtsSettingsRepository());
  });

  group('SpeakFlashcardUseCase', () {
    test('T6: front text is spoken for Korean target language', () async {
      final Result<void> result = await useCase.speakFlashcardFront(
        frontText: '한국어',
        targetLanguage: TargetLanguage.korean,
      );
      expect(result.isOk, true);
      expect(ttsService.lastSpokenText, '한국어');
      expect(ttsService.lastLanguageCode, 'ko-KR');
    });

    test('T6b: front text is spoken for English target language', () async {
      final Result<void> result = await useCase.speakFlashcardFront(
        frontText: 'Hello',
        targetLanguage: TargetLanguage.english,
      );
      expect(result.isOk, true);
      expect(ttsService.lastSpokenText, 'Hello');
      expect(ttsService.lastLanguageCode, 'en-US');
    });

    test('T7: unsupported target language → no engine call (silent ok)', () async {
      final Result<void> result = await useCase.speakFlashcardFront(
        frontText: 'back content',
        targetLanguage: TargetLanguage.unsupported,
      );
      expect(result.isOk, true);
      expect(ttsService.lastSpokenText, isNull);
    });

    test('T8: blank text → no engine call (silent ok)', () async {
      final Result<void> result = await useCase.speakFlashcardFront(
        frontText: '   ',
        targetLanguage: TargetLanguage.korean,
      );
      expect(result.isOk, true);
      expect(ttsService.lastSpokenText, isNull);
    });

    test('T8b: empty text → no engine call (silent ok)', () async {
      final Result<void> result = await useCase.speakFlashcardFront(
        frontText: '',
        targetLanguage: TargetLanguage.korean,
      );
      expect(result.isOk, true);
      expect(ttsService.lastSpokenText, isNull);
    });

    test('speakText: blank text → no engine call', () async {
      final Result<void> result = await useCase.speakText(
        text: '',
        lang: TtsSettings.defaults.frontLanguage,
      );
      expect(result.isOk, true);
      expect(ttsService.lastSpokenText, isNull);
    });
  });
}
