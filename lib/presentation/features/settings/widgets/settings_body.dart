import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/types/account_link_status.dart';
import 'package:memox/domain/types/app_language.dart';
import 'package:memox/domain/types/app_theme_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/account_controller.dart';
import 'package:memox/presentation/features/settings/controllers/appearance_controller.dart';
import 'package:memox/presentation/features/settings/controllers/language_controller.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_controller.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_view.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_avatar.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// The Settings hub body (kit screen 20): an account summary card (signed-out in
/// V1) + grouped category rows that push the immersive settings sub-screens. The
/// row trailing values reflect the live settings (daily goal, theme, language).
/// The Populated / Signing-in / Sync-error account states need the Future sync
/// infra (WBS 8.6.x); V1 always renders signed-out.
class SettingsBody extends ConsumerWidget {
  const SettingsBody({super.key});

  static const double _rowDividerIndent = MxSpacing.space10 + MxSpacing.space3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<AccountLinkStatus> account = ref.watch(
      accountControllerProvider,
    );
    return AppAsyncBuilder<AccountLinkStatus>(
      value: account,
      loading: (_) => const MxLoadingState(),
      error: (Object error, StackTrace? _) => MxErrorState(
        title: l10n.settingsErrorTitle,
        message: l10n.settingsErrorMessage,
      ),
      data: (AccountLinkStatus _) => _content(context, ref, l10n),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final MxColors colors = context.mxColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        MxSpacing.screen,
        MxSpacing.space2,
        MxSpacing.screen,
        MxSpacing.space6,
      ),
      children: <Widget>[
        _AccountCard(
          l10n: l10n,
          onSignIn: () => context.pushNamed(RouteNames.settingsAccount),
        ),
        const SizedBox(height: MxSpacing.space4),
        MxCard(
          key: const ValueKey<String>('mx-node:20-settings/settings-group'),
          padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
          child: Column(
            children: <Widget>[
              _SettingsRow(
                icon: Icons.track_changes_outlined,
                tint: colors.statusNew,
                title: l10n.settingsRowLearning,
                meta: l10n.settingsRowLearningMeta,
                value: _learningValue(ref, l10n),
                onTap: () => context.pushNamed(RouteNames.settingsLearning),
              ),
              const MxDivider(indent: _rowDividerIndent),
              _SettingsRow(
                icon: Icons.volume_up_outlined,
                tint: colors.statusReviewing,
                title: l10n.settingsRowAudio,
                meta: l10n.settingsRowAudioMeta,
                // Audio & speech (TTS) is Future — WBS 8.4.1 (engine + migration).
                value: l10n.settingsValueSoon,
                onTap: null,
              ),
              const MxDivider(indent: _rowDividerIndent),
              _SettingsRow(
                icon: Icons.palette_outlined,
                tint: colors.statusLearning,
                title: l10n.settingsRowAppearance,
                meta: l10n.settingsRowAppearanceMeta,
                value: _appearanceValue(ref, l10n),
                onTap: () => context.pushNamed(RouteNames.settingsAppearance),
              ),
              const MxDivider(indent: _rowDividerIndent),
              _SettingsRow(
                icon: Icons.translate_outlined,
                tint: colors.statusMastered,
                title: l10n.settingsRowLanguage,
                meta: l10n.settingsRowLanguageMeta,
                value: _languageValue(ref, l10n),
                onTap: () => context.pushNamed(RouteNames.settingsLanguage),
              ),
            ],
          ),
        ),
        const SizedBox(height: MxSpacing.space4),
        MxCard(
          padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
          child: Column(
            children: <Widget>[
              _SettingsRow(
                icon: Icons.cloud_outlined,
                tint: colors.statusNew,
                title: l10n.settingsRowAccount,
                meta: l10n.settingsRowAccountMeta,
                onTap: () => context.pushNamed(RouteNames.settingsAccount),
              ),
              const MxDivider(indent: _rowDividerIndent),
              _SettingsRow(
                icon: Icons.info_outline,
                tint: colors.textSecondary,
                title: l10n.settingsRowAbout,
                meta: l10n.settingsRowAboutMeta,
                onTap: () => _showAbout(context, l10n),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _learningValue(WidgetRef ref, AppLocalizations l10n) {
    final LearningSettingsView? view = ref
        .watch(learningSettingsControllerProvider)
        .asData
        ?.value;
    if (view == null) {
      return null;
    }
    return view.goalEnabled
        ? l10n.settingsGoalValue(view.settings.dailyNewLimit)
        : l10n.settingsValueOff;
  }

  String? _appearanceValue(WidgetRef ref, AppLocalizations l10n) {
    final AppThemeMode? mode = ref
        .watch(appearanceControllerProvider)
        .asData
        ?.value;
    return switch (mode) {
      AppThemeMode.system => l10n.appearanceSystem,
      AppThemeMode.light => l10n.appearanceLight,
      AppThemeMode.dark => l10n.appearanceDark,
      null => null,
    };
  }

  String? _languageValue(WidgetRef ref, AppLocalizations l10n) {
    final AppLanguage? language = ref
        .watch(languageControllerProvider)
        .asData
        ?.value;
    return switch (language) {
      AppLanguage.system => l10n.appearanceSystem,
      AppLanguage.english => l10n.languageEnglishTitle,
      AppLanguage.vietnamese => l10n.languageVietnameseTitle,
      null => null,
    };
  }

  void _showAbout(BuildContext context, AppLocalizations l10n) {
    showAboutDialog(context: context, applicationName: l10n.appTitle);
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.l10n, required this.onSignIn});

  final AppLocalizations l10n;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return MxCard(
      key: const ValueKey<String>('mx-node:20-settings/account-card'),
      child: Row(
        children: <Widget>[
          MxAvatar(
            icon: Icons.person_outline,
            size: MxSpacing.space12,
            shape: MxAvatarShape.circle,
            background: colors.surfaceMuted,
            foreground: colors.textSecondary,
          ),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(l10n.settingsNotSignedIn, role: MxTextRole.titleMedium),
                const SizedBox(height: MxSpacing.space1),
                MxText(
                  l10n.settingsSignInPrompt,
                  role: MxTextRole.bodySmall,
                  color: colors.textSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: MxSpacing.space3),
          MxPrimaryButton(
            label: l10n.settingsSignIn,
            icon: Icons.login_outlined,
            size: MxButtonSize.small,
            onPressed: onSignIn,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.tint,
    required this.title,
    required this.meta,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String meta;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final String? value = this.value;
    return MxListTile(
      leading: MxIconTile(color: tint, icon: icon),
      title: title,
      subtitle: meta,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (value != null)
            MxText(
              value,
              role: MxTextRole.labelLarge,
              color: colors.textSecondary,
            ),
          // Chevron only on navigable rows (the disabled Audio row shows none).
          if (onTap != null) ...<Widget>[
            const SizedBox(width: MxSpacing.space2),
            Icon(Icons.chevron_right, color: colors.textSecondary),
          ],
        ],
      ),
    );
  }
}
