---
last_updated: 2026-06-15
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
- `docs/business/history/card-history.md` → `flashcard_progress.last_reset_at` (shipped v6,
  `v6_add_flashcard_progress_last_reset_at.dart`), `study_attempts.box_before`, `box_after`,
  `study_attempts.duration_ms` + `card_events` table (shipped v7,
  `v7_add_card_events_and_attempt_duration.dart`)
- `docs/business/study/study-flow.md` + `docs/business/srs/srs-review.md` →
  `study_match_evaluations`
- `docs/wireframes/17-study-session-fill.md` + `docs/business/srs/srs-review.md` → enum/constraint
  changes for Fill attempt grading channels such as `study_attempts.result = 'recovered'`

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Migration" (ordering, idempotency,
  schemaVersion bump)

**Source files to inspect:**

- `lib/data/datasources/local/migrations/**`
- `lib/data/datasources/local/app_database.dart` (schemaVersion)
- `lib/data/datasources/local/migrations/v4_add_study_tables.dart`
- `lib/data/datasources/local/migrations/v6_add_flashcard_progress_last_reset_at.dart`
- `lib/data/datasources/local/migrations/v7_add_card_events_and_attempt_duration.dart`
- `lib/data/datasources/local/migrations/v8_add_flashcard_pos_and_flag.dart`
- `lib/data/datasources/local/migrations/v9_add_tts_settings.dart`
- `lib/data/datasources/local/migrations/v10_add_study_flow_and_current_mode.dart`
- `lib/data/datasources/local/migrations/v11_clear_new_card_due_at.dart`

## Shipped migrations

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
