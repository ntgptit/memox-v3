import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'deck_dao.g.dart';

/// Thin Drift accessor for the `decks` table.
///
/// Single-table lookups and mutations only — validation, content-mode locks and
/// cross-table updates (parent folder mode) are orchestrated in
/// `FolderRepositoryImpl`, which calls these inside its transactions. No
/// business logic lives here (`docs/database/drift-guide.md`).
@DriftAccessor(include: <String>{'../drift/decks.drift'})
class DeckDao extends DatabaseAccessor<AppDatabase> with _$DeckDaoMixin {
  DeckDao(super.db);

  /// Single deck row, or `null` if it does not exist.
  Future<DeckRow?> findDeckById(String id) =>
      (select(decks)..where((Decks t) => t.id.equals(id))).getSingleOrNull();

  /// Decks under [folderId], used for case-insensitive duplicate checks, the
  /// next `sort_order`, and reorder validation.
  Future<List<DeckRow>> decksInFolder(String folderId) =>
      (select(decks)..where((Decks t) => t.folderId.equals(folderId))).get();

  /// Number of decks in [folderId]. Used to decide whether a folder reverts to
  /// `unlocked` after a deck leaves it.
  Future<int> deckCountInFolder(String folderId) async {
    final Expression<int> count = decks.id.count();
    final TypedResult row =
        await (selectOnly(decks)
              ..addColumns(<Expression<Object>>[count])
              ..where(decks.folderId.equals(folderId)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> insertDeck(DecksCompanion deck) => into(decks).insert(deck);

  Future<void> updateDeckColumns(String id, DecksCompanion changes) =>
      (update(decks)..where((Decks t) => t.id.equals(id))).write(changes);

  Future<void> deleteDeckById(String id) =>
      (delete(decks)..where((Decks t) => t.id.equals(id))).go();
}
