import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_duplicate_check_result.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/ids.dart';

/// Port for flashcard persistence. Use cases depend on this interface;
/// `FlashcardRepositoryImpl` (data layer) implements it.
///
/// Result/error style uses the project's current record-based [Result] (not
/// `Either`/`fpdart` — see the target-architecture note in
/// `docs/contracts/repository-contracts/flashcard-repository.md`). The
/// list-watch stream emits the read model wrapped in a [Result] so the UI can
/// surface a missing-deck `NotFoundFailure` as an error state.
///
/// A flashcard owns a 1:1 `flashcard_progress` row and 0..N `flashcard_tags`
/// rows; create/delete keep them consistent in one transaction. Validation
/// (front/back required-after-trim, tag normalization) lives behind these
/// methods, never in the UI — `docs/business/flashcard/flashcard-management.md`.
///
/// V1 scope (WBS 2.11.1 / 2.12.1 / 2.13.1 / 2.14.1 / 3.4.1): create, update,
/// delete, reorder, and a deck-scoped list-watch with optional front/back search.
/// `move`, bulk operations, status/tag filtering, and `CardState` remain Future
/// (block on the bury/suspend + bulk epics) — see
/// `docs/contracts/repository-contracts/flashcard-repository.md`.
abstract interface class FlashcardRepository {
  /// Watch the flashcard-list read model for [deckId]: deck + folder breadcrumb
  /// + cards (in `sort_order`) + the deck's full [FlashcardListDetail.totalCount].
  ///
  /// When [searchTerm] is non-blank, [FlashcardListDetail.cards] is filtered to
  /// cards whose front or back contains the trimmed, case-insensitive term;
  /// `totalCount` always reflects the full deck total. Emits a
  /// [NotFoundFailure] result when the deck does not exist (e.g. just deleted).
  /// [sort] is reserved for the Future sort control; V1 only honors
  /// [ContentSortMode.manual].
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    DeckId deckId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
  });

  /// Create a flashcard in [deckId] with the initial `flashcard_progress` row
  /// and any `flashcard_tags` — one transaction.
  ///
  /// Trims [front]/[back] and rejects either empty
  /// ([ValidationCode.empty]); trims the optional notes and stores `null` when
  /// blank; normalizes [tags] (trim, lowercase, dedupe case-insensitively,
  /// reject blanks). Rejects a missing deck ([NotFoundFailure]). The card is
  /// appended at the end of the deck's `sort_order`. Decision rows C1, C2, C3,
  /// C8 (`docs/decision-tables/flashcard.md`).
  Future<Result<Flashcard>> createFlashcard({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  });

  /// Update [flashcardId]'s content and tags, optionally resetting its
  /// `flashcard_progress` when [progressPolicy] is
  /// [FlashcardProgressEditPolicy.resetProgress] — one transaction.
  ///
  /// Same validation/normalization as create. The tag list replaces the card's
  /// current tags. Rejects a missing card ([NotFoundFailure]). Decision row C5.
  Future<Result<Flashcard>> updateFlashcard({
    required FlashcardId flashcardId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
    FlashcardProgressEditPolicy progressPolicy =
        FlashcardProgressEditPolicy.keepProgress,
  });

  /// Delete [flashcardId] and its dependent `flashcard_progress` + `flashcard_tags`
  /// rows (cascade via FK) in one transaction. Rejects a missing card
  /// ([NotFoundFailure]). Decision rows C6, C27.
  Future<Result<void>> deleteFlashcard({required FlashcardId flashcardId});

  /// Persist a manual card order: [orderedIds] must be the full set of cards in
  /// [deckId]. Writes `sort_order` by list position in one transaction.
  ///
  /// Rejects ([ValidationCode.invalidFormat], preserving the previous order)
  /// when [orderedIds] has duplicates or does not match the deck's card set
  /// exactly (missing, extra, cross-deck or partial). Decision rows C33, C34.
  Future<Result<void>> reorderFlashcards({
    required DeckId deckId,
    required List<FlashcardId> orderedIds,
  });

  /// Non-blocking manual duplicate **soft-warning** check (WBS 2.20.1): is there
  /// an existing card in [deckId] whose trimmed, case-insensitive `front` +
  /// `back` matches [front] + [back]? [excludeId] skips the card itself on edit.
  /// Never rejects a save — returns a [FlashcardDuplicateCheckResult] for the
  /// editor's "save anyway?" flow. Decision row C40.
  Future<Result<FlashcardDuplicateCheckResult>> checkManualDuplicate({
    required DeckId deckId,
    required String front,
    required String back,
    FlashcardId? excludeId,
  });
}
