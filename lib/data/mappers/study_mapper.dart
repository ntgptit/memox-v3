import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/entities/study_attempt.dart';
import 'package:memox/domain/entities/study_match_evaluation.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_item.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_flow.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_type.dart';

/// Maps Drift rows to study domain types.
abstract final class StudyMapper {
  StudyMapper._();

  static DateTime _dateFromMs(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  static EntryType entryTypeFromStorage(String value) => switch (value) {
    'folder' => EntryType.folder,
    'today' => EntryType.today,
    _ => EntryType.deck,
  };

  static String entryTypeToStorage(EntryType value) => value.name;

  static StudyType studyTypeFromStorage(String value) => switch (value) {
    'srs_review' => StudyType.srsReview,
    _ => StudyType.newCards,
  };

  static String studyTypeToStorage(StudyType value) => switch (value) {
    StudyType.newCards => 'new_cards',
    StudyType.srsReview => 'srs_review',
  };

  static SessionStatus sessionStatusFromStorage(String value) =>
      switch (value) {
        'draft' => SessionStatus.draft,
        'in_progress' => SessionStatus.inProgress,
        'completed' => SessionStatus.completed,
        'cancelled' => SessionStatus.cancelled,
        'failed_to_finalize' => SessionStatus.failedToFinalize,
        _ => SessionStatus.draft,
      };

  static String sessionStatusToStorage(SessionStatus value) => switch (value) {
    SessionStatus.draft => 'draft',
    SessionStatus.inProgress => 'in_progress',
    SessionStatus.completed => 'completed',
    SessionStatus.cancelled => 'cancelled',
    SessionStatus.failedToFinalize => 'failed_to_finalize',
  };

  static AttemptResult attemptResultFromStorage(String value) =>
      switch (value) {
        'perfect' => AttemptResult.perfect,
        'initial_passed' => AttemptResult.initialPassed,
        'recovered' => AttemptResult.recovered,
        'forgot' => AttemptResult.forgot,
        _ => AttemptResult.forgot,
      };

  static String attemptResultToStorage(AttemptResult value) => switch (value) {
    AttemptResult.perfect => 'perfect',
    AttemptResult.initialPassed => 'initial_passed',
    AttemptResult.recovered => 'recovered',
    AttemptResult.forgot => 'forgot',
  };

  static StudyMode studyModeFromStorage(String value) => switch (value) {
    'match' => StudyMode.match,
    'guess' => StudyMode.guess,
    'recall' => StudyMode.recall,
    'fill' => StudyMode.fill,
    _ => StudyMode.review,
  };

  static String studyModeToStorage(StudyMode value) => value.name;

  /// Nullable variant for `study_sessions.current_mode` (the active phase
  /// pointer). A `null` value marks a legacy/single-mode session whose phase
  /// the runtime resolves through the recall fallback.
  static StudyMode? currentModeFromStorage(String? value) =>
      value == null ? null : studyModeFromStorage(value);

  static String? currentModeToStorage(StudyMode? value) =>
      value == null ? null : studyModeToStorage(value);

  static StudyFlow studyFlowFromStorage(String value) => switch (value) {
    'new_full_cycle' => StudyFlow.newFullCycle,
    'new_review_only' => StudyFlow.newReviewOnly,
    'new_match_only' => StudyFlow.newMatchOnly,
    'new_guess_only' => StudyFlow.newGuessOnly,
    'new_recall_only' => StudyFlow.newRecallOnly,
    'new_fill_only' => StudyFlow.newFillOnly,
    'srs_fill_review' => StudyFlow.srsFillReview,
    _ => StudyFlow.srsRecallReview,
  };

  static String studyFlowToStorage(StudyFlow value) => switch (value) {
    StudyFlow.newFullCycle => 'new_full_cycle',
    StudyFlow.newReviewOnly => 'new_review_only',
    StudyFlow.newMatchOnly => 'new_match_only',
    StudyFlow.newGuessOnly => 'new_guess_only',
    StudyFlow.newRecallOnly => 'new_recall_only',
    StudyFlow.newFillOnly => 'new_fill_only',
    StudyFlow.srsRecallReview => 'srs_recall_review',
    StudyFlow.srsFillReview => 'srs_fill_review',
  };

  static StudySession fromSessionRow(StudySessionRow row) => StudySession(
    id: row.id,
    entryType: entryTypeFromStorage(row.entryType),
    entryRefId: row.entryRefId,
    studyType: studyTypeFromStorage(row.studyType),
    status: sessionStatusFromStorage(row.status),
    studyFlow: studyFlowFromStorage(row.studyFlow),
    currentMode: currentModeFromStorage(row.currentMode),
    startedAt: _dateFromMs(row.startedAt),
    updatedAt: _dateFromMs(row.updatedAt),
  );

  static StudySessionItem fromSessionItemRow(StudySessionItemRow row) =>
      StudySessionItem(
        id: row.id,
        sessionId: row.sessionId,
        flashcardId: row.flashcardId,
        sortOrder: row.sortOrder,
        answeredAt: row.answeredAt == null
            ? null
            : _dateFromMs(row.answeredAt!),
        createdAt: _dateFromMs(row.createdAt),
        updatedAt: _dateFromMs(row.updatedAt),
      );

  static StudySessionItem sessionItemFromStorageFields({
    required String id,
    required String sessionId,
    required String flashcardId,
    required int sortOrder,
    int? answeredAt,
    required int createdAt,
    required int updatedAt,
  }) => StudySessionItem(
    id: id,
    sessionId: sessionId,
    flashcardId: flashcardId,
    sortOrder: sortOrder,
    answeredAt: answeredAt == null ? null : _dateFromMs(answeredAt),
    createdAt: _dateFromMs(createdAt),
    updatedAt: _dateFromMs(updatedAt),
  );

  static StudyAttempt fromAttemptRow(StudyAttemptRow row) => StudyAttempt(
    id: row.id,
    sessionItemId: row.sessionItemId,
    result: attemptResultFromStorage(row.result),
    studyMode: studyModeFromStorage(row.studyMode),
    boxBefore: row.boxBefore,
    boxAfter: row.boxAfter,
    userInput: row.userInput,
    attemptedAt: _dateFromMs(row.attemptedAt),
  );

  static StudyMatchEvaluation fromMatchEvaluationRow(
    StudyMatchEvaluationsRow row,
  ) => StudyMatchEvaluation(
    id: row.id,
    sessionId: row.sessionId,
    sessionItemId: row.sessionItemId,
    flashcardId: row.flashcardId,
    boardIndex: row.boardIndex,
    pairId: row.pairId,
    selectedFrontCellId: row.selectedFrontCellId,
    selectedBackCellId: row.selectedBackCellId,
    expectedFrontFlashcardId: row.expectedFrontFlashcardId,
    expectedBackFlashcardId: row.expectedBackFlashcardId,
    isCorrect: row.isCorrect,
    attemptOrder: row.attemptOrder,
    evaluatedAt: _dateFromMs(row.evaluatedAt),
    createdAt: _dateFromMs(row.createdAt),
  );
}
