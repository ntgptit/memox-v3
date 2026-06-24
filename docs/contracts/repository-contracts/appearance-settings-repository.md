---
last_updated: 2026-06-24
implements: lib/domain/repositories/appearance_settings_repository.dart
---

# AppearanceSettingsRepository contract

Port for persisting the app's theme preference (`AppThemeMode`), kit screen 24.
Persistence only — there is no validation (the enum is closed). Backed by
SharedPreferences (`appearance.themeMode`, see
`docs/database/storage-boundaries.md`).

## Methods

```dart
Future<Result<AppThemeMode>> load();
Future<Result<void>> save(AppThemeMode mode);
```

## Rules

- `load()` returns the persisted `AppThemeMode`; a missing or unrecognized
  stored value recovers to `AppThemeMode.system` (via `AppThemeMode.fromStorage`).
- `save(mode)` writes `mode.storageValue` (`system` / `light` / `dark`).
- A SharedPreferences read/write error maps to `StorageFailure`
  (`operation: read|write`, `table: 'appearance_settings'`).

## Use cases

- `LoadAppearanceSettingsUseCase` — pure delegation to `load()`.
- `UpdateAppearanceSettingsUseCase` — pure delegation to `save(mode)`.

## Consumers

- `AppearanceController` (`@Riverpod(keepAlive: true)`) — app-level; `MemoXApp`
  watches it to drive `MaterialApp.themeMode`, and `AppearanceSettingsScreen`
  reads/sets it.

## Source files to inspect

- `lib/domain/types/app_theme_mode.dart`
- `lib/domain/repositories/appearance_settings_repository.dart`
- `lib/domain/usecases/appearance_settings_usecases.dart`
- `lib/data/datasources/local/preferences/appearance_settings_store.dart`
- `lib/data/repositories/appearance_settings_repository_impl.dart`
- `lib/app/di/appearance_settings_providers.dart`
- `lib/presentation/features/settings/controllers/appearance_controller.dart`
