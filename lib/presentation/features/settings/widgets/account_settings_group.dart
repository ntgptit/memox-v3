import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/account_settings_view.dart';
import 'package:memox/domain/models/cloud_account_link.dart';
import 'package:memox/domain/types/cloud_account.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_avatar.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// Renders the Account settings body for each [AccountLinkStatus].
///
/// V1 (WBS 8.5.1) is display-only: the sign-in affordance is shown disabled and
/// the signed-in Drive actions read as "coming soon". Sign-in / sign-out / Drive
/// sync wire up with WBS 8.6.1 / 8.6.2. The signed-out layout matches the kit
/// mock `21-account-sync--signed-out` (hero card + "What stays local").
class AccountSettingsGroup extends StatelessWidget {
  const AccountSettingsGroup({required this.view, super.key});

  final AccountSettingsView view;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CloudAccountLink? link = view.link;
    return switch (view.status) {
      AccountLinkStatus.signedOut => _SignedOut(l10n: l10n),
      AccountLinkStatus.unconfigured => _SignedOut(
        l10n: l10n,
        noticeText: l10n.accountUnconfiguredBody,
      ),
      AccountLinkStatus.unsupported => _SignedOut(
        l10n: l10n,
        noticeText: l10n.accountUnsupportedBody,
      ),
      AccountLinkStatus.signedIn when link != null => _SignedIn(
        l10n: l10n,
        link: link,
        driveNoticeText: l10n.accountDriveBackupComingSoon,
      ),
      AccountLinkStatus.needsDriveAuthorization when link != null => _SignedIn(
        l10n: l10n,
        link: link,
        driveNoticeText: l10n.accountAuthorizeDriveComingSoon,
      ),
      _ => _SignedOut(l10n: l10n),
    };
  }
}

String? _initials(CloudAccountLink link) {
  final String displayName = link.displayName == null
      ? ''
      : StringUtils.trimmed(link.displayName!);
  final String source = displayName.isNotEmpty
      ? displayName
      : StringUtils.trimmed(link.email);
  return source.isEmpty ? null : StringUtils.uppercased(source.substring(0, 1));
}

class _SignedOut extends StatelessWidget {
  const _SignedOut({required this.l10n, this.noticeText});

  final AppLocalizations l10n;

  /// Extra explanation for the `unconfigured` / `unsupported` states; `null`
  /// for a plain signed-out screen (matches the mock, which has no caption).
  final String? noticeText;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.screenPadding),
      children: <Widget>[
        MxCard(
          child: Column(
            children: <Widget>[
              const MxIconTile(
                icon: Icons.cloud_outlined,
                size: SizeTokens.button,
              ),
              const SizedBox(height: SpacingTokens.lg),
              MxText(
                l10n.accountSignedOutHeading,
                role: MxTextRole.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.sm),
              MxText(
                l10n.accountSignedOutBody,
                role: MxTextRole.bodyMedium,
                textAlign: TextAlign.center,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: SpacingTokens.lg),
              MxActionButton(
                intent: MxActionIntent.screenPrimary,
                label: l10n.accountSignInWithGoogle,
                icon: Icons.login,
                onPressed: null,
              ),
              if (noticeText != null) ...<Widget>[
                const SizedBox(height: SpacingTokens.sm),
                MxText(
                  noticeText!,
                  role: MxTextRole.labelMedium,
                  textAlign: TextAlign.center,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        MxSectionHeader(label: l10n.accountWhatStaysLocalTitle),
        const SizedBox(height: SpacingTokens.xs),
        MxCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              MxListTile(
                leading: const MxIconTile(icon: Icons.smartphone_outlined),
                title: l10n.accountStaysLocalDecksTitle,
                subtitle: l10n.accountStaysLocalDecksBody,
              ),
              MxListTile(
                leading: const MxIconTile(icon: Icons.shield_outlined),
                title: l10n.accountStaysLocalNoAccountTitle,
                subtitle: l10n.accountStaysLocalNoAccountBody,
              ),
              MxListTile(
                leading: const MxIconTile(icon: Icons.cloud_upload_outlined),
                title: l10n.accountStaysLocalManualTitle,
                subtitle: l10n.accountStaysLocalManualBody,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignedIn extends StatelessWidget {
  const _SignedIn({
    required this.l10n,
    required this.link,
    required this.driveNoticeText,
  });

  final AppLocalizations l10n;
  final CloudAccountLink link;
  final String driveNoticeText;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.screenPadding),
      children: <Widget>[
        MxSectionHeader(label: l10n.accountSectionLabel),
        const SizedBox(height: SpacingTokens.xs),
        MxCard(
          child: Row(
            children: <Widget>[
              MxAvatar(initials: _initials(link), size: SizeTokens.avatar),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MxText(
                      link.email,
                      role: MxTextRole.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    MxText(
                      l10n.accountSignedInProviderLabel,
                      role: MxTextRole.labelMedium,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        MxSectionHeader(label: l10n.accountDriveBackupSectionLabel),
        const SizedBox(height: SpacingTokens.xs),
        MxCard(
          child: MxText(
            driveNoticeText,
            role: MxTextRole.bodyMedium,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
