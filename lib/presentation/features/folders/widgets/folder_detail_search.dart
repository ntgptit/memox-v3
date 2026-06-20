import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/shared/hooks/mx_search_controller_hooks.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Inline folder-detail search field, bound to `folderSearchQueryProvider`
/// keyed by [folderId] (scope-local). WBS 3.2.2.
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

/// Folder-detail search-mode app bar (field + Cancel), keyed by [folderId].
/// WBS 3.2.2.
class FolderDetailSearchAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  const FolderDetailSearchAppBar({required this.folderId, super.key});

  final String folderId;

  static const double _toolbarHeight = kToolbarHeight + MxSpacing.space4;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    void cancel() {
      ref.read(folderSearchQueryProvider(folderId).notifier).clear();
      ref.read(folderSearchActiveProvider(folderId).notifier).deactivate();
    }

    return MxAppBar(
      automaticallyImplyLeading: false,
      titleSpacing: MxSpacing.screen,
      toolbarHeight: _toolbarHeight,
      titleWidget: FolderDetailSearchField(folderId: folderId, autofocus: true),
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
