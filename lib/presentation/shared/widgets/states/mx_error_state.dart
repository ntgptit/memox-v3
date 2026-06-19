import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// Centered error-state panel: a danger-tinted icon tile, title, message, CTA.
///
/// Purpose:
/// Presents a failed load with a calm, actionable recovery surface so the user
/// always sees what went wrong and how to retry — never a crash or a silent
/// blank screen.
///
/// Use when:
/// A load or operation failed and the user can recover (typically by retrying);
/// pass a retry control via [action].
///
/// Do not use when:
/// The result is legitimately empty (use `MxEmptyState`) or a search returned
/// nothing (use `MxNoResultsState`).
///
/// Category:
/// feedback
///
/// Public API:
/// - title: short headline naming the failure; pass already-localized copy.
/// - message: one or two lines explaining the next step; already-localized.
/// - icon: optional override for the tile glyph (defaults to a warning).
/// - action: optional recovery CTA slot (e.g. a Retry `MxButton`).
class MxErrorState extends StatelessWidget {
  const MxErrorState({
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
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
                color: colors.dangerSoft,
                borderRadius: MxRadius.mdAll,
              ),
              child: Icon(icon, color: colors.danger),
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
