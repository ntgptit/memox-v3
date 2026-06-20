import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_entry_eligibility.freezed.dart';

/// Why a study scope cannot start a session — one row of the empty-scope matrix
/// (`docs/business/study/study-flow.md` §Empty scope matrix; decision rows
/// `S4`/`S4b`/`S4c`/`S4d`/`S4e`/`S4j`/`S4f`/`S4g`). The FE maps each reason to its
/// dedicated empty state + CTA (WBS 4.1.2); the BE only classifies (WBS 4.1.1).
enum StudyScopeEmptyReason {
  /// Deck has zero flashcards. (`studyEmpty_deck_noCards`, S4)
  deckNoCards,

  /// Deck (srs_review) has cards but none due now. (`studyEmpty_deck_noDueCards`, S4e)
  deckNoDueCards,

  /// Folder subtree has zero descendant flashcards. (`studyEmpty_folder_noCards`, S4b)
  folderNoCards,

  /// Folder (srs_review) subtree has cards but none due. (`studyEmpty_folder_noDueCards`, S4j)
  folderNoDueCards,

  /// Today (srs_review) has cards but none due. (`studyEmpty_today_allDone`, S4c)
  todayAllDone,

  /// Today (srs_review) but the user has zero flashcards at all. (`studyEmpty_today_noContent`, S4d)
  todayNoContent,

  /// Every eligible card in scope is buried for today. (`studyEmpty_allBuried`, S4f)
  allBuried,

  /// Every card in scope is suspended. (`studyEmpty_allSuspended`, S4g)
  allSuspended,
}

/// The outcome of resolving a study scope's eligibility (WBS 4.1.1).
///
/// Either there are eligible cards ([eligibleCount] > 0, [emptyReason] null) and
/// the gate may proceed to session creation (WBS 4.2.1), or [emptyReason] holds
/// the matrix branch to render. [nextDueAt] (epoch ms) is the earliest future
/// due time in scope, carried only for the `*_noDueCards` reasons to render
/// "Next due in {relativeTime}" (`null` when no future due exists).
@freezed
sealed class StudyEntryEligibility with _$StudyEntryEligibility {
  const factory StudyEntryEligibility({
    @Default(0) int eligibleCount,
    StudyScopeEmptyReason? emptyReason,
    int? nextDueAt,
  }) = _StudyEntryEligibility;
  const StudyEntryEligibility._();

  /// True when the scope has at least one eligible card and may start a session.
  bool get hasEligible => emptyReason == null && eligibleCount > 0;
}
