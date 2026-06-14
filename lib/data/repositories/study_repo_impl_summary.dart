part of 'study_repo_impl.dart';

Future<Result<DashboardResumeSessionSummary?>>
_findLatestResumableSessionSummary(
  study_dao.StudySessionDao dao,
  int nowMs,
) async {
  try {
    final StudySessionRow? sessionRow = await dao.findLatestResumableSession(
      nowMs: nowMs,
    );
    if (sessionRow == null) {
      return const Result<DashboardResumeSessionSummary?>.ok(null);
    }

    final List<study_dao.StudySessionReviewItemsResult> itemRows = await dao
        .loadSessionReviewItems(sessionRow.id);
    if (itemRows.isEmpty) {
      return const Result<DashboardResumeSessionSummary?>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: 'Study session has no items.',
          table: 'study_session_items',
        ),
      );
    }

    final String? scopeLabel = await _resolveResumableScopeLabel(
      sessionRow,
      dao,
    );
    final StudySessionReview review = StudySessionReview(
      session: StudyMapper.fromSessionRow(sessionRow),
      items: itemRows.map(_fromSessionReviewRow).toList(growable: false),
    );
    final int answeredCount = review.items
        .where(
          (StudySessionReviewItem item) => item.sessionItem.answeredAt != null,
        )
        .length;

    return Result<DashboardResumeSessionSummary?>.ok(
      DashboardResumeSessionSummary(
        session: review.session,
        answeredCount: answeredCount,
        totalCount: review.items.length,
        scopeLabel: scopeLabel,
      ),
    );
  } catch (error) {
    return Result<DashboardResumeSessionSummary?>.err(
      Failure.storage(
        operation: StorageOp.read,
        cause: error.toString(),
        table: 'study_sessions',
      ),
    );
  }
}

Future<Result<StudySession?>> _findResumableSession(
  study_dao.StudySessionDao dao,
  int nowMs,
  StudyScope scope,
) async {
  try {
    final StudySessionRow? row = await dao.findResumableSession(
      scope: scope,
      nowMs: nowMs,
    );
    return Result<StudySession?>.ok(
      row == null ? null : StudyMapper.fromSessionRow(row),
    );
  } catch (error) {
    return Result<StudySession?>.err(
      Failure.storage(
        operation: StorageOp.read,
        cause: error.toString(),
        table: 'study_sessions',
      ),
    );
  }
}

Future<Result<void>> _cancelStudySession(
  study_dao.StudySessionDao dao,
  int nowMs,
  SessionId sessionId,
) async {
  try {
    final int updatedRows = await dao.cancelStudySession(
      sessionId: sessionId,
      updatedAtMs: nowMs,
    );
    if (updatedRows == 0) {
      return Result<void>.err(
        Failure.notFound(entity: 'study_session', id: sessionId),
      );
    }
    return const Result<void>.ok(null);
  } catch (error) {
    return Result<void>.err(
      Failure.storage(
        operation: StorageOp.write,
        cause: error.toString(),
        table: 'study_sessions',
      ),
    );
  }
}
