import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/widgets/account_settings_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Account & Drive sync (kit screen 21). V1 is display-only: the signed-out
/// sign-in hero. A top-level immersive route (`/settings/account`, shell
/// hidden), reached from the Settings hub. Interactive Google sign-in + Drive
/// backup/restore (the other kit states) are Future (WBS 8.6.1/8.6.2). WBS 8.5.1.
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(title: l10n.accountTitle),
      useShell: false,
      body: const AccountSettingsBody(),
    );
  }
}
