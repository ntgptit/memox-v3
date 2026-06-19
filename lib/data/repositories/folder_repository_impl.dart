import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/ids.dart';

part 'folder_repo_impl_mutation_helpers.dart';

/// Drift-backed [FolderRepository].
///
/// Reads compose the generated query results into domain read models; mutations
/// run inside [FolderDao] transactions and enforce the content-mode lock,
/// sibling-name uniqueness and recursive cascade. Mutation helpers (validation,
/// guards, cascade) live in the `folder_repo_impl_mutation_helpers.dart` part.
///
/// [idGenerator] and [nowMs] are injectable so tests get deterministic ids and
/// timestamps.
class FolderRepositoryImpl implements FolderRepository {
  FolderRepositoryImpl({
    required FolderDao dao,
    IdGenerator? idGenerator,
    int Function()? nowMs,
  }) : _dao = dao,
       _idGenerator = idGenerator ?? IdGenerator(),
       _nowMs = nowMs ?? _defaultNowMs;

  final FolderDao _dao;
  final IdGenerator _idGenerator;
  final int Function() _nowMs;

  static int _defaultNowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;

  // ---- Reads ----

  @override
  Stream<LibraryOverview> watchLibraryOverview() =>
      _dao.watchRootFolderSummaries().map(
        (List<RootFolderSummariesResult> rows) => LibraryOverview(
          folders: rows
              .map(
                (RootFolderSummariesResult r) =>
                    _summary(r.folders, r.subfolderCount),
              )
              .toList(growable: false),
        ),
      );

  @override
  Stream<FolderDetail?> watchFolderDetail(FolderId id) => _dao
      .watchChildFolderSummaries(id)
      .asyncMap((List<ChildFolderSummariesResult> children) async {
        final FolderRow? row = await _dao.findFolderById(id);
        if (row == null) return null;
        final List<FolderRow> breadcrumb = await _dao.getBreadcrumb(id);
        return FolderDetail(
          folder: FolderMapper.fromRow(row),
          breadcrumb: breadcrumb
              .map(FolderMapper.fromRow)
              .toList(growable: false),
          subfolders: children
              .map(
                (ChildFolderSummariesResult r) =>
                    _summary(r.folders, r.subfolderCount),
              )
              .toList(growable: false),
          // Deck/card tables not in the schema yet (WBS 2.7.x / 2.11.x).
          deckCount: 0,
          cardCount: 0,
          dueCount: 0,
        );
      });

  FolderSummary _summary(FolderRow row, int subfolderCount) => FolderSummary(
    folder: FolderMapper.fromRow(row),
    subfolderCount: subfolderCount,
    // Deck/card tables not in the schema yet (WBS 2.7.x / 2.11.x).
    deckCount: 0,
    cardCount: 0,
    dueCount: 0,
  );

  // ---- Mutations ----

  @override
  Future<Result<Folder>> createRootFolder({required String name}) async {
    final String trimmed = name.trim();
    final Failure? invalid = _validateName(trimmed);
    if (invalid != null) return _fail<Folder>(invalid);

    try {
      return await _dao.runInTransaction(() async {
        final List<FolderRow> siblings = await _dao.siblingFolders(null);
        final Failure? duplicate = _duplicateAmong(siblings, trimmed);
        if (duplicate != null) return _fail<Folder>(duplicate);

        final Folder folder = _buildNewFolder(
          parentId: null,
          name: trimmed,
          siblings: siblings,
        );
        await _dao.insertFolder(_insertCompanion(folder));
        return _ok(folder);
      });
    } catch (error) {
      return _fail<Folder>(_storageWrite(error));
    }
  }

  @override
  Future<Result<Folder>> createSubfolder({
    required FolderId parentId,
    required String name,
  }) async {
    final String trimmed = name.trim();
    final Failure? invalid = _validateName(trimmed);
    if (invalid != null) return _fail<Folder>(invalid);

    try {
      return await _dao.runInTransaction(() async {
        final FolderRow? parent = await _dao.findFolderById(parentId);
        if (parent == null) {
          return _fail<Folder>(const Failure.notFound(entity: 'folder'));
        }
        final ContentMode parentMode = FolderMapper.contentModeFromStorage(
          parent.contentMode,
        );
        final Failure? guard = _subfolderGuard(parentMode);
        if (guard != null) return _fail<Folder>(guard);

        final List<FolderRow> siblings = await _dao.siblingFolders(parentId);
        final Failure? duplicate = _duplicateAmong(siblings, trimmed);
        if (duplicate != null) return _fail<Folder>(duplicate);

        final Folder child = _buildNewFolder(
          parentId: parentId,
          name: trimmed,
          siblings: siblings,
        );
        await _dao.insertFolder(_insertCompanion(child));

        if (parentMode == ContentMode.unlocked) {
          await _dao.updateFolderColumns(
            parentId,
            FoldersCompanion(
              contentMode: Value(
                FolderMapper.contentModeToStorage(ContentMode.subfolders),
              ),
              updatedAt: Value(_nowMs()),
            ),
          );
        }
        return _ok(child);
      });
    } catch (error) {
      return _fail<Folder>(_storageWrite(error));
    }
  }

  @override
  Future<Result<Folder>> renameFolder({
    required FolderId id,
    required String newName,
  }) async {
    final String trimmed = newName.trim();
    final Failure? invalid = _validateName(trimmed);
    if (invalid != null) return _fail<Folder>(invalid);

    try {
      return await _dao.runInTransaction(() async {
        final FolderRow? row = await _dao.findFolderById(id);
        if (row == null) {
          return _fail<Folder>(const Failure.notFound(entity: 'folder'));
        }
        // No-op when the trimmed name is unchanged.
        if (row.name == trimmed) return _ok(FolderMapper.fromRow(row));

        final List<FolderRow> siblings = await _dao.siblingFolders(
          row.parentId,
        );
        final Failure? duplicate = _duplicateAmong(
          siblings,
          trimmed,
          excludeId: id,
        );
        if (duplicate != null) return _fail<Folder>(duplicate);

        final int now = _nowMs();
        await _dao.updateFolderColumns(
          id,
          FoldersCompanion(name: Value(trimmed), updatedAt: Value(now)),
        );
        return _ok(
          FolderMapper.fromRow(row).copyWith(
            name: trimmed,
            updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
          ),
        );
      });
    } catch (error) {
      return _fail<Folder>(_storageWrite(error));
    }
  }

  @override
  Future<Result<void>> deleteFolder({required FolderId id}) async {
    try {
      return await _dao.runInTransaction(() async {
        final FolderRow? row = await _dao.findFolderById(id);
        if (row == null) {
          return _fail<void>(const Failure.notFound(entity: 'folder'));
        }
        await _cascadeDeleteFolder(id);
        await _revertParentIfEmptied(row.parentId);
        return _ok<void>(null);
      });
    } catch (error) {
      return _fail<void>(_storageWrite(error));
    }
  }

  // ---- Result builders ----

  Result<T> _ok<T>(T data) => (failure: null, data: data);

  Result<T> _fail<T>(Failure failure) => (failure: failure, data: null);
}
