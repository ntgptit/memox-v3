import 'package:memox/app/di/folder_providers.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/deck_summary.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folder_detail_viewmodel.g.dart';

/// Streams the Folder-detail read model (folder + breadcrumb + subfolders +
/// decks + counts) for [folderId]. Emits `null` when the folder is gone (e.g.
/// deleted from elsewhere) so the screen can pop. WBS 3.2.2.
@riverpod
Stream<FolderDetail?> folderDetailStream(Ref ref, String folderId) =>
    ref.watch(watchFolderDetailUseCaseProvider).call(id: folderId);

/// The active inline-search term for one folder-detail screen (scope-local).
/// Keyed by [folderId] so nested folder-detail screens don't share state.
@riverpod
class FolderSearchQuery extends _$FolderSearchQuery {
  @override
  String build(String folderId) => '';

  void setTerm(String term) => state = term;

  void clear() => state = '';
}

/// Whether one folder-detail screen is in search mode. Keyed by [folderId].
@riverpod
class FolderSearchActive extends _$FolderSearchActive {
  @override
  bool build(String folderId) => false;

  void activate() => state = true;

  void deactivate() => state = false;
}

/// Derived folder-detail view: the filtered subfolder/deck sets plus the active
/// term and unfiltered totals, so the screen can tell true-empty from
/// search-no-results.
typedef FolderDetailView = ({
  FolderDetail detail,
  List<FolderSummary> subfolders,
  List<DeckSummary> decks,
  int totalSubfolders,
  int totalDecks,
  String searchTerm,
});

/// Filters [detail]'s subfolders + decks by [term] (normalized name-contains).
/// Pure so the screen can call it inside its data branch. WBS 3.2.2.
FolderDetailView filterFolderDetail(FolderDetail detail, String term) {
  final String trimmed = StringUtils.trimmed(term);
  final List<FolderSummary> allSubfolders = detail.subfolders;
  final List<DeckSummary> allDecks = detail.decks;
  if (trimmed.isEmpty) {
    return (
      detail: detail,
      subfolders: allSubfolders,
      decks: allDecks,
      totalSubfolders: allSubfolders.length,
      totalDecks: allDecks.length,
      searchTerm: '',
    );
  }
  final String needle = StringUtils.caseFold(trimmed);
  return (
    detail: detail,
    subfolders: allSubfolders
        .where(
          (FolderSummary s) =>
              StringUtils.caseFold(s.folder.name).contains(needle),
        )
        .toList(growable: false),
    decks: allDecks
        .where(
          (DeckSummary d) => StringUtils.caseFold(d.deck.name).contains(needle),
        )
        .toList(growable: false),
    totalSubfolders: allSubfolders.length,
    totalDecks: allDecks.length,
    searchTerm: trimmed,
  );
}
