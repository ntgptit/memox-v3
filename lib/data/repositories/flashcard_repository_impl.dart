import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/deck_mapper.dart';
import 'package:memox/data/mappers/flashcard_mapper.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';

/// Drift-backed [FlashcardRepository].
///
/// Reads compose the [FlashcardDao] (cards + count) with the [FolderDao] (deck
/// row + folder breadcrumb + the content-revision change stream). Errors are
/// surfaced as [Failure] values, never raw exceptions
/// (`docs/contracts/error-contract.md`).
class FlashcardRepositoryImpl implements FlashcardRepository {
  FlashcardRepositoryImpl(this._dao, this._folderDao);

  final FlashcardDao _dao;
  final FolderDao _folderDao;

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    String deckId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
  }) {
    final String? normalized =
        (searchTerm == null || StringUtils.trimmed(searchTerm).isEmpty)
        ? null
        : StringUtils.normalize(searchTerm);

    return _folderDao.watchContentChanges().asyncMap(
      (_) => _load(deckId, normalized, sort),
    );
  }

  Future<Result<FlashcardListDetail>> _load(
    String deckId,
    String? normalizedSearch,
    ContentSortMode sort,
  ) async {
    try {
      final DeckRow? deckRow = await _folderDao.findDeck(deckId);
      if (deckRow == null) {
        return Result<FlashcardListDetail>.err(
          Failure.notFound(entity: 'deck', id: deckId),
        );
      }
      final Deck deck = DeckMapper.fromRow(deckRow);

      final List<FolderBreadcrumbSegment> breadcrumb =
          (await _folderDao.breadcrumb(deck.folderId))
              .map(
                (FolderBreadcrumbResult row) =>
                    FolderBreadcrumbSegment(id: row.id, name: row.name),
              )
              .toList(growable: false);

      final List<Flashcard> cards =
          (await _dao.getFlashcards(
            deckId: deckId,
            sort: sort,
            normalizedSearch: normalizedSearch,
          )).map(FlashcardMapper.fromRow).toList(growable: false);

      final int totalCount = await _dao.countFlashcards(deckId);

      return Result<FlashcardListDetail>.ok(
        FlashcardListDetail(
          deck: deck,
          breadcrumb: breadcrumb,
          cards: cards,
          totalCount: totalCount,
        ),
      );
    } catch (error) {
      return Result<FlashcardListDetail>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'flashcards',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteFlashcard({required String flashcardId}) async {
    try {
      final FlashcardRow? row = await _dao.findFlashcard(flashcardId);
      if (row == null) {
        return Result<void>.err(
          Failure.notFound(entity: 'flashcard', id: flashcardId),
        );
      }
      await _dao.deleteFlashcardById(flashcardId);
      return const Result<void>.ok(null);
    } catch (error) {
      return Result<void>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'flashcards',
        ),
      );
    }
  }

  @override
  Future<Result<void>> reorderFlashcards({
    required String deckId,
    required List<String> orderedIds,
  }) async {
    try {
      await _dao.transaction(() async {
        final int nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
        for (int index = 0; index < orderedIds.length; index++) {
          await _dao.updateSortOrder(orderedIds[index], index, nowMs);
        }
      });
      return const Result<void>.ok(null);
    } catch (error) {
      return Result<void>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'flashcards',
        ),
      );
    }
  }

}
