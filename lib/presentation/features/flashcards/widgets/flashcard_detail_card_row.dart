import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// One flashcard row (`docs/wireframes/06-flashcard-list.md` §Card row display
/// rules): Front (large, line 1) + Back (subtitle, line 2). Tap opens edit,
/// long-press / kebab opens the row action sheet.
///
/// Note / example / pronunciation / hint are intentionally NOT shown inline
/// (§Forbidden). Tag chips + state badges are Future (not in the V1 read model).
class FlashcardDetailCardRow extends StatelessWidget {
  const FlashcardDetailCardRow({
    required this.card,
    required this.onTap,
    required this.onShowActions,
    this.trailing,
    super.key,
  });

  final Flashcard card;
  final VoidCallback onTap;
  final VoidCallback onShowActions;

  /// Replaces the trailing kebab in reorder mode (e.g. a drag handle).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color tone = context.colorScheme.onSurfaceVariant;

    return MxCard(
      onTap: onTap,
      onLongPress: onShowActions,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  card.front,
                  role: MxTextRole.titleSmall,
                  fontWeight: TypographyTokens.bold,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.xs),
                MxText(
                  card.back,
                  role: MxTextRole.bodyMedium,
                  color: tone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          trailing ??
              MxIconButton(
                icon: Icons.more_vert,
                tooltip: l10n.flashcardsActionsTitle,
                size: MxIconButtonSize.compact,
                onPressed: onShowActions,
              ),
        ],
      ),
    );
  }
}
