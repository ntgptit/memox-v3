import 'package:memox/domain/types/content_sort_mode.dart';

/// Reads/writes the **per-scope** content-sort preference. Each scope (the
/// Library root, a folder, a deck) is independent, so the Library / Folder
/// detail / Deck / Flashcard screens each remember their own sort.
///
/// The preference is a UI ordering choice, not entity data; it persists so the
/// choice survives restarts. Defaults to [ContentSortMode.manual].
abstract interface class ContentSortRepository {
  /// The persisted sort mode for [scope] (or [ContentSortMode.manual] when
  /// unset/corrupt).
  ContentSortMode read(String scope);

  /// Persists [mode] as the active sort preference for [scope].
  Future<void> write(String scope, ContentSortMode mode);
}
