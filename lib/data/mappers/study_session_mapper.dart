import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

/// Storage codec between the study-session enums/entity and their `study_sessions`
/// row representation (snake_case TEXT tokens; `docs/contracts/types-catalog.md`
/// §EntryType/§StudyType/§SessionStatus, `docs/database/schema-contract.md`).
class StudySessionMapper {
  const StudySessionMapper();

  String entryTypeToken(EntryType type) => switch (type) {
    EntryType.deck => 'deck',
    EntryType.folder => 'folder',
    EntryType.today => 'today',
  };

  EntryType entryTypeFromToken(String token) => switch (token) {
    'deck' => EntryType.deck,
    'folder' => EntryType.folder,
    'today' => EntryType.today,
    _ => throw ArgumentError.value(token, 'entry_type', 'unknown entry type'),
  };

  // Storage tokens per `docs/contracts/types-catalog.md` §StudyType:
  // snake_case `new_cards` / `srs_review`.
  String studyTypeToken(StudyType type) => switch (type) {
    StudyType.newCards => 'new_cards',
    StudyType.srsReview => 'srs_review',
  };

  StudyType studyTypeFromToken(String token) => switch (token) {
    'new_cards' => StudyType.newCards,
    'srs_review' => StudyType.srsReview,
    _ => throw ArgumentError.value(token, 'study_type', 'unknown study type'),
  };

  String statusToken(SessionStatus status) => switch (status) {
    SessionStatus.draft => 'draft',
    SessionStatus.inProgress => 'in_progress',
    SessionStatus.completed => 'completed',
    SessionStatus.cancelled => 'cancelled',
    SessionStatus.failedToFinalize => 'failed_to_finalize',
  };

  SessionStatus statusFromToken(String token) => switch (token) {
    'draft' => SessionStatus.draft,
    'in_progress' => SessionStatus.inProgress,
    'completed' => SessionStatus.completed,
    'cancelled' => SessionStatus.cancelled,
    'failed_to_finalize' => SessionStatus.failedToFinalize,
    _ => throw ArgumentError.value(token, 'status', 'unknown session status'),
  };

  /// Maps a persisted `study_sessions` row to the domain entity.
  StudySession toEntity(StudySessionRow row) => StudySession(
    id: row.id,
    scope: StudyScope(
      entryType: entryTypeFromToken(row.entryType),
      entryRefId: row.entryRefId,
      studyType: studyTypeFromToken(row.studyType),
    ),
    status: statusFromToken(row.status),
    startedAt: DateTime.fromMillisecondsSinceEpoch(row.startedAt, isUtc: true),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt, isUtc: true),
  );

  /// Maps a joined `study_session_items` + `flashcards` row pair to a review
  /// item (WBS 4.3.1).
  StudySessionReviewItem toReviewItem(
    StudySessionItemRow item,
    FlashcardRow card,
  ) => StudySessionReviewItem(
    sessionItemId: item.id,
    flashcardId: card.id,
    front: card.front,
    back: card.back,
    exampleSentence: card.exampleSentence,
    pronunciation: card.pronunciation,
    hint: card.hint,
    sortOrder: item.sortOrder,
    answeredAt: item.answeredAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(item.answeredAt!, isUtc: true),
  );
}
