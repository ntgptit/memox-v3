import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// Labeled slider field with a value summary and evenly spaced sublabels.
///
/// The component mirrors the MemoX settings slider mock: a title/value row,
/// a themed Material slider track, and three aligned sublabels underneath.
class MxSliderField extends StatelessWidget {
  const MxSliderField({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.sublabels,
    required this.onChanged,
    super.key,
  }) : assert(max > min),
       assert(sublabels.length == 3);

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final List<String> sublabels;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final double clampedValue = value.clamp(min, max);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              MxText(label, role: MxTextRole.titleSmall),
              MxText(
                valueLabel,
                role: MxTextRole.titleSmall,
                color: scheme.primary,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Slider(
            value: clampedValue,
            min: min,
            max: max,
            onChanged: onChanged,
            semanticFormatterCallback: (double currentValue) => valueLabel,
          ),
          const SizedBox(height: SpacingTokens.xxs),
          Row(
            children: <Widget>[
              Expanded(
                child: MxText(
                  sublabels[0],
                  role: MxTextRole.labelSmall,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: MxText(
                  sublabels[1],
                  role: MxTextRole.labelSmall,
                  color: scheme.onSurfaceVariant,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: MxText(
                  sublabels[2],
                  role: MxTextRole.labelSmall,
                  color: scheme.onSurfaceVariant,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
      ),
    );
  }
}
