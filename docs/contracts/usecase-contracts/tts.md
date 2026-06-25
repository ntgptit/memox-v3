---
last_updated: 2026-06-25
status: contract
---

# TTS Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

> **Status (2026-06-25): settings + engine + Audio & speech screen + study playback shipped (WBS
> 8.4.1 + 8.4.2 + 8.4.3).** Implemented: the `tts_settings` Drift table (schema v9) +
> `TtsSettings`/`TtsVoice` models + `TtsFrontLanguage`/`TtsLanguageCode` + `TtsSettingsDao` +
> `TtsSettingsRepository` + `GetTtsSettingsUseCase`/`UpdateTtsSettingsUseCase` (per-field
> `updateAutoPlay`/`updateRate`/`updatePitch`/`updateVolume`/`updateVoice`/`updateLanguage`; see
> `docs/contracts/repository-contracts/tts-settings-repository.md`) + the **engine adapter**
> `TtsService`/`FlutterTtsService` (`init`/`availableVoices`/`applySettings`/`speak`/`stop`) + the
> **Audio & speech screen** (`AudioSpeechSettingsScreen` over `TtsAudioController`: voice/language
> picker + sample preview + speed/pitch sliders, kit 23) + **study playback (8.4.3)**:
> `TtsPlaybackPolicy` (`canSpeak(TtsCardSide)` — front only) + `SpeakFlashcardUseCase`
> (`speakFront`/`speakText`) + `StopSpeechUseCase` + the study `StudyTtsController` notifier +
> `StudySpeakButton`/`StudyTtsAutoPlay` widgets wired into review/guess/recall/fill. Each
> `StudySessionReviewItem` now carries its deck's `targetLanguage` (resolved in
> `LoadStudySessionReviewUseCase` via `StudySessionDao.decksByIds`), so playback is gated per card
> without re-querying the deck. **Still target/unbuilt:** `ListVoicesUseCase` (the screen calls
> `TtsService.availableVoices` directly) and `TtsService.state` (`Stream<TtsState>`) — `StudyTtsController`
> holds the speaking-card id directly instead of a stream. Match mode is excluded (board layout has no
> single front prompt / reveal step); Fill speaks the front only on the revealed answer (never while it
> is the hidden answer the learner produces) and does not auto-play. Per-language independent
> settings/voices remain a further Target/Future step.

## Runtime Owners

| Behavior | Owner | Status |
| --- | --- | --- |
| Settings load/save (global/front-language) | `Get`/`UpdateTtsSettingsUseCase` → `TtsSettingsRepositoryImpl` → `TtsSettingsDao` | Current (8.4.1) |
| Engine adapter (apply settings, voice listing, speak/stop) | `TtsService`/`FlutterTtsService` (`flutter_tts`) | Current (8.4.1) |
| Audio & speech screen (preview + pickers + sliders) | `TtsAudioController` → `TtsService` + `Update`/`GetTtsSettingsUseCase` | Current (8.4.2) |
| Voice listing | `TtsService.availableVoices(TtsLanguageCode)` (called by `TtsAudioController`) | Current (8.4.1) |
| Manual speaker (study) | `StudySpeakButton` → `StudyTtsController.toggle` → `SpeakFlashcardUseCase.speakFront` | Current (8.4.3) |
| Auto-play front (study reveal) | `StudyTtsAutoPlay` → `StudyTtsController.autoPlayOnReveal` gated by `TtsSettings.autoPlay` + deck language | Current (8.4.3) |
| Front-only playback policy | `TtsPlaybackPolicy.canSpeak(TtsCardSide)` + `SpeakFlashcardUseCase.speakFront` | Current (8.4.3) |
| Stop on advance/leave | `StopSpeechUseCase` (advance) + `StudyTtsController` `onDispose` (leave) | Current (8.4.3) |
| Per-card deck-language gate | `StudySessionReviewItem.targetLanguage` (resolved in `LoadStudySessionReviewUseCase`) | Current (8.4.3) |
| Storage | Drift table `tts_settings` (single-row, schema v9) | Current (8.4.1) |

## SpeakFlashcardUseCase (Current — 8.4.3)

Realized signature note: the original sketch took `{Flashcard card, Deck deck}`, but study already
loads a `StudySessionReviewItem` carrying the front text **and** the owning deck's resolved
`targetLanguage` (the per-card gate). Speaking from the review item avoids re-querying the flashcard
+ deck mid-session, so the realized API takes the item. Results use the repo `Result<T>` (record
`({Failure? failure, T? data})`), not `Either` (fpdart not adopted).

```dart
/// Speaks the front of a study card, gated by the deck language + front-only policy.
Future<Result<void>> speakFront({required StudySessionReviewItem item});

/// Speaks arbitrary trimmed text in the current global TTS language (e.g. a preview).
Future<Result<void>> speakText(String text);
```

**Rules:**

- `speakFront`: If `item.targetLanguage == TargetLanguage.unsupported` (→ `ttsLanguageCode == null`)
  → silently return success. No error, no toast.
- Map `targetLanguage` → `TtsLanguageCode` via `TargetLanguageTtsCodeX.ttsLanguageCode`. The deck's
  language wins for study playback; the app-level `frontLanguage` is ignored.
- Apply global settings (voice, rate, pitch, volume), then `stop()` any in-flight speech before
  `speak` (no queueing). The explicit `speak(text, language:)` overrides the settings language.
- Speak `item.front`. NEVER speak `back`/`note` (enforced by `TtsPlaybackPolicy.canSpeak`).
- `speakText`: reject blank/whitespace-only text silently (success).
- If the TTS engine throws → return `StorageFailure` (general kind, no user error popup; just log).
  Note: `StorageFailure` is a pragmatic mapping because TTS engine failures are not storage errors;
  a dedicated `PlaybackFailure` type may replace this in a future Failure taxonomy revision — do not
  add it now without approval per `docs/contracts/error-contract.md` §Agent rule.

**Errors:** `StorageFailure` (engine).

## StopSpeechUseCase (Current — 8.4.3)

```dart
Future<Result<void>> call();
```

Stops in-flight playback. Called on card advance (`StudyTtsAutoPlay`) and on leaving the session
(`StudyTtsController` `onDispose`). Engine failure → `StorageFailure` (logged).

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
// Realized (8.4.1): updateLanguage(TtsFrontLanguage language) — domain front-language enum, not the
// engine TtsLanguageCode; also clears frontVoiceName.
Future<Either<Failure, Unit>> updateLanguage(TtsFrontLanguage language); // also clears frontVoiceName
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
**Code paths (Current — 8.4.3):** `lib/domain/usecases/tts_playback_usecases.dart`
(`SpeakFlashcardUseCase`, `StopSpeechUseCase`), `lib/domain/services/tts_playback_policy.dart`
(`TtsPlaybackPolicy`), `lib/domain/types/tts_card_side.dart` (`TtsCardSide`),
`lib/domain/types/tts_language_code.dart` (`TargetLanguageTtsCodeX`),
`lib/presentation/features/study/controllers/study_tts_controller.dart` (`StudyTtsController`),
`lib/presentation/features/study/widgets/study_speak_button.dart`
(`StudySpeakButton`/`StudyTtsAutoPlay`), `lib/app/di/tts_providers.dart` (DI). Settings engine:
`lib/domain/services/tts_service.dart`. `ListVoicesUseCase` + `TtsService.state` remain target.
