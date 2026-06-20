import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/library_create_folder_action.dart';
import 'package:memox/presentation/features/folders/widgets/library_overview_body.dart';
import 'package:memox/presentation/features/folders/widgets/library_search_app_bar.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Library Overview — the root content browser: top-level folders with their
/// recursive counts (grouped card), folder search, folder management via the
/// row overflow sheet, and a `New folder` FAB. State handling lives in
/// [LibraryOverviewBody].
///
/// V1 scope (`docs/design/screens/library-overview.visual-contract.md`): the
/// header sort affordance is visual-only (disabled — no approved sort sheet);
/// a folder-row tap opens the action sheet until folder-detail navigation lands
/// (WBS 3.2.2). WBS 3.1.2 / 2.1.2.
class LibraryOverviewScreen extends ConsumerWidget {
  const LibraryOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // guard:allow-screen-watch -- reason: the app-bar swaps to search mode and
    // the FAB depends on the loaded folder list, so the shell must react to
    // search-active + stream state; pushing these into a body widget would split
    // the app-bar/FAB decision away from where it is applied.
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool searching = ref.watch(librarySearchActiveProvider);
    // The FAB shows only in the loaded-with-folders state (mock `03a`): the
    // true-empty state offers its own inline CTA, and loading / error / search
    // suppress it (mocks `03b` / `03c` / `03d` / `03e`).
    final bool hasFolders =
        ref.watch(libraryOverviewStreamProvider).value?.folders.isNotEmpty ??
        false;
    final bool showFab = !searching && hasFolders;

    return MxScaffold(
      appBar: searching
          ? const LibrarySearchAppBar()
          : MxAppBar(
              title: l10n.libraryTitle,
              actions: <Widget>[
                MxIconButton(
                  icon: Icons.search,
                  tooltip: l10n.librarySearchTooltip,
                  onPressed: () =>
                      ref.read(librarySearchActiveProvider.notifier).activate(),
                ),
                // Visual-only sort affordance (no approved sort sheet yet).
                const MxIconButton(icon: Icons.swap_vert, onPressed: null),
              ],
            ),
      floatingActionButton: showFab
          ? MxFab(
              icon: Icons.create_new_folder_outlined,
              tooltip: l10n.libraryCreateFolderTooltip,
              onPressed: () => runCreateFolder(context, ref),
            )
          : null,
      body: const LibraryOverviewBody(),
    );
  }
}
