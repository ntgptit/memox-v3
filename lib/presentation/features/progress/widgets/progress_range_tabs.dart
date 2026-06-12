import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/types/progress_range.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// Week / Month / All-time segmented control
/// (`docs/wireframes/03-progress.md` §Range tabs; mock `shots/19-progress--*`).
class ProgressRangeTabs extends StatelessWidget {
  const ProgressRangeTabs({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final ProgressRange selected;
  final ValueChanged<ProgressRange> onSelect;

  String _label(AppLocalizations l10n, ProgressRange range) => switch (range) {
    ProgressRange.week => l10n.progressRangeWeek,
    ProgressRange.month => l10n.progressRangeMonth,
    ProgressRange.allTime => l10n.progressRangeAllTime,
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.xxs),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: RadiusTokens.brMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final ProgressRange range in ProgressRange.values)
            _RangeTab(
              label: _label(l10n, range),
              isSelected: range == selected,
              onTap: () => onSelect(range),
            ),
        ],
      ),
    );
  }
}

class _RangeTab extends StatelessWidget {
  const _RangeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;

    return Material(
      color: isSelected ? scheme.surface : scheme.surfaceContainer,
      borderRadius: RadiusTokens.brSm,
      child: MxTappable(
        onTap: onTap,
        borderRadius: RadiusTokens.brSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.xs,
          ),
          child: MxText(
            label,
            role: MxTextRole.labelMedium,
            color: isSelected ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
