import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/search/viewmodels/global_search_viewmodel.dart';
import 'package:memox/presentation/features/search/widgets/global_search_results_view.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_no_results_state.dart';

/// The global-search body above the search dock: renders the search states off
/// `globalSearchResultsProvider` (WBS 3.5.2). Owns the provider watch (the screen
/// shell stays watch-free) and maps:
///
/// - `null` result → the idle prompt (recent/popular are Future, so not shown);
/// - failure → the error state with retry;
/// - empty success → the no-results state with the query echoed;
/// - non-empty success → the grouped results.
class GlobalSearchBody extends ConsumerWidget {
  const GlobalSearchBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Result<SearchResults>?> async = ref.watch(
      globalSearchResultsProvider,
    );

    return AppAsyncBuilder<Result<SearchResults>?>(
      value: async,
      loading: (_) => const MxLoadingState(),
      data: (Result<SearchResults>? result) {
        // Below-min / idle query: the quiet prompt.
        if (result == null) {
          return MxEmptyState(
            icon: Icons.search,
            title: l10n.searchIdleTitle,
            message: l10n.searchIdleMessage,
          );
        }
        if (result.isFailure) {
          return MxErrorState(
            icon: Icons.warning_amber_rounded,
            title: l10n.searchFailedTitle,
            message: l10n.searchFailedMessage,
            action: MxPrimaryButton(
              label: l10n.searchRetry,
              icon: Icons.refresh,
              onPressed: () => ref.invalidate(globalSearchResultsProvider),
            ),
          );
        }
        final SearchResults results = result.data ?? const SearchResults();
        if (results.isEmpty) {
          final String query = StringUtils.trimmed(
            ref.watch(globalSearchQueryProvider),
          );
          return MxNoResultsState(
            title: l10n.searchNoResultsTitle,
            message: l10n.searchNoResultsMessage(query),
          );
        }
        return GlobalSearchResultsView(results: results);
      },
    );
  }
}
