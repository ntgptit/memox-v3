import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

Future<void> addFlashcardOptionalFields(Migrator m, AppDatabase db) async {
  await m.addColumn(db.flashcards, db.flashcards.pronunciation);
  await m.addColumn(db.flashcards, db.flashcards.hint);
}
