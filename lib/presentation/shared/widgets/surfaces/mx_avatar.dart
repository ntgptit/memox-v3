import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// The shape of an [MxAvatar] tile.
enum MxAvatarShape {
  /// Rounded square — the leading tile used in list rows.
  rounded,

  /// Full circle — entity/user representation.
  circle,
}

/// A tinted identity tile showing an icon or short initials.
///
/// Purpose:
/// One consistent leading tile for list rows and headers, so icon/initials
/// tiles share the same size, tint, and shape instead of being hand-built per
/// screen.
///
/// Use when:
/// Representing a folder/deck/entity (icon) or a person/label (initials) as a
/// compact leading element.
///
/// Do not use when:
/// You need a full content surface (use `MxCard`) or a plain icon with no tile.
///
/// Category:
/// display
///
/// Public API:
/// - icon: glyph to show; takes precedence over [label].
/// - label: short initials shown when no [icon] is given.
/// - background: tile fill (defaults to the soft accent tint).
/// - foreground: icon/initials color (defaults to the accent).
/// - size: tile width/height (defaults to the 40dp row tile).
/// - shape: rounded square (default) or circle.
///
/// Variants:
/// - shape: [MxAvatarShape.rounded] (rows) vs [MxAvatarShape.circle] (entities).
class MxAvatar extends StatelessWidget {
  const MxAvatar({
    this.icon,
    this.label,
    this.background,
    this.foreground,
    this.size = MxSpacing.space10,
    this.shape = MxAvatarShape.rounded,
    super.key,
  });

  final IconData? icon;
  final String? label;
  final Color? background;
  final Color? foreground;
  final double size;
  final MxAvatarShape shape;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    final Color fg = foreground ?? colors.accent;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? colors.accentSoft,
        shape: shape == MxAvatarShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: shape == MxAvatarShape.circle ? null : MxRadius.mdAll,
      ),
      child: icon != null
          ? Icon(icon, color: fg)
          : Text(
              label ?? '',
              style: theme.textTheme.labelLarge?.copyWith(color: fg),
            ),
    );
  }
}
