import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/domain/repositories/search_repository.dart';

/// Global Library search (`docs/contracts/usecase-contracts/search.md`,
/// `docs/business/search/global-search.md`).
///
/// Thin orchestration over [SearchRepository]: normalizes the raw query,
/// enforces the 2-char minimum, and delegates the section queries. Notifiers
/// depend on this, never on the repository directly.
class GlobalSearchUseCase {
  const GlobalSearchUseCase(this._repository);

  final SearchRepository _repository;

  /// Below this many characters the query is rejected (`tooShort`); the screen
  /// renders its empty/hint state instead of querying.
  static const int minQueryLength = 2;

  /// Per-section visible cap; totals beyond this drive a "+N more" affordance.
  static const int sectionCap = 5;

  Future<Result<SearchResults>> call({required String query}) {
    final String normalized = StringUtils.normalizeQuery(query);
    if (normalized.length < minQueryLength) {
      return Future<Result<SearchResults>>.value(
        const Result<SearchResults>.err(
          ValidationFailure(field: 'query', code: ValidationCode.tooShort),
        ),
      );
    }
    return _repository.search(query: normalized, sectionCap: sectionCap);
  }
}
