import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/types/tts_front_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/tts_audio_controller.dart';
import 'package:memox/presentation/features/settings/controllers/tts_audio_view.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_busy_overlay.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_radio.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_slider.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// The Audio & speech body (kit screen 23): renders the TTS view-state — engine
/// error / no-voices / loaded (language + voices + preview + speed/pitch) — with
/// playing + saving overlays.
class AudioSpeechSettingsBody extends ConsumerWidget {
  const AudioSpeechSettingsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<TtsAudioView> async = ref.watch(
      ttsAudioControllerProvider,
    );
    return AppAsyncBuilder<TtsAudioView>(
      value: async,
      loading: (_) => const MxLoadingState(),
      error: (Object error, StackTrace? _) => _Hero(
        icon: Icons.warning_amber_rounded,
        tint: context.mxColors.danger,
        title: l10n.audioEngineErrorTitle,
        message: l10n.audioEngineErrorMessage,
        actionLabel: l10n.commonTryAgain,
        onAction: () => ref.invalidate(ttsAudioControllerProvider),
      ),
      data: (TtsAudioView view) => view.voices.isEmpty
          ? _Hero(
              icon: Icons.voice_over_off_outlined,
              tint: context.mxColors.textSecondary,
              title: l10n.audioNoVoicesTitle,
              message: l10n.audioNoVoicesMessage,
            )
          : _loaded(context, ref, l10n, view),
    );
  }

  Widget _loaded(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    TtsAudioView view,
  ) {
    final MxColors colors = context.mxColors;
    final TtsAudioController controller = ref.read(
      ttsAudioControllerProvider.notifier,
    );
    final TtsFrontLanguage language = view.settings.frontLanguage;
    return Stack(
      children: <Widget>[
        ListView(
          padding: const EdgeInsets.fromLTRB(
            MxSpacing.screen,
            MxSpacing.space4,
            MxSpacing.screen,
            MxSpacing.space6,
          ),
          children: <Widget>[
            _Overline(l10n.audioLanguageOverline),
            const SizedBox(height: MxSpacing.space2),
            MxCard(
              key: const ValueKey<String>(
                'mx-node:23-audio-speech/language-row',
              ),
              padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
              child: MxListTile(
                leading: MxIconTile(
                  color: colors.statusReviewing,
                  icon: Icons.translate_outlined,
                ),
                title: l10n.audioVoiceLanguage,
                onTap: () => _pickLanguage(context, controller, language),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MxText(
                      _languageName(l10n, language),
                      role: MxTextRole.labelLarge,
                    ),
                    const SizedBox(width: MxSpacing.space1),
                    Icon(Icons.chevron_right, color: colors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: MxSpacing.space4),
            _Overline(l10n.audioVoiceOverline),
            const SizedBox(height: MxSpacing.space2),
            _VoiceList(view: view, onSelect: controller.setVoice),
            const SizedBox(height: MxSpacing.space4),
            _PreviewCard(
              sample: _sample(l10n, language),
              isPlaying: view.isPlaying,
              onPlay: () => controller.play(_sample(l10n, language)),
              onStop: controller.stop,
            ),
            const SizedBox(height: MxSpacing.space4),
            _TuningCard(
              settings: view.settings,
              onRate: controller.setRate,
              onPitch: controller.setPitch,
            ),
          ],
        ),
        if (view.isSaving) ...<Widget>[
          Positioned.fill(child: ColoredBox(color: colors.overlay)),
          Positioned.fill(child: MxBusyOverlay(label: l10n.audioSaving)),
        ],
      ],
    );
  }

  Future<void> _pickLanguage(
    BuildContext context,
    TtsAudioController controller,
    TtsFrontLanguage current,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TtsFrontLanguage? picked = await showMxBottomSheet<TtsFrontLanguage>(
      context,
      title: l10n.audioVoiceLanguage,
      child: Builder(
        builder: (BuildContext sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final TtsFrontLanguage option in TtsFrontLanguage.values)
              MxListTile(
                title: _languageName(l10n, option),
                trailing: MxRadio(selected: option == current),
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      await controller.setLanguage(picked);
    }
  }

  String _languageName(AppLocalizations l10n, TtsFrontLanguage language) =>
      switch (language) {
        TtsFrontLanguage.korean => l10n.audioLangKorean,
        TtsFrontLanguage.english => l10n.audioLangEnglish,
      };

  String _sample(AppLocalizations l10n, TtsFrontLanguage language) =>
      switch (language) {
        TtsFrontLanguage.korean => l10n.audioSampleKorean,
        TtsFrontLanguage.english => l10n.audioSampleEnglish,
      };
}

class _VoiceList extends StatelessWidget {
  const _VoiceList({required this.view, required this.onSelect});

  final TtsAudioView view;
  final ValueChanged<String?> onSelect;

  static const double _indent = MxSpacing.space10 + MxSpacing.space3;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    final String? selected = view.settings.frontVoiceName;
    return MxCard(
      key: const ValueKey<String>('mx-node:23-audio-speech/voice-list'),
      padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
      child: Column(
        children: <Widget>[
          MxListTile(
            leading: MxIconTile(
              color: colors.statusNew,
              icon: Icons.record_voice_over_outlined,
            ),
            title: l10n.audioSystemDefaultVoice,
            trailing: MxRadio(selected: selected == null),
            onTap: () => onSelect(null),
          ),
          for (final TtsVoice voice in view.voices) ...<Widget>[
            const MxDivider(indent: _indent),
            MxListTile(
              leading: MxIconTile(
                color: colors.statusNew,
                icon: Icons.mic_none_outlined,
              ),
              title: voice.name,
              subtitle: voice.localeTag,
              trailing: MxRadio(selected: selected == voice.name),
              onTap: () => onSelect(voice.name),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.sample,
    required this.isPlaying,
    required this.onPlay,
    required this.onStop,
  });

  final String sample;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxCard(
      key: const ValueKey<String>('mx-node:23-audio-speech/preview-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Overline(l10n.audioPreviewOverline),
          const SizedBox(height: MxSpacing.space3),
          MxText(sample, role: MxTextRole.titleMedium),
          const SizedBox(height: MxSpacing.space4),
          isPlaying
              ? Row(
                  children: <Widget>[
                    Expanded(
                      child: MxPrimaryButton(
                        key: const ValueKey<String>(
                          'mx-node:23-audio-speech/preview-button',
                        ),
                        label: l10n.audioStop,
                        icon: Icons.stop_rounded,
                        fullWidth: true,
                        onPressed: onStop,
                      ),
                    ),
                    const SizedBox(width: MxSpacing.space3),
                    const _Waveform(),
                  ],
                )
              : MxSecondaryButton(
                  key: const ValueKey<String>(
                    'mx-node:23-audio-speech/preview-button',
                  ),
                  label: l10n.audioPlaySample,
                  icon: Icons.play_arrow_rounded,
                  // kit preview-button: tonal fill (accentSoft bg, no border),
                  // not the outlined variant (spec 23-audio-speech/preview-button).
                  variant: MxSecondaryVariant.tonal,
                  fullWidth: true,
                  onPressed: onPlay,
                ),
        ],
      ),
    );
  }
}

/// A small static five-bar waveform shown beside Stop while previewing (the kit
/// animates it; the FE renders a static accent waveform).
class _Waveform extends StatelessWidget {
  const _Waveform();

  static const List<double> _heights = <double>[
    MxSpacing.space2,
    MxSpacing.space4,
    MxSpacing.space5,
    MxSpacing.space3,
    MxSpacing.space2,
  ];

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < _heights.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: MxSpacing.space1),
          Container(
            width: MxSpacing.space1,
            height: _heights[i],
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: MxRadius.pillAll,
            ),
          ),
        ],
      ],
    );
  }
}

class _TuningCard extends StatelessWidget {
  const _TuningCard({
    required this.settings,
    required this.onRate,
    required this.onPitch,
  });

  final TtsSettings settings;
  final ValueChanged<double> onRate;
  final ValueChanged<double> onPitch;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SliderRow(
            label: l10n.audioSpeed,
            value: '${settings.rate.toStringAsFixed(1)}×',
            slider: MxSlider(
              value: settings.rate,
              min: TtsSettings.minRate,
              max: TtsSettings.maxRate,
              onChanged: onRate,
            ),
          ),
          const SizedBox(height: MxSpacing.space5),
          _SliderRow(
            label: l10n.audioPitch,
            value: settings.pitch.toStringAsFixed(1),
            slider: MxSlider(
              value: settings.pitch,
              min: TtsSettings.minPitch,
              max: TtsSettings.maxPitch,
              onChanged: onPitch,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.slider,
  });

  final String label;
  final String value;
  final Widget slider;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MxText(label, role: MxTextRole.titleMedium),
            MxText(
              value,
              role: MxTextRole.labelLarge,
              color: colors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: MxSpacing.space2),
        slider,
      ],
    );
  }
}

class _Overline extends StatelessWidget {
  const _Overline(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: MxSpacing.space1),
    child: MxText(
      text,
      role: MxTextRole.labelMedium,
      color: context.mxColors.textSecondary,
    ),
  );
}

/// The no-voices / engine-error hero card.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.icon,
    required this.tint,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final String? actionLabel = this.actionLabel;
    return ListView(
      padding: const EdgeInsets.all(MxSpacing.screen),
      children: <Widget>[
        MxCard(
          padding: const EdgeInsets.all(MxSpacing.space6),
          child: Column(
            children: <Widget>[
              MxIconTile(color: tint, icon: icon),
              const SizedBox(height: MxSpacing.space4),
              MxText(
                title,
                role: MxTextRole.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MxSpacing.space2),
              MxText(
                message,
                role: MxTextRole.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null) ...<Widget>[
                const SizedBox(height: MxSpacing.space5),
                MxPrimaryButton(
                  label: actionLabel,
                  fullWidth: true,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
