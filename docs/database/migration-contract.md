---
last_updated: 2026-06-21
applies_to: Drift schema migrations
---

# Migration Contract

## When required

Migration is required when changing:

- Table name.
- Column name.
- Column type.
- Constraint.
- Enum values.
- Foreign key.
- Index.
- Required/default value.

## Migration shape

Each migration:

- Bumps `schemaVersion` in `AppDatabase`.
- Adds a step in `MigrationStrategy.onUpgrade`.
- Is irreversible only when justified and documented.
- Preserves data when possible.
- Uses `customStatement` with care; prefer Drift APIs.

## Required updates per migration

- Drift table definition.
- Migration implementation in `lib/data/datasources/local/migrations/**`.
- Generated Drift files via build runner.
- `docs/database/schema-contract.md` (schema_version header and table area if applicable).
- Related business docs (if behavior visible to user).
- Related decision table rows.
- Tests (migration test + affected feature tests).

## Forbidden in migration

- Dropping a column without rename-then-drop sequence across two versions.
- Renaming enum values without data backfill.
- Removing foreign keys.
- Changing timestamp unit.
- Making a step idempotent (`CREATE … IF NOT EXISTS`, swallowing "already exists") to paper over a
  store whose `user_version` disagrees with its contents. That skew is a pre-release artifact, not a
  migration concern — see below.

## Pre-release store skew (generation bump, not a migration)

A stale **pre-release** local store can carry objects from a newer version while its `user_version`
still reads an older one — typically after a schema renumber. `onUpgrade` then re-runs an already-
applied create step and fails (e.g. `index idx_study_sessions_resumable already exists`). This is NOT
fixed with a migration: the chain is correct for any coherent store. Instead bump
`AppConstants.localStoreGeneration` to abandon the incoherent store and open a fresh one
(`docs/database/storage-boundaries.md` §Local store generation). Allowed only pre-release (no
production data); never use it to skip writing a real migration for an actual schema change.

## Verification

Run in order:

```text
dart run build_runner build --delete-conflicting-outputs
python code-verification-guard/guard/run.py check --project . --ruleset memox
dart fix --apply
dart format .
flutter analyze
flutter test test/data/migrations/
flutter test <targeted feature tests>
```

## Migration test contract

For every new migration, add a test that:

- Opens database at previous schema version with sample data.
- Runs migration.
- Asserts data is preserved or transformed as expected.
- Asserts new constraints work.

## Agent rule

Do not claim migration complete without:

- Build runner success.
- Guard pass.
- Analyzer clean.
- Migration test added and passing.
- Targeted feature tests passing.

If any step is skipped, report it explicitly.

## Related

**Schema:**

- `docs/database/schema-contract.md` — full schema with 6 pending migrations enumerated

**Related contracts:**

- `docs/database/storage-boundaries.md` — non-Drift storage that does NOT migrate via Drift
- `docs/architecture/clean-architecture-contract.md`

**Business specs introducing migrations:**

- `docs/business/flashcard/flashcard-management.md` → `flashcard_tags`
- `docs/business/flashcard/flashcard-management.md` → `flashcards.pronunciation`, `flashcards.hint`
- `docs/business/deck/deck-management.md` → `decks.target_language`
- `docs/business/study-actions/bury-suspend.md` → `flashcard_progress.buried_until`, `is_suspended`
- `docs/business/study/study-flow.md` → `study_sessions`, `study_session_items`, `study_attempts`
  (incl. `study_attempts.box_before`, `box_after`) — shipped v6 (`v6_add_study_tables.dart`, WBS 4.0.1)
- `docs/business/history/card-history.md` → `flashcard_progress.last_reset_at`,
  `study_attempts.duration_ms`, `card_events` table — ✅ shipped v7 (`v7_add_card_history.dart`,
  WBS 7.0.1); columns/table only, read logic lands WBS 7.6.1
- `docs/business/study/study-flow.md` + `docs/business/srs/srs-review.md` →
  `study_match_evaluations`
- `docs/wireframes/17-study-session-fill.md` + `docs/business/srs/srs-review.md` → enum/constraint
  changes for Fill attempt grading channels such as `study_attempts.result = 'recovered'`

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Migration" (ordering, idempotency,
  schemaVersion bump)

**Source files to inspect:**

- `lib/data/datasources/local/migrations/**` (live steps: `v2_add_decks.dart`,
  `v3_add_flashcards.dart`, `v4_add_bury_suspend.dart`, `v5_add_folder_color_icon.dart`,
  `v6_add_study_tables.dart`, `v7_add_card_history.dart`)
- `lib/data/datasources/local/app_database.dart` (schemaVersion)
- The prior-iteration step files (`v*_add_flashcard_progress_last_reset_at.dart`,
  `v*_add_card_events_and_attempt_duration.dart`, `v*_add_flashcard_pos_and_flag.dart`,
  `v*_add_tts_settings.dart`, `v*_add_study_flow_and_current_mode.dart`,
  `v*_clear_new_card_due_at.dart`) are **not present** in the current tree — they are re-added at
  their own rebuild version as each feature lands (see the prior-iteration table below).

## Shipped migrations

**Rebuild baseline (2026-06-19, WBS 1.1.5):** the Drift layer was reset.
`app_database.dart` ships the migration infrastructure
(`onCreate`/`onUpgrade`/`beforeOpen` in `AppDatabase.migration`) and the
platform-isolated connection. Each schema bump adds a `migrations/v<N>_*.dart`
step file plus an `onUpgrade` step (guarded by `from`). Current code is at
**schema v8**.

| Version | File | What changed |
|---------|------|--------------|
| v8 | `v8_add_match_evaluations.dart` | Match-evaluation enabler (WBS 4.5.4 / WP-SM1a). Created the append-only `study_match_evaluations` (`id`, `session_id` FK→study_sessions ON DELETE CASCADE, `session_item_id` FK→study_session_items ON DELETE CASCADE, `flashcard_id` FK→flashcards ON DELETE CASCADE, `board_index`, `pair_id`, `selected_front_cell_id`, `selected_back_cell_id`, `expected_front_flashcard_id`, `expected_back_flashcard_id`, `is_correct`, `attempt_order`, `evaluated_at`, `created_at`) + `idx_study_match_evaluations_session` (`session_id`, `attempt_order`) + `idx_study_match_evaluations_session_item`. Additive — no existing table touched, fresh table (no back-fill). No read/write logic yet — repo/use-case persistence lands WP-SM1b, finalization derivation WP-SM2. Migration test: `test/data/migrations/v8_add_match_evaluations_migration_test.dart`; schema test: `test/data/migrations/app_database_schema_test.dart`. WBS 4.5.4. |
| v7 | `v7_add_card_history.dart` | Card-history enabler (WBS 7.0.1). Created `card_events` (`id`, `flashcard_id` FK→flashcards ON DELETE CASCADE, `type`, `occurred_at`, `detail?`) + `idx_card_events_flashcard`; added `flashcard_progress.last_reset_at` (INTEGER NULL) and `study_attempts.duration_ms` (INTEGER NULL). Additive — no existing table touched, new columns default NULL (no back-fill). No read logic yet (review-history query lands WBS 7.6.1). Migration test: `test/data/migrations/v7_add_card_history_migration_test.dart`; schema test: `test/data/migrations/app_database_schema_test.dart`. WBS 7.0.1. |
| v6 | `v6_add_study_tables.dart` | Added the study-persistence tables `study_sessions` (`id`, `entry_type`, `entry_ref_id?`, `study_type`, `status`, `started_at`, `updated_at`) + `idx_study_sessions_resumable`; `study_session_items` (`id`, `session_id` FK→study_sessions ON DELETE CASCADE, `flashcard_id` FK→flashcards ON DELETE CASCADE, `sort_order`, `answered_at?`, timestamps) + `idx_study_session_items_session_sort`; `study_attempts` (`id`, `session_item_id` FK→study_session_items ON DELETE CASCADE, `result`, `study_mode`, `box_before` DEFAULT 0, `box_after` DEFAULT 0, `user_input?`, `attempted_at`) + `idx_study_attempts_session_item`. Additive — no existing table touched, no data back-fill. Migration test: `test/data/migrations/v6_add_study_tables_migration_test.dart`; schema test: `test/data/migrations/app_database_schema_test.dart`. WBS 4.0.1. |
| v5 | `v5_add_folder_color_icon.dart` | Added the nullable `folders.color` + `folders.icon` columns (optional presentation tokens from the folder create/edit pickers; NULL = no custom token → theme default). Additive `addColumn` migration; existing rows need no backfill. Migration test: `test/data/migrations/v5_add_folder_color_icon_migration_test.dart`; schema test: `test/data/migrations/app_database_schema_test.dart`. WBS 2.22.1. |
| v4 | `v4_add_bury_suspend.dart` | Added `flashcard_progress.is_suspended` (BOOLEAN NOT NULL DEFAULT 0 → existing rows back-fill not-suspended) and `flashcard_progress.buried_until` (INTEGER NULL → existing rows back-fill not-buried). Additive, data-preserving; no behavior reads them yet (eligibility read logic lands WBS 4.11.1 / 2.17.1). Migration test: `test/data/migrations/v4_add_bury_suspend_migration_test.dart`; schema test: `test/data/migrations/app_database_schema_test.dart`. WBS 4.0.2. |
| v3 | `v3_add_flashcards.dart` | Added the `flashcards` (`id`, `deck_id` FK→decks ON DELETE CASCADE, `front`, `back`, `example_sentence?`, `pronunciation?`, `hint?`, `sort_order`, timestamps) + `idx_flashcards_deck`; `flashcard_progress` (`flashcard_id` PK = FK→flashcards ON DELETE CASCADE, `box_number` DEFAULT 1, `due_at?`, `review_count` DEFAULT 0, `lapse_count` DEFAULT 0); and `flashcard_tags` (`flashcard_id` FK→flashcards ON DELETE CASCADE, `tag`, PK `(flashcard_id, tag)`) + `idx_flashcard_tags_tag` tables. Additive. Migration test: `test/data/migrations/v3_add_flashcards_migration_test.dart`; schema test: `test/data/migrations/app_database_schema_test.dart`. WBS 2.11.1. |
| v2 | `v2_add_decks.dart` | Added the `decks` table (`id`, `folder_id` FK→folders ON DELETE CASCADE, `name`, `target_language` DEFAULT `'korean'`, `sort_order`, timestamps) + `idx_decks_folder`. Additive. Migration test: `test/data/migrations/v2_add_decks_migration_test.dart`; schema test: `test/data/migrations/app_database_schema_test.dart`. WBS 2.7.1. |
| v1 | `app_database.dart` (onCreate) | Rebuild baseline: `folders` table + `idx_folders_parent`; foreign keys + WAL enabled. Schema test: `test/data/migrations/app_database_schema_test.dart`. |

The rows below describe the **prior iteration's** migration sequence (the target
history the rebuild migrates toward); their step files are not present in the
current tree until each table is re-added.

> **Numbering note:** the rebuild assigns version numbers in its own build order,
> which diverges from the prior iteration's. The version labels below are the
> *prior* sequence and will be **renumbered** as each table is re-added — e.g.
> the prior `v4_add_study_tables.dart` is NOT the live v4 (the live v4 is
> `v4_add_bury_suspend.dart`, shipped above); study tables will land at a later
> rebuild version. Treat the labels below as relative ordering, not as the
> rebuild's final version numbers.

| Version | File | What changed |
|---------|------|--------------|
| v11 | `v11_clear_new_card_due_at.dart` | Data correction: `UPDATE flashcard_progress SET due_at = NULL WHERE review_count = 0 AND due_at IS NOT NULL` so never-studied cards count as NEW (not due). Earlier creation wrote `due_at = now`; brand-new cards must have `due_at = NULL`. Migration test: `test/data/migrations/clear_new_card_due_at_migration_test.dart`. |
| v10 | `v10_add_study_flow_and_current_mode.dart` | Added `study_sessions.study_flow` (TEXT NOT NULL DEFAULT `'srs_recall_review'`) and `study_sessions.current_mode` (TEXT NULL). Both additive; existing rows migrate to the single-phase recall flow / NULL phase. Migration test: `test/data/migrations/study_flow_current_mode_migration_test.dart`. |
| v9 | `v9_add_tts_settings.dart` | Added `tts_settings` single-row table (`id`, `auto_play`, `front_language`, `rate`, `pitch`, `volume`, `front_voice_name`). Migration test: `test/data/migrations/tts_settings_migration_test.dart`. |
| v8 | `v8_add_flashcard_pos_and_flag.dart` | Added `flashcards.part_of_speech`, `flashcards.is_flagged`. |
| v7 | `v7_add_card_events_and_attempt_duration.dart` | Added `card_events` table; `study_attempts.box_before`, `box_after`, `duration_ms`. |
| v6 | `v6_add_flashcard_progress_last_reset_at.dart` | Added `flashcard_progress.last_reset_at`. |
| v5 | `v5_add_study_match_evaluations.dart` | Added `study_match_evaluations` table. |
| v4 | `v4_add_study_tables.dart` | Added `study_sessions`, `study_session_items`, `study_attempts`. |
| v3 | `v3_add_flashcard_tags.dart` | Added `flashcard_tags` table. |
| v2 | `v2_add_flashcard_optional_fields.dart` | Added `flashcards.pronunciation`, `hint`, `example_sentence`. |
