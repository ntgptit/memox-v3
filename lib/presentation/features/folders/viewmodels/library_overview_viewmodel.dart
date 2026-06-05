import 'dart:async';

import 'package:memox/app/di/folder_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_overview_viewmodel.g.dart';

/// Screen-local toolbar state for Library Overview: the inline search term and
/// the (UI-less in V1) sort mode.
class LibraryToolbarState {
  const LibraryToolbarState({
    this.searchTerm = '',
    this.sort = ContentSortMode.manual,
  });

  final String searchTerm;
  final ContentSortMode sort;

  bool get isSearching => StringUtils.trimmed(searchTerm).isNotEmpty;

  LibraryToolbarState copyWith({String? searchTerm, ContentSortMode? sort}) =>
      LibraryToolbarState(
        searchTerm: searchTerm ?? this.searchTerm,
        sort: sort ?? this.sort,
      );
}

/// Holds the inline-search + sort selections that drive the query. Ephemeral UI
/// state (never persisted), so plain auto-dispose is correct.
@riverpod
class LibraryToolbar extends _$LibraryToolbar {
  @override
  LibraryToolbarState build() => const LibraryToolbarState();

  void setSearch(String term) => state = state.copyWith(searchTerm: term);

  void clearSearch() => state = state.copyWith(searchTerm: '');

  void setSort(ContentSortMode sort) => state = state.copyWith(sort: sort);
}

/// Streams the Library Overview read model, reacting to the toolbar. Unwraps the
/// repository [Result]: a [Failure] is thrown so it surfaces as `AsyncError`
/// (rendered by the screen's error section); success emits the model.
///
/// `keepAlive` (deliberate lifecycle) so re-entering the Library tab does not
/// refetch-flicker (`memox.feature_query_provider_keep_alive`).
@Riverpod(keepAlive: true)
Stream<LibraryOverviewReadModel> libraryOverviewQuery(Ref ref) {
  final LibraryToolbarState toolbar = ref.watch(libraryToolbarProvider);
  final useCase = ref.watch(watchLibraryOverviewUseCaseProvider);
  return useCase
      .call(searchTerm: toolbar.searchTerm, sort: toolbar.sort)
      .map(
        (Result<LibraryOverviewReadModel> result) => result.fold(
          // Surface the Failure as AsyncError for the screen's error section.
          // ignore: only_throw_errors
          (Failure failure) => throw failure,
          (LibraryOverviewReadModel model) => model,
        ),
      );
}

/// Executes Library mutations (create folder). Exposes `AsyncValue<void>` for
/// in-flight state; the Drift stream refreshes the list automatically on
/// success, so no manual state push.
@riverpod
class LibraryActionController extends _$LibraryActionController {
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

  Future<Result<Folder>> createFolder(String name) async {
    state = const AsyncValue<void>.loading();
    final useCase = ref.read(createRootFolderUseCaseProvider);
    final Result<Folder> result = await useCase.call(name: name);
    _setSettledState(result);
    return result;
  }

  Future<Result<Folder>> renameFolder(FolderId id, String name) async {
    state = const AsyncValue<void>.loading();
    final useCase = ref.read(renameFolderUseCaseProvider);
    final Result<Folder> result = await useCase.call(id: id, name: name);
    _setSettledState(result);
    return result;
  }

  Future<Result<Folder>> moveFolder(FolderId id, FolderId? newParentId) async {
    state = const AsyncValue<void>.loading();
    final useCase = ref.read(moveFolderUseCaseProvider);
    final Result<Folder> result = await useCase.call(
      id: id,
      newParentId: newParentId,
    );
    _setSettledState(result);
    return result;
  }

  Future<Result<void>> deleteFolder(FolderId id) async {
    state = const AsyncValue<void>.loading();
    final useCase = ref.read(deleteFolderUseCaseProvider);
    final Result<void> result = await useCase.call(id: id);
    _setSettledState(result);
    return result;
  }

  /// Loads the move-destination candidates for [id] (read-only; does not change
  /// the controller's mutation state).
  Future<Result<List<FolderMoveTarget>>> loadMoveTargets(FolderId id) =>
      ref.read(getFolderMoveTargetsUseCaseProvider).call(folderId: id);
}
