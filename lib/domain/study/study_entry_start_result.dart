import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'study_entry_start_result.freezed.dart';

/// Empty-scope variants surfaced by the Study Entry gate.
enum StudyEntryEmptyVariant {
  deckNoCards,
  deckNoDueCards,
  folderNoCards,
  folderNoDueCards,
  todayAllDone,
  todayNoContent,
  allBuried,
  allSuspended,
}

/// Empty-scope metadata used to render the gate's empty state copy.
@freezed
abstract class StudyEntryEmptyState with _$StudyEntryEmptyState {
  const factory StudyEntryEmptyState({
    required StudyEntryEmptyVariant variant,
    DateTime? nextDueAt,
  }) = _StudyEntryEmptyState;
}

/// Outcome of starting study from the gate.
@freezed
abstract class StudyEntryStartResult with _$StudyEntryStartResult {
  const factory StudyEntryStartResult.started({required SessionId sessionId}) =
      StudyEntryStartStarted;

  const factory StudyEntryStartResult.empty({
    required StudyEntryEmptyState emptyState,
  }) = StudyEntryStartEmpty;
}
