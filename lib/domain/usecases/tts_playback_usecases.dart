import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/services/tts_playback_policy.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/types/tts_card_side.dart';
import 'package:memox/domain/types/tts_language_code.dart';
import 'package:memox/domain/usecases/tts_settings_usecases.dart';

/// Study-session speech playback (WBS 8.4.3,
/// `docs/contracts/usecase-contracts/tts.md` §SpeakFlashcardUseCase).
///
/// Realized signature note: the contract sketch took `{Flashcard card, Deck
/// deck}`, but study already loads a [StudySessionReviewItem] that carries the
/// front text **and** the owning deck's resolved `targetLanguage` (the per-card
/// TTS gate). Speaking from the review item avoids re-querying the flashcard +
/// deck mid-session, so [speakFront] takes the item directly. The contract is
/// updated to match.
///
/// Front-only is enforced by [TtsPlaybackPolicy] — the back/note are never
/// spoken. Engine failures map to [Failure.storage] (logged, no popup — a study
/// session must not be interrupted by a speech glitch); blank text and
/// unsupported-language decks resolve to silent success.
class SpeakFlashcardUseCase {
  const SpeakFlashcardUseCase({
    required this.ttsService,
    required this.getSettings,
    this.playbackPolicy = const TtsPlaybackPolicy(),
  });

  final TtsService ttsService;
  final GetTtsSettingsUseCase getSettings;
  final TtsPlaybackPolicy playbackPolicy;

  /// Speak the front side of [item], gated by the deck language + the front-only
  /// policy. An unsupported-language deck or blank front resolves to silent
  /// success (no error). Engine failure → [Failure.storage].
  Future<Result<void>> speakFront({
    required StudySessionReviewItem item,
  }) async {
    // Front-only policy gate (defensive — study only ever passes the front).
    if (!playbackPolicy.canSpeak(TtsCardSide.front)) return _ok;
    // Per-deck gate: unsupported decks are silently skipped (no wrong-accent
    // playback, no toast) — tts-settings.md §Deck-level language gate.
    final TtsLanguageCode? language = item.targetLanguage.ttsLanguageCode;
    if (language == null) return _ok;
    return _speak(StringUtils.trimmed(item.front), language: language);
  }

  /// Speak arbitrary [text] in the current global TTS language (e.g. an explicit
  /// preview). Blank/whitespace-only text resolves to silent success.
  Future<Result<void>> speakText(String text) async {
    final String trimmed = StringUtils.trimmed(text);
    if (trimmed.isEmpty) return _ok;
    final Result<TtsSettings> loaded = await getSettings.call();
    final TtsSettings? settings = loaded.data;
    if (settings == null) return _engineFailure(loaded.failure?.toString());
    return _speak(trimmed, language: settings.frontLanguage.languageCode);
  }

  /// Apply the global settings then speak [text] in [language]. The explicit
  /// language overrides the settings language (the deck's language wins for
  /// study playback). Stops any in-flight speech first (no queueing).
  Future<Result<void>> _speak(
    String text, {
    required TtsLanguageCode language,
  }) async {
    if (text.isEmpty) return _ok;
    final Result<TtsSettings> loaded = await getSettings.call();
    final TtsSettings? settings = loaded.data;
    if (settings == null) return _engineFailure(loaded.failure?.toString());
    try {
      await ttsService.stop();
      await ttsService.applySettings(settings);
      await ttsService.speak(text, language: language);
      return _ok;
    } catch (error) {
      return _engineFailure(error.toString());
    }
  }

  static const Result<void> _ok = (failure: null, data: null);

  Result<void> _engineFailure(String? cause) => (
    failure: Failure.storage(
      // TTS engine failures are not storage reads/writes; `transaction` is the
      // least-misleading neutral op in the current taxonomy (a dedicated
      // `PlaybackFailure` is deferred per error-contract §Agent rule).
      operation: StorageOp.transaction,
      table: 'tts_engine',
      cause: cause ?? 'tts engine failure',
    ),
    data: null,
  );
}

/// Stops any in-flight study speech (WBS 8.4.3) — called on card advance/leave.
/// Engine failure maps to [Failure.storage] (logged, no popup).
class StopSpeechUseCase {
  const StopSpeechUseCase({required this.ttsService});

  final TtsService ttsService;

  Future<Result<void>> call() async {
    try {
      await ttsService.stop();
      return (failure: null, data: null);
    } catch (error) {
      return (
        failure: Failure.storage(
          // See SpeakFlashcardUseCase._engineFailure — engine ops are not
          // storage reads/writes; `transaction` is the neutral op.
          operation: StorageOp.transaction,
          table: 'tts_engine',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }
}
