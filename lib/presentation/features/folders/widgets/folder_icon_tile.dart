import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_opacity.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// A tinted rounded icon tile — the leading affordance on a folder row and the
/// header of the folder action sheet
/// (`docs/design/screens/library-overview.visual-contract.md` §Folder Card
/// Contract).
///
/// Mirrors the kit `.icon-tile`: a `--memox-size-icon-tile` (40px) square at
/// `--memox-radius-md`, with a soft background derived from [color] at
/// [MxOpacity.hover] and the glyph drawn in [color] at full strength. Callers
/// resolve [color] / [icon] from the folder's stored tokens via
/// `folder_visual_tokens.dart`; for neutral / danger sheet rows they pass a
/// theme role color directly.
class FolderIconTile extends StatelessWidget {
  const FolderIconTile({required this.color, required this.icon, super.key});

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
