---
last_updated: 2026-06-19
source: split from memox-core-decision-table.md
applies_to: Google account and Drive sync behavior branches
---

# MemoX Decision Table — Account / Drive Sync

## Convention
- `ID` is stable. Tests reference it by ID (e.g. `// decision: AC1`).
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` column: `TBD` until the implementing agent writes the test.
  Tests must be derived from the Expected column, NOT from code.

## Account

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| AC1 | Load link | No record in SharedPreferences | Return null (signedOut) | C0+C1 | TBD |
| AC2 | Load link | Schema version mismatch | Return null (require re-link) | C1 | TBD |
| AC3 | Load link | Corrupt JSON | Return null, no crash | C1 | TBD |
| AC4 | Sign in | Success + Drive scope granted | Status=`signedIn`, link saved, `driveAuthorizationState=authorized` | C0+C1 | TBD |
| AC5 | Sign in | Success but Drive scope denied | Status=`needsDriveAuthorization`, link saved with denied state | C0+C1 | TBD |
| AC6 | Sign in | OAuth not configured for platform | Status=`unconfigured`, no link saved | C1 | TBD |
| AC7 | Sign out | Linked account | Clear local session, keep DB file | C0+C1 | TBD |
| AC8 | Disconnect | Linked account | Revoke server-side, clear link | C0+C1 | TBD |
| AC9 | DB context | No link | Resolve to guest DB | C0+C1 | TBD |
| AC10 | DB context | Google account link | Resolve to `{db}_{subjectId}` | C0+C1 | TBD |
| AC11 | Guest → signed-in | choice=`attachGuestData` | Transition flags merge needed | C0+C1 | TBD |
| AC12 | Guest → signed-in | choice=`createFreshAccountDatabase` | Transition flags fresh DB | C0+C1 | TBD |

## Drive Sync

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| SY1 | Load sync status | No account | Return `signedOut` | C0+C1 | TBD |
| SY2 | Load sync status | No remote snapshot | Return `noRemoteSnapshot` | C0+C1 | TBD |
| SY3 | Load sync status | Remote fingerprint == metadata fingerprint | Return `synced` | C0+C1 | TBD |
| SY4 | Load sync status | Remote fingerprint != metadata fingerprint | Return `ready` | C0+C1 | TBD |
| SY5 | Upload | Local fingerprint == remote fingerprint | Return `noChanges` | C0+C1 | TBD |
| SY6 | Upload | Differs from remote | Upload + update metadata + return `uploadedLocal` | C0+C1 | TBD |
| SY7 | Restore | Schema version too new | Return `unsupportedSchema`, do not replace | C1 | TBD |
| SY8 | Restore | Success | Replace DB + settings, return `restoredRemote` with `refreshDatabaseProvider` effect | C0+C1 | TBD |
| SY9 | Restore | Failure mid-flow | Return `failed` with message, local data unchanged | C1 | TBD |
| SY10 | Metadata | Loaded for different account | Return null (account mismatch) | C1 | TBD |
| SY11 | Device id | First call | Generate + persist via `IdGenerator` | C0+C1 | TBD |
| SY12 | Cross-device | Remote `deviceId` differs from local | `remoteIsFromOtherDevice` = true | C1 | TBD |
| SY13 | Current restore protection | Restore selected from Account Settings | Show destructive warning before restore; restore has not executed yet | C0+C1 | TBD |
| SY14 | Current restore protection | Restore warning canceled | Do not call restore | C1 | TBD |
| SY15 | Current restore protection | Restore warning confirmed | Call restore once and show success feedback on success | C0+C1 | TBD |
| SY16 | Current restore protection | Duplicate restore call while first restore is running | Ignore the duplicate call; restore repository runs once | C1 | TBD |
| SY17 | Current restore protection | Restore returns failed result | Show safe failure feedback and keep retry available | C1 | TBD |
| SY18 | Full restore protection target | Local fingerprint != last-synced fingerprint | Show strong warning dialog with "Upload local first" primary | C0+C1 | Future |
| SY19 | Full restore protection target | Pre-restore snapshot save fails | Abort restore; do not proceed | C1 | Future |
| SY20 | Full restore protection target | Pre-restore snapshot saved | Surface path notice after restore | C0+C1 | Future |
| SY21 | Full restore protection target | "Restore anyway" path after fingerprint mismatch | Requires second confirmation tap | C1 | Future |
| SY22 | Restore older snapshot | Remote schema version ≤ current app schema version | Restore proceeds; Drift runs forward migrations up to current schema before any read | C1 | Future |
| SY23 | Drive token expired (~1h) | Silent re-authorization succeeds | Fetch a fresh token silently; no UI, no reconnect banner; operation continues | C1 | Future |
| SY24 | Auto-backup (Future opt-in) | DB dirty, debounce elapsed, fingerprint differs | Upload-only backup on unmetered network; skip when fingerprint unchanged; no restore | C1 | Future |
