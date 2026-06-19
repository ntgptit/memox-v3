import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// Centered no-results panel: a neutral icon tile, title, message, optional CTA.
///
/// Purpose:
/// Distinguishes "your search/filter matched nothing" from a genuinely empty
/// collection or a load failure, so the user adjusts the query instead of
/// thinking the data is gone.
///
/// Use when:
/// A search or filter returns zero matches over data that does exist; offer a
/// "clear filters" control via [action] when relevant.
///
/// Do not use when:
/// The collection itself is empty (use `MxEmptyState`) or the load failed (use
/// `MxErrorState`).
///
/// Category:
/// feedback
///
/// Public API:
/// - title: short headline; pass already-localized copy.
/// - message: one or two lines on how to broaden the query; already-localized.
/// - icon: optional override for the tile glyph (defaults to a search glyph).
/// - action: optional CTA slot (e.g. a "Clear filters" `MxButton`).
class MxNoResultsState extends StatelessWidget {
  const MxNoResultsState({
    required this.title,
    required this.message,
    this.icon = Icons.search_off,
    this.action,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    final Widget? action = this.action;
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
                color: colors.surfaceMuted,
                borderRadius: MxRadius.mdAll,
              ),
              child: Icon(icon, color: colors.textSecondary),
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
              action,
            ],
          ],
        ),
      ),
    );
  }
}
