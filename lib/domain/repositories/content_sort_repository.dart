import 'package:memox/domain/types/content_sort_mode.dart';

/// Reads/writes the global content-sort preference shared by the Library,
/// Folder detail, Deck, and Flashcard screens (one SharedPreferences key).
///
/// The preference is a UI ordering choice, not entity data; it persists so the
/// choice survives restarts. Defaults to [ContentSortMode.manual].
abstract interface class ContentSortRepository {
  /// The persisted sort mode (or [ContentSortMode.manual] when unset/corrupt).
  ContentSortMode read();

  /// Persists [mode] as the active sort preference.
  Future<void> write(ContentSortMode mode);
}
