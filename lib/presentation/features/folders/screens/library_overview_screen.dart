import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/library_overview_body.dart';
import 'package:memox/presentation/features/folders/widgets/library_search_field.dart';
import 'package:memox/presentation/features/folders/widgets/library_sections.dart';
import 'package:memox/presentation/features/folders/widgets/library_skeleton.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/dialogs/mx_name_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Library Overview — root content browser (top-level folders only).
///
/// `docs/wireframes/02-library.md`. The shell keeps no provider watching;
/// `_LibraryOverviewView` owns that and renders all six states via
/// `MxRetainedAsyncState` (loaded / skeleton / error) plus the body
/// (true-empty / search-no-results). The header's filter affordance is a
/// visual-only disabled `tune` control (no approved filter sheet yet).
class LibraryOverviewScreen extends ConsumerWidget {
  const LibraryOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(
        titleText: l10n.libraryTitle,
        actions: <Widget>[
          MxIconButton(
            icon: Icons.tune_rounded,
            tooltip: l10n.libraryFilterTooltip,
            onPressed: null,
          ),
        ],
      ),
      floatingActionButton: MxFab.extended(
        icon: Icons.create_new_folder_outlined,
        label: l10n.libraryNewFolderLabel,
        onPressed: () => _showCreateFolderDialog(context, ref),
      ),
      body: const _LibraryOverviewView(),
    );
  }
}

/// Reactive content section — kept out of the screen shell so the shell build
/// stays watch-free (`memox.template_screen_shell_no_ref_watch`).
class _LibraryOverviewView extends ConsumerWidget {
  const _LibraryOverviewView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LibraryOverviewReadModel> query =
        ref.watch(libraryOverviewQueryProvider);
    final LibraryToolbarState toolbar = ref.watch(libraryToolbarProvider);

    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(
            top: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: LibrarySearchField(),
        ),
        Expanded(
          child: MxRetainedAsyncState<LibraryOverviewReadModel>(
            value: query,
            skeletonBuilder: (_) => const LibrarySkeleton(),
            errorBuilder: (Object error, StackTrace? stack) =>
                LibraryErrorSection(
                  onRetry: () =>
                      ref.invalidate(libraryOverviewQueryProvider),
                ),
            data: (LibraryOverviewReadModel model) => LibraryOverviewBody(
              model: model,
              isSearching: toolbar.isSearching,
              onCreateFolder: () => _showCreateFolderDialog(context, ref),
              onClearSearch: () =>
                  ref.read(libraryToolbarProvider.notifier).clearSearch(),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showCreateFolderDialog(BuildContext context, WidgetRef ref) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String? name = await showMxNameDialog(
    context,
    title: l10n.folderCreateDialogTitle,
    fieldLabel: l10n.folderCreateFieldLabel,
    confirmLabel: l10n.commonCreate,
    cancelLabel: l10n.commonCancel,
  );
  if (name == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final Result<Folder> result = await ref
      .read(libraryActionControllerProvider.notifier)
      .createFolder(name);
  if (!context.mounted) {
    return;
  }
  // Success: the Drift stream refreshes the list — no manual state push.
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: _createFolderErrorMessage(l10n, failure),
      isError: true,
    ),
    (Folder _) {},
  );
}

String _createFolderErrorMessage(AppLocalizations l10n, Failure failure) =>
    switch (failure) {
      ValidationFailure(code: ValidationCode.duplicate) =>
        l10n.libraryFolderDuplicateError,
      _ => l10n.libraryCreateFolderError,
    };
