import 'package:drift/drift.dart';

import 'package:memox/data/datasources/local/connection/database_connection.dart';
import 'package:memox/data/datasources/local/migrations/v2_add_flashcard_optional_fields.dart';
import 'package:memox/data/datasources/local/migrations/v3_add_flashcard_tags.dart';
import 'package:memox/data/datasources/local/migrations/v4_add_study_tables.dart';
import 'package:memox/data/datasources/local/migrations/v5_add_study_match_evaluations.dart';
import 'package:memox/data/datasources/local/migrations/v6_add_flashcard_progress_last_reset_at.dart';
import 'package:memox/data/datasources/local/migrations/v7_add_card_events_and_attempt_duration.dart';
import 'package:memox/data/datasources/local/migrations/v8_add_flashcard_pos_and_flag.dart';
import 'package:memox/data/datasources/local/migrations/v9_add_tts_settings.dart';

part 'app_database.g.dart';

/// The local Drift database (`docs/database/schema-contract.md`).
///
/// Schema (tables + indexes) is defined in `.drift` files under `drift/` and
/// pulled in via `include:`; SQL queries live in `drift/folder_queries.drift`
/// (wired through `FolderDao`). Dart here only bootstraps the database,
/// declares the schema version, and owns the migration strategy — no embedded
/// SQL. The platform connection is isolated in `connection/`.
@DriftDatabase(
  include: <String>{
    'drift/folders.drift',
    'drift/decks.drift',
    'drift/flashcards.drift',
    'drift/flashcard_tags.drift',
    'drift/flashcard_progress.drift',
    'drift/study_sessions.drift',
    'drift/study_session_items.drift',
    'drift/study_attempts.drift',
    'drift/study_match_evaluations.drift',
    'drift/card_events.drift',
    'drift/tts_settings.drift',
  },
)
class AppDatabase extends _$AppDatabase {
  /// Production constructor opens the platform connection; tests can inject an
  /// in-memory [QueryExecutor].
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? openMemoxConnection());

  /// Bump and add an `onUpgrade` step for every schema change
  /// (`docs/database/migration-contract.md`).
  static const int currentSchemaVersion = 9;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Tables + the eligibility index are created from the `.drift` schema.
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await addFlashcardOptionalFields(m, this);
      }
      if (from < 3) {
        await addFlashcardTags(m, this);
      }
      if (from < 4) {
        await addStudyTables(m, this);
      }
      if (from < 5) {
        await addStudyMatchEvaluations(m, this);
      }
      if (from < 6) {
        await addFlashcardProgressLastResetAt(m, this);
      }
      if (from < 7) {
        await addCardEventsAndAttemptDuration(m, this);
      }
      if (from < 8) {
        await addFlashcardPosAndFlag(m, this);
      }
      if (from < 9) {
        await addTtsSettings(m, this);
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
