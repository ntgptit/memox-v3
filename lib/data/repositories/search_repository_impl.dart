import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/search_dao.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/domain/repositories/search_repository.dart';

/// Drift-backed [SearchRepository].
///
/// Escapes LIKE wildcards in the (already-normalized) query, builds the
/// exact/prefix/substring patterns, and runs the three section queries in
/// parallel. Any database error is mapped to a read [StorageFailure].
class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl(this._dao);

  final SearchDao _dao;

  @override
  Future<Result<SearchResults>> search({
    required String query,
    required int sectionCap,
  }) async {
    final String escaped = _escapeLike(query);
    final String prefix = '$escaped%';
    final String contains = '%$escaped%';

    try {
      final (
        List<SearchFoldersResult> folders,
        List<SearchDecksResult> decks,
        List<SearchFlashcardsResult> cards,
      ) = await (
        _dao.findFolders(
          exact: query,
          prefix: prefix,
          contains: contains,
          cap: sectionCap,
        ),
        _dao.findDecks(
          exact: query,
          prefix: prefix,
          contains: contains,
          cap: sectionCap,
        ),
        _dao.findFlashcards(
          exact: query,
          prefix: prefix,
          contains: contains,
          cap: sectionCap,
        ),
      ).wait;

      return Result<SearchResults>.ok(
        SearchResults(
          folders: <FolderSearchHit>[
            for (final SearchFoldersResult row in folders)
              FolderSearchHit(id: row.id, name: row.name),
          ],
          decks: <DeckSearchHit>[
            for (final SearchDecksResult row in decks)
              DeckSearchHit(id: row.id, name: row.name),
          ],
          flashcards: <FlashcardSearchHit>[
            for (final SearchFlashcardsResult row in cards)
              FlashcardSearchHit(
                id: row.id,
                deckId: row.deckId,
                front: row.front,
                back: row.back,
              ),
          ],
          folderTotal: folders.isEmpty ? 0 : folders.first.totalCount,
          deckTotal: decks.isEmpty ? 0 : decks.first.totalCount,
          flashcardTotal: cards.isEmpty ? 0 : cards.first.totalCount,
        ),
      );
    } on Object catch (error) {
      return Result<SearchResults>.err(
        Failure.storage(operation: StorageOp.read, cause: error.toString()),
      );
    }
  }

  /// Escapes the LIKE metacharacters so user-typed `%`/`_`/`\` match literally
  /// under `ESCAPE '\'`. Backslash first to avoid double-escaping.
  static String _escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
