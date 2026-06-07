import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';

/// Overline label above a group — ALL-CAPS, +1.2 letter-spacing.
///
/// Section C of the handoff. Renders the `overline` custom text style at
/// `onSurfaceVariant`. Optional trailing widget (e.g. a "See all" text action).
///
/// Purpose:
/// Provides a reusable MemoX layout widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared layout surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - label: public content.
/// - trailing: public property.
/// Category:
/// layout
class MxSectionHeader extends StatelessWidget {
  const MxSectionHeader({required this.label, this.trailing, super.key});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Text title = Text(
      StringUtils.uppercased(label),
      style: context.customTextStyles.overline.copyWith(
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
    if (trailing == null) {
      return title;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(child: title),
        const SizedBox(width: SpacingTokens.sm),
        trailing!,
      ],
    );
  }
}
