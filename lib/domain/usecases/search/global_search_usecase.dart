import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/domain/repositories/search_repository.dart';

/// Global search across folders, decks, and flashcards (WBS 3.5.1).
///
/// Contract: `docs/contracts/usecase-contracts/search.md`,
/// `docs/business/search/global-search.md`. Decision rows SR1-SR7.
///
/// Failures: `ValidationFailure(query, tooShort)`, `StorageFailure(read)`.
class GlobalSearchUseCase {
  const GlobalSearchUseCase({required this.repository});

  final SearchRepository repository;

  /// Minimum normalized query length before the repository is queried (SR1).
  static const int minQueryLength = 2;

  /// Per-section result cap; the read model still reports the un-capped total
  /// for the "+N more" affordance (SR6).
  static const int sectionCap = 5;

  Future<Result<SearchResults>> call({required String query}) async {
    final String normalized = StringUtils.normalizeQuery(query);

    // SR1: reject below the minimum length — the repository is never called.
    if (normalized.length < minQueryLength) {
      return (
        failure: const Failure.validation(
          field: 'query',
          code: ValidationCode.tooShort,
        ),
        data: null,
      );
    }

    // Run the three section queries (the repository escapes LIKE wildcards).
    final Result<List<Folder>> folderResult = await repository.searchFolders(
      normalized,
    );
    if (folderResult.isFailure) {
      return (failure: folderResult.failure, data: null);
    }
    final Result<List<Deck>> deckResult = await repository.searchDecks(
      normalized,
    );
    if (deckResult.isFailure) {
      return (failure: deckResult.failure, data: null);
    }
    final Result<List<Flashcard>> flashcardResult = await repository
        .searchFlashcards(normalized);
    if (flashcardResult.isFailure) {
      return (failure: flashcardResult.failure, data: null);
    }

    final List<Folder> folders = _rankFolders(folderResult.data!, normalized);
    final List<Deck> decks = _rankDecks(deckResult.data!, normalized);
    final List<Flashcard> flashcards = _rankFlashcards(
      flashcardResult.data!,
      normalized,
    );

    return (
      failure: null,
      data: SearchResults(
        folders: _cap(folders),
        decks: _cap(decks),
        flashcards: _cap(flashcards),
        folderTotal: folders.length,
        deckTotal: decks.length,
        flashcardTotal: flashcards.length,
      ),
    );
  }

  List<T> _cap<T>(List<T> items) =>
      items.length <= sectionCap ? items : items.sublist(0, sectionCap);

  // Ranking: exact match (0) → starts-with (1) → substring (2), recency
  // tie-break (newer `updatedAt` first), then a stable id tie-break (SR5).
  List<Folder> _rankFolders(List<Folder> items, String query) {
    final List<Folder> sorted = List<Folder>.of(items);
    sorted.sort((Folder a, Folder b) {
      final int byRank = _matchRank(
        a.name,
        query,
      ).compareTo(_matchRank(b.name, query));
      if (byRank != 0) return byRank;
      final int byRecency = b.updatedAt.compareTo(a.updatedAt);
      if (byRecency != 0) return byRecency;
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  List<Deck> _rankDecks(List<Deck> items, String query) {
    final List<Deck> sorted = List<Deck>.of(items);
    sorted.sort((Deck a, Deck b) {
      final int byRank = _matchRank(
        a.name,
        query,
      ).compareTo(_matchRank(b.name, query));
      if (byRank != 0) return byRank;
      final int byRecency = b.updatedAt.compareTo(a.updatedAt);
      if (byRecency != 0) return byRecency;
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  List<Flashcard> _rankFlashcards(List<Flashcard> items, String query) {
    final List<Flashcard> sorted = List<Flashcard>.of(items);
    sorted.sort((Flashcard a, Flashcard b) {
      // A flashcard matches on front OR back — rank by the better of the two.
      final int rankA = _bestRank(a, query);
      final int rankB = _bestRank(b, query);
      final int byRank = rankA.compareTo(rankB);
      if (byRank != 0) return byRank;
      final int byRecency = b.updatedAt.compareTo(a.updatedAt);
      if (byRecency != 0) return byRecency;
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  int _bestRank(Flashcard card, String query) {
    final int front = _matchRank(card.front, query);
    final int back = _matchRank(card.back, query);
    return front < back ? front : back;
  }

  /// 0 = exact, 1 = starts-with, 2 = substring, 3 = no match (filtered out by
  /// SQL, kept defensive). Compares against the normalized (lowercased) value.
  int _matchRank(String value, String query) {
    final String lowered = StringUtils.caseFold(value);
    if (lowered == query) return 0;
    if (lowered.startsWith(query)) return 1;
    if (lowered.contains(query)) return 2;
    return 3;
  }
}
