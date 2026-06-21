import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/navigation/library_breadcrumb.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';

/// Root orientation anchor for Library Overview: the `🏠 Root` crumb docked
/// under the app bar, with the live root-folder count trailing.
///
/// Purpose:
/// At the Library root there is no ancestry to show, so nested screens' under-
/// app-bar breadcrumb dock would be absent and the root loses its "you are here"
/// anchor. This renders the **same** root crumb the nested breadcrumb shows —
/// `buildLibraryBreadcrumb` with no ancestry yields a single `Root` crumb (home
/// glyph + label), here the current/non-tappable location — so the hierarchy
/// reads identically from the top, and trails the `{n} folders` summary. Shown
/// only in the loaded-with-folders, non-search state (the caller owns that
/// gating, mirroring the FAB). Owner-requested (2026-06-21).
///
/// Category:
/// navigation
class LibraryRootAnchor extends StatelessWidget {
  const LibraryRootAnchor({required this.folderCount, super.key});

  /// The number of root folders, shown as the trailing summary.
  final int folderCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    return Row(
      children: <Widget>[
        Expanded(
          child: MxBreadcrumb(
            // No ancestry at the root → a single `Root` crumb (home glyph +
            // label), which MxBreadcrumb renders as the current location.
            items: buildLibraryBreadcrumb(
              context,
              rootLabel: l10n.libraryRootLabel,
              folders: const <Folder>[],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space1),
          child: MxText(
            l10n.libraryFolderCountHeader(folderCount),
            role: MxTextRole.labelMedium,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
