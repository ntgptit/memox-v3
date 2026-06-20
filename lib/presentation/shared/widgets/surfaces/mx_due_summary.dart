import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// A quiet "today snapshot" due card (the kit `DueSummary`).
///
/// Purpose:
/// One owner for the Dashboard's deliberately low-pressure due summary — a soft
/// tile + count + a SECONDARY (never accent-hero) action — so the dashboard
/// *refers* to work without pressuring the user to study now. The strong study
/// CTAs live on Study / Progress. The [caughtUp] variant shows the all-clear.
///
/// Use when:
/// Summarizing "what's due" on a calm overview surface.
///
/// Do not use when:
/// You need a primary study call-to-action (use an `MxPrimaryButton`).
///
/// Category:
/// card
///
/// Public API:
/// Copy is caller-localized — this widget owns no strings.
/// - title / subtitle: the count line + meta line.
/// - actionLabel / onAction: the optional secondary action (hidden when
///   [caughtUp] or when no label is given).
/// - caughtUp: render the all-clear (check glyph, no action).
class MxDueSummary extends StatelessWidget {
  const MxDueSummary({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.caughtUp = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool caughtUp;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final String? actionLabel = this.actionLabel;
    return MxCard(
      child: Row(
        children: <Widget>[
          MxIconTile(
            color: caughtUp ? colors.statusMastered : colors.accent,
            icon: caughtUp ? Icons.check_rounded : Icons.layers_outlined,
          ),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(title, role: MxTextRole.titleSmall),
                const SizedBox(height: MxSpacing.space1),
                MxText(
                  subtitle,
                  role: MxTextRole.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          if (!caughtUp && actionLabel != null) ...<Widget>[
            const SizedBox(width: MxSpacing.space3),
            MxSecondaryButton(label: actionLabel, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
