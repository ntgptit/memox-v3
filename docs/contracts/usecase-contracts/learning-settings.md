---
last_updated: 2026-06-12
status: contract
---

# Learning Settings Use Cases Contract

> **Current implementation note (2026-06-20, WBS 8.2.1):** `LoadLearningSettingsUseCase` and
> `UpdateLearningSettingsUseCase` are implemented over the project `Result<T>` contract (NOT
> `Either`/`fpdart` — see the target note below; `Result<void>` where the signature shows `Unit`),
> backed by `LearningSettingsRepository`(`Impl`) over `LearningSettingsStore` (SharedPreferences).
> Update validates `dailyNewLimit` (5..200, step 5 → `ValidationFailure(dailyNewLimit, outOfRange)`)
> and normalizes `goalDisabledSince` to a local-midnight date before saving. Code:
> `lib/domain/usecases/learning_settings_usecases.dart`,
> `lib/domain/entities/learning_settings.dart`. Tests:
> `test/domain/usecases/learning_settings_usecases_test.dart`. Wired in
> `lib/app/di/learning_settings_providers.dart`.

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. If the project has not yet adopted `fpdart`, do not add it during
> ordinary feature implementation. First run an approved dependency/API migration task, or use the
> existing repository error/result pattern until that migration is approved.

## LoadLearningSettingsUseCase

```dart
Future<Either<Failure, LearningSettings>> call();
```

Loads the persisted learning settings for study entry and engagement surfaces.

**Errors:** `StorageFailure`.

## UpdateLearningSettingsUseCase

```dart
Future<Either<Failure, Unit>> call({required LearningSettings settings});
```

## Rules

- `dailyNewLimit` must stay within `5..200`.
- `dailyNewLimit` must be on the documented step of `5`.
- `goalDisabledSince` is nullable and passed through to storage after local-date normalization.
- Persist through the learning-settings repository.

**Errors:** `ValidationFailure`, `StorageFailure`.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`,
`docs/contracts/code-style.md`

**Repository:** `docs/contracts/repository-contracts/learning-settings-repository.md`
**Business spec:** `docs/business/engagement/dashboard-engagement.md`
**Storage:** `docs/database/storage-boundaries.md`
**Code paths:** `lib/domain/usecases/learning_settings_usecases.dart`
