import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/shared/hooks/mx_hooks.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// Always-visible inline search below the Library title. Scope-local; it never
/// navigates (`docs/wireframes/02-library.md`). Owns the text controller and
/// pushes changes into [LibraryToolbar].
class LibrarySearchField extends HookConsumerWidget {
  const LibrarySearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String searchTerm = ref.watch(
      libraryToolbarProvider.select(
        (LibraryToolbarState state) => state.searchTerm,
      ),
    );
    final MxSearchControllerState search = useMxSearchController(
      externalText: searchTerm,
      clearWhenExternalTextEmpty: true,
    );

    return MxSearchField(
      controller: search.controller,
      hintText: l10n.librarySearchHint,
      emptyTrailing: _SearchShortcutKeycap(
        label: l10n.librarySearchShortcutLabel,
      ),
      clearTooltip: l10n.librarySearchClearTooltip,
      onChanged: (String value) =>
          ref.read(libraryToolbarProvider.notifier).setSearch(value),
    );
  }
}

class _SearchShortcutKeycap extends StatelessWidget {
  const _SearchShortcutKeycap({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    // Bare keycap: MxSearchField right-aligns and insets the trailing widget.
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xs,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: OpacityTokens.focus),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: OpacityTokens.focus),
        ),
        borderRadius: RadiusTokens.brSm,
      ),
      child: MxText(
        label,
        role: MxTextRole.labelSmall,
        color: scheme.onSurfaceVariant,
        fontWeight: TypographyTokens.semiBold,
      ),
    );
  }
}
