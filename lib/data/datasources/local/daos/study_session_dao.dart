import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Thin accessor for the study-persistence tables (ENABLER — WBS 4.0.1).
///
/// No business logic here (`docs/database/drift-guide.md`): only single-table
/// persistence primitives over `study_sessions` / `study_session_items` /
/// `study_attempts`, plus the stale-session retention sweep. Scope resolution,
/// queue batching, grading, and the SRS box transition live in the study use
/// cases / repository (WBS 4.1.x+). The use case owns the clock — callers pass
/// the cutoff in. These are single-table query-builder operations, so the DAO
/// wraps [AppDatabase] directly instead of declaring `.drift` queries.
class StudySessionDao {
  StudySessionDao(this._db);

  final AppDatabase _db;

  /// Storage tokens for the resumable session statuses (snake_case; see
  /// `docs/contracts/types-catalog.md` §SessionStatus). Kept here as the only
  /// statuses the retention sweep touches; the full state machine + enum/mapper
  /// land with the session lifecycle use cases (WBS 4.2.x).
  static const String statusDraft = 'draft';
  static const String statusInProgress = 'in_progress';
  static const String statusCancelled = 'cancelled';

  /// Inserts a session header row.
  Future<void> insertSession(StudySessionsCompanion session) =>
      _db.into(_db.studySessions).insert(session);

  /// Atomically inserts a session header plus its ordered item rows in one
  /// transaction (`docs/contracts/repository-contracts/study-repository.md`
  /// §Transaction requirements). Either all rows land or none do.
  Future<void> createSessionWithItems(
    StudySessionsCompanion session,
    List<StudySessionItemsCompanion> items,
  ) => _db.transaction(() async {
    await _db.into(_db.studySessions).insert(session);
    // The batch runs inside the outer transaction; an item FK violation throws
    // and rolls back the whole unit (session row included).
    await _db.batch((Batch batch) {
      batch.insertAll(_db.studySessionItems, items);
    });
  });

  /// The session header by [id], or `null` when absent.
  Future<StudySessionRow?> sessionById(String id) => (_db.select(
    _db.studySessions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Inserts a queued item row.
  Future<void> insertItem(StudySessionItemsCompanion item) =>
      _db.into(_db.studySessionItems).insert(item);

  /// The flashcards whose ids are in [ids] (single-table read; the repository
  /// pairs them back with the session items by id for the review screen,
  /// WBS 4.3.1). A single-table IN query rather than a builder join, which keeps
  /// the loosely-typed drift join API out of the data layer.
  Future<List<FlashcardRow>> flashcardsByIds(Iterable<String> ids) =>
      (_db.select(_db.flashcards)..where((t) => t.id.isIn(ids.toList()))).get();

  /// The items of [sessionId] in queue order.
  Future<List<StudySessionItemRow>> itemsForSession(String sessionId) =>
      (_db.select(_db.studySessionItems)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy(<OrderClauseGenerator<StudySessionItems>>[
              (t) => OrderingTerm(expression: t.sortOrder),
            ]))
          .get();

  /// Inserts an attempt row.
  Future<void> insertAttempt(StudyAttemptsCompanion attempt) =>
      _db.into(_db.studyAttempts).insert(attempt);

  /// The attempts recorded against [sessionItemId], oldest first.
  Future<List<StudyAttemptRow>> attemptsForItem(String sessionItemId) =>
      (_db.select(_db.studyAttempts)
            ..where((t) => t.sessionItemId.equals(sessionItemId))
            ..orderBy(<OrderClauseGenerator<StudyAttempts>>[
              (t) => OrderingTerm(expression: t.attemptedAt),
            ]))
          .get();

  /// Cancels every resumable (`draft`/`in_progress`) session whose `updated_at`
  /// is at or before [cutoff] (epoch ms). Returns the number of rows updated.
  /// Sessions are never hard-deleted — they move to `cancelled`.
  Future<int> cancelSessionsUpdatedBefore(int cutoff) =>
      (_db.update(_db.studySessions)..where(
            (t) =>
                t.updatedAt.isSmallerOrEqualValue(cutoff) &
                t.status.isIn(<String>[statusDraft, statusInProgress]),
          ))
          .write(const StudySessionsCompanion(status: Value(statusCancelled)));

  /// Marks the resumable session [id] `cancelled` (never deletes the row — see
  /// `docs/contracts/repository-contracts/study-repository.md` §Forbidden).
  /// Only `draft`/`in_progress` sessions transition (the allowed transitions per
  /// §Constraints); terminal sessions are left untouched. Recorded
  /// `study_attempts` / `study_session_items` are untouched. Returns the number
  /// of rows updated (0 when no such resumable session exists).
  Future<int> markCancelled(String id) =>
      (_db.update(_db.studySessions)..where(
            (t) =>
                t.id.equals(id) &
                t.status.isIn(<String>[statusDraft, statusInProgress]),
          ))
          .write(const StudySessionsCompanion(status: Value(statusCancelled)));
}
