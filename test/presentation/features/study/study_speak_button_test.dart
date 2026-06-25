import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/domain/types/tts_language_code.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/widgets/study_speak_button.dart';

class _FakeTtsService implements TtsService {
  int stopCalls = 0;
  String? spokenText;

  @override
  Future<void> init() async {}

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguageCode language) async =>
      <TtsVoice>[];

  @override
  Future<void> applySettings(TtsSettings settings) async {}

  @override
  Future<void> speak(String text, {required TtsLanguageCode language}) async {
    spokenText = text;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }
}

class _FakeSettingsRepo implements TtsSettingsRepository {
  _FakeSettingsRepo(this.current);
  TtsSettings current;

  @override
  Future<Result<TtsSettings>> load() async => (failure: null, data: current);

  @override
  Future<Result<void>> save(TtsSettings settings) async {
    current = settings;
    return (failure: null, data: null);
  }
}

StudySessionReviewItem _item({
  TargetLanguage language = TargetLanguage.korean,
}) => StudySessionReviewItem(
  sessionItemId: 'i1',
  flashcardId: 'c1',
  front: '안녕',
  back: 'hi',
  sortOrder: 0,
  answeredAt: null,
  targetLanguage: language,
);

const ValueKey<String> _speakKey = ValueKey<String>(
  'mx-node:study-session/speak',
);

Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  required _FakeTtsService engine,
  required _FakeSettingsRepo repo,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ttsServiceProvider.overrideWithValue(engine),
        ttsSettingsRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: MxTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('StudySpeakButton', () {
    testWidgets('shows for a supported deck and speaks on tap', (tester) async {
      final _FakeTtsService engine = _FakeTtsService();
      final _FakeSettingsRepo repo = _FakeSettingsRepo(const TtsSettings());
      await _pump(
        tester,
        engine: engine,
        repo: repo,
        child: StudySpeakButton(item: _item()),
      );

      expect(find.byKey(_speakKey), findsOneWidget);
      await tester.tap(find.byKey(_speakKey));
      await tester.pump();
      await tester.pump();
      expect(engine.spokenText, '안녕');
    });

    testWidgets('is hidden for an unsupported-language deck', (tester) async {
      final _FakeTtsService engine = _FakeTtsService();
      final _FakeSettingsRepo repo = _FakeSettingsRepo(const TtsSettings());
      await _pump(
        tester,
        engine: engine,
        repo: repo,
        child: StudySpeakButton(
          item: _item(language: TargetLanguage.unsupported),
        ),
      );
      expect(find.byKey(_speakKey), findsNothing);
    });
  });

  group('StudyTtsAutoPlay', () {
    testWidgets('auto-plays the front when autoPlay is on', (tester) async {
      final _FakeTtsService engine = _FakeTtsService();
      final _FakeSettingsRepo repo = _FakeSettingsRepo(
        const TtsSettings(autoPlay: true),
      );
      await _pump(
        tester,
        engine: engine,
        repo: repo,
        child: StudyTtsAutoPlay(item: _item(), child: const SizedBox.shrink()),
      );
      // The microtask trigger speaks the front without any tap.
      await tester.pump();
      await tester.pump();
      expect(engine.spokenText, '안녕');
    });

    testWidgets('does not auto-play when autoPlay is off', (tester) async {
      final _FakeTtsService engine = _FakeTtsService();
      final _FakeSettingsRepo repo = _FakeSettingsRepo(const TtsSettings());
      await _pump(
        tester,
        engine: engine,
        repo: repo,
        child: StudyTtsAutoPlay(item: _item(), child: const SizedBox.shrink()),
      );
      await tester.pump();
      await tester.pump();
      expect(engine.spokenText, isNull);
    });
  });
}
