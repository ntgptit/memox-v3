import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/stats/widgets/stats_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Stats — the bottom-nav "Stats" tab (the `/progress` shell branch; screen 18).
///
/// A read-only summary surface: this week's review activity (a column chart) and
/// per-deck mastery. The deeper Progress analytics (range tabs, accuracy, box
/// distribution) live on a separate Progress detail (screen 19, pending). The
/// shell stays watch-free — [StatsBody] owns the data watch. `useShell: false`
/// because the body owns its own gutter + scroll padding (matching the mock).
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(title: l10n.statsTitle),
      useShell: false,
      body: const StatsBody(),
    );
  }
}
