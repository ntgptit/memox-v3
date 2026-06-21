import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// Root orientation anchor for Library Overview: a home glyph + `Root` label
/// docked under the app bar, with the live root-folder count trailing.
///
/// Purpose:
/// At the Library root there is no ancestry to show, so nested screens' under-
/// app-bar breadcrumb dock would be absent and the root loses its "you are here"
/// anchor. This marks the top of the folder hierarchy explicitly — an icon plus
/// the localized `Root` label — and trails the `{n} folders` summary. Shown only
/// in the loaded-with-folders, non-search state (the caller owns that gating,
/// mirroring the FAB). Owner-requested (2026-06-21).
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space1),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.home_outlined,
            size: MxIconSize.md,
            color: colors.textSecondary,
          ),
          const SizedBox(width: MxSpacing.space2),
          MxText(
            l10n.libraryRootLabel,
            role: MxTextRole.labelLarge,
            color: colors.text,
          ),
          const Spacer(),
          MxText(
            l10n.libraryFolderCountHeader(folderCount),
            role: MxTextRole.labelMedium,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
