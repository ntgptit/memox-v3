import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/deck_actions_sheet.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_delete_preview.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_list_body.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_list_skeleton.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_row_actions_sheet.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/hooks/mx_hooks.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

/// Flashcard List — manage the cards in one deck
/// (`docs/wireframes/06-flashcard-list.md`). V1 scope: browse, in-deck search,
/// single-card delete, manual reorder, and the deck overflow (import / reorder /
/// delete deck). Study CTAs, bulk/selection, tag-status filters and state badges
/// are Future and intentionally not surfaced.
class FlashcardListScreen extends ConsumerWidget {
  const FlashcardListScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // guard:allow-screen-watch -- reason: the app bar title + overflow + FAB
    // all need the loaded deck (name + card total).
    final FlashcardListDetail? detail = ref
        .watch(flashcardListQueryProvider(deckId))
        .asData
        ?.value;
    final bool isReordering = ref
        .watch(flashcardListToolbarProvider(deckId))
        .isReordering;

    if (isReordering) {
      return MxScaffold(
        appBar: MxAppBar(
          titleText: l10n.flashcardDeckReorderAction,
          leading: MxIconButton(
            icon: Icons.close,
            tooltip: l10n.commonDone,
            onPressed: () => ref
                .read(flashcardListToolbarProvider(deckId).notifier)
                .stopReorder(),
          ),
          actions: <Widget>[
            MxIconButton(
              icon: Icons.check,
              tooltip: l10n.commonDone,
              onPressed: () => ref
                  .read(flashcardListToolbarProvider(deckId).notifier)
                  .stopReorder(),
            ),
          ],
        ),
        body: _FlashcardListView(deckId: deckId),
      );
    }

    return MxScaffold(
      appBar: MxAppBar(
        titleText: detail?.deck.name ?? '',
        actions: <Widget>[
          MxIconButton(
            icon: Icons.more_vert,
            tooltip: l10n.libraryOverflowTooltip,
            onPressed: detail == null
                ? null
                : () => _openDeckActions(context, ref, detail),
          ),
        ],
      ),
      floatingActionButton: detail == null
          ? null
          : MxFab.extended(
              icon: Icons.add,
              label: l10n.flashcardListAddCardAction,
              onPressed: () => context.pushFlashcardCreate(deckId),
            ),
      body: _FlashcardListView(deckId: deckId),
    );
  }

  Future<void> _openDeckActions(
    BuildContext context,
    WidgetRef ref,
    FlashcardListDetail detail,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DeckListAction? action = await showDeckActions(
      context,
      deckName: detail.deck.name,
      subtitle: _deckSubtitle(l10n, detail),
    );
    if (action == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    switch (action) {
      case DeckListAction.importFlashcards:
        context.pushDeckImport(deckId);
      case DeckListAction.reorder:
        ref.read(flashcardListToolbarProvider(deckId).notifier).startReorder();
      case DeckListAction.delete:
        await _deleteDeck(context, ref);
    }
  }

  Future<void> _deleteDeck(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showMxConfirmDialog(
      context,
      title: l10n.decksDeleteTitle,
      message: l10n.decksDeleteMessage,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (!confirmed) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final Result<void> result = await ref
        .read(flashcardListControllerProvider.notifier)
        .deleteDeck(deckId);
    if (!context.mounted) {
      return;
    }
    result.fold(
      (Failure failure) => showMxSnackbar(
        context,
        message: l10n.failureMessage(
          failure,
          fallback: l10n.flashcardListActionError,
        ),
        isError: true,
      ),
      // The deck is gone — leave the now-stale list for its parent folder.
      (void _) {
        showMxSnackbar(context, message: l10n.decksDeletedMessage);
        unawaited(Navigator.of(context).maybePop());
      },
    );
  }

  static String _deckSubtitle(AppLocalizations l10n, FlashcardListDetail d) =>
      l10n.flashcardListSubtitle(
        d.totalCount,
        _languageLabel(l10n, d.deck.targetLanguage),
      );

  static String _languageLabel(AppLocalizations l10n, TargetLanguage lang) =>
      switch (lang) {
        TargetLanguage.korean => l10n.flashcardListLanguageKorean,
        TargetLanguage.english => l10n.flashcardListLanguageEnglish,
        TargetLanguage.unsupported => l10n.flashcardListLanguageOther,
      };
}

class _FlashcardListView extends ConsumerWidget {
  const _FlashcardListView({required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<FlashcardListDetail> query = ref.watch(
      flashcardListQueryProvider(deckId),
    );
    final FlashcardListToolbarState toolbar = ref.watch(
      flashcardListToolbarProvider(deckId),
    );

    return Column(
      children: <Widget>[
        _FlashcardBreadcrumb(deckId: deckId),
        if (!toolbar.isReordering)
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
            child: _FlashcardSearch(deckId: deckId),
          ),
        Expanded(
          child: MxRetainedAsyncState<FlashcardListDetail>(
            value: query,
            skeletonBuilder: (_) => const FlashcardListSkeleton(),
            errorBuilder: (Object error, StackTrace? stack) => MxErrorState(
              icon: Icons.style_outlined,
              title: AppLocalizations.of(context).flashcardListErrorTitle,
              message: AppLocalizations.of(context).flashcardListErrorMessage,
              retryLabel: AppLocalizations.of(context).commonRetry,
              onRetry: () => ref.invalidate(flashcardListQueryProvider(deckId)),
            ),
            data: (FlashcardListDetail detail) => FlashcardListBody(
              detail: detail,
              isSearching: toolbar.isSearching,
              isReordering: toolbar.isReordering,
              onAddCard: () => context.pushFlashcardCreate(deckId),
              onImport: () => context.pushDeckImport(deckId),
              onClearSearch: () => ref
                  .read(flashcardListToolbarProvider(deckId).notifier)
                  .clearSearch(),
              onCardTap: (Flashcard card) =>
                  context.pushFlashcardEdit(deckId, card.id),
              onCardActions: (Flashcard card) =>
                  _openCardActions(context, ref, card),
              onReorder: (List<String> ids) => _reorder(context, ref, ids),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCardActions(
    BuildContext context,
    WidgetRef ref,
    Flashcard card,
  ) async {
    final FlashcardRowAction? action = await showFlashcardRowActions(
      context,
      front: card.front,
    );
    if (action == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    switch (action) {
      case FlashcardRowAction.edit:
        context.pushFlashcardEdit(deckId, card.id);
      case FlashcardRowAction.viewHistory:
        context.pushFlashcardHistory(deckId, card.id);
      case FlashcardRowAction.delete:
        await _deleteCard(context, ref, card);
    }
  }

  Future<void> _deleteCard(
    BuildContext context,
    WidgetRef ref,
    Flashcard card,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showMxConfirmDialog(
      context,
      title: l10n.flashcardDeleteOneTitle,
      content: FlashcardDeletePreview(front: card.front, back: card.back),
      message: l10n.flashcardDeleteOneMessage,
      confirmLabel: l10n.flashcardsDeleteCardAction,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (!confirmed) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final Result<void> result = await ref
        .read(flashcardListControllerProvider.notifier)
        .deleteFlashcard(card.id);
    if (!context.mounted) {
      return;
    }
    result.fold(
      (Failure failure) => showMxSnackbar(
        context,
        message: l10n.failureMessage(
          failure,
          fallback: l10n.flashcardListActionError,
        ),
        isError: true,
      ),
      (void _) =>
          showMxSnackbar(context, message: l10n.flashcardDeletedOneMessage),
    );
  }

  Future<void> _reorder(
    BuildContext context,
    WidgetRef ref,
    List<String> orderedIds,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Result<void> result = await ref
        .read(flashcardListControllerProvider.notifier)
        .reorderFlashcards(deckId: deckId, orderedIds: orderedIds);
    if (!context.mounted) {
      return;
    }
    result.fold(
      (Failure failure) => showMxSnackbar(
        context,
        message: l10n.failureMessage(
          failure,
          fallback: l10n.flashcardReorderError,
        ),
        isError: true,
      ),
      (_) {},
    );
  }
}

class _FlashcardBreadcrumb extends ConsumerWidget {
  const _FlashcardBreadcrumb({required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FlashcardListDetail? detail = ref
        .watch(flashcardListQueryProvider(deckId))
        .asData
        ?.value;
    if (detail == null) {
      return const SizedBox.shrink();
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<MxBreadcrumbSegment> segments = <MxBreadcrumbSegment>[
      MxBreadcrumbSegment(
        label: l10n.libraryTitle,
        onTap: () => context.goLibrary(),
      ),
      for (final FolderBreadcrumbSegment seg in detail.breadcrumb)
        MxBreadcrumbSegment(
          label: seg.name,
          onTap: () => context.pushFolderDetail(seg.id),
        ),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MxBreadcrumb(segments: segments),
          const SizedBox(height: SpacingTokens.xxs),
          MxText(
            FlashcardListScreen._deckSubtitle(l10n, detail),
            role: MxTextRole.labelMedium,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _FlashcardSearch extends HookConsumerWidget {
  const _FlashcardSearch({required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String searchTerm = ref.watch(
      flashcardListToolbarProvider(
        deckId,
      ).select((FlashcardListToolbarState state) => state.searchTerm),
    );
    final MxSearchControllerState search = useMxSearchController(
      externalText: searchTerm,
      clearWhenExternalTextEmpty: true,
    );
    return MxSearchField(
      controller: search.controller,
      hintText: l10n.flashcardsSearchHint,
      clearTooltip: l10n.librarySearchClearTooltip,
      onChanged: (String value) => ref
          .read(flashcardListToolbarProvider(deckId).notifier)
          .setSearch(value),
    );
  }
}
