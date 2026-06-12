import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/folder_detail_actions.dart';
import 'package:memox/presentation/features/folders/widgets/folder_detail_body.dart';
import 'package:memox/presentation/features/folders/widgets/library_skeleton.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/dialogs/mx_folder_form_dialog.dart';
import 'package:memox/presentation/shared/dialogs/mx_name_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/hooks/mx_hooks.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// Folder Detail — browse a folder's children (subfolders OR decks), with
/// breadcrumb and a mode-constrained create FAB. The canonical mock also shows
/// a mastery summary shell, sort/search affordances, and a visible study CTA
/// shell.
class FolderDetailScreen extends ConsumerWidget {
  const FolderDetailScreen({required this.folderId, super.key});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<FolderDetail> query = ref.watch(
      folderDetailQueryProvider(folderId),
    );
    final FolderDetail? detail = query.asData?.value;
    final FolderDetailToolbarState toolbar = ref.watch(
      folderDetailToolbarProvider(folderId),
    );

    return MxScaffold(
      appBar: MxAppBar(
        titleText: detail?.folder.name ?? '',
        actions: <Widget>[
          MxIconButton(
            icon: Icons.more_vert,
            tooltip: l10n.libraryOverflowTooltip,
            onPressed: detail == null
                ? null
                : () => showFolderDetailActions(context, ref, detail),
          ),
        ],
      ),
      floatingActionButton: _buildFab(context, ref, detail),
      body: _FolderDetailView(
        folderId: folderId,
        sort: toolbar.sort,
        onSearchTap: () => showFolderDetailSearchSheet(context, folderId),
        onSortTap: () => showFolderDetailSortSheet(context, ref, folderId),
      ),
    );
  }

  Widget? _buildFab(BuildContext context, WidgetRef ref, FolderDetail? detail) {
    if (detail == null) {
      return null;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (detail.folder.contentMode) {
      ContentMode.subfolders => MxFab.extended(
        icon: Icons.create_new_folder_outlined,
        label: l10n.folderNewSubfolderLabel,
        onPressed: () => createSubfolderDialog(context, ref, folderId),
      ),
      ContentMode.decks => MxFab.extended(
        icon: Icons.add,
        label: l10n.folderNewDeckLabel,
        onPressed: () => createDeckDialog(context, ref, folderId),
      ),
      ContentMode.unlocked => null,
    };
  }
}

class _FolderDetailView extends ConsumerWidget {
  const _FolderDetailView({
    required this.folderId,
    required this.sort,
    required this.onSearchTap,
    required this.onSortTap,
  });

  final String folderId;
  final ContentSortMode sort;
  final VoidCallback onSearchTap;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<FolderDetail> query = ref.watch(
      folderDetailQueryProvider(folderId),
    );
    final FolderDetailToolbarState toolbar = ref.watch(
      folderDetailToolbarProvider(folderId),
    );

    return Column(
      children: <Widget>[
        _FolderBreadcrumb(folderId: folderId),
        Expanded(
          child: MxRetainedAsyncState<FolderDetail>(
            value: query,
            skeletonBuilder: (_) => const LibrarySkeleton(),
            errorBuilder: (Object error, StackTrace? stack) => MxErrorState(
              icon: Icons.folder_off_outlined,
              title: AppLocalizations.of(context).folderNotFoundTitle,
              message: AppLocalizations.of(context).folderNotFoundMessage,
              retryLabel: AppLocalizations.of(context).commonRetry,
              onRetry: () =>
                  ref.invalidate(folderDetailQueryProvider(folderId)),
            ),
            data: (FolderDetail detail) => FolderDetailBody(
              detail: detail,
              isSearching: toolbar.isSearching,
              searchTerm: toolbar.searchTerm,
              sort: sort,
              onStartStudy: detail.folder.contentMode == ContentMode.decks
                  ? () => context.goStudyEntry(
                      entryType: EntryType.folder,
                      entryRefId: folderId,
                      studyType: StudyType.srsReview,
                    )
                  : null,
              onNewSubfolder: () =>
                  createSubfolderDialog(context, ref, folderId),
              onNewDeck: () => createDeckDialog(context, ref, folderId),
              onClearSearch: () => ref
                  .read(folderDetailToolbarProvider(folderId).notifier)
                  .clearSearch(),
              onShowSubfolderActions: (FolderWithCount item) =>
                  showFolderDetailSubfolderActions(context, ref, item),
              onShowDeckActions: (DeckWithCount item) =>
                  showFolderDetailDeckActions(context, ref, item),
              onSearchTap: onSearchTap,
              onSortTap: onSortTap,
            ),
          ),
        ),
      ],
    );
  }
}

class _FolderBreadcrumb extends ConsumerWidget {
  const _FolderBreadcrumb({required this.folderId});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FolderDetail? detail = ref
        .watch(folderDetailQueryProvider(folderId))
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
    return MxBreadcrumb(segments: segments);
  }
}

Future<void> createSubfolderDialog(
  BuildContext context,
  WidgetRef ref,
  String folderId,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String? name = await showMxFolderCreateDialog(
    context,
    title: l10n.subfolderCreateDialogTitle,
    description: l10n.folderCreateDialogDescription,
    fieldLabel: l10n.subfolderCreateFieldLabel,
    colorLabel: l10n.folderCreateColorLabel,
    iconLabel: l10n.folderCreateIconLabel,
    confirmLabel: l10n.commonCreate,
    cancelLabel: l10n.commonCancel,
  );
  if (name == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final result = await ref
      .read(folderActionControllerProvider.notifier)
      .createSubfolder(folderId, name);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: l10n.failureMessage(
        failure,
        duplicate: l10n.libraryFolderDuplicateError,
        fallback: l10n.folderChildCreateError,
      ),
      isError: true,
    ),
    (_) {},
  );
}

Future<void> createDeckDialog(
  BuildContext context,
  WidgetRef ref,
  String folderId,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String? name = await showMxNameDialog(
    context,
    title: l10n.deckCreateDialogTitle,
    fieldLabel: l10n.deckCreateFieldLabel,
    confirmLabel: l10n.commonCreate,
    cancelLabel: l10n.commonCancel,
  );
  if (name == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final result = await ref
      .read(folderActionControllerProvider.notifier)
      .createDeck(folderId, name);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: l10n.failureMessage(
        failure,
        duplicate: l10n.folderDeckDuplicateError,
        fallback: l10n.folderChildCreateError,
      ),
      isError: true,
    ),
    (_) {},
  );
}

Future<void> showFolderDetailSearchSheet(
  BuildContext context,
  String folderId,
) async {
  await showMxBottomSheet<void>(
    context,
    builder: (BuildContext context) =>
        _FolderDetailSearchSheet(folderId: folderId),
  );
}

Future<void> showFolderDetailSortSheet(
  BuildContext context,
  WidgetRef ref,
  String folderId,
) async {
  final ContentSortMode currentSort = ref
      .read(folderDetailToolbarProvider(folderId))
      .sort;
  await showMxBottomSheet<void>(
    context,
    builder: (BuildContext context) => _FolderDetailSortSheet(
      currentSort: currentSort,
      onSelected: (ContentSortMode sort) => ref
          .read(folderDetailToolbarProvider(folderId).notifier)
          .setSort(sort),
    ),
  );
}

class _FolderDetailSearchSheet extends HookConsumerWidget {
  const _FolderDetailSearchSheet({required this.folderId});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final FolderDetailToolbarState toolbar = ref.watch(
      folderDetailToolbarProvider(folderId),
    );
    final search = useMxSearchController(
      externalText: toolbar.searchTerm,
      clearWhenExternalTextEmpty: true,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.screenPadding,
        SpacingTokens.sm,
        SpacingTokens.screenPadding,
        SpacingTokens.screenPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MxSectionHeader(label: l10n.folderDetailSearchSheetTitle),
          const SizedBox(height: SpacingTokens.md),
          MxSearchField(
            controller: search.controller,
            hintText: l10n.folderDetailSearchHint,
            clearTooltip: l10n.librarySearchClearTooltip,
            autofocus: true,
            onChanged: (String value) => ref
                .read(folderDetailToolbarProvider(folderId).notifier)
                .setSearch(value),
            onClear: () => ref
                .read(folderDetailToolbarProvider(folderId).notifier)
                .clearSearch(),
          ),
          const SizedBox(height: SpacingTokens.lg),
          MxSecondaryButton(
            label: l10n.commonClose,
            onPressed: () => Navigator.of(context).pop(),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _FolderDetailSortSheet extends StatelessWidget {
  const _FolderDetailSortSheet({
    required this.currentSort,
    required this.onSelected,
  });

  final ContentSortMode currentSort;
  final ValueChanged<ContentSortMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<({ContentSortMode mode, String label})>
    options = <({ContentSortMode mode, String label})>[
      (mode: ContentSortMode.manual, label: l10n.folderDetailSortManualLabel),
      (mode: ContentSortMode.name, label: l10n.folderDetailSortNameLabel),
      (mode: ContentSortMode.newest, label: l10n.folderDetailSortNewestLabel),
    ];

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.screenPadding,
              SpacingTokens.sm,
              SpacingTokens.screenPadding,
              SpacingTokens.sm,
            ),
            child: MxSectionHeader(label: l10n.folderDetailSortSheetTitle),
          ),
          for (final ({ContentSortMode mode, String label}) option in options)
            MxListTile(
              title: option.label,
              leading: Icon(
                Icons.sort_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              trailing: currentSort == option.mode
                  ? Icon(
                      Icons.check_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                onSelected(option.mode);
                Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: SpacingTokens.md),
        ],
      ),
    );
  }
}
