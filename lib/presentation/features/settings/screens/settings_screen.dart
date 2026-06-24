import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/widgets/settings_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Settings hub — the bottom-nav "Settings" tab (the `/settings` shell branch;
/// kit screen 20). An account summary card + grouped category rows that push the
/// immersive settings sub-screens. The shell stays watch-free — [SettingsBody]
/// owns the data watch. WBS 8.1.x.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(title: l10n.settingsTitle),
      useShell: false,
      body: const SettingsBody(),
    );
  }
}
