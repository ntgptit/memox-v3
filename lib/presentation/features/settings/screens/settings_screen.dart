import 'package:flutter/material.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// Settings hub state used by the mock/gallery states in
/// `docs/system-design/MemoX Design System/ui_kits/mobile/index.html`.
enum SettingsHubState { populated, loading, signedOut, signingIn, syncError }

/// Settings hub screen.
///
/// The shell keeps bottom navigation outside this screen. The body renders the
/// four hub sections and footer from the mobile mock: Account, Study, App, and
/// About.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({this.state = SettingsHubState.populated, super.key});

  final SettingsHubState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(titleText: l10n.settingsTitle),
      body: ListView(
        children: <Widget>[
          _SettingsSection(
            title: l10n.settingsAccountTitle,
            child: _AccountRow(state: state),
          ),
          const SizedBox(height: SpacingTokens.lg),
          _SettingsSection(
            title: l10n.settingsStudySectionTitle,
            child: _StudySection(state: state),
          ),
          const SizedBox(height: SpacingTokens.lg),
          _SettingsSection(
            title: l10n.settingsAppSectionTitle,
            child: _AppSection(),
          ),
          const SizedBox(height: SpacingTokens.lg),
          _SettingsSection(
            title: l10n.settingsAboutSectionTitle,
            child: _SettingsAboutRow(state: state),
          ),
          const SizedBox(height: SpacingTokens.xs),
          _FooterText(text: l10n.settingsOverviewFooter),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      MxSectionHeader(label: title),
      const SizedBox(height: SpacingTokens.xs),
      MxCard(padding: EdgeInsets.zero, child: child),
    ],
  );
}

class _StudySection extends StatelessWidget {
  const _StudySection({required this.state});

  final SettingsHubState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        _SettingsRow(
          icon: Icons.my_location_outlined,
          iconColor: _accentColor(context, state),
          iconTint: _accentTint(context, state),
          title: l10n.settingsLearningOverviewTitle,
          subtitle: _LearningSubtitle(state: state),
          onTap: () => context.pushSettingsLearning(),
        ),
        const _RowDivider(),
        _SettingsRow(
          icon: Icons.volume_up_outlined,
          iconColor: _accentColor(context, state),
          iconTint: _accentTint(context, state),
          title: l10n.settingsAudioSpeechTitle,
          subtitle: _AudioSubtitle(state: state),
          onTap: () => context.pushSettingsAudioSpeech(),
        ),
        const _RowDivider(),
        _SettingsRow(
          icon: Icons.sell_outlined,
          iconColor: _accentColor(context, state),
          iconTint: _accentTint(context, state),
          title: l10n.settingsManageTagsTitle,
          subtitle: _TagsSubtitle(state: state),
          onTap: () => context.pushSettingsLearningTags(),
        ),
      ],
    );
  }
}

class _AppSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    return Column(
      children: <Widget>[
        _SettingsRow(
          icon: Icons.wb_sunny_outlined,
          iconColor: scheme.onSurfaceVariant,
          iconTint: scheme.surfaceContainer,
          title: l10n.settingsAppearanceTitle,
          subtitle: MxText(
            l10n.settingsAppearanceOverviewSubtitle,
            role: MxTextRole.labelMedium,
            color: scheme.onSurfaceVariant,
          ),
          trailing: _DisabledSoonChip(label: l10n.settingsSoonChip),
          enabled: false,
        ),
        const _RowDivider(),
        _SettingsRow(
          icon: Icons.language_outlined,
          iconColor: scheme.onSurfaceVariant,
          iconTint: scheme.surfaceContainer,
          title: l10n.settingsLanguageTitle,
          subtitle: MxText(
            l10n.settingsLanguageOverviewSubtitle,
            role: MxTextRole.labelMedium,
            color: scheme.onSurfaceVariant,
          ),
          trailing: _DisabledSoonChip(label: l10n.settingsSoonChip),
          enabled: false,
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.state});

  final SettingsHubState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final bool isLoading = state == SettingsHubState.loading;
    final bool isSignedOut = state == SettingsHubState.signedOut;
    return _SettingsRow(
      icon: isSignedOut ? Icons.login_rounded : Icons.person_outline,
      iconColor: _accentColor(context, state),
      iconTint: _accentTint(context, state),
      title: isSignedOut
          ? l10n.settingsAccountSignInSyncTitle
          : l10n.settingsAccountLinkedOverviewTitle,
      subtitle: switch (state) {
        SettingsHubState.loading => const _LoadingSubtitle(width: 156),
        SettingsHubState.signedOut => MxText(
          l10n.settingsAccountSignInSyncSubtitle,
          role: MxTextRole.labelMedium,
          color: scheme.onSurfaceVariant,
        ),
        SettingsHubState.signingIn => _SigningInSubtitle(
          text: l10n.settingsAccountSigningIn,
        ),
        SettingsHubState.syncError => MxText(
          l10n.settingsAccountOverviewSyncErrorSubtitle('alex@memox.app'),
          role: MxTextRole.labelMedium,
          color: scheme.onSurfaceVariant,
        ),
        SettingsHubState.populated => MxText(
          l10n.settingsAccountOverviewSyncedMockSubtitle('alex@memox.app'),
          role: MxTextRole.labelMedium,
          color: scheme.onSurfaceVariant,
        ),
      },
      trailing: state == SettingsHubState.syncError
          ? _DisabledSoonChip(
              label: l10n.settingsOverviewSyncRetry,
              icon: Icons.cloud_off_outlined,
            )
          : const _ChevronTrailing(),
      onTap: isLoading ? null : () => context.pushSettingsAccount(),
      enabled: !isLoading,
    );
  }
}

class _SettingsAboutRow extends StatelessWidget {
  const _SettingsAboutRow({required this.state});

  final SettingsHubState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    return _SettingsRow(
      icon: Icons.info_outline,
      iconColor: scheme.primary,
      iconTint: scheme.primary.withValues(alpha: OpacityTokens.hover),
      title: l10n.settingsAboutMemoXTitle,
      subtitle: _AboutSubtitle(state: state),
      onTap: () => _showAboutDialog(context),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    showAboutDialog(
      context: context,
      applicationName: l10n.appName,
      applicationVersion: _mockAppVersion,
      applicationLegalese: l10n.settingsAboutLegalese,
      children: <Widget>[
        const SizedBox(height: SpacingTokens.sm),
        MxText(l10n.settingsAboutMessage, role: MxTextRole.bodyMedium),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.iconTint,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconTint;
  final String title;
  final Widget subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: MxTappable(
        onTap: onTap,
        borderRadius: RadiusTokens.brLg,
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _LeadingIconTile(
                icon: icon,
                foregroundColor: iconColor,
                backgroundColor: iconTint,
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MxText(
                      title,
                      role: MxTextRole.titleSmall,
                      fontWeight: TypographyTokens.semiBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    subtitle,
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              trailing ?? _ChevronTrailing(color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChevronTrailing extends StatelessWidget {
  const _ChevronTrailing({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) => Icon(
    Icons.chevron_right,
    size: 18,
    color: color ?? context.colorScheme.onSurfaceVariant,
  );
}

class _DisabledSoonChip extends StatelessWidget {
  const _DisabledSoonChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: RadiusTokens.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12, color: scheme.onSurfaceVariant),
            const SizedBox(width: SpacingTokens.xxs),
          ],
          MxText(
            label,
            role: MxTextRole.labelSmall,
            color: scheme.onSurfaceVariant,
            fontWeight: TypographyTokens.bold,
          ),
        ],
      ),
    );
  }
}

class _LeadingIconTile extends StatelessWidget {
  const _LeadingIconTile({
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: RadiusTokens.brMd,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: foregroundColor),
    );
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
    child: ColoredBox(
      color: context.colorScheme.outlineVariant.withValues(
        alpha: OpacityTokens.divider,
      ),
      child: const SizedBox(height: 1),
    ),
  );
}

class _LoadingSubtitle extends StatelessWidget {
  const _LoadingSubtitle({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: width, child: const MxSkeleton(height: 10));
}

class _SigningInSubtitle extends StatelessWidget {
  const _SigningInSubtitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      const MxSkeleton.circle(size: 10),
      const SizedBox(width: SpacingTokens.xs + 2),
      MxText(
        text,
        role: MxTextRole.labelMedium,
        color: context.colorScheme.onSurfaceVariant,
      ),
    ],
  );
}

class _LearningSubtitle extends StatelessWidget {
  const _LearningSubtitle({required this.state});

  final SettingsHubState state;

  @override
  Widget build(BuildContext context) => switch (state) {
    SettingsHubState.loading => const _LoadingSubtitle(width: 176),
    _ => MxText(
      AppLocalizations.of(context).settingsLearningOverviewSummary,
      role: MxTextRole.labelMedium,
      color: context.colorScheme.onSurfaceVariant,
    ),
  };
}

class _AudioSubtitle extends StatelessWidget {
  const _AudioSubtitle({required this.state});

  final SettingsHubState state;

  @override
  Widget build(BuildContext context) => switch (state) {
    SettingsHubState.loading => const _LoadingSubtitle(width: 148),
    _ => MxText(
      AppLocalizations.of(context).settingsAudioSpeechOverviewSummary,
      role: MxTextRole.labelMedium,
      color: context.colorScheme.onSurfaceVariant,
    ),
  };
}

class _TagsSubtitle extends StatelessWidget {
  const _TagsSubtitle({required this.state});

  final SettingsHubState state;

  @override
  Widget build(BuildContext context) => switch (state) {
    SettingsHubState.loading => const _LoadingSubtitle(width: 68),
    _ => MxText(
      AppLocalizations.of(context).settingsManageTagsOverviewSubtitle,
      role: MxTextRole.labelMedium,
      color: context.colorScheme.onSurfaceVariant,
    ),
  };
}

class _AboutSubtitle extends StatelessWidget {
  const _AboutSubtitle({required this.state});

  final SettingsHubState state;

  @override
  Widget build(BuildContext context) => switch (state) {
    SettingsHubState.loading => const _LoadingSubtitle(width: 144),
    _ => MxText(
      AppLocalizations.of(context).settingsAboutVersion(_mockAppVersion),
      role: MxTextRole.labelMedium,
      color: context.colorScheme.onSurfaceVariant,
    ),
  };
}

class _FooterText extends StatelessWidget {
  const _FooterText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => MxText(
    text,
    role: MxTextRole.labelSmall,
    color: context.colorScheme.onSurfaceVariant,
    textAlign: TextAlign.center,
  );
}

Color _accentColor(BuildContext context, SettingsHubState state) {
  if (state == SettingsHubState.syncError) {
    return context.customColors.warning;
  }
  return context.colorScheme.primary;
}

Color _accentTint(BuildContext context, SettingsHubState state) {
  if (state == SettingsHubState.syncError) {
    return context.customColors.warning.withValues(alpha: OpacityTokens.hover);
  }
  if (state == SettingsHubState.signedOut) {
    return context.colorScheme.surfaceContainer;
  }
  return context.colorScheme.primary.withValues(alpha: OpacityTokens.hover);
}

const String _mockAppVersion = '1.4.2 (build 248)';
