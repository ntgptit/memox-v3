---
last_updated: 2026-06-14
status: contract
---

# Account & Sync Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. If the project has not yet adopted `fpdart`, do not add it during
> ordinary feature implementation. First run an approved dependency/API migration task, or use the
> existing repository error/result pattern until that migration is approved.
>
> **Sync surface convention:** Drive `loadStatus` / `upload` / `restore` use cases return
> `DriveSyncStatus` / `DriveSyncRunResult` (result objects), not `Either` — every sync error funnels
> through `DriveSyncRunResult.failed`. Account use cases may follow the repository's standard
> error/result pattern; signatures below are intent, not a literal `Either` mandate before the
> migration is approved.

Optional Google sign-in, per-account database isolation, and manual Google Drive **AppData**
backup/restore with a mandatory pre-restore snapshot. Canonical model:
`docs/business/account-sync/account-sync.md`. Keep this contract in sync with it in the same commit.

> **Status: Specified — nothing implemented (verified 2026-06-11).** Only
> `lib/core/auth/google_auth.dart` (`GoogleAuthGateway`) and
> `lib/core/config/google_oauth_config.dart` exist. Use-case names below are the planned target for
> WBS 8.6.1 / 8.6.2.

## Account entity & store

Account state is `CloudAccountLink`, persisted in **SharedPreferences ONLY** (never Drift — that
would create a chicken-and-egg with the per-account DB) via `CloudAccountStore`, key
`AppConstants.sharedPrefsCloudAccountLinkKey`. `subjectId` (Google `sub`) is the stable identity;
`email` may change for the same account. Malformed payload loads as `null` (treated as not linked).
`AccountLinkStatus` values: `signedOut`, `signedIn`, `needsDriveAuthorization`, `unconfigured`,
`unsupported`, `error`.

## Account use cases

### LoadCloudAccountLinkUseCase

Read the current link from `CloudAccountStore`. Returns `null` when not linked or on schema-version
mismatch / corruption.

### RestoreGoogleAccountUseCase

Silent re-auth on app start (lightweight, no UI). Refreshes `lastSignedInAt` on success; never
prompts. Failure leaves the stored link untouched.

### SignInWithGoogleUseCase

**Rules:**

- Launch the interactive OAuth flow via `GoogleAuthGateway.signIn()`, requesting the Drive AppData
  scope only.
- On success persist `CloudAccountLink`; preserve `linkedAt` across re-sign-in of the same
  `subjectId` (new `subjectId` ⇒ new `linkedAt`). Update `lastSignedInAt`.
- Drive scope granted ⇒ status `signedIn`, `driveAuthorizationState = authorized`. Drive scope
  denied ⇒ status `needsDriveAuthorization` (link still saved). No OAuth config for the platform ⇒
  `unconfigured`, no link saved.
- Switch the active DB file to the account-scoped path via `AccountDatabaseContextResolver`; on a
  guest→signed-in transition apply the `GuestDatabaseSignInChoice` (`attachGuestData` vs
  `createFreshAccountDatabase`). Switching the active DB triggers Riverpod invalidation of all data
  providers.

**Decision rows:** `AC4`, `AC5`, `AC6`, `AC10`, `AC11`, `AC12`.

### AuthorizeGoogleDriveUseCase

Add the Drive AppData scope to an already-linked account via `GoogleAuthGateway.authorizeDrive()`.
Updates `grantedScopes` + `driveAuthorizationState`.

### SignOutGoogleAccountUseCase

**Rules:**

- Local sign-out only (`GoogleAuthGateway.signOut()`); clears the active session and drops back to
  the **guest** DB context.
- **DO NOT delete** the account-scoped DB file. Re-sign-in resumes the same DB. (Decision row `AC7`.)

### DisconnectGoogleAccountUseCase

**Rules:**

- Revoke server-side consent (`GoogleAuthGateway.disconnect()`) and clear the local
  `CloudAccountLink`. Next sign-in re-prompts for the Drive scope. (Decision row `AC8`.)
- Disconnect does **not** delete the account-scoped DB file in V1.

> **Target / Future — destructive "erase account data":** a stronger account-removal path (typed
> `ERASE` confirmation per `docs/wireframes/24-shared-dialogs.md` §delete-confirm) that also deletes
> the account-scoped DB file is **not Current V1**. Do not implement DB deletion under sign-out or
> disconnect. If/when promoted, add it as a separate destructive use case and document it in the
> business spec first.

### PersistGoogleAuthResultUseCase

Persist an auth result produced by an external trigger (e.g. web button) into `CloudAccountStore`,
applying the same status/`linkedAt` rules as `SignInWithGoogleUseCase`.

### GetDriveAppDataAccessTokenUseCase

Obtain a short-lived Drive access token for a single API call via
`GoogleAuthGateway.driveAccessToken()`, which **silently re-authorizes** the existing grant (the ~1h
access-token expiry is refreshed without UI). The app does NOT persist OAuth tokens itself;
`google_sign_in` 7.x owns the token lifecycle (no `flutter_secure_storage`). `null` (silent refresh
failed — consent revoked / Google session gone) ⇒ `needsDriveAuthorization`; the presentation layer
shows the reconnect banner and only then runs interactive re-auth. Never re-trigger interactive
sign-in on a normal 1-hour expiry. See `docs/business/account-sync/account-sync.md` §Token lifetime &
silent refresh. (Decision row `SY23`.)

## Drive sync use cases

All three delegate to `DriveSyncRepository`
(`docs/contracts/repository-contracts/sync-repository.md`).

### LoadDriveSyncStatusUseCase

Read-only. Refresh `DriveSyncStatus` from Drive AppData + per-account metadata. (Decision rows
`SY1`–`SY4`.)

### UploadLocalDriveSnapshotUseCase

Build the local snapshot (DB bytes + settings JSON + manifest), upload to Drive AppData, update
metadata. Same fingerprint as remote ⇒ `noChanges`; otherwise `uploadedLocal`. (Decision rows `SY5`,
`SY6`.)

### RestoreDriveSnapshotUseCase

**Rules:**

- Replacement-only (no merge). Replaces BOTH database and settings from the remote snapshot.
- Pre-restore safety: build a snapshot to the temp dir as `memox-pre-restore-{timestamp}.zip`; if it
  fails → **abort** (original DB UNCHANGED). Surface the path notice after success.
- Schema gate: remote `appDatabaseSchemaVersion` **>** current app ⇒ `unsupportedSchema` (block,
  prompt update). Equal or **lower** proceeds — after the atomic file swap Drift runs forward
  migrations up to `AppDatabase.schemaVersion` before any read model is served
  (`docs/database/migration-contract.md`).
- On success set `restoreEffect = refreshDatabaseProvider`; the presentation layer MUST process it
  via the runtime effects helper. (Decision rows `SY7`, `SY8`, `SY9`, `SY22`.)

> **Target / Partial — full restore protection** (decision rows `SY18`–`SY21`): compare local
> fingerprint vs `DriveSyncMetadata.localFingerprint`; on mismatch show the strong warning dialog
> with "Upload local first" as the visually emphasized primary action and "Restore anyway" gated by
> a second confirmation tap. Current V1 shows the destructive-restore warning before a single
> replacement restore.

### Auto-backup (Future)

A Future opt-in auto-backup (`docs/business/account-sync/account-sync.md` §Auto-backup) reuses
`UploadLocalDriveSnapshotUseCase` on a debounced/periodic, constraint-gated schedule. It is
**upload-only** (never auto-restore), idempotent via fingerprint, and depends on silent token
refresh. Not V1; requires an approved background-scheduler dependency. (Decision row `SY24`.)

## Forbidden patterns

- ❌ Auto-restore on sign-in. In V1 auto-upload is also forbidden; a Future opt-in auto-backup is
  upload-only and must never auto-restore.
- ❌ Skip the pre-restore snapshot when local DB has data; continue restore if the snapshot fails.
- ❌ Store the account link in Drift, or store OAuth tokens in SharedPreferences / Drift /
  `flutter_secure_storage`.
- ❌ Log tokens, fingerprints, settings JSON, or DB content.
- ❌ Delete the account-scoped DB on sign-out or disconnect (no V1 erase path).
- ❌ Backup outside the Drive AppData folder; request scopes beyond AppData without security review.
- ❌ Serve queries against a restored older-schema DB before Drift migrations run.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types),
`docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business spec:** `docs/business/account-sync/account-sync.md`
**Repository:** `docs/contracts/repository-contracts/sync-repository.md`
**Migration:** `docs/database/migration-contract.md`
**Wireframes:** `docs/wireframes/19-settings-account.md`, `docs/wireframes/24-shared-dialogs.md`
§restore-warning
**Decision table:** `docs/decision-tables/memox-core-decision-table.md` rows under "Account / Drive
sync" (`AC1`–`SY22`)
**Code paths (planned target — WBS 8.6.1 / 8.6.2):** cloud-account use-case bundle, drive-sync
use-case bundle, `lib/core/auth/google_auth.dart` (exists),
`lib/core/config/google_oauth_config.dart` (exists)
</content>
