import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';

/// Big tabular metric + overline caption.
///
/// Section E of the handoff. Renders the 48px `statDisplay` style with
/// tabular figures (so digits don't jitter as the value counts up) over an
/// ALL-CAPS caption.
class MxStatDisplay extends StatelessWidget {
  const MxStatDisplay({
    required this.value,
    required this.caption,
    this.alignment = CrossAxisAlignment.center,
    this.color,
    super.key,
  });

  final String value;
  final String caption;
  final CrossAxisAlignment alignment;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: <Widget>[
        Text(
          value,
          style: context.customTextStyles.statDisplay.copyWith(
            color: color ?? scheme.onSurface,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: SpacingTokens.xs + 2),
        Text(
          StringUtils.uppercased(caption),
          style: context.customTextStyles.overline.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
