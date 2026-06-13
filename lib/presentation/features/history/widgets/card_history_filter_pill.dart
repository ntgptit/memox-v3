import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/viewmodels/card_history_viewmodel.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// "All events" timeline filter pill (`docs/wireframes/09-flashcard-history.md`).
/// Opens a bottom sheet to pick the active [CardHistoryFilter].
class CardHistoryFilterPill extends StatelessWidget {
  const CardHistoryFilterPill({
    required this.filter,
    required this.onSelected,
    super.key,
  });

  final CardHistoryFilter filter;
  final ValueChanged<CardHistoryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxTappable(
      onTap: () => _open(context),
      borderRadius: RadiusTokens.brFull,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          borderRadius: RadiusTokens.brFull,
          border: Border.all(
            color: scheme.outlineVariant,
            width: BorderTokens.width,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.filter_list,
              size: SizeTokens.iconXs,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: SpacingTokens.xxs),
            MxText(
              _label(AppLocalizations.of(context), filter),
              role: MxTextRole.labelMedium,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: SpacingTokens.xxs),
            Icon(
              Icons.expand_more,
              size: SizeTokens.iconXs,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final CardHistoryFilter? picked =
        await showMxBottomSheet<CardHistoryFilter>(
          context,
          builder: (BuildContext sheetContext) => _FilterSheet(current: filter),
        );
    if (picked != null) {
      onSelected(picked);
    }
  }

  static String _label(AppLocalizations l10n, CardHistoryFilter filter) =>
      switch (filter) {
        CardHistoryFilter.all => l10n.cardHistoryFilterAll,
        CardHistoryFilter.reviews => l10n.cardHistoryFilterReviews,
        CardHistoryFilter.lifecycle => l10n.cardHistoryFilterLifecycle,
      };
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.current});

  final CardHistoryFilter current;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.lg,
              SpacingTokens.md,
              SpacingTokens.lg,
              SpacingTokens.sm,
            ),
            child: MxText(
              l10n.cardHistoryFilterSheetTitle,
              role: MxTextRole.titleSmall,
            ),
          ),
          for (final CardHistoryFilter option in CardHistoryFilter.values)
            _FilterRow(
              label: CardHistoryFilterPill._label(l10n, option),
              selected: option == current,
              onTap: () => Navigator.of(context).pop(option),
            ),
          const SizedBox(height: SpacingTokens.sm),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxTappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: MxText(
                label,
                role: MxTextRole.bodyLarge,
                color: selected ? scheme.primary : scheme.onSurface,
              ),
            ),
            if (selected)
              Icon(Icons.check, size: SizeTokens.iconSm, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}
