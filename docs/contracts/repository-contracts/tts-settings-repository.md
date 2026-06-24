---
last_updated: 2026-06-25
implements: lib/domain/repositories/tts_settings_repository.dart
---

# TtsSettingsRepository contract

Port for persisting the single global `TtsSettings` row (kit screen 23,
`tts_settings` id `'default'`). Backed by Drift (a single-row table — NOT
SharedPreferences). Canonical model + ranges: `docs/business/tts/tts-settings.md`;
schema: `docs/database/schema-contract.md` §tts_settings.

## Methods

```dart
Future<Result<TtsSettings>> load();
Future<Result<void>> save(TtsSettings settings);
```

## Rules

- `load()` returns the persisted settings; a **missing row** resolves to
  `const TtsSettings()` (documented defaults). Out-of-range slider values
  **self-heal** — `TtsSettings.normalized()` clamps `rate`/`pitch`/`volume` on
  load.
- `save(settings)` clamps the sliders (`settings.normalized()`) before the
  upsert, so the table CHECK constraints never trip.
- A Drift read/write error maps to `StorageFailure` (`operation: read|write`,
  `table: 'tts_settings'`).

## Use cases

- `GetTtsSettingsUseCase` — pure delegation to `load()`.
- `UpdateTtsSettingsUseCase` — per-field mutations (`updateAutoPlay`/`updateRate`/
  `updatePitch`/`updateVolume`/`updateVoice`/`updateLanguage`); each loads, applies
  the change (sliders clamped; `updateLanguage`/`updateVoice(null)` clear
  `frontVoiceName`), normalizes, and saves.

## Status (WBS 8.4.1)

The settings **persistence** (table v9 + migration + model + DAO + repo + Get/
Update use cases + DI) is **Implemented**. The speech **engine** (`TtsService` /
`FlutterTtsService` — voice listing + `speak`/`stop` + auto-play gating) and the
Audio & speech screen (WBS 8.4.2) are the immediate follow-up.

## Source files to inspect

- `lib/domain/types/tts_front_language.dart`
- `lib/domain/models/tts_settings.dart`
- `lib/domain/repositories/tts_settings_repository.dart`
- `lib/domain/usecases/tts_settings_usecases.dart`
- `lib/data/datasources/local/drift/tts_settings.drift`
- `lib/data/datasources/local/migrations/v9_add_tts_settings.dart`
- `lib/data/datasources/local/daos/tts_settings_dao.dart`
- `lib/data/repositories/tts_settings_repository_impl.dart`
- `lib/app/di/tts_providers.dart`
