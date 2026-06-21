import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'progress_dao.g.dart';

/// One due-deck row from the progress due-summary query (WBS 7.1.1).
typedef DeckDueCountRow = ({String deckId, String deckName, int dueCount});

/// One box row from the box-distribution query (WBS 7.2.1).
typedef BoxCountRow = ({int boxNumber, int cardCount});

/// Thin Drift accessor for the progress due-summary query (WBS 7.1.1).
///
/// No business logic here (`docs/database/drift-guide.md`): runs the single
/// grouped query from
/// `lib/data/datasources/local/drift/progress_queries.drift` and normalizes each
/// row. Suspended / currently-buried exclusion lives in the SQL; the repository
/// derives the global total and the use case owns the `now` clock.
@DriftAccessor(include: <String>{'../drift/progress_queries.drift'})
class ProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ProgressDaoMixin {
  ProgressDao(super.db);

  /// Per-deck due counts as of [now] (epoch ms), only decks with due cards,
  /// ordered by due count desc.
  Future<List<DeckDueCountRow>> dueCounts(int now) async {
    final List<DueCountsByDeckResult> rows = await dueCountsByDeck(now).get();
    return <DeckDueCountRow>[
      for (final DueCountsByDeckResult row in rows)
        (deckId: row.deckId, deckName: row.deckName, dueCount: row.dueCount),
    ];
  }

  /// Card counts grouped by Leitner box from `flashcard_progress` (raw rows; the
  /// repository validates the range and zero-fills 1..8).
  Future<List<BoxCountRow>> boxCounts() async {
    final List<BoxDistributionResult> rows = await boxDistribution().get();
    return <BoxCountRow>[
      for (final BoxDistributionResult row in rows)
        (boxNumber: row.boxNumber, cardCount: row.cardCount),
    ];
  }
}
