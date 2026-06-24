import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// One row of the Tag-Management list (kit `11`): a neutral `#` tile + the tag
/// name over its card count, with a trailing overflow (kebab) that opens the
/// per-tag action sheet (Rename / Merge / Delete).
class TagRow extends StatelessWidget {
  const TagRow({required this.tag, required this.onOverflow, super.key});

  final TagWithCount tag;
  final VoidCallback onOverflow;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MxSpacing.space2),
      child: Row(
        children: <Widget>[
          MxIconTile(color: colors.textSecondary, icon: Icons.tag),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  tag.name,
                  role: MxTextRole.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: MxSpacing.space1),
                MxText(
                  l10n.tagManagementCardCount(tag.cardCount),
                  role: MxTextRole.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          MxIconButton(
            icon: Icons.more_vert,
            tooltip: l10n.tagManagementActionsTooltip,
            onPressed: onOverflow,
          ),
        ],
      ),
    );
  }
}
