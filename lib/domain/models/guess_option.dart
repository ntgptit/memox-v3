import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'guess_option.freezed.dart';

/// One multiple-choice option card in Guess mode (WBS 4.5.6).
///
/// Guess shows a card's front and asks the user to pick the correct [back] from
/// a small set of option cards. Exactly one option in a built set has
/// [isCorrect] `true` (the target card's own back); the rest are distinct
/// distractor backs drawn from the session's other cards
/// (`docs/business/study/study-flow.md` §study modes; decision rows S47/S80-S83).
///
/// [flashcardId] is the source card of this option (the target for the correct
/// option, a distractor card otherwise) — it keys the option for selection and
/// list animations. The grading itself stays binary: a correct pick records
/// `perfect`, a wrong pick `forgot`, through the existing one-terminal-attempt
/// path (`RecordStudySessionAnswerUseCase`, WBS 4.4.1).
@freezed
sealed class GuessOption with _$GuessOption {
  const factory GuessOption({
    required FlashcardId flashcardId,
    required String back,
    required bool isCorrect,
  }) = _GuessOption;
}
