import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/dashboard_dao.dart';
import 'package:memox/data/repositories/dashboard_repository_impl.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_type.dart';

void main() {
  // DashboardRepositoryImpl.loadResumeSessionSummary (WBS 5.1.1): the most
  // recently active resumable session (any scope) within the 30-day window,
  // with answered/total progress (docs/business/resume/resume-session.md).
  group('DashboardRepositoryImpl.loadResumeSessionSummary', () {
    late AppDatabase db;
    late DashboardRepositoryImpl repository;

    const int now = 1000 * 60 * 60 * 24 * 100;
    final int window = StudyRepository.resumeWindow.inMilliseconds;

    setUp(() async {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = DashboardRepositoryImpl(dao: DashboardDao(db));
      // A deck for the items' flashcards to reference (FK satisfied).
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'f1',
              name: 'f1',
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'f1',
              name: 'd1',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
    tearDown(() => db.close());

    Future<void> insertSession({
      required String id,
      String entryType = 'deck',
      String? entryRefId = 'd1',
      String studyType = 'new_cards',
      String status = 'in_progress',
      required int updatedAt,
    }) => db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: id,
            entryType: entryType,
            studyType: studyType,
            status: status,
            startedAt: updatedAt,
            updatedAt: updatedAt,
            entryRefId: Value<String?>(entryRefId),
          ),
        );

    Future<void> insertItem(
      String id,
      String sessionId, {
      int? answeredAt,
    }) async {
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'c-$id',
              deckId: 'd1',
              front: id,
              back: id,
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.studySessionItems)
          .insert(
            StudySessionItemsCompanion.insert(
              id: id,
              sessionId: sessionId,
              flashcardId: 'c-$id',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
              answeredAt: Value<int?>(answeredAt),
            ),
          );
    }

    test(
      'returns the most recent resumable session with its progress',
      () async {
        await insertSession(id: 'old', updatedAt: now - 5000);
        await insertSession(
          id: 'new',
          entryType: 'today',
          entryRefId: null,
          studyType: 'srs_review',
          updatedAt: now - 1000,
        );
        await insertItem('a', 'new', answeredAt: now);
        await insertItem('b', 'new');
        await insertItem('c', 'new');

        final result = await repository.loadResumeSessionSummary(now: now);

        expect(result.failure, isNull);
        final summary = result.data!;
        expect(summary.sessionId, 'new');
        expect(summary.scope.entryType, EntryType.today);
        expect(summary.scope.entryRefId, isNull);
        expect(summary.scope.studyType, StudyType.srsReview);
        expect(summary.totalCount, 3);
        expect(summary.answeredCount, 1);
        expect(summary.progress, closeTo(1 / 3, 1e-9));
        expect(summary.lastActiveAt.millisecondsSinceEpoch, now - 1000);
      },
    );

    test('returns null when there is no resumable session', () async {
      final result = await repository.loadResumeSessionSummary(now: now);
      expect(result.failure, isNull);
      expect(result.data, isNull);
    });

    test('excludes terminal sessions', () async {
      await insertSession(id: 'done', status: 'completed', updatedAt: now);
      final result = await repository.loadResumeSessionSummary(now: now);
      expect(result.data, isNull);
    });

    test('excludes sessions older than the 30-day window', () async {
      await insertSession(id: 'stale', updatedAt: now - window - 1);
      final result = await repository.loadResumeSessionSummary(now: now);
      expect(result.data, isNull);
    });

    test('reports a session with no items as zero progress', () async {
      await insertSession(id: 'empty', updatedAt: now);
      final result = await repository.loadResumeSessionSummary(now: now);
      expect(result.data?.totalCount, 0);
      expect(result.data?.progress, 0);
    });
  });

  // DashboardRepositoryImpl.loadSummary (WBS 5.x / 3.7.1): the due-card count
  // applies the F13 active-eligibility exclusion — suspended and currently-buried
  // cards are excluded, an expired bury still counts as due
  // (docs/business/study-actions/bury-suspend.md §238: all due-count surfaces).
  group('DashboardRepositoryImpl.loadSummary due exclusion', () {
    late AppDatabase db;
    late DashboardRepositoryImpl repository;
    const int now = 1000 * 60 * 60 * 24 * 100;
    int seq = 0;

    setUp(() async {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = DashboardRepositoryImpl(dao: DashboardDao(db));
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'f1',
              name: 'f1',
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'f1',
              name: 'd1',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
    tearDown(() => db.close());

    Future<void> addCard({
      int? dueAt,
      bool suspended = false,
      int? buriedUntil,
    }) async {
      final String id = 'card-${seq++}';
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: id,
              deckId: 'd1',
              front: id,
              back: id,
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: id,
              dueAt: Value<int?>(dueAt),
              isSuspended: Value<bool>(suspended),
              buriedUntil: Value<int?>(buriedUntil),
            ),
          );
    }

    test(
      'excludes suspended and currently-buried cards from cardsDue',
      () async {
        await addCard(dueAt: now - 1); // active due
        await addCard(dueAt: now - 1, suspended: true); // suspended → excluded
        await addCard(
          dueAt: now - 1,
          buriedUntil: now + 5000,
        ); // buried → excluded
        await addCard(
          dueAt: now - 1,
          buriedUntil: now - 1,
        ); // expired bury → due
        await addCard(); // NEW (due_at NULL) → not due

        final result = await repository.loadSummary(now: now);

        expect(result.failure, isNull);
        expect(result.data!.cardsDue, 2); // active due + expired-bury due
      },
    );
  });
}
