import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_stroke.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/shared/hooks/mx_search_controller_hooks.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';

/// Inline flashcard-list search field, bound to `flashcardSearchQueryProvider`
/// keyed by [deckId] (front/back filter is applied server-side). Provider-synced
/// via [useMxSearchController] so the body's no-results `Clear` CTA resets the
/// field. WBS 3.4.2.
class FlashcardListSearchField extends HookConsumerWidget {
  const FlashcardListSearchField({
    required this.deckId,
    this.autofocus = false,
    super.key,
  });

  final String deckId;
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String term = ref.watch(flashcardSearchQueryProvider(deckId));
    final MxSearchControllerState search = useMxSearchController(
      externalText: term,
      clearWhenExternalTextEmpty: true,
    );
    return MxSearchField(
      controller: search.controller,
      hintText: l10n.flashcardSearchHint,
      autofocus: autofocus,
      onChanged: (String value) => ref
          .read(flashcardSearchQueryProvider(deckId).notifier)
          .setTerm(value),
    );
  }
}

/// The flashcard-list **persistent** bottom search dock (kit `06` `search-dock`):
/// a flat full-bleed bar pinned at the foot — a top hairline over a surface fill
/// — hosting the [FlashcardListSearchField]. Unlike the toggle docks on Library /
/// Folder detail, this dock is **always present** while the deck has cards (the
/// kit `06` Loaded state ships the dock in its base tree); it is hidden only in
/// the empty / loading / error / reorder states.
///
/// Mounted in the `Scaffold.bottomNavigationBar` slot (via `MxScaffold`) so it
/// renders flat and full-bleed — no rounded/elevated BottomSheet chrome — and
/// reserves its own foot room under the card list. WBS 3.4.2.
class FlashcardListSearchDock extends StatelessWidget {
  const FlashcardListSearchDock({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.divider, width: MxStroke.hairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.screen,
            vertical: MxSpacing.space3,
          ),
          child: FlashcardListSearchField(deckId: deckId),
        ),
      ),
    );
  }
}
