import 'dart:async';

import 'package:drift/drift.dart';

import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/id_generator.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';

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

    final Stream<List<QueryRow>> source = _dao.watchLibraryOverview(
      nowMs: _endOfTodayMs(),
      orderClause: _orderClause(sort),
      normalizedSearch: normalized,
    );

    return source.transform(
      StreamTransformer<List<QueryRow>, Result<LibraryOverviewReadModel>>.fromHandlers(
        handleData: (List<QueryRow> rows, EventSink<Result<LibraryOverviewReadModel>> sink) =>
            sink.add(Result<LibraryOverviewReadModel>.ok(_toReadModel(rows))),
        handleError: (Object error, StackTrace stack, EventSink<Result<LibraryOverviewReadModel>> sink) =>
            sink.add(
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
          Failure.validation(
            field: 'name',
            code: ValidationCode.duplicate,
          ),
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

  LibraryOverviewReadModel _toReadModel(List<QueryRow> rows) {
    final List<FolderWithCount> folders = rows
        .map(FolderMapper.overviewItemFromQueryRow)
        .toList(growable: false);
    // Global totals are repeated on every row; read from the first, else 0
    // (no rows ⇒ no folders at all ⇒ totals are 0).
    final QueryRow? first = rows.isEmpty ? null : rows.first;
    return LibraryOverviewReadModel(
      folders: folders,
      dueToday: first?.read<int>('due_today_total') ?? 0,
      totalFolderCount: first?.read<int>('total_folder_count') ?? 0,
    );
  }

  /// Trusted, controlled `ORDER BY` fragment. Folders are kept stable by
  /// `sort_order` then creation time as a tiebreaker.
  static String _orderClause(ContentSortMode sort) => switch (sort) {
    ContentSortMode.name => 'LOWER(f.name) ASC, f.sort_order ASC',
    ContentSortMode.newest => 'f.created_at DESC, f.sort_order ASC',
    // lastStudied has no dedicated column yet; fall back to manual order.
    ContentSortMode.lastStudied ||
    ContentSortMode.manual => 'f.sort_order ASC, f.created_at ASC',
  };

  /// End of the current local day in UTC epoch ms — cards due any time today
  /// count toward "due today".
  static int _endOfTodayMs() {
    final DateTime now = DateTime.now();
    final DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return endOfDay.millisecondsSinceEpoch;
  }
}
