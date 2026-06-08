import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'study_session_item.freezed.dart';

/// A flashcard queued inside a study session.
@freezed
abstract class StudySessionItem with _$StudySessionItem {
  const factory StudySessionItem({
    required String id,
    required SessionId sessionId,
    required FlashcardId flashcardId,
    required int sortOrder,
    DateTime? answeredAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StudySessionItem;
}
