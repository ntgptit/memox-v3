import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';

/// Port for global-search reads (WBS 3.5.1). `SearchRepositoryImpl` (data
/// layer) implements it over the LIKE-based Drift queries.
///
/// The use case normalizes + length-checks the query and applies ranking/caps;
/// the repository only escapes LIKE wildcards (`%`, `_`, `\`) and returns the
/// raw matching rows per section. Result/error style uses the project's current
/// record-based [Result] (not `Either`/`fpdart`). On a read error each method
/// returns `StorageFailure(read)`. See
/// `docs/contracts/usecase-contracts/search.md`.
abstract interface class SearchRepository {
  /// Folders whose name matches [normalizedQuery] (case-insensitive substring).
  Future<Result<List<Folder>>> searchFolders(String normalizedQuery);

  /// Decks whose name matches [normalizedQuery].
  Future<Result<List<Deck>>> searchDecks(String normalizedQuery);

  /// Flashcards whose front or back matches [normalizedQuery].
  Future<Result<List<Flashcard>>> searchFlashcards(String normalizedQuery);
}
