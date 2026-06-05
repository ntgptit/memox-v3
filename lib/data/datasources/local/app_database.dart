import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:memox/data/datasources/local/tables/decks.dart';
import 'package:memox/data/datasources/local/tables/flashcard_progress.dart';
import 'package:memox/data/datasources/local/tables/flashcards.dart';
import 'package:memox/data/datasources/local/tables/folders.dart';

part 'app_database.g.dart';

/// The local Drift database (`docs/database/schema-contract.md`).
///
/// Rebuilt incrementally per feature slice: this version carries the content
/// tree (`folders`, `decks`, `flashcards`) plus SRS scheduling
/// (`flashcard_progress`) needed by the Library feature. Foreign keys stay ON,
/// WAL stays on (drift_flutter default), and the DB runs off the UI isolate via
/// `shareAcrossIsolates`.
@DriftDatabase(tables: <Type>[Folders, Decks, Flashcards, FlashcardProgress])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openDefault());

  /// Bump and add an `onUpgrade` step for every schema change
  /// (`docs/database/migration-contract.md`).
  static const int currentSchemaVersion = 1;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_flashcard_progress_eligibility '
        'ON flashcard_progress (is_suspended, buried_until, due_at)',
      );
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openDefault() => driftDatabase(
    name: 'memox',
    native: const DriftNativeOptions(shareAcrossIsolates: true),
    // Flutter Web requires the wasm + worker assets. Place
    // `sqlite3.wasm` and `drift_worker.js` under `web/` (see
    // https://drift.simonbinder.eu/web/). On non-web platforms these
    // options are ignored.
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
