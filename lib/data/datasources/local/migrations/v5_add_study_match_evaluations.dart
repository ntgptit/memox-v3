import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

Future<void> addStudyMatchEvaluations(Migrator m, AppDatabase db) async {
  await m.createTable(db.studyMatchEvaluations);
  await m.createIndex(db.idxStudyMatchEvaluationsSession);
  await m.createIndex(db.idxStudyMatchEvaluationsSessionItem);
}
