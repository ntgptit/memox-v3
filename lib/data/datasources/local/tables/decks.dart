import 'package:drift/drift.dart';

import 'package:memox/data/datasources/local/tables/folders.dart';

/// `decks` table (`docs/database/schema-contract.md`,
/// `docs/business/deck/deck-management.md`).
///
/// Every deck belongs to exactly one folder ([folderId] NOT NULL, cascade on
/// folder delete) — the folder-owned-deck invariant is locked (Prompt 43A).
/// [targetLanguage] stores the `TargetLanguage` enum as lowercase text.
@DataClassName('DeckRow')
class Decks extends Table {
  @override
  String get tableName => 'decks';

  TextColumn get id => text()();

  TextColumn get folderId =>
      text().references(Folders, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  /// `TargetLanguage` as lowercase text; default `korean`.
  TextColumn get targetLanguage =>
      text().withDefault(const Constant('korean'))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
