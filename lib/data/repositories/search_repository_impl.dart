import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/search_dao.dart';
import 'package:memox/data/mappers/deck_mapper.dart';
import 'package:memox/data/mappers/flashcard_mapper.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/repositories/search_repository.dart';

/// Drift-backed [SearchRepository] (WBS 3.5.1).
///
/// Escapes the LIKE wildcards (`%`, `_`, `\`) in the already-normalized query,
/// wraps it in `%…%` for a substring match, and binds it to the `ESCAPE '\'`
/// queries on [SearchDao]. Ranking/caps live in `GlobalSearchUseCase`; this
/// layer only filters + maps rows. Read errors map to `StorageFailure(read)`.
class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl({required SearchDao dao}) : _dao = dao;

  final SearchDao _dao;

  /// Build the escaped `%…%` substring pattern from the normalized query.
  String _pattern(String normalizedQuery) =>
      '%${StringUtils.escapeLike(normalizedQuery)}%';

  @override
  Future<Result<List<Folder>>> searchFolders(String normalizedQuery) async {
    try {
      final List<FolderRow> rows = await _dao.findFolders(
        _pattern(normalizedQuery),
      );
      return (
        failure: null,
        data: rows.map(FolderMapper.fromRow).toList(growable: false),
      );
    } catch (error) {
      return (failure: _storageRead(error, 'folders'), data: null);
    }
  }

  @override
  Future<Result<List<Deck>>> searchDecks(String normalizedQuery) async {
    try {
      final List<DeckRow> rows = await _dao.findDecks(
        _pattern(normalizedQuery),
      );
      return (
        failure: null,
        data: rows.map(DeckMapper.fromRow).toList(growable: false),
      );
    } catch (error) {
      return (failure: _storageRead(error, 'decks'), data: null);
    }
  }

  @override
  Future<Result<List<Flashcard>>> searchFlashcards(
    String normalizedQuery,
  ) async {
    try {
      final List<FlashcardRow> rows = await _dao.findFlashcards(
        _pattern(normalizedQuery),
      );
      return (
        failure: null,
        data: rows.map(FlashcardMapper.fromRow).toList(growable: false),
      );
    } catch (error) {
      return (failure: _storageRead(error, 'flashcards'), data: null);
    }
  }

  Failure _storageRead(Object error, String table) => Failure.storage(
    operation: StorageOp.read,
    table: table,
    cause: error.toString(),
  );
}
