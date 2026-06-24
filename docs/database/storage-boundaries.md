---
last_updated: 2026-06-21
applies_to: persistence boundary, data access patterns
---

# Storage Boundaries

## Purpose

Define where data belongs and how layers access it.

## Local store generation

Every on-device store name embeds a **generation** tag — `AppConstants.guestDatabaseStore` resolves
to `memox_guest_g{AppConstants.localStoreGeneration}` (web: the IndexedDB/OPFS database name; native:
the `.sqlite` file stem). Bumping `localStoreGeneration` makes drift open a brand-new store, so the
previous one is simply **abandoned** (a deliberate, destructive reset with no migration).

Use it only for a pre-release reset, when an old local store is inconsistent with the current
migration chain and `onUpgrade` cannot recover. Concretely: the 2026-06 rebuild renumbered schema
versions, so a stale dev store can hold v6 study objects while its `user_version` is ≤ 5 — `onUpgrade`
then re-runs `migrateV5ToV6` and fails on an existing object (`index idx_study_sessions_resumable
already exists`). MemoX is local-first with no remote telemetry and no production data, so abandoning
the stale store is safe. **Current generation: `2`** (bumped 2026-06-21 to clear pre-rebuild stores).

This is NOT a substitute for migrations: real schema evolution still goes through a versioned
`onUpgrade` step. Bump the generation only to discard incoherent pre-release stores, never to skip
writing a migration.

## Content sort

The content-sort preference is **per scope** — each sortable object remembers its own sort, so a
choice on a folder never bleeds into a deck. Scopes: `library` (root), `folder:<id>`, `deck:<id>`.
Each persists in SharedPreferences under **`library.sort.<scope>`**, storing a `ContentSortMode`
`enum.name` token (`manual` / `name` / `newest`). Access goes through `ContentSortRepository`
(`ContentSortStore` → SharedPreferences); an unset/unknown/deferred token reads back as `manual`.
It is a UI ordering choice, not entity data — so it lives in prefs, never in Drift. WBS 2.23.1.

## Source of truth

Local Drift database is the source of truth for persistent app data.

Provider state is NOT persistent storage.

## Correct flow

```text
Screen -> ViewModel/Notifier -> UseCase -> Repository -> DAO/Drift -> Database
```

## Forbidden flow

```text
Screen -> DAO
Widget -> AppDatabase
Presentation -> Drift table
Domain -> Drift
Provider memory -> persistent source of truth
```

## Read patterns

When reading from database, choose the right pattern.

| Use case | Pattern | API |
| --- | --- | --- |
| List screen, reactive | Stream | `watchAll`, `watchByX` |
| Detail screen, reactive | Stream | `watchById` |
| Form initial load (one-shot) | Future | `getById` |
| Search results | Stream (debounced) | `watchSearch` |
| Count badge | Stream | `watchCount` |
| Background validation | Future | `exists`, `getById` |

Rule: prefer Stream for anything user-visible. Use Future only for one-shot reads.

## Write patterns

| Use case | API | Wraps in transaction |
| --- | --- | --- |
| Single row insert | `repository.add` | No (single op) |
| Single row update | `repository.update` | No |
| Single row delete | `repository.delete` | If cascade cleanup needed |
| Multi-row ops | `repository.bulkX` | Yes |
| Cross-table ops | UseCase orchestrates | Yes |

## Transaction required

Use transaction for:

- Creating subfolder and updating parent mode.
- Creating deck and updating parent mode.
- Deleting folder/deck/flashcard with cleanup.
- Importing flashcards.
- Creating session and session items.
- Recording attempt plus related state changes.
- Finalizing session and updating progress.

## Refresh rule

After mutation:

- Repository emits via watched streams (automatic via Drift).
- For non-streamed reads, invalidate related providers.
- Update content revision mechanism when used.
- Let UI reload from database.
- Do not manually patch UI list as the only source of truth.

## Revision mechanism

When a feature needs to invalidate a non-Drift cache (e.g., aggregated dashboard counts), use a content revision counter:

- Provider exposes `int revision`.
- Mutation use case increments revision.
- Dependent provider watches revision and refetches.

Do not use revision as a substitute for Drift streams in normal list/detail screens.

## DAO access rule

| Layer | Can access DAO? |
| --- | --- |
| Presentation (widget, viewmodel, notifier) | No |
| Domain (use case, repository contract) | No |
| Data (repository impl) | Yes |
| Data (DAO) | Yes (it is the DAO) |
| Data (mapper) | No (works on Drift rows passed to it) |

## Migration

See `docs/database/migration-contract.md` for schema change procedure.

## Agent rule

Persistence logic belongs in data/repository/use case flow, not in widgets or notifiers.

When in doubt about whether to use Stream or Future: use Stream.

## Related

**Schema:**

- `docs/database/schema-contract.md` — what belongs in Drift

**Related contracts:**

- `docs/database/migration-contract.md`
- `docs/state/state-management-contract.md` — provider memory is NOT a persistence boundary

**Business specs touching non-Drift storage:**

- `docs/business/engagement/dashboard-engagement.md` → learning settings, streak, reminder time in SharedPreferences
- `docs/business/tts/tts-settings.md` → per-language TTS settings in SharedPreferences
- `docs/business/search/global-search.md` → recent searches in SharedPreferences
- `docs/business/account-sync/account-sync.md` → account link (`sharedPrefsCloudAccountLinkKey`) and
  per-account Drive sync metadata (`sharedPrefsDriveSyncMetadataKey`) in SharedPreferences;
  account-scoped DB file path; `DriveSyncManifest` is the remote (Drive AppData) record, not a local
  store
- `docs/business/flashcard/flashcard-management.md` → "Save and add another" toggle (session memory, NOT persisted)

**Settings stored outside Drift**

| Setting | Store | Key | Default | Notes |
| --- | --- | --- | --- | --- |
| Daily new-card limit | SharedPreferences (`lib/data/datasources/local/preferences/learning_settings_store.dart`) | `learning.dailyNewLimit` | `20` | Caps new-card eligibility in study entry. |
| Goal disabled since | SharedPreferences (`lib/data/datasources/local/preferences/learning_settings_store.dart`) | `learning.goalDisabledSince` | `null` | Local `YYYY-MM-DD`; cleared when the goal is enabled. |
| Theme mode | SharedPreferences (`lib/data/datasources/local/preferences/appearance_settings_store.dart`) | `appearance.themeMode` | `system` | `AppThemeMode.storageValue` (`system`/`light`/`dark`); unknown/missing recovers to `system`. Drives `MaterialApp.themeMode`. |

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Storage boundaries" (account-scoped DB switching, prefs key prefixes)
