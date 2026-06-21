import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/navigation/library_breadcrumb.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';

/// Root orientation anchor for Library Overview: the single (non-tappable)
/// `Library` breadcrumb crumb plus the live root-folder count, docked under the
/// app bar exactly where nested Library screens show their ancestry trail.
///
/// Purpose:
/// At the Library root there is no ancestry to show, so the breadcrumb dock that
/// every nested Library screen carries would simply be absent and the root would
/// lose the shared "you are here" anchor. This renders the root of that same
/// trail (`Library`, styled as the current crumb) plus a `{n} folders` summary,
/// so the dock stays consistent across the whole Library branch and the root
/// reads as the top of the hierarchy. The crumb intentionally mirrors the
/// app-bar title — the same way a nested screen's deepest folder is both the
/// title and the current crumb. Owner-requested (2026-06-21).
///
/// Use when:
/// On Library Overview in the loaded-with-folders, non-search state (the caller
/// owns that gating, mirroring the FAB).
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
            // No ancestry at the root: a single `Library` crumb, which
            // MxBreadcrumb renders as the (non-tappable) current location.
            items: buildLibraryBreadcrumb(
              context,
              libraryLabel: l10n.libraryTitle,
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
