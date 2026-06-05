import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/types/content_mode.dart';

/// Maps Drift rows to folder domain types
/// (`docs/contracts/repository-contracts/folder-repository.md` §Required mappers).
///
/// Repositories MUST map to entities — Drift row types never escape the data
/// layer.
abstract final class FolderMapper {
  FolderMapper._();

  static ContentMode contentModeFromStorage(String value) => switch (value) {
    'subfolders' => ContentMode.subfolders,
    'decks' => ContentMode.decks,
    _ => ContentMode.unlocked,
  };

  /// Enum name matches storage form (`unlocked` / `subfolders` / `decks`).
  static String contentModeToStorage(ContentMode mode) => mode.name;

  static DateTime _dateFromMs(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  static Folder fromRow(FolderRow row) => fromStorageFields(
    id: row.id,
    parentId: row.parentId,
    name: row.name,
    contentMode: row.contentMode,
    sortOrder: row.sortOrder,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  /// Converts database storage fields to the domain entity.
  ///
  /// This intentionally does not accept generated query-result classes. Drift
  /// owns exact query result shapes; repositories pass the generated fields
  /// here only when they need the storage-to-domain transformation.
  static Folder fromStorageFields({
    required String id,
    required String? parentId,
    required String name,
    required String contentMode,
    required int sortOrder,
    required int createdAt,
    required int updatedAt,
  }) => Folder(
    id: id,
    parentId: parentId,
    name: name,
    contentMode: contentModeFromStorage(contentMode),
    sortOrder: sortOrder,
    createdAt: _dateFromMs(createdAt),
    updatedAt: _dateFromMs(updatedAt),
  );
}
