import 'dart:async';

import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/types/tts_language_code.dart';
import 'package:memox/domain/usecases/tts_playback_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_tts_controller.g.dart';

/// Drives front-side speech across every study mode (WBS 8.4.3,
/// `docs/business/tts/tts-settings.md` §Playback policy).
///
/// State is the `sessionItemId` currently being spoken (or `null` when idle), so
/// `StudySpeakButton` can render play/stop without a `TtsState` stream — the
/// engine awaits speak-completion, so [_speak] clears the marker when playback
/// ends. The controller owns the no-queue rule (stop before every speak) and
/// stops the engine on dispose (leaving the session).
@riverpod
class StudyTtsController extends _$StudyTtsController {
  bool _disposed = false;

  @override
  String? build() {
    final StopSpeechUseCase stop = ref.watch(stopSpeechUseCaseProvider);
    ref.onDispose(() {
      _disposed = true;
      // Stop on leave (the session screen disposed) — fire-and-forget.
      unawaited(stop.call());
    });
    return null;
  }

  /// Manual speaker tap: stop if [item] is the one speaking, otherwise speak it.
  Future<void> toggle(StudySessionReviewItem item) async {
    if (state == item.sessionItemId) {
      await stop();
      return;
    }
    await _speak(item);
  }

  /// Auto-play on card reveal — only when the global `autoPlay` flag is on and
  /// the deck language is supported. A silent no-op otherwise (no toast).
  Future<void> autoPlayOnReveal(StudySessionReviewItem item) async {
    if (item.targetLanguage.ttsLanguageCode == null) return;
    final Result<TtsSettings> loaded = await ref
        .read(getTtsSettingsUseCaseProvider)
        .call();
    if (loaded.data?.autoPlay != true) return;
    await _speak(item);
  }

  /// Stop in-flight speech (card advance / leave).
  Future<void> stop() async {
    _setState(null);
    await ref.read(stopSpeechUseCaseProvider).call();
  }

  Future<void> _speak(StudySessionReviewItem item) async {
    _setState(item.sessionItemId);
    // Failure is tolerated (logged in the use case, no popup — speech must not
    // interrupt a study session). The engine awaits completion, so clear the
    // speaking marker once it returns, unless another card took over meanwhile.
    await ref.read(speakFlashcardUseCaseProvider).speakFront(item: item);
    if (state == item.sessionItemId) _setState(null);
  }

  void _setState(String? value) {
    if (_disposed) return;
    state = value;
  }
}
