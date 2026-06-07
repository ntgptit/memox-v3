import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/folder_detail.dart';

/// Full flashcard editor read model.
///
/// Carries the deck context for the breadcrumb, the editable flashcard
/// content, the normalized tag list, and the current learning progress snapshot
/// used by the edit-progress policy dialog.
class FlashcardDetail {
  const FlashcardDetail({
    required this.deck,
    required this.breadcrumb,
    required this.flashcard,
    required this.tags,
    required this.progress,
  });

  final Deck deck;
  final List<FolderBreadcrumbSegment> breadcrumb;
  final Flashcard flashcard;
  final List<String> tags;
  final FlashcardProgressSnapshot? progress;
}

/// Snapshot of a flashcard's local SRS progress.
class FlashcardProgressSnapshot {
  const FlashcardProgressSnapshot({
    required this.boxNumber,
    required this.dueAt,
    required this.buriedUntil,
    required this.isSuspended,
    required this.reviewCount,
    required this.lapseCount,
    required this.lastStudiedAt,
  });

  final int boxNumber;
  final DateTime? dueAt;
  final DateTime? buriedUntil;
  final bool isSuspended;
  final int reviewCount;
  final int lapseCount;
  final DateTime? lastStudiedAt;

  bool get isFresh =>
      boxNumber == 1 &&
      dueAt != null &&
      buriedUntil == null &&
      !isSuspended &&
      reviewCount == 0 &&
      lapseCount == 0 &&
      lastStudiedAt == null;
}
