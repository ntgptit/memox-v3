import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';

/// Builds the `🏠 Root › Folder › … › leaf` trail for a nested Library screen
/// (Folder detail, Flashcard list) as a list of [MxBreadcrumbItem]s.
///
/// One owner so every nested Library screen shows the same quiet trail and the
/// same navigation semantics (design redesign — breadcrumb docks under the app
/// bar). The first crumb is always the **Root** anchor (home glyph + [rootLabel];
/// taps back to the branch root via `goNamed`) — the same marker the Library
/// Overview root anchor shows, so the hierarchy reads consistently from the top.
/// Each ancestor folder taps into its own detail (`pushNamed`).
///
/// Leaf handling:
/// - When [currentLeafLabel] is `null` (Folder detail), the last item in
///   [folders] is the current location: it renders as the non-tappable current
///   crumb (the deepest folder is also the app-bar title).
/// - When [currentLeafLabel] is provided (Flashcard list — the deck is the
///   current screen, not a folder), **every** folder is a tappable ancestor and
///   the deck name is appended as the non-tappable current crumb.
List<MxBreadcrumbItem> buildLibraryBreadcrumb(
  BuildContext context, {
  required String rootLabel,
  required List<Folder> folders,
  String? currentLeafLabel,
}) {
  final List<MxBreadcrumbItem> items = <MxBreadcrumbItem>[
    MxBreadcrumbItem(
      label: rootLabel,
      icon: Icons.home_outlined,
      onTap: () => context.goNamed(RouteNames.library),
    ),
  ];
  for (int i = 0; i < folders.length; i++) {
    final Folder folder = folders[i];
    // With no explicit leaf, the deepest folder is the current location and must
    // not be tappable; otherwise every folder is a navigable ancestor.
    final bool isCurrentFolder =
        currentLeafLabel == null && i == folders.length - 1;
    items.add(
      MxBreadcrumbItem(
        label: folder.name,
        onTap: isCurrentFolder
            ? null
            : () => context.pushNamed(
                RouteNames.folderDetail,
                pathParameters: <String, String>{RouteParams.id: folder.id},
              ),
      ),
    );
  }
  if (currentLeafLabel != null) {
    items.add(MxBreadcrumbItem(label: currentLeafLabel));
  }
  return items;
}
