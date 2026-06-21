import 'package:memox/app/di/content_sort_providers.dart';
import 'package:memox/domain/repositories/content_sort_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_sort_provider.g.dart';

/// The content-sort modes offered by the sort sheet, in display order.
///
/// `ContentSortMode.lastStudied` is intentionally **excluded**: it needs a
/// last-studied aggregate read model (a subtree join over study attempts) that
/// does not exist yet — see `docs/wireframes/02-library.md` §Sort options.
const List<ContentSortMode> kSortSheetModes = <ContentSortMode>[
  ContentSortMode.manual,
  ContentSortMode.name,
  ContentSortMode.newest,
];

/// Sort scope for the Library root.
const String sortScopeLibrary = 'library';

/// Sort scope for a folder's detail screen (each folder remembers its own sort).
String sortScopeFolder(String folderId) => 'folder:$folderId';

/// Sort scope for a deck's flashcard list (each deck remembers its own sort).
String sortScopeDeck(String deckId) => 'deck:$deckId';

/// The content-sort preference for a single [scope] (the Library root, a folder,
/// or a deck). Keyed by scope so choosing a sort on one object never bleeds into
/// another — persisted per scope under `library.sort.<scope>` via
/// [ContentSortRepository]. Defaults to [ContentSortMode.manual].
///
/// `keepAlive` so a scope's sort survives leaving and returning to its screen
/// within a session (it is also persisted across restarts).
@Riverpod(keepAlive: true)
class LibrarySort extends _$LibrarySort {
  @override
  Future<ContentSortMode> build(String scope) async {
    final ContentSortRepository repo = await ref.watch(
      contentSortRepositoryProvider.future,
    );
    return repo.read(scope);
  }

  /// Persists [mode] for this scope and reflects it immediately. No-op when
  /// unchanged.
  Future<void> setSort(ContentSortMode mode) async {
    if (state.value == mode) return;
    final ContentSortRepository repo = await ref.read(
      contentSortRepositoryProvider.future,
    );
    await repo.write(scope, mode);
    state = AsyncData<ContentSortMode>(mode);
  }
}

/// The current sort mode for [scope], resolved synchronously for read-side use
/// (defaults to [ContentSortMode.manual] while the preference is still loading).
@riverpod
ContentSortMode librarySortMode(Ref ref, String scope) =>
    ref.watch(librarySortProvider(scope)).value ?? ContentSortMode.manual;
