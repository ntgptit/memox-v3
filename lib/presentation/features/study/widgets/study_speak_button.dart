import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/types/tts_language_code.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_tts_controller.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';

/// The manual TTS speaker glyph for a study prompt (WBS 8.4.3). Speaks the front
/// of [item]; toggles to a stop glyph while that card is speaking. Hidden when
/// the deck language is unsupported (the per-deck TTS gate — no wrong-accent
/// playback, `docs/business/tts/tts-settings.md` §Deck-level language gate).
class StudySpeakButton extends ConsumerWidget {
  const StudySpeakButton({required this.item, super.key});

  final StudySessionReviewItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Per-deck gate: no speaker affordance for unsupported-language decks.
    if (item.targetLanguage.ttsLanguageCode == null) {
      return const SizedBox.shrink();
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isSpeaking =
        ref.watch(studyTtsControllerProvider) == item.sessionItemId;
    return MxIconButton.toolbar(
      key: const ValueKey<String>('mx-node:study-session/speak'),
      icon: isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
      tooltip: isSpeaking ? l10n.studySpeakStop : l10n.studySpeakPlay,
      onPressed: () =>
          unawaited(ref.read(studyTtsControllerProvider.notifier).toggle(item)),
    );
  }
}

/// Triggers auto-play when the shown card changes and stops in-flight speech on
/// card advance (WBS 8.4.3). Wraps a mode's content so every prompt-based study
/// mode (review/guess/recall/fill) shares one auto-play trigger. Leaving the
/// session stops the engine via the controller's dispose.
class StudyTtsAutoPlay extends HookConsumerWidget {
  const StudyTtsAutoPlay({required this.item, required this.child, super.key});

  /// The currently shown card.
  final StudySessionReviewItem item;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fire once per shown card (keyed on the item id): stop the previous card's
    // speech, then auto-play the new card (gated by the global `autoPlay` flag +
    // deck language inside the controller). Deferred to a microtask so it runs
    // outside build. Leaving the session stops the engine via the controller's
    // dispose, so no cleanup callback is needed here.
    useEffect(() {
      final StudyTtsController controller = ref.read(
        studyTtsControllerProvider.notifier,
      );
      unawaited(
        Future<void>.microtask(() async {
          await controller.stop();
          await controller.autoPlayOnReveal(item);
        }),
      );
      return null;
    }, <Object>[item.sessionItemId]);
    return child;
  }
}
