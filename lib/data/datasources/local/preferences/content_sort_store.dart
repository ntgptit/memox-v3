import 'package:shared_preferences/shared_preferences.dart';

/// Thin SharedPreferences accessor for the per-scope content-sort preference.
///
/// Each sort scope (the Library root, a folder, a deck) persists independently
/// under `library.sort.<scope>`, so choosing a sort on one object never bleeds
/// into another. Reads/writes the raw enum token only — default + corrupt
/// recovery live in `ContentSortRepositoryImpl`
/// (`docs/database/storage-boundaries.md` §Content sort).
class ContentSortStore {
  ContentSortStore(this._prefs);

  final SharedPreferences _prefs;

  /// Key prefix for every per-scope content-sort preference.
  static const String keyPrefix = 'library.sort.';

  String _key(String scope) => '$keyPrefix$scope';

  /// Raw stored `ContentSortMode` token for [scope] (`enum.name`), or `null`
  /// when unset. A value stored under the wrong type returns `null` (treated as
  /// missing/corrupt by the caller) instead of throwing.
  String? readSortToken(String scope) {
    final Object? value = _prefs.get(_key(scope));
    return value is String ? value : null;
  }

  Future<void> writeSortToken(String scope, String token) =>
      _prefs.setString(_key(scope), token);
}
