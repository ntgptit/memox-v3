import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';
import 'package:memox/domain/repositories/study_repository.dart';

void main() {
  // StudyRepositoryImpl skeleton (WBS 4.0.1): only the stale-session retention
  // sweep is implemented; the session lifecycle lands with WBS 4.1.x+. The
  // 30-day resume window comes from `StudyRepository.resumeWindow`
  // (`docs/contracts/repository-contracts/study-repository.md`).
  group('StudyRepositoryImpl.expireOldSessions', () {
    late AppDatabase db;
    late StudyRepositoryImpl repository;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = StudyRepositoryImpl(dao: StudySessionDao(db));
    });
    tearDown(() => db.close());

    Future<void> insertSession({
      required String id,
      required String status,
      required int updatedAt,
    }) async {
      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: id,
              entryType: 'today',
              studyType: 'srs_review',
              status: status,
              startedAt: updatedAt,
              updatedAt: updatedAt,
            ),
          );
    }

    test('cancels resumable sessions older than the 30-day window', () async {
      const int now = 1000 * 60 * 60 * 24 * 100; // day 100 in epoch ms
      final int stale = now - StudyRepository.resumeWindow.inMilliseconds - 1;
      final int fresh = now - StudyRepository.resumeWindow.inMilliseconds + 1;

      await insertSession(id: 'stale-draft', status: 'draft', updatedAt: stale);
      await insertSession(
        id: 'stale-active',
        status: 'in_progress',
        updatedAt: stale,
      );
      await insertSession(id: 'fresh', status: 'draft', updatedAt: fresh);
      // A terminal session is never resumable, so the sweep must not touch it
      // even though it is old.
      await insertSession(
        id: 'old-completed',
        status: 'completed',
        updatedAt: stale,
      );

      final result = await repository.expireOldSessions(now: now);

      expect(result.failure, isNull);
      expect(result.data, 2, reason: 'only the two stale resumable sessions');

      final List<StudySessionRow> rows = await db
          .select(db.studySessions)
          .get();
      final Map<String, String> byId = <String, String>{
        for (final StudySessionRow r in rows) r.id: r.status,
      };
      expect(byId['stale-draft'], 'cancelled');
      expect(byId['stale-active'], 'cancelled');
      expect(byId['fresh'], 'draft', reason: 'inside the window');
      expect(byId['old-completed'], 'completed', reason: 'not resumable');
    });

    test('returns 0 when the table is empty', () async {
      final result = await repository.expireOldSessions(now: 0);
      expect(result.failure, isNull);
      expect(result.data, 0);
    });
  });
}
