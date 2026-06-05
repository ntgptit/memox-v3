import 'package:drift/drift.dart';

import 'package:memox/data/datasources/local/tables/flashcards.dart';

/// `flashcard_progress` table — one-to-one SRS scheduling per flashcard
/// (`docs/database/schema-contract.md`, `docs/business/srs/srs-review.md`,
/// `docs/business/study-actions/bury-suspend.md`).
///
/// A card is **due** when it is not suspended, not currently buried, and its
/// [dueAt] has passed. The eligibility index mirrors the schema contract's
/// `idx_flashcard_progress_eligibility`.
@DataClassName('FlashcardProgressRow')
class FlashcardProgress extends Table {
  @override
  String get tableName => 'flashcard_progress';

  TextColumn get flashcardId =>
      text().references(Flashcards, #id, onDelete: KeyAction.cascade)();

  /// Leitner box 1..8.
  IntColumn get boxNumber => integer().withDefault(const Constant(1))();

  /// Next review time, UTC epoch ms. `NULL` = brand-new, never scheduled.
  IntColumn get dueAt => integer().nullable()();

  /// Buried until this UTC epoch ms (`NULL` = not buried).
  IntColumn get buriedUntil => integer().nullable()();

  BoolColumn get isSuspended =>
      boolean().withDefault(const Constant(false))();

  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  IntColumn get lapseCount => integer().withDefault(const Constant(0))();

  /// Last study time, UTC epoch ms.
  IntColumn get lastStudiedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{flashcardId};
}
