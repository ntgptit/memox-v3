import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'search_dao.g.dart';

/// Thin Drift accessor for the LIKE-based global search queries (WBS 3.5.1).
///
/// The repository lowercases + escapes the user query (`%`, `_`, `\`) and binds
/// it as the `:pattern` argument; these generated queries declare `ESCAPE '\'`
/// and compare against `lower(column)`. Ranking/caps live in the use case. No
/// business logic here (`docs/database/drift-guide.md`).
@DriftAccessor(include: <String>{'../drift/search_queries.drift'})
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  SearchDao(super.db);

  /// Folders whose name matches [pattern] (already lowercased + escaped).
  Future<List<FolderRow>> findFolders(String pattern) async {
    final List<SearchFoldersResult> rows = await searchFolders(pattern).get();
    return rows
        .map((SearchFoldersResult r) => r.folders)
        .toList(growable: false);
  }

  /// Decks whose name matches [pattern].
  Future<List<DeckRow>> findDecks(String pattern) async {
    final List<SearchDecksResult> rows = await searchDecks(pattern).get();
    return rows.map((SearchDecksResult r) => r.decks).toList(growable: false);
  }

  /// Flashcards whose front or back matches [pattern].
  Future<List<FlashcardRow>> findFlashcards(String pattern) async {
    final List<SearchFlashcardsResult> rows = await searchFlashcards(
      pattern,
    ).get();
    return rows
        .map((SearchFlashcardsResult r) => r.flashcards)
        .toList(growable: false);
  }
}
