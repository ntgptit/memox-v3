import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/types/tts_front_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/tts_audio_controller.dart';
import 'package:memox/presentation/features/settings/controllers/tts_audio_view.dart';
import 'package:memox/presentation/features/settings/screens/audio_speech_settings_screen.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_slider.dart';

import '../../../support/golden_harness.dart';

class _FakeController extends TtsAudioController {
  _FakeController(this._view, {this.fail = false});
  final TtsAudioView _view;
  final bool fail;
  @override
  Future<TtsAudioView> build() async {
    if (fail) {
      throw Exception('engine');
    }
    return _view;
  }
}

const List<TtsVoice> _voices = <TtsVoice>[
  TtsVoice(name: 'Yuna', localeTag: 'ko-KR'),
  TtsVoice(name: 'Minho', localeTag: 'ko-KR'),
];

TtsAudioView _loaded(
  TtsFrontLanguage lang, {
  bool playing = false,
  bool saving = false,
}) => TtsAudioView(
  settings: TtsSettings(frontLanguage: lang, frontVoiceName: 'Yuna'),
  voices: _voices,
  isPlaying: playing,
  isSaving: saving,
);

TtsAudioView _noVoices() =>
    const TtsAudioView(settings: TtsSettings(), voices: <TtsVoice>[]);

Future<void> _pump(
  WidgetTester tester, {
  required TtsAudioView view,
  bool fail = false,
  Brightness brightness = Brightness.light,
  bool golden = false,
}) async {
  if (golden) {
    tester.view.physicalSize = kGoldenSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ttsAudioControllerProvider.overrideWith(
          () => _FakeController(view, fail: fail),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AudioSpeechSettingsScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  group('AudioSpeechSettingsScreen states', () {
    testWidgets('loaded shows language, voices, preview, sliders', (
      tester,
    ) async {
      await _pump(tester, view: _loaded(TtsFrontLanguage.korean));
      expect(find.text('Voice language'), findsOneWidget);
      expect(find.text('Korean'), findsOneWidget);
      expect(find.text('System default'), findsOneWidget);
      expect(find.text('Yuna'), findsOneWidget);
      expect(find.text('Play sample'), findsOneWidget);
      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('Pitch'), findsOneWidget);
      expect(find.byType(MxSlider), findsNWidgets(2));
    });

    testWidgets('playing shows the Stop button', (tester) async {
      await _pump(
        tester,
        view: _loaded(TtsFrontLanguage.korean, playing: true),
      );
      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Play sample'), findsNothing);
    });

    testWidgets('no voices shows the empty hero', (tester) async {
      await _pump(tester, view: _noVoices());
      expect(find.text('No voices installed'), findsOneWidget);
    });

    testWidgets('engine error shows the error hero', (tester) async {
      await _pump(tester, view: _noVoices(), fail: true);
      await tester.pumpAndSettle();
      expect(find.text('Speech engine unavailable'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('AudioSpeechSettingsScreen goldens', () {
    final Map<String, ({TtsAudioView view, bool fail})> cases =
        <String, ({TtsAudioView view, bool fail})>{
          'korean': (view: _loaded(TtsFrontLanguage.korean), fail: false),
          'english': (view: _loaded(TtsFrontLanguage.english), fail: false),
          'playing': (
            view: _loaded(TtsFrontLanguage.korean, playing: true),
            fail: false,
          ),
          'saving': (
            view: _loaded(TtsFrontLanguage.korean, saving: true),
            fail: false,
          ),
          'no-voices': (view: _noVoices(), fail: false),
          'engine-error': (view: _noVoices(), fail: true),
        };
    for (final MapEntry<String, ({TtsAudioView view, bool fail})> entry
        in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${entry.key} — ${brightness.name}', (tester) async {
          await _pump(
            tester,
            view: entry.value.view,
            fail: entry.value.fail,
            brightness: brightness,
            golden: true,
          );
          if (entry.value.fail) {
            await tester.pump(const Duration(milliseconds: 50));
          }
          await expectLater(
            find.byType(AudioSpeechSettingsScreen),
            matchesGoldenFile(
              'goldens/audio_speech_${entry.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }
  });
}
