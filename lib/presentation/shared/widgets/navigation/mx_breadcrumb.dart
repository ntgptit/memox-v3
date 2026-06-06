import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// A tappable segment of an [MxBreadcrumb] path.
class MxBreadcrumbSegment {
  const MxBreadcrumbSegment({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;
}

/// Folder ▸ deck ▸ card path — horizontally scrollable.
///
/// Section A of the handoff. The last segment is the current location: bold and
/// non-tappable regardless of its `onTap`.
class MxBreadcrumb extends StatelessWidget {
  const MxBreadcrumb({required this.segments, super.key});

  final List<MxBreadcrumbSegment> segments;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final TextTheme text = context.textTheme;
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < segments.length; i++) {
      final bool isLast = i == segments.length - 1;
      final MxBreadcrumbSegment segment = segments[i];
      if (i > 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xxs),
            child: Icon(
              Icons.chevron_right,
              size: SizeTokens.iconXs,
              color: scheme.onSurfaceVariant,
            ),
          ),
        );
      }
      final TextStyle style = (text.labelLarge ?? const TextStyle()).copyWith(
        color: isLast ? scheme.onSurface : scheme.onSurfaceVariant,
        fontWeight: isLast ? TypographyTokens.bold : TypographyTokens.medium,
      );
      children.add(
        MxTappable(
          onTap: isLast ? null : segment.onTap,
          borderRadius: RadiusTokens.brFull,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.sm,
              vertical: SpacingTokens.xs,
            ),
            child: Text(segment.label, style: style),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
