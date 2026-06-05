import 'package:drift/drift.dart';

import 'package:memox/data/datasources/local/tables/decks.dart';

/// `flashcards` table (`docs/database/schema-contract.md`,
/// `docs/business/flashcard/flashcard-management.md`).
///
/// Belongs to exactly one deck ([deckId] NOT NULL, cascade on deck delete).
/// SRS scheduling lives in the sibling `flashcard_progress` row.
@DataClassName('FlashcardRow')
class Flashcards extends Table {
  @override
  String get tableName => 'flashcards';

  TextColumn get id => text()();

  TextColumn get deckId =>
      text().references(Decks, #id, onDelete: KeyAction.cascade)();

  /// Term / prompt side.
  TextColumn get front => text()();

  /// Meaning / answer side.
  TextColumn get back => text()();

  /// Optional example sentence shown on the back.
  TextColumn get exampleSentence => text().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
