import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/types/account_link_status.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/account_controller.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// The Account body (kit screen 21). V1 renders the signed-out sign-in hero over
/// the [AccountController] (which only ever resolves `signedOut` until sign-in
/// lands). The "Continue with Google" CTA is disabled — interactive sign-in +
/// Drive backup/restore (the other kit states) are Future (WBS 8.6.1/8.6.2).
class AccountSettingsBody extends ConsumerWidget {
  const AccountSettingsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<AccountLinkStatus> async = ref.watch(
      accountControllerProvider,
    );
    return AppAsyncBuilder<AccountLinkStatus>(
      value: async,
      loading: (_) => const MxLoadingState(),
      error: (Object error, StackTrace? _) => MxErrorState(
        title: l10n.accountErrorTitle,
        message: l10n.accountErrorMessage,
      ),
      // V1 only resolves signedOut; sign-in / Drive states are Future.
      // Expansion point — when interactive sign-in lands (WBS 8.6.1), switch on
      // the status (signedIn / needsDriveAuthorization / …) here instead of
      // always rendering the signed-out hero.
      data: (AccountLinkStatus _) => _SignInHero(l10n: l10n),
    );
  }
}

class _SignInHero extends StatelessWidget {
  const _SignInHero({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        MxSpacing.screen,
        MxSpacing.space4,
        MxSpacing.screen,
        MxSpacing.space6,
      ),
      children: <Widget>[
        MxCard(
          key: const ValueKey<String>('mx-node:21-account-sync/signin-card'),
          padding: const EdgeInsets.all(MxSpacing.space6),
          child: Column(
            children: <Widget>[
              MxIconTile(color: colors.accent, icon: Icons.cloud_outlined),
              const SizedBox(height: MxSpacing.space4),
              MxText(
                l10n.accountSignInTitle,
                role: MxTextRole.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MxSpacing.space2),
              MxText(
                l10n.accountSignInMessage,
                role: MxTextRole.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MxSpacing.space5),
              MxPrimaryButton(
                key: const ValueKey<String>(
                  'mx-node:21-account-sync/signin-button',
                ),
                label: l10n.accountContinueWithGoogle,
                icon: Icons.login_outlined,
                fullWidth: true,
                // Disabled in V1 — interactive sign-in is Future (WBS 8.6.1).
                onPressed: null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
