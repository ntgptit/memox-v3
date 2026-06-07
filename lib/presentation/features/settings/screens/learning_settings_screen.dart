import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/easing_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

part 'learning_settings_screen_parts_screen.dart';

/// Learning settings mock/gallery states from
/// `docs/system-design/MemoX Design System/ui_kits/mobile/index.html`.
enum LearningSettingsState { goalOn, goalOff, reminderOn, permDenied, saving }

/// Learning settings screen.
///
/// The screen is navigation-only in the current app shell. It renders the
/// mock's goal, reminder, tag, and future study-default sections as a static
/// preview with state variants.
class LearningSettingsScreen extends StatelessWidget {
  const LearningSettingsScreen({
    this.state = LearningSettingsState.goalOn,
    super.key,
  });

  final LearningSettingsState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(
        titleText: l10n.settingsLearningOverviewTitle,
        leading: MxIconButton(
          icon: Icons.arrow_back,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
        actions: <Widget>[
          _LearningSavedChip(
            label: l10n.settingsLearningSavedChip,
            visible: state == LearningSettingsState.saving,
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          _LearningSettingsSection(
            title: l10n.settingsLearningDailyGoalSectionTitle,
            hint: state == LearningSettingsState.goalOff
                ? l10n.settingsLearningGoalOffHint
                : null,
            child: _DailyGoalCard(
              goalEnabled: state != LearningSettingsState.goalOff,
              l10n: l10n,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          _LearningSettingsSection(
            title: l10n.settingsLearningReminderSectionTitle,
            hint:
                state == LearningSettingsState.reminderOn ||
                    state == LearningSettingsState.permDenied
                ? null
                : l10n.settingsLearningReminderHint,
            child: _ReminderCard(
              reminderEnabled:
                  state == LearningSettingsState.reminderOn ||
                  state == LearningSettingsState.permDenied,
              permissionDenied: state == LearningSettingsState.permDenied,
              l10n: l10n,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          _LearningSettingsSection(
            title: l10n.settingsLearningTagsSectionTitle,
            child: _LearningTagsCard(l10n: l10n),
          ),
          const SizedBox(height: SpacingTokens.lg),
          _LearningSettingsSection(
            title: l10n.settingsLearningFutureStudyDefaultsTitle,
            hint: l10n.settingsLearningFutureStudyDefaultsHint,
            child: _LearningStudyDefaultsCard(l10n: l10n),
          ),
        ],
      ),
    );
  }
}

class _LearningSettingsSection extends StatelessWidget {
  const _LearningSettingsSection({
    required this.title,
    required this.child,
    this.hint,
  });

  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      MxSectionHeader(label: title),
      if (hint != null) ...<Widget>[
        const SizedBox(height: SpacingTokens.xxs),
        MxText(
          hint!,
          role: MxTextRole.labelMedium,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ],
      const SizedBox(height: SpacingTokens.xs),
      MxCard(padding: EdgeInsets.zero, child: child),
    ],
  );
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.goalEnabled, required this.l10n});

  final bool goalEnabled;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      _LearningToggleRow(
        leadingIcon: null,
        title: l10n.settingsLearningGoalToggleTitle,
        subtitle: goalEnabled
            ? l10n.settingsLearningGoalToggleSubtitleOn
            : l10n.settingsLearningGoalToggleSubtitleOff,
        value: goalEnabled,
        onChanged: (_) {},
      ),
      const _LearningRowDivider(),
      _LearningGoalSliderBlock(goalEnabled: goalEnabled, l10n: l10n),
      const _LearningRowDivider(),
      _LearningToggleRow(
        leadingIcon: Icons.local_fire_department_outlined,
        title: l10n.settingsLearningStreakToggleTitle,
        subtitle: l10n.settingsLearningStreakToggleSubtitle,
        value: true,
        onChanged: (_) {},
        enabled: goalEnabled,
      ),
    ],
  );
}

class _LearningGoalSliderBlock extends StatelessWidget {
  const _LearningGoalSliderBlock({
    required this.goalEnabled,
    required this.l10n,
  });

  final bool goalEnabled;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final double progress =
        ((_dailyGoalValue - _goalMin) / (_goalMax - _goalMin))
            .clamp(0, 1)
            .toDouble();
    return Opacity(
      opacity: goalEnabled ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !goalEnabled,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    l10n.settingsLearningCardsPerDayLabel,
                    style: context.customTextStyles.overline.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      MxText(
                        l10n.settingsCardsCountValue(_dailyGoalValue),
                        role: MxTextRole.titleLarge,
                        color: scheme.primary,
                        fontWeight: TypographyTokens.bold,
                      ),
                      const SizedBox(width: SpacingTokens.xxs),
                      MxText(
                        l10n.folderSummaryCardsStat,
                        role: MxTextRole.labelMedium,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 22,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: <Widget>[
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHigh,
                            borderRadius: RadiusTokens.brFull,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: RadiusTokens.brFull,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(progress * 2 - 1, 0),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          border: Border.all(color: scheme.primary, width: 2),
                          borderRadius: RadiusTokens.brFull,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.22),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _GoalTrackTick(position: 0, active: 0 <= progress),
                    _GoalTrackTick(position: 0.25, active: 0.25 <= progress),
                    _GoalTrackTick(position: 0.5, active: 0.5 <= progress),
                    _GoalTrackTick(position: 0.75, active: 0.75 <= progress),
                    const _GoalTrackTick(position: 1, active: true),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _GoalScaleLabel(text: '5'),
                  _GoalScaleLabel(text: '50'),
                  _GoalScaleLabel(text: '100'),
                  _GoalScaleLabel(text: '150'),
                  _GoalScaleLabel(text: '200'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    size: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: SpacingTokens.xxs + 1),
                  MxText(
                    l10n.settingsLearningDragHint,
                    role: MxTextRole.labelSmall,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalTrackTick extends StatelessWidget {
  const _GoalTrackTick({required this.position, required this.active});

  final double position;
  final bool active;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment(position * 2 - 1, 0),
    child: Container(
      width: 2,
      height: 2,
      decoration: BoxDecoration(
        color: active
            ? context.colorScheme.surfaceContainerLowest.withValues(alpha: 0.85)
            : context.colorScheme.outlineVariant,
        borderRadius: RadiusTokens.brFull,
      ),
    ),
  );
}

class _GoalScaleLabel extends StatelessWidget {
  const _GoalScaleLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => MxText(
    text,
    role: MxTextRole.labelSmall,
    color: context.colorScheme.onSurfaceVariant,
  );
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminderEnabled,
    required this.permissionDenied,
    required this.l10n,
  });

  final bool reminderEnabled;
  final bool permissionDenied;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      _LearningToggleRow(
        leadingIcon: null,
        title: l10n.settingsLearningReminderToggleTitle,
        subtitle: reminderEnabled
            ? l10n.settingsLearningReminderToggleSubtitleOn
            : l10n.settingsLearningReminderToggleSubtitleOff,
        value: reminderEnabled,
        onChanged: (_) {},
      ),
      const _LearningRowDivider(),
      _LearningNavigationRow(
        leadingIcon: Icons.schedule_outlined,
        title: l10n.settingsLearningReminderTimeLabel,
        value: l10n.settingsLearningReminderTimeValue,
        enabled: reminderEnabled && !permissionDenied,
        onTap: () {},
      ),
      if (permissionDenied) ...<Widget>[
        const _LearningRowDivider(),
        _PermissionBanner(l10n: l10n),
      ],
    ],
  );
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: context.customColors.warning.withValues(alpha: 0.06),
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withValues(
              alpha: OpacityTokens.divider,
            ),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        12,
        SpacingTokens.md,
        SpacingTokens.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.notifications_off_outlined,
            size: 16,
            color: context.customColors.warning,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MxText(
                  l10n.settingsLearningNotificationsBlockedTitle,
                  role: MxTextRole.titleSmall,
                  fontWeight: TypographyTokens.bold,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                MxText(
                  l10n.settingsLearningNotificationsBlockedBody,
                  role: MxTextRole.labelMedium,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(height: SpacingTokens.sm),
                MxActionButton(
                  intent: MxActionIntent.cardPrimary,
                  label: l10n.settingsLearningOpenSystemSettings,
                  icon: Icons.open_in_new_rounded,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningToggleRow extends StatelessWidget {
  const _LearningToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.leadingIcon,
    this.enabled = true,
  });

  final IconData? leadingIcon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: MxTappable(
        onTap: enabled ? () => onChanged(!value) : null,
        borderRadius: RadiusTokens.brLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: 13,
          ),
          child: Row(
            children: <Widget>[
              if (leadingIcon != null) ...<Widget>[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.08),
                    borderRadius: RadiusTokens.brMd,
                  ),
                  alignment: Alignment.center,
                  child: Icon(leadingIcon, size: 15, color: scheme.primary),
                ),
                const SizedBox(width: SpacingTokens.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MxText(
                      title,
                      role: MxTextRole.titleSmall,
                      color: scheme.onSurface,
                      fontWeight: TypographyTokens.semiBold,
                    ),
                    const SizedBox(height: 2),
                    MxText(
                      subtitle,
                      role: MxTextRole.labelMedium,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              _LearningSwitch(value: value),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningNavigationRow extends StatelessWidget {
  const _LearningNavigationRow({
    required this.title,
    required this.enabled,
    required this.onTap,
    this.rowKey,
    this.subtitle,
    this.value,
    this.leadingIcon,
  });

  final Key? rowKey;
  final IconData? leadingIcon;
  final String title;
  final String? subtitle;
  final String? value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: MxTappable(
        key: rowKey,
        onTap: enabled ? onTap : null,
        borderRadius: RadiusTokens.brLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: 13,
          ),
          child: Row(
            children: <Widget>[
              if (leadingIcon != null) ...<Widget>[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.08),
                    borderRadius: RadiusTokens.brMd,
                  ),
                  alignment: Alignment.center,
                  child: Icon(leadingIcon, size: 15, color: scheme.primary),
                ),
                const SizedBox(width: SpacingTokens.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MxText(
                      title,
                      role: MxTextRole.titleSmall,
                      color: scheme.onSurface,
                      fontWeight: TypographyTokens.semiBold,
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      MxText(
                        subtitle!,
                        role: MxTextRole.labelMedium,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              if (value != null) ...<Widget>[
                MxText(
                  value!,
                  role: MxTextRole.labelLarge,
                  color: scheme.onSurfaceVariant,
                  fontWeight: TypographyTokens.semiBold,
                ),
                const SizedBox(width: 6),
              ],
              Icon(
                Icons.chevron_right,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningSwitch extends StatelessWidget {
  const _LearningSwitch({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Semantics(
      toggled: value,
      child: Container(
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          color: value ? scheme.primary : scheme.surfaceContainerHigh,
          borderRadius: RadiusTokens.brFull,
        ),
        child: Stack(
          children: <Widget>[
            AnimatedPositioned(
              duration: DurationTokens.fast,
              curve: EasingTokens.standard,
              left: value ? 21 : 3,
              top: 3,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: RadiusTokens.brFull,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.18),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
