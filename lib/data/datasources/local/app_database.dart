import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/connection/database_connection.dart';
import 'package:memox/data/datasources/local/migrations/v2_add_decks.dart';
import 'package:memox/data/datasources/local/migrations/v3_add_flashcards.dart';

part 'app_database.g.dart';

/// The MemoX local Drift database — the source of truth for all entity data.
///
/// Schema (tables + indexes) lives in `.drift` files pulled in via `include:`;
/// SQL queries live in `.drift` query files. No long raw SQL in Dart. See
/// `docs/database/drift-guide.md` and `docs/database/schema-contract.md`.
///
/// Baseline (WBS 1.1.5): schema version 1 with the `folders` table and the
/// migration infrastructure ([migration]). New tables append to `include:`,
/// bump [currentSchemaVersion], and add an `onUpgrade` step plus a
/// `migrations/v<N>_*.dart` step file (`docs/database/migration-contract.md`).
///
/// v2 (WBS 2.7.1): added the `decks` table (`migrations/v2_add_decks.dart`).
/// v3 (WBS 2.11.1): added the `flashcards`, `flashcard_progress`, and
/// `flashcard_tags` tables (`migrations/v3_add_flashcards.dart`).
@DriftDatabase(
  include: <String>{
    'drift/folders.drift',
    'drift/decks.drift',
    'drift/flashcards.drift',
  },
)
class AppDatabase extends _$AppDatabase {
  /// Production constructor — opens the platform connection (off the UI
  /// isolate on native; `WasmDatabase` on web).
  AppDatabase() : super(openConnection());

  /// Test/seam constructor — inject an in-memory or custom executor.
  AppDatabase.forExecutor(super.executor);

  /// Current schema version. Bump on every schema change and add a matching
  /// `onUpgrade` step (`docs/database/migration-contract.md`).
  static const int currentSchemaVersion = 3;

  @override
  int get schemaVersion => currentSchemaVersion;

  /// Migration infrastructure. At the baseline version (1) a fresh install runs
  /// `onCreate`; each future schema bump appends one ordered step inside
  /// `onUpgrade` (oldest first), per `docs/database/migration-contract.md`.
  /// Foreign keys are enabled in `beforeOpen` and must stay on
  /// (`docs/database/schema-contract.md` §Rules).
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Ordered steps, oldest first (one per version). Each guarded by `from`
      // so a multi-version upgrade runs every intervening step.
      if (from < 2) {
        await migrateV1ToV2(m, this);
      }
      if (from < 3) {
        await migrateV2ToV3(m, this);
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
