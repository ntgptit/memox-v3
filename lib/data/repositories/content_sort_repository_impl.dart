import 'package:memox/data/datasources/local/preferences/content_sort_store.dart';
import 'package:memox/domain/repositories/content_sort_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';

/// SharedPreferences-backed [ContentSortRepository]: maps the per-scope stored
/// token to a [ContentSortMode] (unknown/corrupt → manual) and writes back the
/// `enum.name` token. See `docs/database/storage-boundaries.md` §Content sort.
class ContentSortRepositoryImpl implements ContentSortRepository {
  ContentSortRepositoryImpl(this._store);

  final ContentSortStore _store;

  @override
  ContentSortMode read(String scope) =>
      contentSortModeFromToken(_store.readSortToken(scope));

  @override
  Future<void> write(String scope, ContentSortMode mode) =>
      _store.writeSortToken(scope, mode.name);
}
