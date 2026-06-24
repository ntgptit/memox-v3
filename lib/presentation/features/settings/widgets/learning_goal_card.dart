import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_view.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_slider.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_switch.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// The Daily goal card (kit `22--goal-on/off`): a header row (icon + title +
/// toggle) and, when on, the "N cards / day" value, a slider, and quick-pick
/// chips. Backed by `LearningSettings.dailyNewLimit` + `goalDisabledSince`.
///
/// Note: the kit slider exposes a 5..60 range (the common daily range); the
/// `LearningSettings` contract validates up to 200, so larger persisted values
/// stay valid but are not reachable from this slider
/// (`docs/wireframes/20-settings-learning.md` §status).
class LearningGoalCard extends StatelessWidget {
  const LearningGoalCard({
    required this.view,
    required this.onToggle,
    required this.onLimit,
    super.key,
  });

  final LearningSettingsView view;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onLimit;

  static const int _sliderMin = 5;
  static const int _sliderMax = 60;
  static const List<int> _presets = <int>[10, 20, 30, 50];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    final bool on = view.goalEnabled;
    final int limit = view.settings.dailyNewLimit;

    return MxCard(
      key: const ValueKey<String>('mx-node:22-learning-settings/goal-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MxListTile(
            leading: MxIconTile(
              color: colors.info,
              icon: Icons.track_changes_outlined,
            ),
            title: l10n.learningGoalTitle,
            subtitle: on ? l10n.learningGoalOnDesc : l10n.learningGoalOffDesc,
            trailing: MxSwitch(
              key: const ValueKey<String>(
                'mx-node:22-learning-settings/goal-toggle',
              ),
              value: on,
              onChanged: onToggle,
            ),
          ),
          if (on) ..._goalControls(l10n, colors, limit),
        ],
      ),
    );
  }

  List<Widget> _goalControls(
    AppLocalizations l10n,
    MxColors colors,
    int limit,
  ) {
    const int divisions =
        (_sliderMax - _sliderMin) ~/ LearningSettings.dailyNewLimitStep;
    return <Widget>[
      const SizedBox(height: MxSpacing.space3),
      const MxDivider(),
      const SizedBox(height: MxSpacing.space3),
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          MxText(limit.toString(), role: MxTextRole.displayLarge),
          const SizedBox(width: MxSpacing.space2),
          MxText(
            l10n.learningGoalUnit,
            role: MxTextRole.labelLarge,
            color: colors.textSecondary,
          ),
        ],
      ),
      const SizedBox(height: MxSpacing.space2),
      MxSlider(
        key: const ValueKey<String>('mx-node:22-learning-settings/goal-slider'),
        value: limit.toDouble(),
        min: _sliderMin.toDouble(),
        max: _sliderMax.toDouble(),
        divisions: divisions,
        onChanged: (double value) => onLimit(value.round()),
      ),
      const SizedBox(height: MxSpacing.space2),
      Row(
        key: const ValueKey<String>(
          'mx-node:22-learning-settings/goal-presets',
        ),
        children: <Widget>[
          for (int i = 0; i < _presets.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: MxSpacing.space2),
            Expanded(
              child: _PresetChip(
                value: _presets[i],
                selected: _presets[i] == limit,
                onTap: () => onLimit(_presets[i]),
              ),
            ),
          ],
        ],
      ),
    ];
  }
}

/// A quick-pick goal chip (kit `.chip` / `.chip.due.solid` when selected).
class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return MxTappable(
      onTap: onTap,
      borderRadius: MxRadius.pillAll,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space2),
        decoration: BoxDecoration(
          color: selected ? colors.accent : colors.surfaceMuted,
          borderRadius: MxRadius.pillAll,
        ),
        child: MxText(
          value.toString(),
          role: MxTextRole.labelLarge,
          color: selected ? colors.accentContrast : colors.textSecondary,
        ),
      ),
    );
  }
}
