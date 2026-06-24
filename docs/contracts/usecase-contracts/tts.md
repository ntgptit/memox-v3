---
last_updated: 2026-06-25
status: contract
---

# TTS Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

> **Status (2026-06-25): settings persistence shipped (WBS 8.4.1, schema v9); engine + screen
> pending.** The `tts_settings` Drift table + `TtsSettings` model + `TtsSettingsDao` +
> `TtsSettingsRepository` + `GetTtsSettingsUseCase`/`UpdateTtsSettingsUseCase` now **exist** (the
> per-field Update API below is realized as `updateAutoPlay`/`updateRate`/`updatePitch`/
> `updateVolume`/`updateVoice`/`updateLanguage`; see
> `docs/contracts/repository-contracts/tts-settings-repository.md`). Still **target/unbuilt**: the
> speech runtime — `TtsService`/`FlutterTtsService`, `TtsController`, `SpeakFlashcardUseCase`,
> `StopSpeechUseCase`, `ListVoicesUseCase`, `TtsPlaybackPolicy` — and the Audio & Speech screen
> (kit 23, WBS 8.4.2). Those sections below remain the **target** structure. The first slice is
> global/front-language settings with front-only playback **and** deck `target_language` gating
> (the `decks.target_language` column already exists). Per-language independent settings/voices are
> a further Target/Future step.

## Target Runtime Owners (first slice — none exist yet)

| Behavior | Target owner |
| --- | --- |
| Manual preview / explicit text speech | `TtsController.speakText` → `SpeakFlashcardUseCase.speakText` → `TtsService.speak` |
| Auto-play front text | `TtsController.autoPlayTextSide` gated by `TtsSettings.autoPlay` and `TtsPlaybackPolicy` |
| Front-only playback policy | `TtsPlaybackPolicy` and `SpeakFlashcardUseCase.speakFlashcardSide` |
| Global/front-language settings load/save | `TtsSettingsNotifier` → `TtsSettingsRepositoryImpl` → `TtsSettingsDao` |
| Voice listing | `ttsVoicesProvider(language)` → `TtsService.availableVoices(language)` |
| Storage | Drift table `tts_settings` (single-row; requires schema migration) |

## Target Use Cases

The sections below describe the target use-case contract. Do not mark them Current until the API exists with matching tests.

## SpeakFlashcardUseCase (Target — first slice)

```dart
/// Speaks the front side of a flashcard, gated by deck language and playback policy.
Future<Either<Failure, Unit>> speakFlashcardSide({required Flashcard card, required Deck deck});

/// Speaks arbitrary trimmed text in the current global TTS language.
Future<Either<Failure, Unit>> speakText(String text);
```

**Rules:**

- `speakFlashcardSide`: If `deck.target_language == TargetLanguage.unsupported` → silently return `Right(unit)`. No error.
- Map `target_language` to `TtsLanguageCode`. Delegate language selection to deck; ignore app-level `frontLanguage` for study playback.
- Apply global settings (voice, rate, pitch, volume) — per-language settings storage is Target/Future.
- Speak `card.front`. NEVER speak `card.back` (enforced by `TtsPlaybackPolicy`).
- `speakText`: reject blank/whitespace-only text silently (`Right(unit)`).
- If TTS engine fails to initialize or speak → return `StorageFailure` (general kind, no user error popup needed; just log). Note: `StorageFailure` is a pragmatic mapping because TTS engine failures are not storage errors; a dedicated `PlaybackFailure` type may replace this in a future Failure taxonomy revision — do not add it now without approval per `docs/contracts/error-contract.md` §Agent rule.

**Errors:** `StorageFailure` (engine).

## StopSpeechUseCase (Target/Future)

```dart
Future<Either<Failure, Unit>> call();
```

Stops in-flight playback.

## ListVoicesUseCase (Target/Future)

```dart
Future<Either<Failure, List<TtsVoice>>> call({required TtsLanguageCode lang});
```

Returns available voices on device for given language. Always prepends "System default".

**Errors:** `StorageFailure` (engine).

## GetTtsSettingsUseCase / UpdateTtsSettingsUseCase (Target — first slice)

First slice exposes one global setting row. All slider writes clamp via `TtsSettings.normalize*` — values outside range are clamped, not rejected, because sliders enforce range in UI and corrupt DB values must self-heal on load. `ValidationFailure(outOfRange)` is NOT raised for rate/pitch/volume.

```dart
Future<TtsSettings> getAll();
Future<Either<Failure, Unit>> updateAutoPlay(bool value);
Future<Either<Failure, Unit>> updateRate(double value);   // clamps to [0.3, 0.7]
Future<Either<Failure, Unit>> updatePitch(double value);  // clamps to [0.7, 1.5]
Future<Either<Failure, Unit>> updateVolume(double value); // clamps to [0.0, 1.0]
Future<Either<Failure, Unit>> updateVoice(String? voiceName);
Future<Either<Failure, Unit>> updateLanguage(TtsLanguageCode lang); // also clears frontVoiceName
```

**Rules:**

- Every write path for `rate`, `pitch`, `volume` MUST call `TtsSettings.normalizeRate/normalizePitch/normalizeVolume` before persisting.
- `updateLanguage` MUST clear `frontVoiceName` (stored voice belongs to the previous language).
- Persist immediately; no save button (decision row T1).

**Errors:** `StorageFailure`.

## UpdateTtsSettingsUseCase — per-language variant (Target/Future)

Independent Korean/English settings with separate storage require an approved schema migration first. Do not implement until that migration is approved.

```dart
// Future — requires per-language storage migration
Future<Either<Failure, Unit>> updateLanguageSettings(TtsLanguageCode lang, TtsLanguageSettings settings);
```

## Forbidden patterns

- ❌ Speak `back` anywhere.
- ❌ Auto-play when `deck.target_language == unsupported`. Silently skip.
- ❌ Treat independent Korean/English settings as Current before the per-language storage migration exists.
- ❌ Use different engine instance in preview vs study session.
- ❌ Show error popup on TTS engine failure during study. Log + silently skip.
- ❌ Return `ValidationFailure(code: outOfRange)` for slider values outside `[min, max]`. Clamp via `TtsSettings.normalize*` instead.
- ❌ Implement `updateLanguageSettings(lang, settings)` in the first slice; that requires an approved per-language migration.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Repositories (target — none exist yet):** `lib/domain/repositories/tts_settings_repository.dart` implemented by `lib/data/repositories/tts_settings_repository_impl.dart`, backed by Drift table `tts_settings` (requires schema migration; see `docs/database/schema-contract.md` §Target table areas).

**Business spec:** `docs/business/tts/tts-settings.md`
**Wireframes:** `docs/wireframes/21-settings-audio-speech.md`, `docs/wireframes/13-study-session-review.md` through `docs/wireframes/17-study-session-fill.md`
**Decision table:** rows under "TTS"
**Code paths (target — none exist yet):** `lib/domain/usecases/tts_usecases.dart`, `lib/domain/services/tts_service.dart`, `lib/domain/services/tts_playback_policy.dart`, `lib/presentation/features/tts/providers/tts_controller_notifier.dart`, `lib/presentation/features/tts/providers/tts_settings_notifier.dart`
