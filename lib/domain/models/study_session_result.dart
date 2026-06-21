import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';

part 'study_session_result.freezed.dart';

/// One card in a finished study session, paired with its terminal SRS outcome,
/// as loaded for the result screen (WBS 4.7.1). [result] is the terminal
/// `AttemptResult` derived from the item's attempts (the V1 last-attempt
/// classifier), or `null` when the item was never answered.
@freezed
sealed class StudySessionResultItem with _$StudySessionResultItem {
  const factory StudySessionResultItem({
    required String sessionItemId,
    required FlashcardId flashcardId,
    required String front,
    required String back,
    required int sortOrder,
    required AttemptResult? result,
  }) = _StudySessionResultItem;
  const StudySessionResultItem._();

  /// Whether this item received a terminal attempt.
  bool get isAnswered => result != null;

  /// Whether the terminal result was `forgot` (a lapse).
  bool get isForgot => result == AttemptResult.forgot;

  /// Whether the terminal result was a passing outcome (answered, not `forgot`).
  bool get isPassed => isAnswered && !isForgot;
}

/// The result-summary payload for a session: its persisted header plus the
/// ordered, flashcard-joined items with their terminal outcomes
/// (`docs/contracts/usecase-contracts/study.md` §LoadStudySessionResultUseCase).
/// The result screen (WBS 4.7.2) reads the aggregate counts off the getters.
@freezed
sealed class StudySessionResult with _$StudySessionResult {
  const factory StudySessionResult({
    required StudySession session,
    required List<StudySessionResultItem> items,
  }) = _StudySessionResult;
  const StudySessionResult._();

  /// Total queued items.
  int get total => items.length;

  /// How many items received a terminal attempt.
  int get answeredCount => items.where((i) => i.isAnswered).length;

  /// How many items finalized as `forgot` (lapses).
  int get forgotCount => items.where((i) => i.isForgot).length;

  /// How many items finalized as a passing outcome.
  int get passedCount => items.where((i) => i.isPassed).length;
}
