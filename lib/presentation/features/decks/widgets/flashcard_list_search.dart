import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/shared/hooks/mx_search_controller_hooks.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Inline flashcard-list search field, bound to `flashcardSearchQueryProvider`
/// keyed by [deckId] (front/back filter is applied server-side). WBS 3.4.2.
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

/// Flashcard-list search-mode app bar (field + Cancel), keyed by [deckId].
class FlashcardListSearchAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  const FlashcardListSearchAppBar({required this.deckId, super.key});

  final String deckId;

  static const double _toolbarHeight = kToolbarHeight + MxSpacing.space4;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    void cancel() {
      ref.read(flashcardSearchQueryProvider(deckId).notifier).clear();
      ref.read(flashcardSearchActiveProvider(deckId).notifier).deactivate();
    }

    return MxAppBar(
      automaticallyImplyLeading: false,
      titleSpacing: MxSpacing.screen,
      toolbarHeight: _toolbarHeight,
      titleWidget: FlashcardListSearchField(deckId: deckId, autofocus: true),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: MxSpacing.space2),
          child: MxSecondaryButton(
            label: l10n.commonCancel,
            variant: MxSecondaryVariant.text,
            onPressed: cancel,
          ),
        ),
      ],
    );
  }
}
