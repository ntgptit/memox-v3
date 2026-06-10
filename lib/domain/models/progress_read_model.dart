import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/box_number.dart';
import 'package:memox/domain/types/ids.dart';

part 'progress_read_model.freezed.dart';

@freezed
abstract class DeckDueSummary with _$DeckDueSummary {
  const factory DeckDueSummary({
    required DeckId deckId,
    required String deckName,
    required FolderId parentFolderId,
    required int dueCount,
  }) = _DeckDueSummary;
}

@freezed
abstract class ProgressDueSummary with _$ProgressDueSummary {
  const factory ProgressDueSummary({
    required int totalDueCount,
    required List<DeckDueSummary> decks,
  }) = _ProgressDueSummary;
}

@freezed
abstract class BoxDistributionItem with _$BoxDistributionItem {
  const factory BoxDistributionItem({
    required BoxNumber boxNumber,
    required int cardCount,
  }) = _BoxDistributionItem;
}

@freezed
abstract class BoxDistribution with _$BoxDistribution {
  const factory BoxDistribution({required List<BoxDistributionItem> boxes}) =
      _BoxDistribution;
}

@freezed
abstract class StudyStatistics with _$StudyStatistics {
  const factory StudyStatistics({
    required int completedSessionCount,
    required int totalAttemptCount,
    required int correctCount,
    required int forgotCount,
    required DateTime? lastStudiedAt,
  }) = _StudyStatistics;
}

@freezed
abstract class ProgressReadModel with _$ProgressReadModel {
  const factory ProgressReadModel({
    required ProgressDueSummary dueSummary,
    required BoxDistribution boxDistribution,
    required StudyStatistics studyStatistics,
  }) = _ProgressReadModel;
}
