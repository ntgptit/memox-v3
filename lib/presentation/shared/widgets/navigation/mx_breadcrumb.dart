import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// One segment in an [MxBreadcrumb] trail.
@immutable
class MxBreadcrumbItem {
  const MxBreadcrumbItem({required this.label, this.icon, this.onTap});

  final String label;

  /// Optional leading glyph rendered before [label] (e.g. the home glyph on the
  /// root crumb). Inherits the segment's current-vs-ancestor colour.
  final IconData? icon;

  final VoidCallback? onTap;
}

/// A horizontal path trail (e.g. folder ancestry) with chevron separators.
///
/// Purpose:
/// One breadcrumb primitive so ancestry trails share spacing, separators, and
/// the current-vs-ancestor emphasis, and scroll instead of overflowing on deep
/// paths.
///
/// Use when:
/// Showing where the user is inside a nested hierarchy (folders), with tappable
/// ancestors.
///
/// Do not use when:
/// There is no hierarchy to show, or a single back action suffices.
///
/// Category:
/// navigation
///
/// Public API:
/// - items: ordered trail; the last item is the current location (not tappable
///   styling); earlier items use their [MxBreadcrumbItem.onTap].
class MxBreadcrumb extends StatelessWidget {
  const MxBreadcrumb({required this.items, super.key});

  final List<MxBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) Icon(Icons.chevron_right, color: colors.textTertiary),
            _segment(theme, colors, items[i], isCurrent: i == items.length - 1),
          ],
        ],
      ),
    );
  }

  Widget _segment(
    ThemeData theme,
    MxColors colors,
    MxBreadcrumbItem item, {
    required bool isCurrent,
  }) {
    final Color color = isCurrent ? colors.text : colors.textSecondary;
    final Text label = Text(
      item.label,
      style: theme.textTheme.labelLarge?.copyWith(color: color),
    );
    final Widget content = item.icon == null
        ? label
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(item.icon, size: MxIconSize.sm, color: color),
              const SizedBox(width: MxSpacing.space1),
              label,
            ],
          );
    final Widget padded = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.space1,
        vertical: MxSpacing.space1,
      ),
      child: content,
    );
    if (isCurrent || item.onTap == null) {
      return padded;
    }
    return MxTappable(onTap: item.onTap, child: padded);
  }
}
