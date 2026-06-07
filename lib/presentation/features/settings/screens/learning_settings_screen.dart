import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_settings_tile.dart';

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
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Column(
      children: <Widget>[
        MxSettingsTile.toggle(
          title: l10n.settingsLearningGoalToggleTitle,
          subtitle: goalEnabled
              ? l10n.settingsLearningGoalToggleSubtitleOn
              : l10n.settingsLearningGoalToggleSubtitleOff,
          value: goalEnabled,
          onChanged: (_) {},
        ),
        const _LearningRowDivider(),
        Opacity(
          opacity: goalEnabled ? 1 : 0.45,
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
                      MxText(
                        l10n.settingsCardsCountValue(_dailyGoalValue),
                        role: MxTextRole.titleMedium,
                        color: scheme.primary,
                        fontWeight: TypographyTokens.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  const _DailyGoalTrack(goalValue: _dailyGoalValue),
                  const SizedBox(height: SpacingTokens.xs),
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
                  const SizedBox(height: SpacingTokens.sm),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.info_outline,
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: SpacingTokens.xxs + 2),
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
        ),
        const _LearningRowDivider(),
        Opacity(
          opacity: goalEnabled ? 1 : 0.45,
          child: IgnorePointer(
            ignoring: !goalEnabled,
            child: MxSettingsTile.toggle(
              leadingIcon: Icons.local_fire_department_outlined,
              title: l10n.settingsLearningStreakToggleTitle,
              subtitle: l10n.settingsLearningStreakToggleSubtitle,
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyGoalTrack extends StatelessWidget {
  const _DailyGoalTrack({required this.goalValue});

  final int goalValue;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final double progress = ((goalValue - _goalMin) / (_goalMax - _goalMin))
        .clamp(0, 1)
        .toDouble();
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Positioned.fill(
            child: Center(
              child: Container(
                height: 6,
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
                  height: 6,
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
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border.all(color: scheme.primary, width: 2),
                borderRadius: RadiusTokens.brFull,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          ..._trackMarkers(progress, scheme),
        ],
      ),
    );
  }

  List<Widget> _trackMarkers(double progress, ColorScheme scheme) => <Widget>[
    _TrackMarker(position: 0, active: 0 <= progress, color: scheme),
    _TrackMarker(position: 0.25, active: 0.25 <= progress, color: scheme),
    _TrackMarker(position: 0.5, active: 0.5 <= progress, color: scheme),
    _TrackMarker(position: 0.75, active: 0.75 <= progress, color: scheme),
    _TrackMarker(position: 1, active: true, color: scheme),
  ];
}

class _TrackMarker extends StatelessWidget {
  const _TrackMarker({
    required this.position,
    required this.active,
    required this.color,
  });

  final double position;
  final bool active;
  final ColorScheme color;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment(position * 2 - 1, 0),
    child: Container(
      width: 2,
      height: 2,
      decoration: BoxDecoration(
        color: active
            ? color.surface.withValues(alpha: 0.85)
            : color.outlineVariant,
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
      MxSettingsTile.toggle(
        title: l10n.settingsLearningReminderToggleTitle,
        subtitle: reminderEnabled
            ? l10n.settingsLearningReminderToggleSubtitleOn
            : l10n.settingsLearningReminderToggleSubtitleOff,
        value: reminderEnabled,
        onChanged: (_) {},
      ),
      const _LearningRowDivider(),
      Opacity(
        opacity: reminderEnabled && !permissionDenied ? 1 : 0.45,
        child: IgnorePointer(
          ignoring: !reminderEnabled || permissionDenied,
          child: MxSettingsTile.navigation(
            leadingIcon: Icons.schedule_outlined,
            title: l10n.settingsLearningReminderTimeLabel,
            value: l10n.settingsLearningReminderTimeValue,
            onTap: () {},
          ),
        ),
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
        color: context.customColors.warning.withValues(alpha: 0.08),
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withValues(
              alpha: OpacityTokens.divider,
            ),
          ),
        ),
      ),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.notifications_off_outlined,
            size: 18,
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
