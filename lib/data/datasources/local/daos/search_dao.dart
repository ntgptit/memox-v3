import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'search_dao.g.dart';

/// Drift accessor for global Library search reads
/// (`docs/wireframes/11-library-search.md`).
///
/// SQL lives in `drift/search_queries.drift` (pulled in via `include`); these
/// methods are thin wrappers that bind the pre-built LIKE patterns and run the
/// generated, type-safe section queries. Pattern escaping + normalization is
/// the repository's job — the DAO trusts its inputs.
///
/// Drift orders the generated positional params by first appearance in the SQL
/// (`contains` in the WHERE, then `exact`/`prefix` in the ORDER BY, then `cap`
/// in the LIMIT), so these named wrappers exist to bind by name and forward in
/// that exact order — never reorder the underlying calls.
@DriftAccessor(include: <String>{'../drift/search_queries.drift'})
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  SearchDao(super.db);

  Future<List<SearchFoldersResult>> findFolders({
    required String exact,
    required String prefix,
    required String contains,
    required int cap,
  }) => searchFolders(contains, exact, prefix, cap).get();

  Future<List<SearchDecksResult>> findDecks({
    required String exact,
    required String prefix,
    required String contains,
    required int cap,
  }) => searchDecks(contains, exact, prefix, cap).get();

  Future<List<SearchFlashcardsResult>> findFlashcards({
    required String exact,
    required String prefix,
    required String contains,
    required int cap,
  }) => searchFlashcards(contains, exact, prefix, cap).get();
}
