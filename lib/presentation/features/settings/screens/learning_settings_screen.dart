import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/widgets/learning_settings_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Learning settings (kit screen 22): the daily-goal + reminder hub. A top-level
/// immersive route (`/settings/learning`, shell hidden), reached from the
/// Settings hub. The body owns the goal state; the shell stays watch-free.
/// WBS 8.2.2.
class LearningSettingsScreen extends StatelessWidget {
  const LearningSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(title: l10n.learningSettingsTitle),
      useShell: false,
      body: const LearningSettingsBody(),
    );
  }
}
