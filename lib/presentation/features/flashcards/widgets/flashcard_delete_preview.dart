import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// Front/back preview surface shown inside the delete-confirmation dialog
/// (`docs/wireframes/06-flashcard-list.md` delete-card,
/// `docs/wireframes/08-flashcard-edit.md` delete). Reused by the Flashcard List
/// single-card delete and the Flashcard Edit danger-zone delete so both render
/// the same real front/back content above the warning copy.
class FlashcardDeletePreview extends StatelessWidget {
  const FlashcardDeletePreview({
    required this.front,
    required this.back,
    super.key,
  });

  final String front;
  final String back;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      key: const ValueKey<String>('flashcard_delete_preview'),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: RadiusTokens.brMd,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MxText(
            front,
            role: MxTextRole.titleSmall,
            fontWeight: TypographyTokens.bold,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (back.isNotEmpty) ...<Widget>[
            const SizedBox(height: SpacingTokens.xxs),
            MxText(
              back,
              role: MxTextRole.bodyMedium,
              color: scheme.onSurfaceVariant,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
