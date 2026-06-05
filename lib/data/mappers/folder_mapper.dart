import 'package:drift/drift.dart' show QueryRow;

import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/library_overview.dart';
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

  static Folder fromRow(FolderRow row) => Folder(
    id: row.id,
    parentId: row.parentId,
    name: row.name,
    contentMode: contentModeFromStorage(row.contentMode),
    sortOrder: row.sortOrder,
    createdAt: _dateFromMs(row.createdAt),
    updatedAt: _dateFromMs(row.updatedAt),
  );

  /// Builds a [FolderWithCount] from a Library Overview query row.
  static FolderWithCount overviewItemFromQueryRow(QueryRow row) => FolderWithCount(
    folder: Folder(
      id: row.read<String>('id'),
      parentId: row.read<String?>('parent_id'),
      name: row.read<String>('name'),
      contentMode: contentModeFromStorage(row.read<String>('content_mode')),
      sortOrder: row.read<int>('sort_order'),
      createdAt: _dateFromMs(row.read<int>('created_at')),
      updatedAt: _dateFromMs(row.read<int>('updated_at')),
    ),
    subfolderCount: row.read<int>('subfolder_count'),
    deckCount: row.read<int>('deck_count'),
    cardCount: row.read<int>('card_count'),
    dueCount: row.read<int>('due_count'),
  );
}
