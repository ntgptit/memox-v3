import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/study_entry_dao.dart';
import 'package:memox/data/datasources/local/daos/study_scope_dao.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart';
import 'package:memox/domain/repositories/study_entry_repository.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

/// Drift-backed [StudyEntryRepository] (WBS 4.1.1).
///
/// Runs the per-scope count query and classifies it against the empty-scope
/// matrix (`docs/business/study/study-flow.md`; decision rows `S4`/`S4b`/`S4c`/
/// `S4d`/`S4e`/`S4j`/`S4f`/`S4g`). New study draws from every active, non-buried
/// card; SRS review draws only from due cards. Missing `flashcard_progress` rows
/// already count as new active cards in the query (decision row S23).
class StudyEntryRepositoryImpl implements StudyEntryRepository {
  const StudyEntryRepositoryImpl({
    required StudyEntryDao dao,
    required StudyScopeDao scopeDao,
  }) : _dao = dao,
       _scopeDao = scopeDao;

  final StudyEntryDao _dao;
  final StudyScopeDao _scopeDao;

  @override
  Future<Result<StudyEntryEligibility>> resolveEligibility({
    required StudyScope scope,
    required int now,
  }) async {
    final String? refId = scope.entryRefId;
    if (scope.entryType != EntryType.today &&
        (refId == null || refId.isEmpty)) {
      return (
        failure: Failure.validation(
          field: 'entryRefId',
          code: ValidationCode.empty,
          message:
              'A ${scope.entryType.name} study scope requires an entry id.',
        ),
        data: null,
      );
    }

    try {
      final StudyScopeCounts counts = switch (scope.entryType) {
        EntryType.deck => await _dao.deckCounts(refId!, now),
        EntryType.folder => await _dao.folderCounts(refId!, now),
        EntryType.today => await _dao.todayCounts(now),
      };
      return (failure: null, data: _classify(scope, counts));
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'flashcard_progress',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<List<FlashcardId>>> resolveEligibleCardIds({
    required StudyScope scope,
    required int now,
  }) async {
    final String? refId = scope.entryRefId;
    if (scope.entryType != EntryType.today &&
        (refId == null || refId.isEmpty)) {
      return (
        failure: Failure.validation(
          field: 'entryRefId',
          code: ValidationCode.empty,
          message:
              'A ${scope.entryType.name} study scope requires an entry id.',
        ),
        data: null,
      );
    }

    final bool isNew = scope.studyType == StudyType.newCards;
    try {
      final List<String> ids = switch (scope.entryType) {
        EntryType.deck =>
          isNew
              ? await _scopeDao.deckNewCardIds(deckId: refId!, now: now)
              : await _scopeDao.deckDueCardIds(deckId: refId!, now: now),
        EntryType.folder =>
          isNew
              ? await _scopeDao.folderNewCardIds(folderId: refId!, now: now)
              : await _scopeDao.folderDueCardIds(folderId: refId!, now: now),
        EntryType.today =>
          isNew
              ? await _scopeDao.todayNewCardIds(now: now)
              : await _scopeDao.todayDueCardIds(now: now),
      };
      // New study is trimmed to the remaining daily quota (WBS 4.5.10); review
      // study is returned in full.
      if (isNew) {
        return (failure: null, data: await _capByDailyNewLimit(ids, now));
      }
      return (failure: null, data: ids);
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'flashcard_progress',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  /// Trims the ordered new-card [ids] to the remaining daily quota
  /// (`StudyEntryRepository.dailyNewLimit` minus what has been consumed in the
  /// local day containing [now], WBS 4.5.10). The local-day window is computed in
  /// Dart (never a SQLite modifier) so the cap is timezone-stable.
  Future<List<FlashcardId>> _capByDailyNewLimit(
    List<FlashcardId> ids,
    int now,
  ) async {
    final DateTime local = DateTime.fromMillisecondsSinceEpoch(now).toLocal();
    final DateTime dayStart = DateTime(local.year, local.month, local.day);
    final int start = dayStart.millisecondsSinceEpoch;
    final int end = dayStart
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch;
    final int used = await _scopeDao.newCardsUsedInWindow(
      start: start,
      end: end,
    );
    final int remaining = (StudyEntryRepository.dailyNewLimit - used).clamp(
      0,
      ids.length,
    );
    return ids.take(remaining).toList();
  }

  /// Maps the scope counts to an eligibility outcome. Precedence: no cards →
  /// `*NoCards`/`noContent`; every card suspended/buried → `allSuspended`
  /// (all suspended) or `allBuried` (a non-suspended remainder, all buried);
  /// else eligible, or `*NoDueCards`/`allDone` for an SRS scope with nothing due.
  StudyEntryEligibility _classify(StudyScope scope, StudyScopeCounts c) {
    if (c.total == 0) {
      return StudyEntryEligibility(
        emptyReason: switch (scope.entryType) {
          EntryType.deck => StudyScopeEmptyReason.deckNoCards,
          EntryType.folder => StudyScopeEmptyReason.folderNoCards,
          EntryType.today => StudyScopeEmptyReason.todayNoContent,
        },
      );
    }

    if (c.activeNonBuried == 0) {
      return StudyEntryEligibility(
        emptyReason: c.suspended >= c.total
            ? StudyScopeEmptyReason.allSuspended
            : StudyScopeEmptyReason.allBuried,
      );
    }

    final int eligible = scope.studyType == StudyType.newCards
        ? c.activeNonBuried
        : c.dueEligible;
    if (eligible > 0) {
      return StudyEntryEligibility(eligibleCount: eligible);
    }

    // SRS review scope with active cards but none due now.
    return switch (scope.entryType) {
      EntryType.deck => StudyEntryEligibility(
        emptyReason: StudyScopeEmptyReason.deckNoDueCards,
        nextDueAt: c.nextDueAt,
      ),
      EntryType.folder => StudyEntryEligibility(
        emptyReason: StudyScopeEmptyReason.folderNoDueCards,
        nextDueAt: c.nextDueAt,
      ),
      EntryType.today => const StudyEntryEligibility(
        emptyReason: StudyScopeEmptyReason.todayAllDone,
      ),
    };
  }
}
