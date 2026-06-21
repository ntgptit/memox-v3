import 'package:shared_preferences/shared_preferences.dart';

/// Thin SharedPreferences accessor for the global content-sort preference
/// (Library / Folder detail / Deck / Flashcard share one key). Reads/writes the
/// raw enum token only — default + corrupt recovery live in the provider that
/// maps the token to `ContentSortMode` (`docs/database/storage-boundaries.md`).
class ContentSortStore {
  ContentSortStore(this._prefs);

  final SharedPreferences _prefs;

  /// Persisted SharedPreferences key (one global preference across the content
  /// screens), per `docs/database/storage-boundaries.md` §Content sort.
  static const String sortKey = 'library.sort';

  /// Raw stored `ContentSortMode` token (`enum.name`), or `null` when unset.
  /// Reading a value stored under the wrong type returns `null` (treated as
  /// missing/corrupt by the caller) instead of throwing.
  String? readSortToken() {
    final Object? value = _prefs.get(sortKey);
    return value is String ? value : null;
  }

  Future<void> writeSortToken(String token) => _prefs.setString(sortKey, token);
}
