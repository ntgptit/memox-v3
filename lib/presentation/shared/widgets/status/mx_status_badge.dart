import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/widgets/status/mx_card_status.dart';

/// Card-lifecycle pill — colored dot + label on a neutral container.
///
/// Section E of the handoff. The [label] is caller-supplied (localized); the
/// color comes from [status].
class MxStatusBadge extends StatelessWidget {
  const MxStatusBadge({
    required this.status,
    required this.label,
    super.key,
  });

  final MxCardStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color tone = status.color(context);
    return Container(
      height: SizeTokens.chipSm,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: RadiusTokens.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: SpacingTokens.sm - 1,
            height: SpacingTokens.sm - 1,
            decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
          ),
          const SizedBox(width: SpacingTokens.xs + 2),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: tone,
              fontWeight: TypographyTokens.bold,
            ),
          ),
        ],
      ),
    );
  }
}
