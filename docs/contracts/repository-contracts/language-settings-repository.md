---
last_updated: 2026-06-24
implements: lib/domain/repositories/language_settings_repository.dart
---

# LanguageSettingsRepository contract

Port for persisting the app's UI-language preference (`AppLanguage`), kit screen
25. Persistence only — there is no validation (the enum is closed). Backed by
SharedPreferences (`language.appLanguage`, see
`docs/database/storage-boundaries.md`).

## Methods

```dart
Future<Result<AppLanguage>> load();
Future<Result<void>> save(AppLanguage language);
```

## Rules

- `load()` returns the persisted `AppLanguage`; a missing or unrecognized stored
  value recovers to `AppLanguage.system` (via `AppLanguage.fromStorage`).
- `save(language)` writes `language.storageValue` (`system` / `en` / `vi`).
- A SharedPreferences read/write error maps to `StorageFailure`
  (`operation: read|write`, `table: 'language_settings'`).

## Use cases

- `LoadLanguageSettingsUseCase` — pure delegation to `load()`.
- `UpdateLanguageSettingsUseCase` — pure delegation to `save(language)`.

## Consumers

- `LanguageController` (`@Riverpod(keepAlive: true)`) — app-level; `MemoXApp`
  watches it to drive `MaterialApp.locale` (`AppLanguage.system` → `null` =
  device locale; the app re-localizes live, no restart), and
  `LanguageSettingsScreen` reads/sets it.

## Source files to inspect

- `lib/domain/types/app_language.dart`
- `lib/domain/repositories/language_settings_repository.dart`
- `lib/domain/usecases/language_settings_usecases.dart`
- `lib/data/datasources/local/preferences/language_settings_store.dart`
- `lib/data/repositories/language_settings_repository_impl.dart`
- `lib/app/di/language_settings_providers.dart`
- `lib/presentation/features/settings/controllers/language_controller.dart`
