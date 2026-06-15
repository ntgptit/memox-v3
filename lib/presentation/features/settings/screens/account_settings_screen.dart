import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/account_settings_view.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/viewmodels/account_settings_viewmodel.dart';
import 'package:memox/presentation/features/settings/widgets/account_settings_group.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Account & Sync settings screen (route `/settings/account`).
///
/// V1 (WBS 8.5.1) is display-only: it shows the linked/unlinked state from the
/// stored [CloudAccountLink]. Sign-in, sign-out, and Drive sync actions land
/// with WBS 8.6.1 / 8.6.2.
class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<AccountSettingsView> view = ref.watch(
      accountSettingsViewProvider,
    );
    return MxScaffold(
      appBar: MxAppBar(
        titleText: l10n.accountSettingsTitle,
        leading: MxIconButton(
          icon: Icons.arrow_back,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
      ),
      body: AppAsyncBuilder<AccountSettingsView>(
        value: view,
        error: (Object error, StackTrace? _) => _AccountError(
          message: error is Failure
              ? l10n.failureMessage(error, fallback: l10n.accountErrorBody)
              : l10n.accountErrorBody,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(accountSettingsViewProvider),
        ),
        data: (AccountSettingsView value) => AccountSettingsGroup(view: value),
      ),
    );
  }
}

class _AccountError extends StatelessWidget {
  const _AccountError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: SizeTokens.iconXl,
              color: scheme.error,
            ),
            const SizedBox(height: SpacingTokens.lg),
            MxText(
              message,
              role: MxTextRole.bodyMedium,
              textAlign: TextAlign.center,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: SpacingTokens.lg),
            MxActionButton(
              intent: MxActionIntent.inline,
              label: retryLabel,
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
