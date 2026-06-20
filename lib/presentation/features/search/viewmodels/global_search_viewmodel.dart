import 'package:memox/app/di/search_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/domain/usecases/search/global_search_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_search_viewmodel.g.dart';

/// The current global-search query (the `/search` destination). Empty string =
/// the idle prompt. WBS 3.5.2.
@riverpod
class GlobalSearchQuery extends _$GlobalSearchQuery {
  @override
  String build() => '';

  void setTerm(String term) => state = term;

  void clear() => state = '';
}

/// Runs global search for the current [GlobalSearchQuery] over the ready
/// `GlobalSearchUseCase` (WBS 3.5.1). Resolves to:
///
/// - `null` when the normalized query is below the use case's minimum length —
///   the screen shows the idle prompt (the empty/hint state);
/// - a [Result] otherwise: a failure drives the error state, a success carries
///   the [SearchResults] (possibly [SearchResults.isEmpty] → no-results).
///
/// The failure stays in-band in the [Result] (matching the flashcard-list view
/// model) rather than thrown, so the screen interprets it. Debounce: a re-keyed
/// query rebuilds this provider, so the in-flight wait is abandoned; the use case
/// only runs once typing settles for [GlobalSearchUseCase.inputDebounce]. WBS 3.5.2.
@riverpod
Future<Result<SearchResults>?> globalSearchResults(Ref ref) async {
  final String query = ref.watch(globalSearchQueryProvider);
  final String normalized = StringUtils.normalizeQuery(query);
  if (normalized.length < GlobalSearchUseCase.minQueryLength) {
    return null;
  }

  // Watch the use case so it (and its repository/DAO chain) stays alive for this
  // provider's lifetime — reading it across the debounce gap could otherwise use
  // a disposed instance if the chain were auto-disposed mid-flight.
  final GlobalSearchUseCase useCase = ref.watch(globalSearchUseCaseProvider);

  // Debounce: if the query changes during the wait this provider is disposed and
  // rebuilt, so skip the now-stale use-case call.
  bool disposed = false;
  ref.onDispose(() => disposed = true);
  await Future<void>.delayed(GlobalSearchUseCase.inputDebounce);
  if (disposed) return null;

  return useCase.call(query: query);
}
