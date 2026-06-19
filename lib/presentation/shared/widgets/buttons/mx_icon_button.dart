import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';

/// A toolbar/app-bar icon button with a touch-safe target.
///
/// Purpose:
/// One icon-action primitive so app-bar and toolbar glyph buttons share the
/// same color, touch target, and tooltip handling instead of raw `IconButton`s.
///
/// Use when:
/// Placing a compact glyph-only action (search, sort, settings, close) in an
/// app bar, toolbar, or row.
///
/// Do not use when:
/// The action needs a visible label (use `MxActionButton` / `MxSecondaryButton`).
///
/// Category:
/// button
///
/// Public API:
/// - icon: the glyph to show.
/// - onPressed: tap handler; null disables the button.
/// - tooltip: optional long-press / hover tooltip and semantic label.
/// - color: optional icon color (defaults to the secondary text token).
class MxIconButton extends StatelessWidget {
  const MxIconButton({
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      color: color ?? colors.textSecondary,
    );
  }
}
