import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/widgets/language_settings_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Language settings (kit screen 25): the app-language picker (System / English /
/// Tiếng Việt). A top-level immersive route (`/settings/language`, shell hidden),
/// reached from the Settings hub. The body owns the language state; the shell
/// stays watch-free. WBS 8.8.1.
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(title: l10n.languageTitle),
      useShell: false,
      body: const LanguageSettingsBody(),
    );
  }
}
