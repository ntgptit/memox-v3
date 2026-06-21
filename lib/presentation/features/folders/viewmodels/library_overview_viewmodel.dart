import 'package:memox/app/di/folder_providers.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/presentation/shared/sort/content_sort.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_overview_viewmodel.g.dart';

/// Streams the Library root read model (top-level folders + counts) from the
/// watch use case. The screen derives its load / empty / error states from the
/// resulting `AsyncValue` (`docs/wireframes/02-library.md` §States). WBS 3.1.2.
@riverpod
Stream<LibraryOverview> libraryOverviewStream(Ref ref) =>
    ref.watch(watchLibraryOverviewUseCaseProvider).call();

/// The active inline-search term (scope-local; never routes to Global Search).
/// Empty string = no filter. WBS 3.1.2.
@riverpod
class LibrarySearchQuery extends _$LibrarySearchQuery {
  @override
  String build() => '';

  void setTerm(String term) => state = term;

  void clear() => state = '';
}

/// Whether the Library is in search mode — the app bar shows the search field +
/// Cancel instead of the title + search/sort icons (mock `03e`). Activating it
/// (search icon) reveals the field; Cancel deactivates and clears the term.
/// WBS 3.1.2.
@riverpod
class LibrarySearchActive extends _$LibrarySearchActive {
  @override
  bool build() => false;

  void activate() => state = true;

  void deactivate() => state = false;
}

/// Derived Library list state: the filtered + unfiltered folder sets plus the
/// active term, so the screen can tell true-empty from search-no-results
/// (`docs/wireframes/02-library.md` §States).
typedef LibraryListView = ({
  List<FolderSummary> folders,
  int totalFolderCount,
  String searchTerm,
});

/// Filters [overview]'s top-level folders by [term] (V1: a normalized
/// name-contains over the loaded roots — broadening to the whole tree is Future,
/// needs a dedicated query). Pure so the screen can call it inside its data
/// branch without a provider that assumes the stream has resolved. WBS 3.1.2.
LibraryListView filterLibrary(LibraryOverview overview, String term) {
  final String trimmed = StringUtils.trimmed(term);
  final List<FolderSummary> all = overview.folders;
  if (trimmed.isEmpty) {
    return (folders: all, totalFolderCount: all.length, searchTerm: '');
  }
  final String needle = StringUtils.caseFold(trimmed);
  final List<FolderSummary> filtered = all
      .where(
        (FolderSummary s) =>
            StringUtils.caseFold(s.folder.name).contains(needle),
      )
      .toList(growable: false);
  return (folders: filtered, totalFolderCount: all.length, searchTerm: trimmed);
}

/// Orders root [folders] by [mode] for display — delegates to the shared
/// [sortByContentMode] core (keyed on the folder name + creation time). WBS
/// 2.23.1.
List<FolderSummary> sortLibraryFolders(
  List<FolderSummary> folders,
  ContentSortMode mode,
) => sortByContentMode<FolderSummary>(
  folders,
  mode,
  name: (FolderSummary s) => s.folder.name,
  createdAt: (FolderSummary s) => s.folder.createdAt,
);
