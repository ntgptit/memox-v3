import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

Future<void> addFlashcardTags(Migrator m, AppDatabase db) async {
  await m.createTable(db.flashcardTags);
  await m.createIndex(db.idxFlashcardTagsTag);
}
