import 'dart:async';

import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/id_generator.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/deck_mapper.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/data/repositories/folder_repo_impl_mutation_helpers.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/target_language.dart';

/// Drift-backed [FolderRepository].
///
/// Stream errors are caught and surfaced as a [StorageFailure] value (never a
/// raw exception), per `docs/contracts/error-contract.md`.
class FolderRepositoryImpl implements FolderRepository {
  FolderRepositoryImpl(this._dao);

  final FolderDao _dao;

  @override
  Stream<Result<LibraryOverviewReadModel>> watchLibraryOverview({
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
  }) {
    final String? normalized =
        (searchTerm == null || StringUtils.trimmed(searchTerm).isEmpty)
        ? null
        : StringUtils.normalize(searchTerm);

    final Stream<List<LibraryOverviewResult>> source = _dao
        .watchLibraryOverview(
          nowMs: _endOfTodayMs(),
          sort: sort,
          normalizedSearch: normalized,
        );

    return source.transform(
      StreamTransformer<
        List<LibraryOverviewResult>,
        Result<LibraryOverviewReadModel>
      >.fromHandlers(
        handleData:
            (
              List<LibraryOverviewResult> rows,
              EventSink<Result<LibraryOverviewReadModel>> sink,
            ) => sink.add(
              Result<LibraryOverviewReadModel>.ok(_toReadModel(rows)),
            ),
        handleError:
            (
              Object error,
              StackTrace stack,
              EventSink<Result<LibraryOverviewReadModel>> sink,
            ) => sink.add(
              Result<LibraryOverviewReadModel>.err(
                Failure.storage(
                  operation: StorageOp.read,
                  cause: error.toString(),
                  table: 'folders',
                ),
              ),
            ),
      ),
    );
  }

  @override
  Future<Result<Folder>> createRootFolder({required String name}) async {
    try {
      final FolderRow? created = await _dao.transaction(() async {
        final String normalized = StringUtils.normalize(name);
        final List<String> existing = await _dao.rootFolderNames();
        final bool duplicate = existing.any(
          (String n) => StringUtils.normalize(n) == normalized,
        );
        if (duplicate) {
          return null;
        }
        final int nextOrder = (await _dao.maxRootSortOrder()) + 1;
        final int nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
        final String id = IdGenerator.newId();
        await _dao.insertFolder(
          FoldersCompanion.insert(
            id: id,
            name: name,
            sortOrder: Value<int>(nextOrder),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
        return _dao.findFolder(id);
      });

      if (created == null) {
        return const Result<Folder>.err(
          Failure.validation(field: 'name', code: ValidationCode.duplicate),
        );
      }
      return Result<Folder>.ok(FolderMapper.fromRow(created));
    } catch (error) {
      return Result<Folder>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'folders',
        ),
      );
    }
  }

  @override
  Future<Result<Folder>> createSubfolder({
    required String parentId,
    required String name,
  }) async {
    try {
      final FolderRow created = await _dao.transaction(() async {
        final FolderRow? parent = await _dao.findFolder(parentId);
        if (parent == null) {
          throw _RuleViolation(
            Failure.notFound(entity: 'folder', id: parentId),
          );
        }
        final ContentMode parentMode = FolderMapper.contentModeFromStorage(
          parent.contentMode,
        );
        if (parentMode == ContentMode.decks) {
          throw const _RuleViolation(
            Failure.unsupportedAction(
              action: 'create_subfolder_in_decks_folder',
            ),
          );
        }
        final String normalized = StringUtils.normalize(name);
        final List<String> siblings = await _dao.childFolderNames(parentId);
        if (siblings.any(
          (String n) => StringUtils.normalize(n) == normalized,
        )) {
          throw const _RuleViolation(
            Failure.validation(field: 'name', code: ValidationCode.duplicate),
          );
        }
        final int nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
        final String id = IdGenerator.newId();
        await _dao.insertFolder(
          FoldersCompanion.insert(
            id: id,
            name: name,
            parentId: Value<String?>(parentId),
            sortOrder: Value<int>(
              (await _dao.maxChildFolderSortOrder(parentId)) + 1,
            ),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
        if (parentMode == ContentMode.unlocked) {
          await _dao.setFolderContentMode(
            parentId,
            FolderMapper.contentModeToStorage(ContentMode.subfolders),
          );
        }
        return (await _dao.findFolder(id))!;
      });
      return Result<Folder>.ok(FolderMapper.fromRow(created));
    } on _RuleViolation catch (violation) {
      return Result<Folder>.err(violation.failure);
    } catch (error) {
      return Result<Folder>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'folders',
        ),
      );
    }
  }

  @override
  Future<Result<Deck>> createDeck({
    required String parentFolderId,
    required String name,
    required TargetLanguage targetLanguage,
  }) async {
    try {
      final DeckRow created = await _dao.transaction(() async {
        final FolderRow? parent = await _dao.findFolder(parentFolderId);
        if (parent == null) {
          throw _RuleViolation(
            Failure.notFound(entity: 'folder', id: parentFolderId),
          );
        }
        final ContentMode parentMode = FolderMapper.contentModeFromStorage(
          parent.contentMode,
        );
        if (parentMode == ContentMode.subfolders) {
          throw const _RuleViolation(
            Failure.unsupportedAction(
              action: 'create_deck_in_subfolders_folder',
            ),
          );
        }
        final String normalized = StringUtils.normalize(name);
        final List<String> siblings = await _dao.deckNames(parentFolderId);
        if (siblings.any(
          (String n) => StringUtils.normalize(n) == normalized,
        )) {
          throw const _RuleViolation(
            Failure.validation(field: 'name', code: ValidationCode.duplicate),
          );
        }
        final int nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
        final String id = IdGenerator.newId();
        await _dao.insertDeck(
          DecksCompanion.insert(
            id: id,
            folderId: parentFolderId,
            name: name,
            targetLanguage: Value<String>(
              DeckMapper.targetLanguageToStorage(targetLanguage),
            ),
            sortOrder: Value<int>(
              (await _dao.maxDeckSortOrder(parentFolderId)) + 1,
            ),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
        if (parentMode == ContentMode.unlocked) {
          await _dao.setFolderContentMode(
            parentFolderId,
            FolderMapper.contentModeToStorage(ContentMode.decks),
          );
        }
        return (await _dao.findDeck(id))!;
      });
      return Result<Deck>.ok(DeckMapper.fromRow(created));
    } on _RuleViolation catch (violation) {
      return Result<Deck>.err(violation.failure);
    } catch (error) {
      return Result<Deck>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'decks',
        ),
      );
    }
  }

  @override
  Future<Result<Deck>> renameDeck({
    required String deckId,
    required String name,
  }) => renameDeckTxn(_dao, deckId, name);

  @override
  Future<Result<Deck>> moveDeck({
    required String deckId,
    required String newParentId,
  }) => moveDeckTxn(_dao, deckId, newParentId);

  @override
  Future<Result<Folder>> renameFolder({
    required String folderId,
    required String name,
  }) => renameFolderTxn(_dao, folderId, name);

  @override
  Future<Result<Folder>> moveFolder({
    required String folderId,
    required String? newParentId,
  }) => moveFolderTxn(_dao, folderId, newParentId);

  @override
  Future<Result<void>> reorderFolders({
    required String? parentId,
    required List<String> orderedIds,
  }) => reorderFoldersTxn(_dao, parentId, orderedIds);

  @override
  Future<Result<void>> reorderDecks({
    required String parentId,
    required List<String> orderedIds,
  }) => reorderDecksTxn(_dao, parentId, orderedIds);

  @override
  Future<Result<void>> deleteFolder({required String folderId}) =>
      deleteFolderTxn(_dao, folderId);

  @override
  Future<Result<void>> deleteDeck({required String deckId}) =>
      deleteDeckTxn(_dao, deckId);

  @override
  Future<Result<List<FolderMoveTarget>>> getFolderMoveTargets({
    required String folderId,
  }) => folderMoveTargets(_dao, folderId);

  @override
  Stream<Result<FolderDetail>> watchFolderDetail(
    String folderId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
  }) {
    final String? normalized =
        (searchTerm == null || StringUtils.trimmed(searchTerm).isEmpty)
        ? null
        : StringUtils.normalize(searchTerm);

    return _dao.watchContentChanges().asyncMap(
      (_) => _loadFolderDetail(folderId, normalized, sort),
    );
  }

  Future<Result<FolderDetail>> _loadFolderDetail(
    String folderId,
    String? normalizedSearch,
    ContentSortMode sort,
  ) async {
    try {
      final FolderRow? folderRow = await _dao.findFolder(folderId);
      if (folderRow == null) {
        return Result<FolderDetail>.err(
          Failure.notFound(entity: 'folder', id: folderId),
        );
      }
      final Folder folder = FolderMapper.fromRow(folderRow);
      final int nowMs = _endOfTodayMs();

      final List<FolderBreadcrumbSegment> breadcrumb =
          (await _dao.breadcrumb(folderId))
              .map(
                (FolderBreadcrumbResult row) =>
                    FolderBreadcrumbSegment(id: row.id, name: row.name),
              )
              .toList(growable: false);

      // A folder holds either subfolders or decks (never both); the unused list
      // stays empty.
      final List<FolderWithCount> subfolders =
          folder.contentMode == ContentMode.subfolders
          ? (await _dao.getSubfolderItems(
              parentId: folderId,
              nowMs: nowMs,
              sort: sort,
              normalizedSearch: normalizedSearch,
            )).map(_folderWithCountFromSubfolderItem).toList(growable: false)
          : const <FolderWithCount>[];

      final List<DeckWithCount> decks = folder.contentMode == ContentMode.decks
          ? (await _dao.getDeckItems(
              folderId: folderId,
              nowMs: nowMs,
              sort: sort,
              normalizedSearch: normalizedSearch,
            )).map(_deckWithCountFromDeckItem).toList(growable: false)
          : const <DeckWithCount>[];

      return Result<FolderDetail>.ok(
        FolderDetail(
          folder: folder,
          breadcrumb: breadcrumb,
          subfolders: subfolders,
          decks: decks,
        ),
      );
    } catch (error) {
      return Result<FolderDetail>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'folders',
        ),
      );
    }
  }

  LibraryOverviewReadModel _toReadModel(List<LibraryOverviewResult> rows) {
    final List<FolderWithCount> folders = rows
        .map(_folderWithCountFromLibraryOverview)
        .toList(growable: false);
    // Global totals are repeated on every row; read from the first, else 0
    // (no rows ⇒ no folders at all ⇒ totals are 0).
    final LibraryOverviewResult? first = rows.isEmpty ? null : rows.first;
    return LibraryOverviewReadModel(
      folders: folders,
      dueToday: first?.dueTodayTotal ?? 0,
      totalFolderCount: first?.totalFolderCount ?? 0,
    );
  }

  static FolderWithCount _folderWithCountFromLibraryOverview(
    LibraryOverviewResult row,
  ) => FolderWithCount(
    folder: FolderMapper.fromStorageFields(
      id: row.id,
      parentId: row.parentId,
      name: row.name,
      contentMode: row.contentMode,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    ),
    subfolderCount: row.subfolderCount,
    deckCount: row.deckCount,
    cardCount: row.cardCount,
    dueCount: row.dueCount,
    subtitle: row.subtitle,
    newCount: row.newCount,
    mastery: row.mastery,
  );

  static FolderWithCount _folderWithCountFromSubfolderItem(
    SubfolderItemsResult row,
  ) => FolderWithCount(
    folder: FolderMapper.fromStorageFields(
      id: row.id,
      parentId: row.parentId,
      name: row.name,
      contentMode: row.contentMode,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    ),
    subfolderCount: row.subfolderCount,
    deckCount: row.deckCount,
    cardCount: row.cardCount,
    dueCount: row.dueCount,
  );

  static DeckWithCount _deckWithCountFromDeckItem(DeckItemsResult row) =>
      DeckWithCount(
        deck: DeckMapper.fromStorageFields(
          id: row.id,
          folderId: row.folderId,
          name: row.name,
          targetLanguage: row.targetLanguage,
          sortOrder: row.sortOrder,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        ),
        cardCount: row.cardCount,
        dueCount: row.dueCount,
        lastStudiedAt: row.lastStudiedAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row.lastStudiedAt!),
      );

  /// End of the current local day in UTC epoch ms — cards due any time today
  /// count toward "due today".
  static int _endOfTodayMs() {
    final DateTime now = DateTime.now();
    final DateTime endOfDay = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
      999,
    );
    return endOfDay.millisecondsSinceEpoch;
  }
}

/// Internal control-flow marker: carries the business [Failure] out of a Drift
/// transaction so it can be converted to a `Result` at the repository boundary
/// (and the transaction rolls back). Never escapes this file.
class _RuleViolation implements Exception {
  const _RuleViolation(this.failure);

  final Failure failure;
}
