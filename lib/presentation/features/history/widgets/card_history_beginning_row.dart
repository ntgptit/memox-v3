import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// Terminal "Beginning of history" marker closing the activity feed
/// (`docs/wireframes/09-flashcard-history.md` §Timeline).
class CardHistoryBeginningRow extends StatelessWidget {
  const CardHistoryBeginningRow({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: SizeTokens.iconMd,
            child: Center(
              child: Container(
                width: SpacingTokens.sm,
                height: SpacingTokens.sm,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.outlineVariant,
                    width: BorderTokens.width,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          MxText(
            AppLocalizations.of(context).cardHistoryBeginning,
            role: MxTextRole.labelMedium,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
