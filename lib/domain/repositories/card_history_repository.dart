import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/types/ids.dart';

/// Read port for per-card history (kit screen 09; WBS 7.6.1).
///
/// V1 exposes a single full-load read (per-card scale is small — no pagination,
/// per `docs/business/history/card-history.md`). The `Either` shape in the
/// contract is the target architecture; this uses the repository `Result<T>`
/// pattern.
abstract interface class CardHistoryRepository {
  /// Loads the Card History read model for [flashcardId]: the header (preview +
  /// SRS snapshot + lifetime counters + average duration) plus the merged
  /// activity feed (graded attempts + lifecycle events, newest first). The feed
  /// always ends with a synthesized `created` event from the card's `created_at`.
  /// A missing card maps to a `NotFoundFailure`; a read error to a
  /// `StorageFailure` (decision rows H1/H4/H7).
  Future<Result<CardHistory>> loadCardHistory({
    required FlashcardId flashcardId,
  });
}
