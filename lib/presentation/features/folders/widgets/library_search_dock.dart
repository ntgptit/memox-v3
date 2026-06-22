import 'package:flutter/material.dart';
import 'package:memox/presentation/features/folders/widgets/library_search_field.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_scoped_search_dock.dart';

/// The Library search-mode bottom dock (kit `03` Search state, `search-dock`):
/// the shared [MxScopedSearchDock] chrome hosting the autofocused folder
/// [LibrarySearchField]. The regular Library app bar (title + sort) stays above
/// it, and the FAB is suppressed while searching, matching the mock. WBS 3.1.2.
class LibrarySearchDock extends StatelessWidget {
  const LibrarySearchDock({super.key});

  @override
  Widget build(BuildContext context) =>
      const MxScopedSearchDock(child: LibrarySearchField(autofocus: true));
}
