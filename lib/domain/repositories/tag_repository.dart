import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:memox/domain/models/tag_with_count.dart';

/// Port for tag-management persistence over `flashcard_tags`. Use cases depend
/// on this interface; `TagRepositoryImpl` (data layer) implements it.
///
/// Tags are global (cross-deck), stored lowercased + trimmed. Validation (no
/// comma, ≤50 chars) happens in the domain layer (`TagValidator`) before these
/// methods; the repository assumes pre-normalized input. See
/// `docs/contracts/repository-contracts/tag-repository.md`.
///
/// > V1 scope (WBS 8.3.1): the Tag-Management surface — distinct list + counts
/// > and transactional rename/merge/delete. Per-card add/remove tag is owned by
/// > the flashcard editor (`FlashcardRepository`); deck-scoped tag reads and
/// > study-by-tag land with their own WBS rows.
abstract interface class TagRepository {
  /// All distinct tags with their card counts, as a live stream, ordered by
  /// count (desc) then name. Drives the Tag-Management list (the screen filters
  /// it for search).
  Stream<List<TagWithCount>> watchAllWithCount();

  /// Whether a tag equal to [normalizedName] (case-insensitive) already exists.
  /// Used by rename to detect a collision before writing.
  Future<Result<bool>> existsCaseInsensitive(String normalizedName);

  /// Rename [normalizedOldName] to [normalizedNewName] across every card in one
  /// transaction. No-op when the two are equal. Rejects with [ConflictFailure]
  /// when [normalizedNewName] already exists as another tag (caller decides
  /// whether to merge). Decision row TG5.
  Future<Result<void>> rename({
    required String normalizedOldName,
    required String normalizedNewName,
  });

  /// Merge [normalizedSource] into [normalizedDestination] in one transaction:
  /// every card tagged with the source becomes tagged with the destination
  /// (de-duplicated when it already had it), then the source rows are removed.
  /// Returns the affected-card count. Decision row TG6.
  Future<Result<MergeResult>> merge({
    required String normalizedSource,
    required String normalizedDestination,
  });

  /// Delete [normalizedName] from every card (the cards themselves are NOT
  /// deleted). Returns the number of cards that carried the tag. Decision row
  /// TG7.
  Future<Result<int>> delete(String normalizedName);
}
