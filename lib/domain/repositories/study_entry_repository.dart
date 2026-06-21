import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_scope.dart';

/// Read port for study entry eligibility (WBS 4.1.1).
///
/// Resolves whether a [StudyScope] can start a session and, when it cannot, the
/// empty-scope matrix branch to render (`docs/business/study/study-flow.md`
/// §Empty scope matrix). Card-list loading + batching live in session creation
/// (WBS 4.2.1); this port only classifies the scope's counts.
abstract interface class StudyEntryRepository {
  /// The per-local-day new-card study cap (WBS 4.5.10). New-card eligibility is
  /// reduced by the quota already consumed today; `srs_review` is unaffected.
  /// Aliases [LearningSettings.defaultDailyNewLimit] (the single source of truth
  /// for the default) so the two cannot diverge; the settings-backed per-user
  /// override is deferred (`docs/business/study/study-flow.md` §Rules).
  static const int dailyNewLimit = LearningSettings.defaultDailyNewLimit;

  /// Classifies [scope] as of [now] (epoch ms). Returns a
  /// [StudyEntryEligibility] (eligible count or an empty reason). A `deck`/
  /// `folder` scope with a `null` `entryRefId` is a `ValidationFailure`; a read
  /// error maps to a `StorageFailure`.
  Future<Result<StudyEntryEligibility>> resolveEligibility({
    required StudyScope scope,
    required int now,
  });

  /// Resolves the ordered eligible flashcard ids for [scope] as of [now] (epoch
  /// ms) — the queue the session-creation flow draws from (WBS 4.11.1). Suspended
  /// and currently-buried cards are excluded, mirroring [resolveEligibility]'s
  /// counts so the count and the resolved queue agree
  /// (`docs/business/study-actions/bury-suspend.md`). Ordering: due-date for
  /// `srs_review`, sort-order for `new_cards`
  /// (`docs/business/study/study-flow.md` §Rules). The `maxSessionItems` cap is
  /// applied by the caller (WBS 4.2.4). A `deck`/`folder` scope with a `null`
  /// `entryRefId` is a `ValidationFailure`; a read error maps to a
  /// `StorageFailure`.
  Future<Result<List<FlashcardId>>> resolveEligibleCardIds({
    required StudyScope scope,
    required int now,
  });
}
