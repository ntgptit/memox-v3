import 'package:memox/domain/types/study_mode.dart';

/// The ordered sequence of [StudyMode] phases a study session plays through
/// (`docs/business/study/study-flow.md` §Study flows,
/// `docs/contracts/types-catalog.md` §StudyFlow).
///
/// A flow is the **phase plan** of a session: a session moves through
/// [orderedModes] one phase at a time (per-phase chaining — the whole batch
/// clears one mode before the next mode begins). The active phase is persisted
/// on `study_sessions.current_mode`; the plan itself is persisted on
/// `study_sessions.study_flow`.
///
/// Storage: `study_sessions.study_flow` TEXT, snake_case (see
/// `StudyMapper.studyFlowToStorage`).
enum StudyFlow {
  /// New cards, full learning: review → match → guess → recall → fill.
  newFullCycle,

  /// Quick browse: review only.
  newReviewOnly,

  /// Targeted practice: match only.
  newMatchOnly,

  /// Targeted practice: guess only.
  newGuessOnly,

  /// Targeted practice: recall only.
  newRecallOnly,

  /// Targeted practice: fill only.
  newFillOnly,

  /// SRS review default (adopted 2026-06-10): recall only.
  srsRecallReview,

  /// SRS review, opt-in production practice: fill only.
  srsFillReview,
}

/// Phase-plan behavior for a [StudyFlow].
///
/// The mode → flow mapping lives only here so callers never hardcode a phase
/// sequence. A single-mode flow (e.g. [StudyFlow.newReviewOnly]) is a chain of
/// length one — its only phase is also its last phase.
extension StudyFlowPlan on StudyFlow {
  /// The ordered phases this flow plays through. Never empty.
  List<StudyMode> get orderedModes => switch (this) {
    StudyFlow.newFullCycle => const <StudyMode>[
      StudyMode.review,
      StudyMode.match,
      StudyMode.guess,
      StudyMode.recall,
      StudyMode.fill,
    ],
    StudyFlow.newReviewOnly => const <StudyMode>[StudyMode.review],
    StudyFlow.newMatchOnly => const <StudyMode>[StudyMode.match],
    StudyFlow.newGuessOnly => const <StudyMode>[StudyMode.guess],
    StudyFlow.newRecallOnly => const <StudyMode>[StudyMode.recall],
    StudyFlow.newFillOnly => const <StudyMode>[StudyMode.fill],
    StudyFlow.srsRecallReview => const <StudyMode>[StudyMode.recall],
    StudyFlow.srsFillReview => const <StudyMode>[StudyMode.fill],
  };

  /// The first phase to play. The value persisted as `current_mode` at create.
  StudyMode get firstMode => orderedModes.first;

  /// Whether [mode] is the terminal phase (the phase that finalizes).
  ///
  /// A [mode] that is not part of this flow is treated as terminal so an
  /// out-of-plan session can never get stuck without a finish path.
  bool isLastMode(StudyMode mode) {
    final int index = orderedModes.indexOf(mode);
    return index < 0 || index == orderedModes.length - 1;
  }

  /// The phase after [mode], or `null` when [mode] is the last (or not in plan).
  StudyMode? nextModeAfter(StudyMode mode) {
    final int index = orderedModes.indexOf(mode);
    if (index < 0 || index >= orderedModes.length - 1) {
      return null;
    }
    return orderedModes[index + 1];
  }
}
