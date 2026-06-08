import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/types/study_scope.dart';

part 'study_session_dao.g.dart';

@DriftAccessor(
  include: <String>{
    '../drift/study_sessions.drift',
    '../drift/study_session_items.drift',
    '../drift/study_attempts.drift',
    '../drift/study_scope_queries.drift',
  },
)
class StudySessionDao extends DatabaseAccessor<AppDatabase>
    with _$StudySessionDaoMixin {
  StudySessionDao(super.db);

  Future<StudySessionRow?> findSession(String id) => (select(
    studySessions,
  )..where((StudySessions row) => row.id.equals(id))).getSingleOrNull();

  Future<List<StudySessionReviewItemsResult>> loadSessionReviewItems(
    String sessionId,
  ) => studySessionReviewItems(sessionId).get();

  Future<FolderRow?> findFolder(String id) => (select(
    folders,
  )..where((Folders row) => row.id.equals(id))).getSingleOrNull();

  Future<DeckRow?> findDeck(String id) => (select(
    decks,
  )..where((Decks row) => row.id.equals(id))).getSingleOrNull();

  Future<StudySessionRow?> findResumableSession({
    required StudyScope scope,
    required int nowMs,
  }) =>
      (select(studySessions)
            ..where(
              (StudySessions row) =>
                  row.entryType.equals(scope.entryType.name) &
                  (scope.entryRefId == null
                      ? row.entryRefId.isNull()
                      : row.entryRefId.equals(scope.entryRefId!)) &
                  row.status.isIn(const <String>['draft', 'in_progress']) &
                  row.startedAt.isBiggerThanValue(
                    nowMs - const Duration(days: 30).inMilliseconds,
                  ),
            )
            ..orderBy(<OrderingTerm Function(StudySessions)>[
              (StudySessions row) => OrderingTerm(
                expression: row.startedAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<List<StudyDeckCardsResult>> loadDeckCards(String deckId) =>
      studyDeckCards(deckId).get();

  Future<List<StudyFolderCardsResult>> loadFolderCards(String folderId) =>
      studyFolderCards(folderId).get();

  Future<List<StudyTodayCardsResult>> loadTodayCards() =>
      studyTodayCards().get();

  Future<void> insertStudySession(StudySessionsCompanion session) =>
      into(studySessions).insert(session);

  Future<void> insertStudySessionItem(StudySessionItemsCompanion item) =>
      into(studySessionItems).insert(item);

  Future<void> insertStudyAttempt(StudyAttemptsCompanion attempt) =>
      into(studyAttempts).insert(attempt);
}
