import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

/// Round icon button with two densities.
///
/// Section B of the handoff. [compact] is a 36dp visual box with a 20dp glyph
/// (the everyday density); [toolbar] keeps the 48dp appbar-safe box. Both keep
/// a ≥ 48dp touch target via `MaterialTapTargetSize.padded`.
enum MxIconButtonSize {
  compact(36, SizeTokens.iconSm),
  toolbar(SizeTokens.button, SizeTokens.iconMd);

  const MxIconButtonSize(this.box, this.glyph);

  final double box;
  final double glyph;
}

/// Compact icon-only action button with MemoX shared sizing.
///
/// Purpose:
/// Provides a reusable icon button that keeps the MemoX touch-target and
/// density rules consistent across screens.
///
/// Use when:
/// A surface needs a small icon-only action, either in toolbar density or as
/// a compact standalone control.
///
/// Do not use when:
/// The action needs a text label, a full-width primary action, or more than
/// one control in the same surface.
///
/// Category:
/// button
///
/// Public API:
/// - icon: icon glyph shown inside the button
/// - onPressed: tap callback; `null` disables the button
/// - tooltip: optional accessibility tooltip
/// - color: optional icon color override
/// - size: density preset that controls the visual box and glyph size
class MxIconButton extends StatelessWidget {
  const MxIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.size = MxIconButtonSize.toolbar,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final MxIconButtonSize size;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    tooltip: tooltip,
    icon: Icon(icon),
    iconSize: size.glyph,
    color: color,
    visualDensity: VisualDensity.compact,
    constraints: BoxConstraints.tightFor(width: size.box, height: size.box),
    padding: EdgeInsets.zero,
  );
}
