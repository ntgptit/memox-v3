import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/dashboard_dao.dart';
import 'package:memox/data/mappers/study_session_mapper.dart';
import 'package:memox/domain/models/dashboard_recent_deck.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/dashboard_summary.dart';
import 'package:memox/domain/repositories/dashboard_repository.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/study_scope.dart';

/// Drift-backed [DashboardRepository] (WBS 5.x — design redesign).
///
/// Maps the single summary row to [DashboardSummary]; read errors map to
/// `StorageFailure(read)`. No business logic here — the use case owns the clock.
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({
    required DashboardDao dao,
    StudySessionMapper mapper = const StudySessionMapper(),
  }) : _dao = dao,
       _mapper = mapper;

  final DashboardDao _dao;
  final StudySessionMapper _mapper;

  @override
  Future<Result<DashboardSummary>> loadSummary({required int now}) async {
    try {
      final row = await _dao.dueSummary(now);
      return (
        failure: null,
        data: DashboardSummary(
          cardsDue: row.cardsDue,
          decksWithDue: row.decksWithDue,
        ),
      );
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
  Future<Result<DashboardResumeSessionSummary?>> loadResumeSessionSummary({
    required int now,
  }) async {
    try {
      final int cutoff = now - StudyRepository.resumeWindow.inMilliseconds;
      final DashboardResumeSessionResult? row = await _dao.resumeSession(
        cutoff,
      );
      if (row == null) {
        return (failure: null, data: null);
      }
      return (
        failure: null,
        data: DashboardResumeSessionSummary(
          sessionId: row.id,
          scope: StudyScope(
            entryType: _mapper.entryTypeFromToken(row.entryType),
            entryRefId: row.entryRefId,
            studyType: _mapper.studyTypeFromToken(row.studyType),
          ),
          answeredCount: row.answeredItems,
          totalCount: row.totalItems,
          lastActiveAt: DateTime.fromMillisecondsSinceEpoch(
            row.updatedAt,
            isUtc: true,
          ),
          scopeName: row.scopeName,
        ),
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'study_sessions',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<int>> countDecks() async {
    try {
      return (failure: null, data: await _dao.deckCount());
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'decks',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<List<DashboardRecentDeck>>> loadRecentDecks({
    required int now,
    required int limit,
  }) async {
    try {
      final rows = await _dao.recentDecks(now, limit);
      return (
        failure: null,
        data: <DashboardRecentDeck>[
          for (final row in rows)
            DashboardRecentDeck(
              deckId: row.id,
              name: row.name,
              cardCount: row.cardCount,
              dueCount: row.dueCount,
              lastStudiedAt: DateTime.fromMillisecondsSinceEpoch(
                row.lastStudiedAt ?? 0,
                isUtc: true,
              ),
            ),
        ],
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'card_events',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }
}
