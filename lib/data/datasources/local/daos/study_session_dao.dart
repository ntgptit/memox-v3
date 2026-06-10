import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/study/study_session_limits.dart';
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

  Future<StudySessionRow?> findLatestResumableSession({required int nowMs}) =>
      (select(studySessions)
            ..where(
              (StudySessions row) =>
                  row.status.isIn(const <String>['draft', 'in_progress']) &
                  row.updatedAt.isBiggerThanValue(
                    nowMs -
                        const Duration(
                          days: resumableSessionExpiryDays,
                        ).inMilliseconds,
                  ),
            )
            ..orderBy(<OrderingTerm Function(StudySessions)>[
              (StudySessions row) => OrderingTerm(
                expression: row.updatedAt,
                mode: OrderingMode.desc,
              ),
              (StudySessions row) => OrderingTerm(
                expression: row.startedAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<List<StudySessionReviewItemsResult>> loadSessionReviewItems(
    String sessionId,
  ) => studySessionReviewItems(sessionId).get();

  Future<List<StudySessionAttemptsResult>> loadSessionAttempts(
    String sessionId,
  ) => studySessionAttempts(sessionId).get();

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
                  row.updatedAt.isBiggerThanValue(
                    nowMs -
                        const Duration(
                          days: resumableSessionExpiryDays,
                        ).inMilliseconds,
                  ),
            )
            ..orderBy(<OrderingTerm Function(StudySessions)>[
              (StudySessions row) => OrderingTerm(
                expression: row.updatedAt,
                mode: OrderingMode.desc,
              ),
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

  Future<void> insertFlashcardProgress(FlashcardProgressCompanion progress) =>
      into(attachedDatabase.flashcardProgress).insert(progress);

  Future<int> markStudySessionItemAnswered({
    required String sessionItemId,
    required int answeredAtMs,
    required int updatedAtMs,
  }) =>
      (update(
        studySessionItems,
      )..where((StudySessionItems row) => row.id.equals(sessionItemId))).write(
        StudySessionItemsCompanion(
          answeredAt: Value<int?>(answeredAtMs),
          updatedAt: Value<int>(updatedAtMs),
        ),
      );

  Future<int> updateFlashcardProgress({
    required String flashcardId,
    required int boxNumber,
    required int dueAtMs,
    required int reviewCount,
    required int lapseCount,
    required int lastStudiedAtMs,
  }) =>
      (update(attachedDatabase.flashcardProgress)..where(
            (FlashcardProgress row) => row.flashcardId.equals(flashcardId),
          ))
          .write(
            FlashcardProgressCompanion(
              boxNumber: Value<int>(boxNumber),
              dueAt: Value<int?>(dueAtMs),
              reviewCount: Value<int>(reviewCount),
              lapseCount: Value<int>(lapseCount),
              lastStudiedAt: Value<int?>(lastStudiedAtMs),
            ),
          );

  Future<int> updateStudySessionStatus({
    required String sessionId,
    required String status,
    required int updatedAtMs,
  }) =>
      (update(
        studySessions,
      )..where((StudySessions row) => row.id.equals(sessionId))).write(
        StudySessionsCompanion(
          status: Value<String>(status),
          updatedAt: Value<int>(updatedAtMs),
        ),
      );

  Future<int> touchStudySession({
    required String sessionId,
    required int updatedAtMs,
  }) =>
      (update(studySessions)
            ..where((StudySessions row) => row.id.equals(sessionId)))
          .write(StudySessionsCompanion(updatedAt: Value<int>(updatedAtMs)));

  Future<FlashcardProgressRow?> findFlashcardProgress(String flashcardId) =>
      (select(attachedDatabase.flashcardProgress)..where(
            (FlashcardProgress row) => row.flashcardId.equals(flashcardId),
          ))
          .getSingleOrNull();

  Future<int> cancelStudySession({
    required String sessionId,
    required int updatedAtMs,
  }) =>
      (update(
        studySessions,
      )..where((StudySessions row) => row.id.equals(sessionId))).write(
        StudySessionsCompanion(
          status: const Value<String>('cancelled'),
          updatedAt: Value<int>(updatedAtMs),
        ),
      );
}
