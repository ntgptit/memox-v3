---
last_updated: 2026-06-12
status: contract
---

# Learning Settings Repository Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. If the project has not yet adopted `fpdart`, do not add it during
> ordinary feature implementation. First run an approved dependency/API migration task, or use the
> existing repository error/result pattern until that migration is approved.

Learning settings are stored outside Drift in SharedPreferences.

## Methods

```dart
Future<Either<Failure, LearningSettings>> load();
Future<Either<Failure, Unit>> save(LearningSettings settings);
```

## Rules

- `load()` returns defaults when keys are missing.
- `dailyNewLimit` defaults to `20`.
- `goalDisabledSince` is nullable and stored as a local `YYYY-MM-DD` string when set.
- Invalid or corrupt persisted `dailyNewLimit` is recovered to the default.
- Repository performs persistence only. Validation stays in the use case.

## Errors

- `StorageFailure` on SharedPreferences read/write failures.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`,
`docs/contracts/code-style.md`

**Use cases:** `docs/contracts/usecase-contracts/learning-settings.md`
**Business spec:** `docs/business/engagement/dashboard-engagement.md`
**Storage:** `docs/database/storage-boundaries.md`
**Code paths:** `lib/domain/repositories/learning_settings_repository.dart`,
`lib/data/repositories/learning_settings_repository_impl.dart`,
`lib/data/datasources/local/preferences/learning_settings_store.dart`
