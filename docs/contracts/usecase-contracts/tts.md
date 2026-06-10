---
last_updated: 2026-06-01
status: contract
---

# TTS Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

> **Status correction (2026-06-10):** NO TTS runtime exists in the current codebase — no
> `TtsService`, no `TtsController`, no `SpeakFlashcardUseCase`, no `TtsSettingsDao`, no
> `tts_settings` table. The Audio & Speech settings screen is a static mock. Everything in this
> contract, including the "runtime owners" table below, is the **target** structure for WBS 8.4.x
> (`docs/business/tts/tts-settings.md`). The first slice is global/front-language settings with
> front-only playback; per-language independent settings and deck `target_language` gating are a
> further Target/Future step.

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

## SpeakFrontUseCase (Target/Future)

```dart
Future<Either<Failure, Unit>> call({required Flashcard card, required Deck deck});
```

**Rules:**

- If `deck.target_language == TargetLanguage.unsupported` → silently return `Right(unit)`. No error.
- Map `target_language` to `TtsLanguageCode`.
- Apply per-language settings (voice, rate, pitch, volume).
- Speak `card.front`. NEVER speak `card.back`.
- If TTS engine fails to initialize or speak → return `StorageFailure` (general kind, no user error popup needed; just log).

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

## GetTtsSettingsUseCase / UpdateTtsSettingsUseCase (Target/Future)

```dart
Future<TtsSettings> getAll();
Future<Either<Failure, Unit>> updateAutoPlay(bool value);
Future<Either<Failure, Unit>> updateLanguageSettings(TtsLanguageCode lang, TtsLanguageSettings settings);
```

**Rules:**

- Validate rate ∈ [0.3, 0.7], pitch ∈ [0.7, 1.5], volume ∈ [0.0, 1.0]. Else `ValidationFailure(code: outOfRange)`.
- Per-language settings stored independently.
- Persist through the approved target storage after the migration/product decision.

**Errors:** `ValidationFailure`, `StorageFailure`.

## Forbidden patterns

- ❌ Speak `back` anywhere.
- ❌ Auto-play when `deck.target_language == unsupported`. Silently skip.
- ❌ Treat independent Korean/English settings as Current before the target API/storage migration exists.
- ❌ Use different engine instance in preview vs study session.
- ❌ Show error popup on TTS engine failure during study. Log + silently skip.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Repositories used (Current V1):** `lib/domain/repositories/tts_settings_repository.dart` implemented by `lib/data/repositories/tts_settings_repository_impl.dart`, backed by Drift table `tts_settings`.

**Business spec:** `docs/business/tts/tts-settings.md`
**Wireframes:** `docs/wireframes/21-settings-audio-speech.md`, `docs/wireframes/13-study-session-review.md` through `docs/wireframes/17-study-session-fill.md`
**Decision table:** rows under "TTS"
**Code paths:** `lib/domain/usecases/tts_usecases.dart`, `lib/domain/services/tts_service.dart`, `lib/domain/services/tts_playback_policy.dart`, `lib/presentation/features/tts/providers/tts_controller_notifier.dart`, `lib/presentation/features/tts/providers/tts_settings_notifier.dart`
