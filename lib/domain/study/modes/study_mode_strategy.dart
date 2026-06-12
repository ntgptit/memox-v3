import 'package:memox/domain/study/fill/fill_answer_evaluator.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// # Study mode Strategy pattern — how it works and how to extend it
///
/// MemoX models per-mode behavior with the classic **Strategy pattern**:
/// every [StudyMode] enum value has exactly one concrete strategy class, and
/// callers (viewmodels) talk to the strategy contract instead of branching on
/// the enum themselves. Strategies are resolved through
/// `StudyModeStrategyFactory.resolve(...)` (see
/// `lib/domain/study/modes/study_mode_strategy_factory.dart`), which is the
/// **only** place allowed to map `StudyMode → StudyModeStrategy`.
///
/// ## Why a `sealed` base instead of one fat interface
///
/// The five study modes do not differ merely in *how* they implement the same
/// steps — they differ in *what interaction they are*:
///
/// | Family                            | Modes                 | Interaction                          |
/// |-----------------------------------|-----------------------|--------------------------------------|
/// | [BinaryGradeStudyModeStrategy]    | recall, review, guess | one card → binary pass/fail outcome  |
/// | [TypedAnswerStudyModeStrategy]    | fill                  | typed production, evaluator-graded   |
/// | [BoardStudyModeStrategy]          | match                 | pair board, append-only evaluations  |
///
/// A single `process()`-style interface would force modes to implement
/// operations they cannot support (the pre-refactor design threw
/// `UnsupportedError` from Fill/Match grading methods — an Interface
/// Segregation violation). Instead, the base class is `sealed` and each
/// **interaction family** below declares only the operations every member can
/// honor. Callers pattern-match on the family:
///
/// ```dart
/// final StudyModeStrategy strategy = StudyModeStrategyFactory.resolve(
///   studyMode: session.mode,
/// );
/// switch (strategy) {
///   case BinaryGradeStudyModeStrategy(): // recall / review / guess
///   case TypedAnswerStudyModeStrategy(): // fill
///   case BoardStudyModeStrategy():       // match
/// }
/// ```
///
/// Because the base is `sealed`, the compiler proves the switch above is
/// exhaustive — adding a family without handling it anywhere is a
/// **compile-time** error, which is strictly stronger than a runtime
/// registry lookup (the Spring `Map<Enum, Bean>` style) could give us.
///
/// ## Why the families live in this file
///
/// Dart's `sealed` modifier requires all *direct* subtypes to be declared in
/// the same library. The three family classes are therefore declared here,
/// while each concrete per-mode strategy lives in its own file and extends
/// its family (the families are `abstract base`, so they remain extendable
/// from other files but never `implement`-able, keeping shared state safe).
///
/// ## Checklist — adding a new study mode
///
/// 1. Add the value to the [StudyMode] enum (`lib/domain/types/`).
/// 2. Pick the interaction family. Only introduce a new family here when the
///    interaction genuinely fits none of the existing ones.
/// 3. Create `lib/domain/study/modes/{mode}_study_mode_strategy.dart` with a
///    `final class {Mode}StudyModeStrategy extends {Family}` and a `const`
///    constructor.
/// 4. Add the enum arm in `StudyModeStrategyFactory.resolve` — the compiler
///    flags every non-exhaustive `switch` on [StudyMode] for you.
/// 5. Add a decision-table row (S4x) + a factory test in
///    `test/domain/study/modes/study_mode_strategy_factory_test.dart`, and
///    update `docs/business/study/study-flow.md` §Study modes in the same
///    commit (doc-code parity rule).
sealed class StudyModeStrategy {
  /// Strategies are stateless and `const`; per-session state belongs to the
  /// session/viewmodel layer, never to the strategy.
  const StudyModeStrategy(this.mode);

  /// The [StudyMode] identity this strategy implements.
  ///
  /// This is the strategy's registry key (the equivalent of a Java
  /// `getStudyMode()`): it is what gets persisted on `study_attempts` rows,
  /// so it must always equal the enum value the factory resolved it from.
  final StudyMode mode;

  /// Whether this mode drives the V1 reveal → self-grade screen flow
  /// (show front, tap "Show answer", grade with Forgot / Got it).
  ///
  /// Only recall uses that flow in V1; every other mode — including the
  /// binary-grade siblings review and guess — has its own presentation flow,
  /// so the default is `false` and recall overrides it.
  bool get usesRevealSelfGradeFlow => false;
}

/// Family: modes whose per-card outcome collapses to a **binary pass/fail**
/// that is mapped onto an [AttemptResult] and persisted as one terminal
/// attempt per card.
///
/// Members and what "pass/fail" means for each:
///
/// - **recall** — user self-grades after reveal (Got it / Forgot).
/// - **review** — both sides shown; swipe right = pass, left = fail.
/// - **guess**  — system-graded: correct option = pass, wrong option = fail.
///
/// Callers obtain the persisted result exclusively through
/// [mapForgotAction] / [mapGotItAction] so the `outcome → AttemptResult`
/// mapping stays inside the strategy (e.g. a future mode could map "pass" to
/// [AttemptResult.recovered] without touching any viewmodel).
abstract base class BinaryGradeStudyModeStrategy extends StudyModeStrategy {
  const BinaryGradeStudyModeStrategy(super.mode);

  /// Maps the failing outcome (Forgot tap, wrong swipe, wrong option) to the
  /// [AttemptResult] recorded for the current card.
  AttemptResult mapForgotAction();

  /// Maps the passing outcome (Got it tap, right swipe, correct option) to
  /// the [AttemptResult] recorded for the current card.
  AttemptResult mapGotItAction();
}

/// Family: modes where the user **produces a typed answer** and a
/// deterministic evaluator — not the user — derives the terminal
/// [AttemptResult].
///
/// Sole V1 member: **fill** (strict trim-only front production; see
/// `docs/business/study/study-flow.md` §Study modes). The caller precomputes
/// the terminal result via [evaluateAnswer] and then records it through the
/// regular one-terminal-attempt path
/// (`RecordStudySessionAnswerUseCase`); there is no self-grade step.
abstract base class TypedAnswerStudyModeStrategy extends StudyModeStrategy {
  const TypedAnswerStudyModeStrategy(super.mode);

  /// Evaluates the user's typed input against the expected answer and
  /// returns the typed evaluation (terminal [AttemptResult] + metadata).
  FillAnswerEvaluation evaluateAnswer({
    required String typedInput,
    required String expectedFront,
    required bool hintUsed,
    bool overrideApplied = false,
  });

  /// Whether this mode can be offered for a card with the given front text
  /// (e.g. fill rejects trivial fronts that are too short to type).
  bool isAvailable(String front);
}

/// Family: modes played on a **multi-card board** where individual taps are
/// persisted as append-only evaluations and the terminal per-card
/// [AttemptResult] is derived later, at session finalization.
///
/// Sole V1 member: **match** (5-pair board; see
/// `RecordMatchEvaluationUseCase` in
/// `docs/contracts/usecase-contracts/study.md`). This family deliberately
/// exposes **no per-card grading API**: Match never grades a single card
/// mid-session, so giving it [BinaryGradeStudyModeStrategy]'s methods would
/// reintroduce the `UnsupportedError` smell this hierarchy exists to remove.
abstract base class BoardStudyModeStrategy extends StudyModeStrategy {
  const BoardStudyModeStrategy(super.mode);
}
