import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_editor_body.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

/// Card create / edit editor screen (mock `07` / `08`): an X / Save app bar, the
/// deck breadcrumb, and FRONT / BACK fields. Pushed over the flashcard list;
/// [cardId] `null` is **create**, otherwise **edit**. Reads the deck +
/// (for edit) the card from the existing `flashcardListStreamProvider`.
///
/// V1 shell (WP-FL2a): front/back only. The Details expander (tags / note /
/// example / pronunciation / hint) and the full `07`/`08` state matrix
/// (saving / save-failed / load-error / delete) land with WP-FL2b. WBS
/// 2.11.2 / 2.12.2.
class FlashcardEditorScreen extends ConsumerWidget {
  const FlashcardEditorScreen({required this.deckId, this.cardId, super.key});

  final String deckId;

  /// The edited card id, or `null` for a new card.
  final String? cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Result<FlashcardListDetail>> async = ref.watch(
      flashcardListStreamProvider(deckId),
    );

    return AppAsyncBuilder<Result<FlashcardListDetail>>(
      value: async,
      loading: (_) => _shell(context, l10n, const SizedBox.shrink()),
      error: (_, _) => _shell(context, l10n, _errorBody(context, l10n)),
      data: (Result<FlashcardListDetail> result) {
        final FlashcardListDetail? detail = result.data;
        if (detail == null) {
          return _shell(context, l10n, _errorBody(context, l10n));
        }
        final String? id = cardId;
        final Flashcard? card = id == null ? null : _findCard(detail.cards, id);
        // Edit target gone (deleted elsewhere) → the load-error surface.
        if (id != null && card == null) {
          return _shell(context, l10n, _errorBody(context, l10n));
        }
        return FlashcardEditorForm(
          deckId: deckId,
          deck: detail.deck,
          breadcrumb: detail.breadcrumb,
          card: card,
        );
      },
    );
  }

  Flashcard? _findCard(List<Flashcard> cards, String id) {
    for (final Flashcard c in cards) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// A bare editor shell (X app bar only) for the transient loading / error
  /// states — there is no card to save yet.
  Widget _shell(BuildContext context, AppLocalizations l10n, Widget body) =>
      MxScaffold(
        appBar: MxAppBar(
          automaticallyImplyLeading: false,
          leading: MxIconButton(
            icon: cardId == null ? Icons.close : Icons.arrow_back,
            tooltip: l10n.commonCancel,
            onPressed: () => context.pop(),
          ),
          title: cardId == null ? l10n.cardCreateTitle : l10n.cardEditTitle,
        ),
        body: body,
      );

  Widget _errorBody(BuildContext context, AppLocalizations l10n) =>
      MxErrorState(
        title: l10n.flashcardLoadFailedTitle,
        message: l10n.flashcardLoadFailedMessage,
        icon: Icons.cloud_off_outlined,
        action: MxPrimaryButton(
          label: l10n.commonCancel,
          icon: Icons.arrow_back,
          fullWidth: true,
          onPressed: () => context.pop(),
        ),
      );
}
