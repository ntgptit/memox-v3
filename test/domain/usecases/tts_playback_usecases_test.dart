import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/domain/types/tts_language_code.dart';
import 'package:memox/domain/usecases/tts_playback_usecases.dart';
import 'package:memox/domain/usecases/tts_settings_usecases.dart';

/// Records what was asked of the engine; can be told to throw on speak.
class _FakeTtsService implements TtsService {
  bool throwOnSpeak = false;
  int stopCalls = 0;
  TtsSettings? appliedSettings;
  String? spokenText;
  TtsLanguageCode? spokenLanguage;

  @override
  Future<void> init() async {}

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguageCode language) async =>
      <TtsVoice>[];

  @override
  Future<void> applySettings(TtsSettings settings) async {
    appliedSettings = settings;
  }

  @override
  Future<void> speak(String text, {required TtsLanguageCode language}) async {
    if (throwOnSpeak) throw StateError('engine down');
    spokenText = text;
    spokenLanguage = language;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }
}

class _FakeSettingsRepo implements TtsSettingsRepository {
  TtsSettings current = const TtsSettings();

  @override
  Future<Result<TtsSettings>> load() async => (failure: null, data: current);

  @override
  Future<Result<void>> save(TtsSettings settings) async {
    current = settings;
    return (failure: null, data: null);
  }
}

StudySessionReviewItem _item({
  String front = 'こんにちは',
  TargetLanguage language = TargetLanguage.korean,
}) => StudySessionReviewItem(
  sessionItemId: 'i1',
  flashcardId: 'c1',
  front: front,
  back: 'hello',
  sortOrder: 0,
  answeredAt: null,
  targetLanguage: language,
);

void main() {
  late _FakeTtsService engine;
  late _FakeSettingsRepo repo;
  late SpeakFlashcardUseCase speak;

  setUp(() {
    engine = _FakeTtsService();
    repo = _FakeSettingsRepo();
    speak = SpeakFlashcardUseCase(
      ttsService: engine,
      getSettings: GetTtsSettingsUseCase(repository: repo),
    );
  });

  group('SpeakFlashcardUseCase.speakFront', () {
    test('speaks the front in the deck language (korean → ko-KR)', () async {
      final Result<void> result = await speak.speakFront(item: _item());
      expect(result.failure, isNull);
      expect(engine.spokenText, 'こんにちは');
      expect(engine.spokenLanguage, TtsLanguageCode.koKR);
      // Applies settings + stops any prior speech before speaking (no queue).
      expect(engine.appliedSettings, isNotNull);
      expect(engine.stopCalls, 1);
    });

    test('english deck speaks with en-US', () async {
      await speak.speakFront(
        item: _item(front: 'cat', language: TargetLanguage.english),
      );
      expect(engine.spokenLanguage, TtsLanguageCode.enUS);
    });

    test('unsupported deck is a silent no-op (no engine call)', () async {
      final Result<void> result = await speak.speakFront(
        item: _item(language: TargetLanguage.unsupported),
      );
      expect(result.failure, isNull);
      expect(engine.spokenText, isNull);
      expect(engine.stopCalls, 0);
    });

    test('blank front is a silent no-op', () async {
      final Result<void> result = await speak.speakFront(
        item: _item(front: '   '),
      );
      expect(result.failure, isNull);
      expect(engine.spokenText, isNull);
    });

    test(
      'engine failure maps to StorageFailure (logged, no rethrow)',
      () async {
        engine.throwOnSpeak = true;
        final Result<void> result = await speak.speakFront(item: _item());
        expect(result.failure, isA<StorageFailure>());
      },
    );

    test('never speaks the back', () async {
      await speak.speakFront(item: _item(front: 'front-only'));
      expect(engine.spokenText, 'front-only');
      expect(engine.spokenText, isNot('hello'));
    });
  });

  group('SpeakFlashcardUseCase.speakText', () {
    test('blank text is a silent no-op', () async {
      final Result<void> result = await speak.speakText('   ');
      expect(result.failure, isNull);
      expect(engine.spokenText, isNull);
    });

    test('speaks trimmed text in the global front language', () async {
      repo.current = const TtsSettings(); // korean default
      final Result<void> result = await speak.speakText('  hi  ');
      expect(result.failure, isNull);
      expect(engine.spokenText, 'hi');
      expect(engine.spokenLanguage, TtsLanguageCode.koKR);
    });
  });

  group('StopSpeechUseCase', () {
    test('stops the engine', () async {
      final Result<void> result = await StopSpeechUseCase(
        ttsService: engine,
      ).call();
      expect(result.failure, isNull);
      expect(engine.stopCalls, 1);
    });
  });
}
