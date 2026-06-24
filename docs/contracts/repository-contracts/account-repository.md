---
last_updated: 2026-06-24
implements: lib/domain/repositories/account_repository.dart
---

# AccountRepository contract (V1 display-only)

Port for reading the Google-account link status (kit screen 21). **V1 is
read-only and display-only** — interactive sign-in / Drive sync (which would add
`signIn` / `authorizeDrive` / `signOut` / `disconnect` here) land in WBS
8.6.1/8.6.2 per `docs/contracts/usecase-contracts/account-sync.md`. Backed by
SharedPreferences (`account.cloudAccountLink`, see
`docs/database/storage-boundaries.md`).

## Methods

```dart
Future<Result<AccountLinkStatus>> loadStatus();
```

## Rules

- `loadStatus()` derives the status from link **presence**: no stored
  `CloudAccountLink` payload → `AccountLinkStatus.signedOut`; a payload present →
  `signedIn`. Because V1 never writes a link (no interactive sign-in yet), this
  always resolves to `signedOut`.
- When sign-in lands (8.6.1), parsing the stored `CloudAccountLink` JSON into the
  full `AccountLinkStatus` set (`needsDriveAuthorization` / `unconfigured` / …)
  replaces the presence check.
- A SharedPreferences read error maps to `StorageFailure`
  (`operation: read`, `table: 'cloud_account_link'`).

## Use cases

- `LoadAccountStatusUseCase` — pure delegation to `loadStatus()`.

## Consumers

- `AccountController` — the Account screen reads the status; V1 renders the
  signed-out sign-in hero (disabled CTA).

## Source files to inspect

- `lib/domain/types/account_link_status.dart`
- `lib/domain/repositories/account_repository.dart`
- `lib/domain/usecases/account_usecases.dart`
- `lib/data/datasources/local/preferences/cloud_account_store.dart`
- `lib/data/repositories/account_repository_impl.dart`
- `lib/app/di/account_providers.dart`
- `lib/presentation/features/settings/controllers/account_controller.dart`
