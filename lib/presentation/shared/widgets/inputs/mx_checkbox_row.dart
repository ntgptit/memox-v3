import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

/// Shared checkbox row primitive for local session toggles.
///
/// Purpose:
/// Provides a reusable MemoX input widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared input surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - label: public content.
/// - value: public configuration.
/// - onChanged: callback.
/// Category:
/// input
class MxCheckboxRow extends StatelessWidget {
  const MxCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxTappable(
      onTap: () => onChanged(!value),
      borderRadius: RadiusTokens.brMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xxs),
        child: Row(
          children: <Widget>[
            Checkbox(
              value: value,
              onChanged: (bool? next) => onChanged(next ?? false),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: SpacingTokens.xs),
            Expanded(
              child: MxText(
                label,
                role: MxTextRole.labelMedium,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
