/// Deck flashcard-list status selector (WBS 2.17.1).
///
/// The backend selector for the flashcard list read path; it is not a persisted
/// field. A card's state is derived from its `flashcard_progress` row at read
/// time (a card with no progress row is a new, active card):
///
/// - [all] — every card regardless of state (default).
/// - [active] — not suspended and not currently buried (an expired bury counts
///   as active).
/// - [due] — active and currently due (`due_at <= now`); future-due, suspended,
///   and currently-buried cards are excluded.
/// - [suspended] — suspended cards only.
/// - [buried] — currently-buried cards only (`buried_until > now`).
///
/// See `docs/contracts/types-catalog.md` §FlashcardStatusFilter and
/// `docs/business/study-actions/bury-suspend.md` §Filters (decision rows
/// C36/C37, BS8/BS9).
enum FlashcardStatusFilter { all, active, due, suspended, buried }
