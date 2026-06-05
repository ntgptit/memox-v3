import 'package:drift/drift.dart';

/// `folders` table (`docs/database/schema-contract.md`).
///
/// Self-referencing tree via [parentId] (`NULL` = root). [contentMode] stores
/// the `ContentMode` enum as lowercase text; mapping lives in the data-layer
/// mapper. Self-FK is Restrict (cleanup happens in a transaction, not cascade).
@DataClassName('FolderRow')
class Folders extends Table {
  @override
  String get tableName => 'folders';

  TextColumn get id => text()();

  /// Parent folder id; `NULL` for a root folder.
  TextColumn get parentId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.restrict)();

  TextColumn get name => text()();

  /// `ContentMode` as lowercase text: `unlocked` / `subfolders` / `decks`.
  TextColumn get contentMode =>
      text().withDefault(const Constant('unlocked'))();

  /// Manual ordering within the parent.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
