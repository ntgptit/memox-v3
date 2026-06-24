import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_switch.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// The Daily reminder card (kit `22--goal-*` reminder row): a header row with a
/// disabled toggle.
///
/// The reminder feature (enable + time + repeat + OS notification permission) is
/// **Future** — there is no reminder persistence in `LearningSettings` and no
/// notification-scheduling dependency yet (engagement reminders are pending
/// approval, `docs/business/system/overview.md`). The card renders the off state
/// the goal-on/goal-off mocks show, with the toggle disabled until that BE lands.
class LearningReminderCard extends StatelessWidget {
  const LearningReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    return MxCard(
      key: const ValueKey<String>('mx-node:22-learning-settings/reminder-card'),
      child: MxListTile(
        leading: MxIconTile(
          color: colors.warn,
          icon: Icons.notifications_outlined,
        ),
        title: l10n.learningReminderTitle,
        subtitle: l10n.learningReminderOffDesc,
        // Disabled (onChanged: null) — reminders are Future (no BE yet).
        trailing: const MxSwitch(value: false),
      ),
    );
  }
}
