import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// Centered empty-state panel: an icon tile, title, message, and optional CTA.
///
/// Purpose:
/// Gives every screen one consistent "there is nothing here yet" surface so a
/// legitimately empty result never reads as a bug, and always points the user
/// at the first useful action.
///
/// Use when:
/// A load succeeded but returned no items the user can act on (an empty folder,
/// deck, or list) and you want to guide them forward.
///
/// Do not use when:
/// The load failed (use `MxErrorState`) or a search/filter returned nothing
/// (use `MxNoResultsState`).
///
/// Category:
/// feedback
///
/// Public API:
/// - icon: glyph shown in the tinted tile.
/// - title: short headline; pass already-localized copy.
/// - message: one or two lines of guidance; pass already-localized copy.
/// - action: optional primary CTA slot (e.g. an `MxButton`).
class MxEmptyState extends StatelessWidget {
  const MxEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MxSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MxSpacing.space12,
              height: MxSpacing.space12,
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius: MxRadius.mdAll,
              ),
              child: Icon(icon, color: colors.accent),
            ),
            const SizedBox(height: MxSpacing.space4),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MxSpacing.space2),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: MxSpacing.space5),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
