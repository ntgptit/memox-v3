import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'card_history_dao.g.dart';

/// The Card History header row (kit screen 09, WBS 7.6.1).
typedef CardHistoryHeaderRow = ({
  String front,
  int createdAt,
  String deckName,
  int boxNumber,
  int reviewCount,
  int lapseCount,
  int? lastResetAt,
});

/// One graded-attempt row from the Card History timeline query.
typedef CardHistoryAttemptRow = ({
  String result,
  String studyMode,
  int boxBefore,
  int boxAfter,
  int? durationMs,
  int attemptedAt,
});

/// One lifecycle-event row from `card_events`.
typedef CardHistoryEventRow = ({String type, int occurredAt, String? detail});

/// Thin Drift accessor for the Card History reads (WBS 7.6.1).
///
/// No business logic (`docs/database/drift-guide.md`): runs the queries from
/// `lib/data/datasources/local/drift/history_queries.drift` and normalizes each
/// row; the repository composes the header, computes accuracy from counters, and
/// merges the feed.
@DriftAccessor(include: <String>{'../drift/history_queries.drift'})
class CardHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$CardHistoryDaoMixin {
  CardHistoryDao(super.db);

  /// Header for [flashcardId], or null when the card does not exist.
  Future<CardHistoryHeaderRow?> header(String flashcardId) async {
    final CardHistoryHeaderResult? row = await cardHistoryHeader(
      flashcardId,
    ).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return (
      front: row.front,
      createdAt: row.createdAt,
      deckName: row.deckName,
      boxNumber: row.boxNumber,
      reviewCount: row.reviewCount,
      lapseCount: row.lapseCount,
      lastResetAt: row.lastResetAt,
    );
  }

  /// Mean measured attempt duration (ms), or null when none is logged.
  Future<double?> avgDuration(String flashcardId) =>
      cardHistoryAvgDuration(flashcardId).getSingle();

  /// All graded attempts for [flashcardId], newest first.
  Future<List<CardHistoryAttemptRow>> attempts(String flashcardId) async {
    final List<CardHistoryAttemptsResult> rows = await cardHistoryAttempts(
      flashcardId,
    ).get();
    return <CardHistoryAttemptRow>[
      for (final CardHistoryAttemptsResult r in rows)
        (
          result: r.result,
          studyMode: r.studyMode,
          boxBefore: r.boxBefore,
          boxAfter: r.boxAfter,
          durationMs: r.durationMs,
          attemptedAt: r.attemptedAt,
        ),
    ];
  }

  /// Lifecycle events for [flashcardId], newest first.
  Future<List<CardHistoryEventRow>> events(String flashcardId) async {
    final List<CardHistoryEventsResult> rows = await cardHistoryEvents(
      flashcardId,
    ).get();
    return <CardHistoryEventRow>[
      for (final CardHistoryEventsResult r in rows)
        (type: r.type, occurredAt: r.occurredAt, detail: r.detail),
    ];
  }
}
