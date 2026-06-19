import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/types/content_mode.dart';

/// Maps between the Drift `FolderRow` and the domain [Folder] entity.
///
/// Storage conventions (`docs/database/schema-contract.md`): `content_mode` is
/// the lowercase enum name; timestamps are UTC epoch milliseconds. Repositories
/// MUST map rows through here and never leak `FolderRow` past the data layer
/// (`docs/contracts/repository-contracts/folder-repository.md` §Forbidden).
abstract final class FolderMapper {
  const FolderMapper._();

  static Folder fromRow(FolderRow row) => Folder(
    id: row.id,
    parentId: row.parentId,
    name: row.name,
    contentMode: contentModeFromStorage(row.contentMode),
    sortOrder: row.sortOrder,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt, isUtc: true),
  );

  static ContentMode contentModeFromStorage(String value) => switch (value) {
    'unlocked' => ContentMode.unlocked,
    'subfolders' => ContentMode.subfolders,
    'decks' => ContentMode.decks,
    _ => throw ArgumentError.value(
      value,
      'content_mode',
      'Unknown ContentMode',
    ),
  };

  static String contentModeToStorage(ContentMode mode) => mode.name;
}
