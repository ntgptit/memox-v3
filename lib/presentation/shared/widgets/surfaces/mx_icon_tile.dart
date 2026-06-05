import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

/// Tinted square holding a leading glyph for list rows.
///
/// Section C of the handoff. Default tint is `primary @10%`; pass [color] to
/// recolor (e.g. accent for folders). Sizes 40 / 44.
class MxIconTile extends StatelessWidget {
  const MxIconTile({
    required this.icon,
    this.color,
    this.size = 44,
    super.key,
  });

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color tint = color ?? context.colorScheme.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: OpacityTokens.hover),
        borderRadius: RadiusTokens.brMd,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: SizeTokens.iconSm + 2, color: tint),
    );
  }
}
