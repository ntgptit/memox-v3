import 'package:memox/data/datasources/local/preferences/content_sort_store.dart';
import 'package:memox/domain/repositories/content_sort_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';

/// SharedPreferences-backed [ContentSortRepository]: maps the stored token to a
/// [ContentSortMode] (unknown/corrupt → manual) and writes back the `enum.name`
/// token. See `docs/database/storage-boundaries.md` §Content sort.
class ContentSortRepositoryImpl implements ContentSortRepository {
  ContentSortRepositoryImpl(this._store);

  final ContentSortStore _store;

  @override
  ContentSortMode read() => contentSortModeFromToken(_store.readSortToken());

  @override
  Future<void> write(ContentSortMode mode) => _store.writeSortToken(mode.name);
}
