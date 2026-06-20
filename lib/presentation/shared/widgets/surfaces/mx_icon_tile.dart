import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_opacity.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// A tinted rounded icon tile — the leading affordance on list rows and the
/// header of action sheets / summary cards.
///
/// Purpose:
/// One owner for the kit `.icon-tile`: a `--memox-size-icon-tile` (40px) square
/// at `--memox-radius-md`, so every tinted leading glyph shares the same size,
/// radius, and soft-tint recipe instead of ad-hoc `Container`s.
///
/// Use when:
/// A row / card / sheet header needs a small tinted icon chip.
///
/// Do not use when:
/// You need a plain icon (use `Icon` with an `MxIconSize`) or a large feature
/// hero tile.
///
/// Category:
/// display
///
/// Public API:
/// - color: the tint — the glyph color; the background is this color at
///   [MxOpacity.hover] (a soft tinted fill).
/// - icon: the glyph drawn inside the tile.
class MxIconTile extends StatelessWidget {
  const MxIconTile({required this.color, required this.icon, super.key});

  /// Tile tint — the glyph color; the background is this color at low alpha.
  final Color color;

  /// The glyph drawn inside the tile.
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: MxSpacing.space10,
    height: MxSpacing.space10,
    decoration: BoxDecoration(
      color: color.withValues(alpha: MxOpacity.hover),
      borderRadius: MxRadius.mdAll,
    ),
    child: Icon(icon, color: color, size: MxIconSize.md),
  );
}
