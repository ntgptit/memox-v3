import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_stroke.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/shared/hooks/mx_search_controller_hooks.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';

/// Inline folder-detail search field, bound to `folderSearchQueryProvider`
/// keyed by [folderId] (scope-local). Provider-synced via [useMxSearchController]
/// so the body's no-results `Clear` CTA can reset the field. WBS 3.2.2.
class FolderDetailSearchField extends HookConsumerWidget {
  const FolderDetailSearchField({
    required this.folderId,
    this.autofocus = false,
    super.key,
  });

  final String folderId;
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String term = ref.watch(folderSearchQueryProvider(folderId));
    final MxSearchControllerState search = useMxSearchController(
      externalText: term,
      clearWhenExternalTextEmpty: true,
    );
    return MxSearchField(
      controller: search.controller,
      hintText: l10n.folderDetailSearchHint,
      autofocus: autofocus,
      onChanged: (String value) =>
          ref.read(folderSearchQueryProvider(folderId).notifier).setTerm(value),
    );
  }
}

/// The folder-detail search-mode bottom dock (kit `04` Search state `search-dock`):
/// a flat full-bleed bar pinned at the foot — a top hairline over a surface fill —
/// hosting the autofocused [FolderDetailSearchField]. The regular folder app bar
/// (title + sort + overflow) stays above it and the FAB is suppressed while
/// searching, matching the mock.
///
/// Mounted in the `Scaffold.bottomNavigationBar` slot (via `MxScaffold`) so it
/// renders flat and full-bleed — no rounded/elevated BottomSheet chrome — and
/// reserves its own foot room under the content. Mirrors `LibrarySearchDock`
/// (object 1, WP-L10). WBS 3.2.2.
class FolderDetailSearchDock extends StatelessWidget {
  const FolderDetailSearchDock({required this.folderId, super.key});

  final String folderId;

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
          child: FolderDetailSearchField(folderId: folderId, autofocus: true),
        ),
      ),
    );
  }
}
