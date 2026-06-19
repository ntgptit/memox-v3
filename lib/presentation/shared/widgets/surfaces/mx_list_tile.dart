import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// A single content row: optional leading tile, title, subtitle, and trailing.
///
/// Purpose:
/// The standard list row for libraries, decks, and settings, so every row
/// shares the same height, spacing, overflow handling, and tap ink instead of
/// raw `ListTile`s with inconsistent metrics.
///
/// Use when:
/// Rendering a tappable (or static) row inside a card or list section.
///
/// Do not use when:
/// The row needs a bespoke multi-line layout — compose it directly instead.
///
/// Category:
/// display
///
/// Public API:
/// - title: primary line; pass already-localized copy.
/// - subtitle: optional secondary line; already-localized.
/// - leading: optional leading widget (e.g. an `MxAvatar`).
/// - trailing: optional trailing widget (e.g. a chevron).
/// - onTap: optional tap handler; when set the row shows a shaped ink ripple.
class MxListTile extends StatelessWidget {
  const MxListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    return MxTappable(
      onTap: onTap,
      borderRadius: MxRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
        child: Row(
          children: <Widget>[
            if (leading != null) ...<Widget>[
              leading!,
              const SizedBox(width: MxSpacing.space3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: MxSpacing.space2),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
