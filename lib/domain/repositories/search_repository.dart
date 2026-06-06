import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/search_results.dart';

/// Global Library search data access (`docs/contracts/usecase-contracts/search.md`).
///
/// Implemented by `SearchRepositoryImpl` over Drift. Uses the existing [Result]
/// pattern (the contract's `Either<Failure, T>` is the fpdart target, not yet
/// adopted). V1 promoted scope is folders + decks + flashcards; the tags
/// section lands with the tag subsystem.
abstract interface class SearchRepository {
  /// Runs the three section queries and returns up to [sectionCap] hits each
  /// plus the full per-section totals.
  ///
  /// [query] is assumed already normalized by the use case (trimmed,
  /// lowercased, internal whitespace collapsed) and at least 2 chars. The
  /// implementation escapes LIKE wildcards (`%`, `_`, `\`) before binding.
  Future<Result<SearchResults>> search({
    required String query,
    required int sectionCap,
  });
}
