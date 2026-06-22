---
last_updated: 2026-06-06
status: guide
---

# Drift Database Guide

How the local database is structured and how to extend it. The guiding rule:
**SQL lives in `.drift` files, Dart only wraps and calls the generated APIs.**

## Why `.drift` files

- Schema (tables, columns, indexes) and SQL queries (SELECT / JOIN / search /
  recursive aggregates) are written in `.drift` files, not as raw SQL strings
  embedded in Dart.
- Drift generates **type-safe** Dart from them: row classes, companions, and one
  method + result class per named query. Parameters and result columns are
  checked at build time.
- SQL stays readable and reviewable in one place, separated from business/UI
  code. Dart files hold only bootstrap, connection, and thin DAO wrappers.

## Layout

```
lib/data/datasources/local/
  app_database.dart            # @DriftDatabase(include: {...}); schemaVersion + migration. No SQL.
  app_database.g.dart          # generated — do NOT edit
  connection/
    database_connection.dart       # conditional export (native vs web)
    database_connection_native.dart# LazyDatabase + NativeDatabase + path_provider
    database_connection_web.dart    # WasmDatabase
  drift/
    folders.drift              # table  (AS FolderRow)
    decks.drift                # table  (AS DeckRow)
  flashcards.drift           # table  (AS FlashcardRow)
  flashcard_progress.drift   # table + index (AS FlashcardProgressRow)
  study_tables.drift         # study_sessions/_items/_attempts + study_match_evaluations (+ indexes)
  folder_queries.drift       # named SQL queries (imports the table files)
  daos/
    folder_dao.dart            # thin wrappers: bind params / build ORDER BY, call generated methods
    folder_dao.g.dart          # generated — do NOT edit
```

- **Tables** live in `drift/*.drift` (one file per table). Each ends with
  `AS <RowName>` so the generated row class keeps a stable name (e.g.
  `FolderRow`). Indexes are declared next to their table.
- **Queries** live in `drift/folder_queries.drift`. They `import` the table
  files and are pulled onto `FolderDao` via `@DriftAccessor(include: {...})`.
- The **connection** is isolated in `connection/` so platform details never
  leak into `AppDatabase`.

## How to add a new table

1. Create `lib/data/datasources/local/drift/<name>.drift`:
   ```sql
   import 'folders.drift';            -- if it has FKs to another table

   CREATE TABLE my_things (
     id TEXT NOT NULL PRIMARY KEY,
     folder_id TEXT NOT NULL REFERENCES folders (id) ON DELETE CASCADE,
     name TEXT NOT NULL,
     created_at INTEGER NOT NULL
   ) AS MyThingRow;                   -- AS <RowName> keeps a stable Dart class name

   CREATE INDEX idx_my_things_folder ON my_things (folder_id);
   ```
2. Add it to `app_database.dart`:
   ```dart
   @DriftDatabase(include: <String>{ ..., 'drift/my_things.drift' })
   ```
3. **Schema change** → bump `AppDatabase.currentSchemaVersion`, add an
   `onUpgrade` migration step, and update `docs/database/schema-contract.md` +
   `docs/database/migration-contract.md` (same commit).
4. Run codegen (below).

Column naming: write `snake_case` in `.drift`; Drift exposes `camelCase`
getters (`folder_id` → `folderId`). Use `BOOLEAN` for bool columns (Drift maps
it to `INTEGER` + a `CHECK (col IN (0, 1))`).

## How to add a new query

1. Add a named query to `drift/folder_queries.drift` (or a new query file that
   imports the tables it needs):
   ```sql
   thingsInFolder(:folderId AS TEXT):
   SELECT my_things.* FROM my_things
   WHERE my_things.folder_id = :folderId
   ORDER BY my_things.created_at DESC;
   ```
   - `:name` → a bound variable (a generated parameter). Variables default to
     **non-null**; for an optional filter use a sentinel
     (`(:search = '' OR ...)`) rather than relying on NULL.
   - `$name` in `ORDER BY $name` → an `OrderBy` placeholder built in Dart, for a
     runtime sort. No-arg queries omit the `()`.
   - List explicit columns (or `table.*`) instead of bare `SELECT *` so the
     generated result class is fully typed.
2. Run codegen. Drift generates `thingsInFolder(...)` plus a `ThingsInFolderRow`
   result class.
3. Call it from a thin DAO method. Repository code consumes the generated
   result class directly and composes the domain read model there. Keep mapper
   files for real storage-to-domain transformations such as enum strings,
   epoch timestamps, defaults, or invariant handling — not for mirroring exact
   query-result shapes. Keep DAO methods delegating — no SQL in Dart.

## How to run build_runner

After any `.drift` (or annotated Dart) change:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Never edit `*.g.dart` by hand.

## Rule: no long SQL embedded in Dart

- Do **not** write multi-line `customSelect('...long SQL...')` in Dart. Put the
  query in a `.drift` file and call the generated method.
- Trivial, dependency-only Dart statements are acceptable (e.g.
  `customStatement('PRAGMA foreign_keys = ON')` in the migration `beforeOpen`).
- Single-table reads/mutations may use Drift's query builder
  (`select` / `update` / `delete` / `into`) instead of `.drift` queries.

## Related

- `docs/database/schema-contract.md` — the authoritative table/column list.
- `docs/database/migration-contract.md` — versioning + migration rules.
- `docs/database/storage-boundaries.md` — what belongs in the DB vs preferences.
