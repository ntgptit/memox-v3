import 'dart:async';

import 'package:memox/app/di/search_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/domain/usecases/search/global_search_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_viewmodel.g.dart';

/// Raw search text typed on the global search screen. Ephemeral UI state (never
/// persisted), so plain auto-dispose is correct.
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setQuery(String value) => state = value;

  void clear() => state = '';
}

/// Debounced global-search results.
///
/// Emits `null` while the normalized query is shorter than
/// [GlobalSearchUseCase.minQueryLength] — the screen renders its empty/hint
/// state instead of querying. Otherwise it debounces 300ms (a superseded
/// keystroke disposes this computation before the query fires), runs
/// [GlobalSearchUseCase], and unwraps the [Result]: a [Failure] is thrown so it
/// surfaces as `AsyncError` for the screen's error state.
@riverpod
Future<SearchResults?> searchResults(Ref ref) async {
  final String query = ref.watch(searchQueryProvider);
  final String normalized = StringUtils.normalizeQuery(query);
  if (normalized.length < GlobalSearchUseCase.minQueryLength) {
    return null;
  }

  bool disposed = false;
  ref.onDispose(() => disposed = true);
  // 300ms debounce (`docs/business/search/global-search.md` §V1 query input).
  await Future<void>.delayed(DurationTokens.slow);
  if (disposed) {
    return null;
  }

  final GlobalSearchUseCase useCase = ref.watch(globalSearchUseCaseProvider);
  final Result<SearchResults> result = await useCase.call(query: query);
  return result.fold(
    // Surface the Failure as AsyncError for the screen's error state.
    // ignore: only_throw_errors
    (Failure failure) => throw failure,
    (SearchResults value) => value,
  );
}
