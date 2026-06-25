import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';

part 'study_session_review.freezed.dart';

/// One queued card in a study session, joined with its flashcard content, as
/// loaded for the review screen (WBS 4.3.1). [answeredAt] is `null` until the
/// item receives a terminal attempt.
///
/// [targetLanguage] is the owning deck's declared front language (WBS 8.4.3 —
/// the per-card TTS gate, `docs/business/tts/tts-settings.md` §Deck-level
/// language gate). It rides on the read model so study playback never re-queries
/// the deck; a session that spans decks of different languages keeps each card's
/// own language. Defaults to [TargetLanguage.korean] (the `decks.target_language`
/// storage default) when a fixture omits it.
@freezed
sealed class StudySessionReviewItem with _$StudySessionReviewItem {
  const factory StudySessionReviewItem({
    required String sessionItemId,
    required FlashcardId flashcardId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    required int sortOrder,
    required DateTime? answeredAt,
    @Default(TargetLanguage.korean) TargetLanguage targetLanguage,
  }) = _StudySessionReviewItem;
  const StudySessionReviewItem._();

  /// Whether this item already has a terminal attempt.
  bool get isAnswered => answeredAt != null;
}

/// The loaded review payload for a session: its persisted header plus the
/// ordered, flashcard-joined items (`docs/contracts/usecase-contracts/study.md`
/// §LoadStudySessionReviewUseCase). The review controller resumes at
/// [firstUnansweredIndex] (or opens finish-ready when every item is answered).
@freezed
sealed class StudySessionReview with _$StudySessionReview {
  const factory StudySessionReview({
    required StudySession session,
    required List<StudySessionReviewItem> items,
  }) = _StudySessionReview;
  const StudySessionReview._();

  /// Total queued items.
  int get total => items.length;

  /// How many items already have a terminal attempt.
  int get answeredCount => items.where((i) => i.isAnswered).length;

  /// Whether every item is answered (the session is finish-ready on reload).
  bool get isComplete => items.isNotEmpty && answeredCount == total;

  /// Index of the first unanswered item, or `null` when all are answered.
  int? get firstUnansweredIndex {
    final int index = items.indexWhere((i) => !i.isAnswered);
    return index == -1 ? null : index;
  }
}
