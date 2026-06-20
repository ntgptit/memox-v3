import 'package:flutter/material.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// A tinted rounded icon tile — the leading affordance on a folder row and the
/// header of the folder action sheet
/// (`docs/design/screens/library-overview.visual-contract.md` §Folder Card
/// Contract).
///
/// Thin folder-facing alias of the shared [MxIconTile] (single source for the
/// kit `.icon-tile` recipe) so folder rows/sheets keep their semantic name while
/// the size/radius/soft-tint logic lives in one place. Callers resolve [color] /
/// [icon] from the folder's stored tokens via `folder_visual_tokens.dart`; for
/// neutral / danger sheet rows they pass a theme role color directly.
class FolderIconTile extends StatelessWidget {
  const FolderIconTile({required this.color, required this.icon, super.key});

  /// Tile tint — the glyph color; the background is this color at low alpha.
  final Color color;

  /// The glyph drawn inside the tile.
  final IconData icon;

  @override
  Widget build(BuildContext context) => MxIconTile(color: color, icon: icon);
}
