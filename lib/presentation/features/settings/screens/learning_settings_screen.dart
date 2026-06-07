import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/shadow_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/widgets/learning_settings_screen_content.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

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
          LearningSavedChip(
            label: l10n.settingsLearningSavedChip,
            visible: state == LearningSettingsState.saving,
          ),
        ],
      ),
      body: _LearningSettingsBody(state: state, l10n: l10n),
    );
  }
}

class _LearningSettingsBody extends StatelessWidget {
  const _LearningSettingsBody({required this.state, required this.l10n});

  final LearningSettingsState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => ListView(
    children: <Widget>[
      _LearningDailyGoalSection(state: state, l10n: l10n),
      const SizedBox(height: SpacingTokens.lg),
      _LearningReminderSection(state: state, l10n: l10n),
      const SizedBox(height: SpacingTokens.lg),
      _LearningTagsSection(l10n: l10n),
      const SizedBox(height: SpacingTokens.lg),
      _LearningFutureDefaultsSection(l10n: l10n),
    ],
  );
}

class _LearningDailyGoalSection extends StatelessWidget {
  const _LearningDailyGoalSection({required this.state, required this.l10n});

  final LearningSettingsState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => _LearningSettingsSection(
    title: l10n.settingsLearningDailyGoalSectionTitle,
    hint: state == LearningSettingsState.goalOff
        ? l10n.settingsLearningGoalOffHint
        : null,
    child: _DailyGoalCard(
      goalEnabled: state != LearningSettingsState.goalOff,
      l10n: l10n,
    ),
  );
}

class _LearningReminderSection extends StatelessWidget {
  const _LearningReminderSection({required this.state, required this.l10n});

  final LearningSettingsState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => _LearningSettingsSection(
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
  );
}

class _LearningTagsSection extends StatelessWidget {
  const _LearningTagsSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => _LearningSettingsSection(
    title: l10n.settingsLearningTagsSectionTitle,
    child: LearningTagsCard(l10n: l10n),
  );
}

class _LearningFutureDefaultsSection extends StatelessWidget {
  const _LearningFutureDefaultsSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => _LearningSettingsSection(
    title: l10n.settingsLearningFutureStudyDefaultsTitle,
    hint: l10n.settingsLearningFutureStudyDefaultsHint,
    child: LearningStudyDefaultsCard(l10n: l10n),
  );
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

const int _dailyGoalValue = 20;
const int _goalMin = 5;
const int _goalMax = 200;

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.goalEnabled, required this.l10n});

  final bool goalEnabled;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      LearningToggleRow(
        leadingIcon: null,
        title: l10n.settingsLearningGoalToggleTitle,
        subtitle: goalEnabled
            ? l10n.settingsLearningGoalToggleSubtitleOn
            : l10n.settingsLearningGoalToggleSubtitleOff,
        value: goalEnabled,
        onChanged: (_) {},
      ),
      const LearningRowDivider(),
      _LearningGoalSliderBlock(goalEnabled: goalEnabled, l10n: l10n),
      const LearningRowDivider(),
      LearningToggleRow(
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
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _LearningGoalSliderHeader(
                title: l10n.settingsLearningCardsPerDayLabel,
                valueText: l10n.settingsCardsCountValue(_dailyGoalValue),
                statLabel: l10n.folderSummaryCardsStat,
                scheme: scheme,
              ),
              const SizedBox(height: SpacingTokens.lg),
              _LearningGoalSliderTrack(progress: progress, scheme: scheme),
              const SizedBox(height: SpacingTokens.sm),
              const _LearningGoalSliderScaleRow(),
              const SizedBox(height: SpacingTokens.sm),
              _LearningGoalSliderHint(
                hintText: l10n.settingsLearningDragHint,
                scheme: scheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningGoalSliderHeader extends StatelessWidget {
  const _LearningGoalSliderHeader({
    required this.title,
    required this.valueText,
    required this.statLabel,
    required this.scheme,
  });

  final String title;
  final String valueText;
  final String statLabel;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: <Widget>[
      Text(
        title,
        style: context.customTextStyles.overline.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          MxText(
            valueText,
            role: MxTextRole.titleLarge,
            color: scheme.primary,
            fontWeight: TypographyTokens.bold,
          ),
          const SizedBox(width: SpacingTokens.xxs),
          MxText(
            statLabel,
            role: MxTextRole.labelMedium,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    ],
  );
}

class _LearningGoalSliderTrack extends StatelessWidget {
  const _LearningGoalSliderTrack({
    required this.progress,
    required this.scheme,
  });

  final double progress;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: SizeTokens.iconBadge,
    child: Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        Positioned.fill(
          child: Center(
            child: Container(
              height: SpacingTokens.micro,
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
                height: SpacingTokens.micro,
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
            width: SizeTokens.iconSm,
            height: SizeTokens.iconSm,
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(
                color: scheme.primary,
                width: BorderTokens.focusWidth,
              ),
              borderRadius: RadiusTokens.brFull,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.22),
                  blurRadius: ShadowTokens.blurSm,
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
  );
}

class _LearningGoalSliderScaleRow extends StatelessWidget {
  const _LearningGoalSliderScaleRow();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      _GoalScaleLabel(text: '5'),
      _GoalScaleLabel(text: '50'),
      _GoalScaleLabel(text: '100'),
      _GoalScaleLabel(text: '150'),
      _GoalScaleLabel(text: '200'),
    ],
  );
}

class _LearningGoalSliderHint extends StatelessWidget {
  const _LearningGoalSliderHint({required this.hintText, required this.scheme});

  final String hintText;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Icon(
        Icons.info_outline,
        size: SizeTokens.iconTiny,
        color: scheme.onSurfaceVariant,
      ),
      const SizedBox(width: SpacingTokens.xs),
      MxText(
        hintText,
        role: MxTextRole.labelSmall,
        color: scheme.onSurfaceVariant,
      ),
    ],
  );
}

class _GoalTrackTick extends StatelessWidget {
  const _GoalTrackTick({required this.position, required this.active});

  final double position;
  final bool active;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment(position * 2 - 1, 0),
    child: Container(
      width: SizeTokens.dot,
      height: SizeTokens.dot,
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
      LearningToggleRow(
        leadingIcon: null,
        title: l10n.settingsLearningReminderToggleTitle,
        subtitle: reminderEnabled
            ? l10n.settingsLearningReminderToggleSubtitleOn
            : l10n.settingsLearningReminderToggleSubtitleOff,
        value: reminderEnabled,
        onChanged: (_) {},
      ),
      const LearningRowDivider(),
      LearningNavigationRow(
        leadingIcon: Icons.schedule_outlined,
        title: l10n.settingsLearningReminderTimeLabel,
        value: l10n.settingsLearningReminderTimeValue,
        enabled: reminderEnabled && !permissionDenied,
        onTap: () {},
      ),
      if (permissionDenied) ...<Widget>[
        const LearningRowDivider(),
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
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.notifications_off_outlined,
            size: SizeTokens.iconXs,
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
