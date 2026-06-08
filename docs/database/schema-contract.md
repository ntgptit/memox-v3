---
last_updated: 2026-06-08
applies_to: Drift schema, all tables, migrations
schema_version: 4 (see lib/data/datasources/local/app_database.dart `currentSchemaVersion`)
---

# Database Schema Contract

## Current implementation status (incremental rebuild)

The Drift data layer is being **rebuilt incrementally, per feature slice**. The
table-area and migration sections below describe the **target** schema (the
mature shape to migrate toward); they are intentionally ahead of the current
code per the "do not downgrade target concepts" rule.

**Current schema** (`AppDatabase.currentSchemaVersion`): **4**. Tables shipped
so far (added for the Library + Study features):

| Table                | Columns (current)                                                                                                                                                                                     |
|----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `folders`            | `id`, `parent_id` (self-FK, restrict), `name`, `content_mode`, `sort_order`, `created_at`, `updated_at`                                                                                               |
| `decks`              | `id`, `folder_id` (FK→folders, cascade), `name`, `target_language`, `sort_order`, `created_at`, `updated_at`                                                                                          |
| `flashcards`         | `id`, `deck_id` (FK→decks, cascade), `front`, `back`, `example_sentence?`, `pronunciation?`, `hint?`, `sort_order`, `created_at`, `updated_at`                                                    |
| `flashcard_tags`     | `flashcard_id` (FK→flashcards, cascade), `tag` + index `idx_flashcard_tags_tag`                                                                                                                     |
| `flashcard_progress` | `flashcard_id` (PK, FK→flashcards, cascade), `box_number`, `due_at?`, `buried_until?`, `is_suspended`, `review_count`, `lapse_count`, `last_studied_at?` + index `idx_flashcard_progress_eligibility` |
| `study_sessions`     | `id` (PK), `entry_type`, `entry_ref_id?`, `study_type`, `status`, `started_at`, `updated_at` + index `idx_study_sessions_resumable`                                                                |
| `study_session_items` | `id` (PK), `session_id` (FK→study_sessions, cascade), `flashcard_id` (FK→flashcards, cascade), `sort_order`, `answered_at?`, `created_at`, `updated_at` + index `idx_study_session_items_session_sort` |
| `study_attempts`     | `id` (PK), `session_item_id` (FK→study_session_items, cascade), `result`, `study_mode`, `box_before`, `box_after`, `user_input?`, `attempted_at` + index `idx_study_attempts_session_item`           |

Remaining target tables (`tts_settings`) land with their
feature slice. When a new table/column ships, bump
`AppDatabase.currentSchemaVersion`, add an `onUpgrade` step
(`docs/database/migration-contract.md`), and update this section.

## Source files to inspect

- `lib/data/datasources/local/app_database.dart`
- `lib/data/datasources/local/drift/**` (`.drift` schema + query files — tables, indexes, SQL)
- `lib/data/datasources/local/connection/**` (platform connection)
- See `docs/database/drift-guide.md` for the `.drift` layout and how to add tables/queries.

## Rules

- Drift is the local database layer.
- Current schema version: see `AppDatabase.currentSchemaVersion`.
- Foreign keys must stay enabled (`PRAGMA foreign_keys = ON`).
- WAL mode must stay enabled (`PRAGMA journal_mode = WAL`).
- Database must not run on UI isolate. The connection is isolated under
  `lib/data/datasources/local/connection/`: native uses `LazyDatabase` +
  `NativeDatabase.createInBackground` (file path via `path_provider`); web uses `WasmDatabase`.
- Schema (tables + indexes) is defined in `.drift` files and pulled into `AppDatabase` via
  `include:`; SQL queries live in `.drift` query files. No long raw SQL strings in Dart
  (`docs/database/drift-guide.md`).
- IDs are text (UUID-like, generated via `IdGenerator`).
- Enums are text.
- Timestamps are UTC epoch milliseconds.
- Generated Drift files must not be edited manually.

## Per-account database isolation

The Drift database file name is parameterized by the active account (see
`docs/business/account-sync/account-sync.md`):

| Account context | Database file name                                       |
|-----------------|----------------------------------------------------------|
| Guest (no link) | `{AppConstants.localDatabaseName}_guest`                 |
| Google account  | `{AppConstants.localDatabaseName}_{normalizedSubjectId}` |

Implications:

- Every Drift schema rule applies independently per account database.
- Migrations run separately for each account file.
- Account link itself is NOT in Drift (it lives in SharedPreferences) — otherwise the app could not
  decide which DB to open at boot.
- Drive sync metadata, TTS settings (within a DB), and all entity data are scoped to the active
  account database.

## Target table areas

This table describes the target persistence contract. Some entries are ahead of the current
implementation and require migration before feature implementation.

| Area          | Table                                                                                                                                                                                     |
|---------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Folders       | `folders`                                                                                                                                                                                 |
| Decks         | `decks`; `target_language` is Target / Migration Required per `docs/business/deck/deck-management.md`; nullable `folder_id` for root decks is Rejected / Not Applicable                   |
| Flashcards    | `flashcards`                                                                                                                                                                              |
| SRS progress  | `flashcard_progress`; `buried_until` and `is_suspended` are implemented in the current schema. `last_reset_at` remains Target / Migration Required per `docs/business/history/card-history.md` |
| Tags          | `flashcard_tags`                                                                                                                                                                          |
| TTS settings  | Target: `tts_settings` (single-row, id=`'default'`). If current implementation uses `tts_settings_records`, keep a mapper/migration note before renaming.                                 |

## Settings stored outside Drift

These belong in SharedPreferences (not Drift), see business docs for rationale:

| Setting                 | Store                                           | Spec                                               |
|-------------------------|-------------------------------------------------|----------------------------------------------------|
| Daily goal value        | SharedPreferences (`study_settings_store.dart`) | `docs/business/engagement/dashboard-engagement.md` |
| Goal enabled toggle     | SharedPreferences                               | `docs/business/engagement/dashboard-engagement.md` |
| Reminder time           | SharedPreferences                               | `docs/business/engagement/dashboard-engagement.md` |
| Reminder enabled toggle | SharedPreferences                               | `docs/business/engagement/dashboard-engagement.md` |
| Longest streak          | SharedPreferences                               | `docs/business/engagement/dashboard-engagement.md` |
| Last goal-met date      | SharedPreferences                               | `docs/business/engagement/dashboard-engagement.md` |
| Recent searches         | SharedPreferences                               | `docs/business/search/global-search.md`            |
| Cloud account link      | SharedPreferences                               | `docs/business/account-sync/account-sync.md`       |
| Drive sync metadata     | SharedPreferences                               | `docs/business/account-sync/account-sync.md`       |
| Locale, theme mode      | SharedPreferences                               | code-only                                          |

Rationale: these are device-local user preferences. Putting them in Drift would require migrating
them across per-account database switches. SharedPreferences naturally stays with the device.

## Pending schema changes

The following schema changes are required to implement new specs. Each requires a migration per
`docs/database/migration-contract.md`.

### V1 migration gate

A pending column listed here does not automatically approve every dependent feature. Before coding,
check `docs/MANIFEST.md`, `docs/business/system/overview.md`, and
`docs/checklist/implementation-checklist.md`.

- `flashcards.pronunciation` and `flashcards.hint` — ✅ implemented in schema v2 (flashcard create
  optional detail fields).
- `flashcard_tags.tag` — ✅ implemented in schema v3 (create-time tags on flashcards).
- `study_attempts.result = 'recovered'` — ✅ implemented in schema v13 for Fill hint-taint /
  Mark-correct grading. Schema v13 intentionally also repairs schema-12 databases that were created
  before the recovered CHECK migration was version-safe.
- `flashcard_progress.last_reset_at`, `study_attempts.box_before`, and `study_attempts.box_after`
  are reserved for the Future Proposal Card History feature unless promoted.
- `decks.target_language` may be implemented only with the deck/TTS migration task that updates
  Drift schema, mapper, tests, and generated code.
- `decks.folder_id` nullable is Rejected / Not Applicable after Prompt 43A.
  Keep `folder_id` non-null because every deck belongs to exactly one folder.

| Change                                                                                  | Source spec                                                                   | Notes                                                                                                                                                                                                                                                                                                                 |
|-----------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Add `decks.target_language TEXT NOT NULL DEFAULT 'korean'`                              | `docs/business/deck/deck-management.md`                                       | Migration backfills existing rows to `'korean'`.                                                                                                                                                                                                                                                                      |
| Rejected / Not Applicable: change `decks.folder_id` from `TEXT NOT NULL` to `TEXT NULL` | `docs/business/deck/deck-management.md`, `docs/wireframes/02-library.md`      | Superseded by product-owner decision. Do not make deck parent nullable; folder-owned deck invariant remains locked.                                                                                                                                                                                                   |
| ✅ DONE (current) `flashcard_progress.buried_until INTEGER NULL`                         | `docs/business/study-actions/bury-suspend.md`                                 | Default null. Shipped in the current schema.                                                                                                                                                                                                                                                                         |
| ✅ DONE (current) `flashcard_progress.is_suspended BOOL NOT NULL DEFAULT 0`              | `docs/business/study-actions/bury-suspend.md`                                 | Default false. Shipped in the current schema.                                                                                                                                                                                                                                                                         |
| Add `flashcard_progress.last_reset_at INTEGER NULL`                                     | `docs/business/history/card-history.md`                                       | Default null. Updated when user resets a card's progress.                                                                                                                                                                                                                                                             |
| Add `study_attempts.box_before INTEGER NOT NULL DEFAULT 0`                              | `docs/business/history/card-history.md`                                       | Migration backfill: set to 0 for pre-migration rows (treated as "unknown"; history view displays "—" for box transition on those rows).                                                                                                                                                                               |
| Add `study_attempts.box_after INTEGER NOT NULL DEFAULT 0`                               | `docs/business/history/card-history.md`                                       | Same migration semantics as `box_before`.                                                                                                                                                                                                                                                                             |
| ✅ DONE (current) compound index `flashcard_progress(is_suspended, buried_until, due_at)` | `docs/business/study-actions/bury-suspend.md`                                 | Added as `idx_flashcard_progress_eligibility`.                                                                                                                                                                                                                                                                        |
| ✅ DONE (v11) compound index `flashcard_tags(tag, flashcard_id)`                         | `docs/business/tags/tag-system.md`                                            | Added as `idx_flashcard_tags_tag`. Tags are stored lowercased, so a plain index on `tag` supports `LOWER(tag)` lookups for lowercased input.                                                                                                                                                                          |
| ✅ DONE (v11) lowercase `flashcard_tags.tag` storage                                     | `docs/business/tags/tag-system.md`                                            | Tags are stored lowercased (case-insensitive identity). Schema v11 dedupes case variants per card then lowercases existing rows; writers (`FlashcardDao`, `FlashcardTagDao`) normalize on insert.                                                                                                                     |
| ✅ DONE (v13) allow `study_attempts.result = 'recovered'`                                | `docs/wireframes/17-study-session-fill.md`, `docs/business/srs/srs-review.md` | Rebuilds the `study_attempts.result` CHECK constraint so hint-tainted Fill exact matches and Mark-correct overrides can persist a passing-but-not-perfect attempt without faking `incorrect`. Runs for any DB below schema 13, including legacy schema-12 files whose CHECK still only allowed `correct`/`incorrect`. |
| Consider index on `study_attempts(box_after)`                                           | `docs/business/history/card-history.md`                                       | Only if box-progression analytics need it; profile first.                                                                                                                                                                                                                                                             |

When implementing, bump `AppDatabase.currentSchemaVersion` accordingly and update this doc's
frontmatter `schema_version`.

### Migration ordering note

`box_before` / `box_after` migration must run BEFORE any new study session can record attempts, so
the inserts include the new columns. The default `0` represents "unknown / pre-migration"; UI must
render `0` as "—" not as "Box 0".

## Entity relationship overview

```mermaid
erDiagram
    folders ||--o{ folders : parent_of
    folders ||--o{ decks : contains
    decks ||--o{ flashcards : contains
    flashcards ||--|| flashcard_progress : has
    flashcards ||--o{ flashcard_tags : has
    decks ||--o{ study_sessions : entry
    folders ||--o{ study_sessions : entry
    study_sessions ||--o{ study_session_items : contains
    study_session_items ||--o{ study_attempts : has
    flashcards ||--o{ study_session_items : references
```

## Foreign key cascade rules

| Parent                | Child                 | On delete                                                  |
|-----------------------|-----------------------|------------------------------------------------------------|
| `folders` (self)      | `folders`             | Restrict (no orphan via direct FK; cleanup in transaction) |
| `folders`             | `decks`               | Cascade                                                    |
| `decks`               | `flashcards`          | Cascade                                                    |
| `flashcards`          | `flashcard_progress`  | Cascade                                                    |
| `flashcards`          | `flashcard_tags`      | Cascade                                                    |
| `flashcards`          | `study_session_items` | Cascade                                                    |
| `study_sessions`      | `study_session_items` | Cascade                                                    |
| `study_session_items` | `study_attempts`      | Cascade                                                    |

## Schema change checklist

- Update Drift table definition.
- Add migration.
- Update enum values when needed.
- Update repository/mapper.
- Update business docs.
- Update tests.
- Run build runner.
- Run guard.
- Run analyzer.

## Forbidden

- Do not edit generated database file manually.
- Do not rename enum values casually.
- Do not add new table without migration and docs.
- Do not duplicate SRS session tables when study session tables already represent review.
- Do not disable foreign keys.
- Do not change timestamp unit (must stay UTC epoch ms).

## Agent rule

When changing schema, always read `docs/database/migration-contract.md` first.

## Related

This schema is referenced by every business spec that touches persistent state.

**Per-table consumers:**

| Table                                                                                           | Primary business specs                                                                                                    |
|-------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|
| `folders`                                                                                       | `docs/business/folder/folder-management.md`                                                                               |
| `decks` (incl. `target_language` pending migration)                                             | `docs/business/deck/deck-management.md`, `docs/business/tts/tts-settings.md`                                              |
| `flashcards`                                                                                    | `docs/business/flashcard/flashcard-management.md`                                                                         |
| `flashcard_progress` (incl. `last_reset_at` pending migration)                           | `docs/business/srs/srs-review.md`, `docs/business/history/card-history.md`                                                             |
| `flashcard_tags`                                                                                | `docs/business/tags/tag-system.md`, `docs/business/flashcard/flashcard-management.md`                                     |
| `study_sessions`                                                                                | `docs/business/study/study-flow.md`, `docs/business/resume/resume-session.md`                                             |
| `study_session_items`                                                                           | `docs/business/study/study-flow.md`                                                                                       |
| `study_attempts` (incl. `box_before`, `box_after` pending migrations)                           | `docs/business/srs/srs-review.md`, `docs/business/history/card-history.md`                                                |

**Related contracts:**

- `docs/database/migration-contract.md` — how schema changes ship
- `docs/database/storage-boundaries.md` — what lives in Drift vs SharedPreferences vs files
- `docs/architecture/clean-architecture-contract.md` — DAO/repository pattern

**Wireframes that depend on schema:**

- `docs/wireframes/06-flashcard-list.md` — filters consume status columns
- `docs/wireframes/09-flashcard-history.md` — timeline reads `study_attempts`
- `docs/wireframes/19-settings-account.md` — sync reads/writes whole DB

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Schema" (column existence, default
  values, NOT NULL)

**Source files to inspect:**

- `lib/data/datasources/local/drift/**` (`.drift` tables, indexes, queries)
- `lib/data/datasources/local/connection/**`
- `lib/data/datasources/local/app_database.dart`
- `lib/data/datasources/local/migrations/**`
