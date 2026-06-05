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
