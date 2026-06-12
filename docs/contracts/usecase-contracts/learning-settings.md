---
last_updated: 2026-06-12
status: contract
---

# Learning Settings Use Cases Contract

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
