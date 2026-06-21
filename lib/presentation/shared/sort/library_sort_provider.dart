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

/// The global content-sort preference shared by Library, Folder detail, Deck,
/// and Flashcard screens (one SharedPreferences key, `library.sort`, behind
/// [ContentSortRepository]). Persisted so the choice survives restarts; defaults
/// to [ContentSortMode.manual].
///
/// `keepAlive` because it is app-wide shared state read by several feature
/// screens; losing it on the last listener would reset the user's sort.
@Riverpod(keepAlive: true)
class LibrarySort extends _$LibrarySort {
  @override
  Future<ContentSortMode> build() async {
    final ContentSortRepository repo = await ref.watch(
      contentSortRepositoryProvider.future,
    );
    return repo.read();
  }

  /// Persists [mode] and reflects it immediately. No-op when unchanged.
  Future<void> setSort(ContentSortMode mode) async {
    if (state.value == mode) return;
    final ContentSortRepository repo = await ref.read(
      contentSortRepositoryProvider.future,
    );
    await repo.write(mode);
    state = AsyncData<ContentSortMode>(mode);
  }
}

/// The current sort mode, resolved synchronously for read-side use (defaults to
/// [ContentSortMode.manual] while the preference is still loading).
@riverpod
ContentSortMode librarySortMode(Ref ref) =>
    ref.watch(librarySortProvider).value ?? ContentSortMode.manual;
