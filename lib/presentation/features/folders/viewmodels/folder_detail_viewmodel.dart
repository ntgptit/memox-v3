import 'dart:async';

import 'package:memox/app/di/folder_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folder_detail_viewmodel.g.dart';

/// Per-folder toolbar state: inline search term + sort mode.
class FolderDetailToolbarState {
  const FolderDetailToolbarState({
    this.searchTerm = '',
    this.sort = ContentSortMode.manual,
  });

  final String searchTerm;
  final ContentSortMode sort;

  bool get isSearching => StringUtils.trimmed(searchTerm).isNotEmpty;

  FolderDetailToolbarState copyWith({
    String? searchTerm,
    ContentSortMode? sort,
  }) => FolderDetailToolbarState(
    searchTerm: searchTerm ?? this.searchTerm,
    sort: sort ?? this.sort,
  );
}

/// Ephemeral search/sort selections, scoped per folder so stacked folder-detail
/// screens don't share state.
@riverpod
class FolderDetailToolbar extends _$FolderDetailToolbar {
  @override
  FolderDetailToolbarState build(String folderId) =>
      const FolderDetailToolbarState();

  void setSearch(String term) => state = state.copyWith(searchTerm: term);

  void clearSearch() => state = state.copyWith(searchTerm: '');

  void setSort(ContentSortMode sort) => state = state.copyWith(sort: sort);
}

/// Streams a folder's detail, reacting to its toolbar. `keepAlive` (deliberate
/// lifecycle, per `memox.state_management.query_provider_keep_alive`) so popping back to
/// a parent folder does not refetch-flicker. Unwraps the [Result]: a [Failure]
/// (e.g. NotFound) surfaces as `AsyncError` for the screen's error state.
@Riverpod(keepAlive: true)
Stream<FolderDetail> folderDetailQuery(Ref ref, String folderId) {
  final FolderDetailToolbarState toolbar = ref.watch(
    folderDetailToolbarProvider(folderId),
  );
  final useCase = ref.watch(watchFolderDetailUseCaseProvider);
  return useCase
      .call(folderId, searchTerm: toolbar.searchTerm, sort: toolbar.sort)
      .map(
        (Result<FolderDetail> result) => result.fold(
          // ignore: only_throw_errors -- reason: Riverpod stream query surfaces repository Failure as AsyncError.
          (Failure failure) => throw failure,
          (FolderDetail detail) => detail,
        ),
      );
}

/// Executes folder-detail mutations (create subfolder / deck). The Drift stream
/// refreshes the list automatically on success, so no manual state push.
@riverpod
class FolderActionController extends _$FolderActionController {
  @override
  FutureOr<void> build() {}

  void _setSettledState<T>(Result<T> result) {
    if (!ref.mounted) {
      return;
    }

    state = result.fold(
      (Failure failure) => AsyncValue<void>.error(failure, StackTrace.current),
      (T _) => const AsyncValue<void>.data(null),
    );
  }

  Future<Result<Folder>> createSubfolder(String parentId, String name) async {
    state = const AsyncValue<void>.loading();
    final useCase = ref.read(createSubfolderUseCaseProvider);
    final Result<Folder> result = await useCase.call(
      parentId: parentId,
      name: name,
    );
    _setSettledState(result);
    return result;
  }

  Future<Result<Deck>> createDeck(String parentFolderId, String name) async {
    state = const AsyncValue<void>.loading();
    final useCase = ref.read(createDeckUseCaseProvider);
    final Result<Deck> result = await useCase.call(
      parentFolderId: parentFolderId,
      name: name,
    );
    _setSettledState(result);
    return result;
  }
}
