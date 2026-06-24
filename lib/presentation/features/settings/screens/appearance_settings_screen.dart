import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/widgets/appearance_settings_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Appearance settings (kit screen 24): the theme-mode picker (Light / Dark /
/// System). A top-level immersive route (`/settings/appearance`, shell hidden),
/// reached from the Settings hub. The body owns the theme state; the shell stays
/// watch-free. WBS 8.8.1.
class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(title: l10n.appearanceTitle),
      useShell: false,
      body: const AppearanceSettingsBody(),
    );
  }
}
