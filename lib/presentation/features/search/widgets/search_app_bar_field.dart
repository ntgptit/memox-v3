import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/hooks/mx_hooks.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// The global-search input, hosted in the screen app bar. Owns the text
/// controller, autofocuses on open, and mirrors query changes from the parent.
///
/// One-directional per edge: parent query drives controller, and keystrokes
/// flow back through [onChanged].
class SearchAppBarField extends HookWidget {
  const SearchAppBarField({
    required this.query,
    required this.onChanged,
    super.key,
  });

  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxSearchControllerState search = useMxSearchController(
      externalText: query,
      clearWhenExternalTextEmpty: true,
    );
    return MxSearchField(
      controller: search.controller,
      autofocus: true,
      hintText: l10n.searchFieldHint,
      clearTooltip: l10n.searchClearTooltip,
      emptyTrailing: const _SearchShortcutKeycap(),
      onChanged: onChanged,
    );
  }
}

class _SearchShortcutKeycap extends StatelessWidget {
  const _SearchShortcutKeycap();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: SizeTokens.surfaceBadgeSm,
        height: SizeTokens.surfaceBadgeSm,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.16),
          borderRadius: RadiusTokens.brSm,
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.38),
          ),
        ),
        child: MxText(
          String.fromCharCode(0x4B),
          role: MxTextRole.labelSmall,
          color: scheme.onSurfaceVariant,
          fontWeight: TypographyTokens.bold,
        ),
      ),
    );
  }
}
