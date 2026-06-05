import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';

/// Overline label above a group — ALL-CAPS, +1.2 letter-spacing.
///
/// Section C of the handoff. Renders the `overline` custom text style at
/// `onSurfaceVariant`. Optional trailing widget (e.g. a "See all" text action).
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
