import 'package:memox/domain/study/modes/fill_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/guess_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/match_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/recall_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/review_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/study_mode.dart';

/// **Factory** — the single place that maps `StudyMode → StudyModeStrategy`.
///
/// Any other code that needs per-mode behavior must go through [resolve]
/// (or pattern-match on the strategy it returns); branching on [StudyMode]
/// directly inside viewmodels/widgets defeats the Strategy pattern and is
/// forbidden.
///
/// ## Why an exhaustive `switch`, not a registry map
///
/// In DI-container ecosystems (e.g. Spring) factories are usually built as a
/// `Map<Enum, Strategy>` auto-populated by the container, keyed by something
/// like `getStudyMode()`. Dart has no classpath scanning, so such a map
/// would be hand-written anyway — and a map lookup only fails at **runtime**
/// when an entry is missing. The `switch` below is exhaustive over the
/// [StudyMode] enum, so adding a new enum value without wiring its strategy
/// is a **compile-time** error. Keep it a `switch`; do not "modernize" it
/// into a map.
///
/// Strategies are stateless `const` objects, so the factory is `static` and
/// needs no Riverpod provider. If a strategy ever grows a real dependency
/// (repository, evaluator service), move resolution behind a provider at
/// that point — not before.
abstract final class StudyModeStrategyFactory {
  /// Resolves the active mode strategy for the current study session.
  ///
  /// V1 fallback: the session header now persists `study_flow` / `current_mode`,
  /// but the V1 review controller does not yet consume `current_mode`, so a
  /// `null` [studyMode] (no route mode) resolves to [StudyMode.recall] — the
  /// documented default in `docs/business/study/study-flow.md` (decision row
  /// S45).
  static StudyModeStrategy resolve({StudyMode? studyMode}) {
    final StudyMode resolvedMode = studyMode ?? StudyMode.recall;
    return switch (resolvedMode) {
      StudyMode.recall => const RecallStudyModeStrategy(),
      StudyMode.review => const ReviewStudyModeStrategy(),
      StudyMode.guess => const GuessStudyModeStrategy(),
      StudyMode.fill => const FillStudyModeStrategy(),
      StudyMode.match => const MatchStudyModeStrategy(),
    };
  }
}
