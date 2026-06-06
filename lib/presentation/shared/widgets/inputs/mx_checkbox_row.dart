import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

/// Shared checkbox row primitive for local session toggles.
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
