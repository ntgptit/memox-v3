---
last_updated: 2026-06-14
status: contract
---

# Drive Sync Repository Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. If the project has not yet adopted `fpdart`, do not add it during
> ordinary feature implementation. First run an approved dependency/API migration task, or use the
> existing repository error/result pattern until that migration is approved.
>
> **Sync error convention (overrides the generic note for this surface):** the Drive sync surface
> does NOT return `Either` from upload/restore. By design every sync error funnels through
> `DriveSyncRunResult.failed` with a user-safe message (see `docs/business/account-sync/account-sync.md`
> §Rules → Drive sync). Raw network/HTTP exceptions must never reach the UI.

Manual Google Drive **AppData** backup/restore. NOT a Drift repository — it operates on the local
Drift file (through a platform snapshot gateway), the Drive AppData REST API, and SharedPreferences
metadata. The canonical model, statuses, and flows live in
`docs/business/account-sync/account-sync.md`; this file is the repository-level contract for that
spec. Keep both in sync in the same commit.

> **Status: Specified — nothing implemented (verified 2026-06-11).** Only `lib/core/auth/google_auth.dart`
> (the `GoogleAuthGateway` port) and `lib/core/config/google_oauth_config.dart` exist today. Symbol
> names below are the planned target structure for WBS 8.6.2.

## Methods

```dart
abstract interface class DriveSyncRepository {
  /// Read-only. Refresh status from Drive AppData + per-account metadata.
  Future<DriveSyncStatus> loadStatus();

  /// Build local snapshot, upload to Drive AppData, update metadata.
  Future<DriveSyncRunResult> uploadLocalSnapshot();

  /// Download remote snapshot, replace local DB + settings, update metadata.
  /// Sets `restoreEffect = refreshDatabaseProvider` on success.
  Future<DriveSyncRunResult> restoreRemoteSnapshot();
}
```

- `loadStatus` returns a `DriveSyncStatus` whose `kind` is one of the `DriveSyncStatusKind` values
  documented in the business spec (current impl produces `signedOut`, `unconfigured`,
  `needsDriveAuthorization`, `noRemoteSnapshot`, `ready`, `synced`, `failure`).
- `uploadLocalSnapshot` / `restoreRemoteSnapshot` return `DriveSyncRunResult` with a
  `DriveSyncActionKind` and, for restore, a `DriveSyncRestoreEffect`.

## Snapshot, manifest, fingerprint (canonical: business spec)

These shapes are owned by `docs/business/account-sync/account-sync.md`. Repeated here only as the
binding contract; do not redefine them differently.

### Snapshot archive

A snapshot is a single self-contained archive (`.zip`) built/decoded by `DriveSyncSnapshotCodec`,
containing three parts:

| Part           | Contents                                                                 |
|----------------|--------------------------------------------------------------------------|
| Database bytes | Raw bytes of the current Drift SQLite file (via the platform gateway).   |
| Settings       | App settings serialized to JSON (TTS, learning defaults, theme, locale). |
| Manifest       | `DriveSyncManifest` JSON (metadata describing the snapshot).             |

Settings JSON is part of the snapshot — restore replaces BOTH database and settings.

### Manifest

`DriveSyncManifest` fields: `manifestVersion`, `snapshotFormatVersion`, `appId` (`'memox'`),
`appDatabaseSchemaVersion`, `createdAt`, `deviceId`, `deviceLabel`, `databaseSha256`,
`settingsSha256`, `snapshotSizeBytes`, `accountSubjectId`, `appVersion`. `manifestVersion`,
`snapshotFormatVersion`, and the account-link schema version are independent integers — bump only
the relevant one on a format change.

### Fingerprint (change detection)

Fingerprint is a composite string, NOT a timestamp comparison and NOT a re-hash of canonicalized
table content:

```text
'{appId}:{snapshotFormatVersion}:{appDatabaseSchemaVersion}:{accountSubjectId}:{databaseSha256}:{settingsSha256}'
```

`databaseSha256` is SHA-256 over the **raw bytes** of the Drift file exported by the gateway;
`settingsSha256` is SHA-256 over the settings JSON. Local vs remote are "the same content" iff their
fingerprints are equal.

## Metadata (per-account)

`DriveSyncMetadata` is stored in SharedPreferences (key:
`AppConstants.sharedPrefsDriveSyncMetadataKey`), per account. Fields: `accountSubjectId`,
`manifestFileId`, `snapshotFileId`, `remoteFingerprint`, `localFingerprint`,
`remoteManifestVersion`, `remoteSnapshotVersion`, `lastSyncedAt`. `matchesAccount(subjectId)` rejects
metadata from a different account; switching accounts does not carry metadata. The persistent
`deviceId` is created lazily via `DriveSyncMetadataStore.loadOrCreateDeviceId`.

## Platform snapshot gateway

The only platform-specific surface. `createPlatformLocalDatabaseSnapshotGateway(AppDatabase)` is the
single entry point (conditional import io/web/stub); presentation/domain MUST NOT import platform
files directly. Contract:

- `exportDatabase()` → raw bytes of the active Drift file.
- `restoreDatabase(bytes)` → write bytes back as the active Drift file (atomic on IO).
- `currentSchemaVersion` → `AppDatabase.schemaVersion`.

The stub gateway throws `UnsupportedError` on every call (intentionally noisy — never replace with a
no-op). Web depends on `web/sqlite3.wasm` + `web/drift_worker.dart.js`; missing assets surface as
`WasmProbeFailure`, not silent zero-byte snapshots.

## Operational rules

### Upload

1. Load account link. `signedOut` → return status `signedOut`; missing Drive scope or reauth
   required → `needsDriveAuthorization`.
2. Get a short-lived Drive access token (see Token handling).
3. Build local snapshot (DB bytes + settings JSON + manifest) and compute fingerprint.
4. Load remote snapshot if present. Same fingerprint → return `noChanges`.
5. Different or absent → upload archive to Drive AppData, update metadata (file ids + fingerprints).
6. Return `uploadedLocal`.

### Restore (replacement-only, with pre-restore safety)

1. Load account link. `signedOut` → `signedOut`. Get Drive access token.
2. **Pre-restore snapshot (safety net):** build a snapshot identical to what would be uploaded and
   write it to the platform **temporary directory** as `memox-pre-restore-{timestamp}.zip`
   (timestamp = ISO local time). If the snapshot save fails → **abort restore** (hard stop; original
   DB UNCHANGED). Surface the path to the user after a successful restore via a non-modal notice.
3. Download remote snapshot. Not found → `noRemoteSnapshot`.
4. Schema gate: if remote `appDatabaseSchemaVersion` **>** current app schema version →
   `unsupportedSchema` (block restore, prompt app update). A remote schema **≤** current is allowed —
   see "Restoring older snapshots" below.
5. Decode archive via `DriveSyncSnapshotCodec`.
6. Replace local DB file **atomically** (write bytes to a temp file via the gateway, then swap) and
   replace settings.
7. Update metadata. Set `restoreEffect = refreshDatabaseProvider`.
8. Return `restoredRemote` with the effect — the presentation layer MUST process it via the runtime
   effects helper or the UI stays bound to the stale `AppDatabase`.

### Restoring older snapshots (schema migration)

When the restored snapshot's `appDatabaseSchemaVersion` is **lower** than the current app schema
version, the swapped-in file is an older-schema database. After the swap, Drift opens the file and
**runs its forward migrations** up to `AppDatabase.schemaVersion` (per
`docs/database/migration-contract.md`) before any read model is served. Restore MUST NOT serve
queries against an un-migrated older file. Only a **higher** remote schema is rejected
(`unsupportedSchema`); equal or lower proceeds through normal Drift migration.

## Token handling

- Drive access is via a **short-lived** access token obtained per API call through
  `GoogleAuthGateway.driveAccessToken()` (returns `null` when no account is authorized → treat as
  `needsDriveAuthorization`).
- The app does NOT persist OAuth access/refresh tokens itself. `google_sign_in` 7.x owns the token
  lifecycle (authentication vs. authorization are separate; the plugin manages refresh). There is no
  app-managed token store and no `flutter_secure_storage` dependency for sync.
- Never log tokens, manifest content, settings JSON, or database content
  (`docs/quality/observability-contract.md`).

## Constraints

- Drive **AppData** folder ONLY (scope `https://www.googleapis.com/auth/drive.appdata`). Other apps
  and the user's Drive UI cannot see these files. Do not request broader Drive scopes.
- Snapshot includes database bytes AND settings JSON.
- Fingerprint (composite string above) is the only change-detection mechanism. Do not compare
  timestamps.
- Manifest is the canonical record of remote state; absent manifest ⇒ no backup exists.
- Metadata is per-account; switching accounts does not carry it.
- Restore is **replacement-only** (no merge) in V1.
- Sync is **manual** in V1 — no background/auto sync.

## Forbidden

- ❌ Backup outside the Drive AppData folder.
- ❌ Request OAuth scopes beyond AppData without security review.
- ❌ App-managed OAuth token store / tokens in SharedPreferences, Drift, or `flutter_secure_storage`.
- ❌ Log tokens, manifest, settings, or DB content.
- ❌ Continue restore if the pre-restore snapshot fails to save.
- ❌ Non-atomic DB replace (writing directly over the active DB without a temp file + swap).
- ❌ Serve queries against a restored older-schema DB before Drift migrations run.
- ❌ Surface raw network/HTTP exceptions — funnel through `DriveSyncRunResult.failed`.
- ❌ Auto-upload on every data change (manual only in V1).

## Test contract

Use a `FakeDriveService` / fake `GoogleAuthGateway` in tests. See decision-table rows `SY1`–`SY22`
in `docs/decision-tables/memox-core-decision-table.md`.

- `loadStatus`: signedOut / noRemoteSnapshot / synced / ready / failure.
- Upload: same fingerprint → `noChanges`; differs → `uploadedLocal` + metadata updated.
- Restore: schema too new → `unsupportedSchema`, DB unchanged.
- Restore: older remote schema → forward migration runs, no stale read.
- Restore: success → DB + settings replaced, `restoredRemote` with `refreshDatabaseProvider`.
- Restore: failure mid-flow → `failed`, local data unchanged.
- Pre-restore snapshot failure → abort restore, DB unchanged.
- Metadata loaded for a different account → null (account mismatch).
- Drive access token absent → `needsDriveAuthorization`.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`,
`docs/contracts/code-style.md`

**Business spec:** `docs/business/account-sync/account-sync.md`
**Use cases:** `docs/contracts/usecase-contracts/account-sync.md`
**Storage boundaries:** `docs/database/storage-boundaries.md`
**Migration:** `docs/database/migration-contract.md`
**Wireframes:** `docs/wireframes/19-settings-account.md`, `docs/wireframes/24-shared-dialogs.md`
§restore-warning
**Decision table:** `docs/decision-tables/memox-core-decision-table.md` rows under "Account / Drive
sync"
**Code paths (planned target — WBS 8.6.2):**

- Drive sync repository (`GoogleDriveSyncRepository`) + helper modules
- Drive AppData REST client
- `DriveSyncSnapshotCodec`, `DriveSyncMetadataStore`
- platform local-database snapshot gateway (io / web / stub) behind
  `createPlatformLocalDatabaseSnapshotGateway`
- `lib/core/auth/google_auth.dart` (exists), `lib/core/config/google_oauth_config.dart` (exists)
</content>
</invoke>
