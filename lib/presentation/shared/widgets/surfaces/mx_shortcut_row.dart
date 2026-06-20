import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// A quiet, tappable entry-point row (the kit `ShortcutRow`): a flat (border-only)
/// card with a tinted icon tile, a label + optional subtitle, and a trailing
/// chevron.
///
/// Purpose:
/// One owner for cross-screen "refer / navigate" shortcuts (e.g. Dashboard →
/// Progress / Study). Flat by design — no accent fill, no shadow — so it reads as
/// a navigate affordance, not a study CTA.
///
/// Use when:
/// Offering a low-emphasis jump to another screen from a summary surface.
///
/// Do not use when:
/// The action is a primary call-to-action (use an `MxPrimaryButton`) or a plain
/// list item inside a grouped card (use `MxListTile`).
///
/// Category:
/// display
///
/// Public API:
/// - icon: the leading glyph.
/// - label: primary line (already-localized).
/// - subtitle: optional secondary line (already-localized).
/// - tint: icon-tile tint (defaults to the accent role).
/// - onTap: tap handler.
class MxShortcutRow extends StatelessWidget {
  const MxShortcutRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.tint,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return MxCard(
      elevated: false,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
      child: MxListTile(
        leading: MxIconTile(color: tint ?? colors.accent, icon: icon),
        title: label,
        subtitle: subtitle,
        trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
      ),
    );
  }
}
