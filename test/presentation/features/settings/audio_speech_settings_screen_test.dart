import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/screens/audio_speech_settings_screen.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';

Widget _appShell(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

Future<void> _pumpScreen(
  WidgetTester tester, {
  AudioSpeechSettingsState state = AudioSpeechSettingsState.loaded,
}) async {
  await tester.pumpWidget(_appShell(AudioSpeechSettingsScreen(state: state)));
  await tester.pump();
}

void main() {
  testWidgets('renders the Korean gallery state', (tester) async {
    await _pumpScreen(tester);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(AudioSpeechSettingsScreen)),
    );

    expect(
      find.text(
        StringUtils.uppercased(l10n.settingsAudioSpeechGeneralSectionTitle),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        StringUtils.uppercased(l10n.settingsAudioSpeechLanguageSectionTitle),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        StringUtils.uppercased(
          l10n.settingsAudioSpeechVoiceSectionTitle(
            l10n.settingsAudioSpeechKoreanLanguageLabel,
          ),
        ),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsAudioSpeechDefaultVoiceBadge), findsNWidgets(2));

    await tester.scrollUntilVisible(
      find.text(l10n.settingsAudioSpeechChangesSavedText),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text(l10n.settingsAudioSpeechKoreanSampleText), findsOneWidget);
    expect(
      find.text(l10n.settingsAudioSpeechKoreanSampleHint),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsAudioSpeechPreviewVoiceLabel), findsOneWidget);
    expect(
      find.text(l10n.settingsAudioSpeechSupportedLanguagesBody),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsAudioSpeechChangesSavedText), findsOneWidget);
  });

  testWidgets('renders the English gallery state', (tester) async {
    await _pumpScreen(tester, state: AudioSpeechSettingsState.english);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(AudioSpeechSettingsScreen)),
    );

    expect(find.text(l10n.settingsAudioSpeechEnglishTabLabel), findsOneWidget);
    expect(find.text(l10n.settingsAudioSpeechKoreanSampleHint), findsNothing);
    expect(
      find.text(
        StringUtils.uppercased(
          l10n.settingsAudioSpeechVoiceSectionTitle(
            l10n.settingsAudioSpeechEnglishLanguageLabel,
          ),
        ),
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text(l10n.settingsAudioSpeechChangesSavedText),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text(l10n.settingsAudioSpeechEnglishSampleText), findsOneWidget);
    expect(find.text(l10n.settingsAudioSpeechChangesSavedText), findsOneWidget);
  });

  testWidgets('renders loading skeletons for the voice card', (tester) async {
    await _pumpScreen(tester, state: AudioSpeechSettingsState.loading);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(AudioSpeechSettingsScreen)),
    );

    expect(find.byType(MxSkeleton), findsWidgets);
    expect(find.text(l10n.settingsAudioSpeechPreviewSectionTitle), findsNothing);
  });

  testWidgets('renders the empty voices card', (tester) async {
    await _pumpScreen(tester, state: AudioSpeechSettingsState.empty);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(AudioSpeechSettingsScreen)),
    );

    expect(
      find.text(l10n.settingsAudioSpeechNoVoicesTitle(
        l10n.settingsAudioSpeechKoreanLanguageLabel,
      )),
      findsOneWidget,
    );
    expect(
      find.text(l10n.settingsAudioSpeechNoVoicesBody(
        l10n.settingsAudioSpeechKoreanLanguageLabel,
      )),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsAudioSpeechOpenSystemSpeech), findsOneWidget);
  });

  testWidgets('renders the engine error banner', (tester) async {
    await _pumpScreen(tester, state: AudioSpeechSettingsState.engineErr);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(AudioSpeechSettingsScreen)),
    );

    expect(
      find.text(l10n.settingsAudioSpeechEngineUnavailableTitle),
      findsOneWidget,
    );
    expect(
      find.text(l10n.settingsAudioSpeechEngineUnavailableBody),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsAudioSpeechOpenSystemSettings), findsOneWidget);
  });

  testWidgets('renders the playing preview state', (tester) async {
    await _pumpScreen(tester, state: AudioSpeechSettingsState.playing);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(AudioSpeechSettingsScreen)),
    );

    await tester.scrollUntilVisible(
      find.text(l10n.settingsAudioSpeechChangesSavedText),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text(l10n.settingsAudioSpeechPlayingLabel), findsOneWidget);
    expect(find.text(l10n.settingsAudioSpeechPreviewVoiceLabel), findsNothing);
  });

  testWidgets('renders the saved chip in the app bar', (tester) async {
    await _pumpScreen(tester, state: AudioSpeechSettingsState.saving);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(AudioSpeechSettingsScreen)),
    );

    expect(find.text(l10n.settingsAudioSpeechSaved), findsOneWidget);
  });
}
