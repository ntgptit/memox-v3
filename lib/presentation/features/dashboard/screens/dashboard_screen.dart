import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/widgets/dashboard_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Dashboard — the `/home` destination (engagement; WBS 5.x — restored 2026-06-25
/// by owner ruling). A "today overview" hub: a greeting app bar with a settings
/// affordance over a stat strip + continue-studying + due snapshot + recent decks
/// + a Stats shortcut. The shell stays watch-free — [DashboardBody] owns the watch.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({this.now, super.key});

  /// Reference time for the greeting + date (injected by tests/goldens for
  /// determinism). Defaults to `DateTime.now()`.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(
        titleWidget: _Greeting(now: now ?? DateTime.now()),
        actions: <Widget>[
          MxIconButton(
            key: const ValueKey<String>('mx-node:02-dashboard/settings'),
            icon: Icons.settings_outlined,
            tooltip: l10n.settingsTitle,
            onPressed: () => context.goNamed(RouteNames.settings),
          ),
        ],
      ),
      body: DashboardBody(now: now),
    );
  }
}

/// The app-bar greeting block: today's date over a time-of-day greeting.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    final String date = MaterialLocalizations.of(context).formatFullDate(now);
    final String greeting = now.hour < 12
        ? l10n.dashboardGreetingMorning
        : now.hour < 18
        ? l10n.dashboardGreetingAfternoon
        : l10n.dashboardGreetingEvening;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MxText(
          date,
          role: MxTextRole.bodySmall,
          color: colors.textSecondary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        MxText(
          greeting,
          role: MxTextRole.displayMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
