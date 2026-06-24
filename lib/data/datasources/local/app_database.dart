import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/connection/database_connection.dart';
import 'package:memox/data/datasources/local/migrations/v2_add_decks.dart';
import 'package:memox/data/datasources/local/migrations/v3_add_flashcards.dart';
import 'package:memox/data/datasources/local/migrations/v4_add_bury_suspend.dart';
import 'package:memox/data/datasources/local/migrations/v5_add_folder_color_icon.dart';
import 'package:memox/data/datasources/local/migrations/v6_add_study_tables.dart';
import 'package:memox/data/datasources/local/migrations/v7_add_card_history.dart';
import 'package:memox/data/datasources/local/migrations/v8_add_match_evaluations.dart';
import 'package:memox/data/datasources/local/migrations/v9_add_tts_settings.dart';

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
/// v4 (WBS 4.0.2): added `flashcard_progress.is_suspended` +
/// `flashcard_progress.buried_until` bury/suspend columns
/// (`migrations/v4_add_bury_suspend.dart`).
/// v5 (WBS 2.22.1): added the nullable `folders.color` + `folders.icon` columns
/// (`migrations/v5_add_folder_color_icon.dart`).
/// v6 (WBS 4.0.1): added the study-persistence tables `study_sessions`,
/// `study_session_items`, and `study_attempts` (the FK chain + resume/queue/
/// attempt indexes; `migrations/v6_add_study_tables.dart`).
/// v7 (WBS 7.0.1): card-history enabler — added the `card_events` table (+
/// `idx_card_events_flashcard`), `flashcard_progress.last_reset_at`, and
/// `study_attempts.duration_ms` (`migrations/v7_add_card_history.dart`).
/// v8 (WBS 4.5.4): added the append-only `study_match_evaluations` table
/// (`migrations/v8_add_match_evaluations.dart`).
/// v9 (WBS 8.4.1): added the single-row `tts_settings` table for global TTS
/// preferences (`migrations/v9_add_tts_settings.dart`).
@DriftDatabase(
  include: <String>{
    'drift/folders.drift',
    'drift/decks.drift',
    'drift/flashcards.drift',
    'drift/study_tables.drift',
    'drift/card_events.drift',
    'drift/tts_settings.drift',
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
  static const int currentSchemaVersion = 9;

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
      if (from < 4) {
        await migrateV3ToV4(m, this);
      }
      if (from < 5) {
        await migrateV4ToV5(m, this);
      }
      if (from < 6) {
        await migrateV5ToV6(m, this);
      }
      if (from < 7) {
        await migrateV6ToV7(m, this);
      }
      if (from < 8) {
        await migrateV7ToV8(m, this);
      }
      if (from < 9) {
        await migrateV8ToV9(m, this);
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
