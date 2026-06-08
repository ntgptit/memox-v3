import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

Future<void> addStudyTables(Migrator m, AppDatabase db) async {
  await m.createTable(db.studySessions);
  await m.createTable(db.studySessionItems);
  await m.createTable(db.studyAttempts);
  await m.createIndex(db.idxStudySessionsResumable);
  await m.createIndex(db.idxStudySessionItemsSessionSort);
  await m.createIndex(db.idxStudyAttemptsSessionItem);
}
