import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/search/viewmodels/search_viewmodel.dart';
import 'package:memox/presentation/features/search/widgets/search_app_bar_field.dart';
import 'package:memox/presentation/features/search/widgets/search_results_view.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

/// Global Library search (`docs/wireframes/11-library-search.md`).
///
/// Searches folders, decks, and flashcards. Renders all five states:
/// empty/hint (below the 2-char minimum), loading (debounced query in flight),
/// results (grouped sections), no-results (matched nothing), and error. The
/// `GlobalSearchScreen` owns the query watch for app bar sync; the
/// `_SearchResultsSection` still owns the results watch
/// (`memox.screen_shell.template_shell_no_ref_watch`).
class GlobalSearchScreen extends ConsumerWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // guard:allow-screen-watch -- reason: the app bar query must mirror the
    // provider state so the search field stays in sync with the results
    // section, which owns the actual search watch.
    final String query = ref.watch(searchQueryProvider);
    return MxScaffold(
      appBar: MxAppBar(
        title: SearchAppBarField(
          query: query,
          onChanged: (String value) =>
              ref.read(searchQueryProvider.notifier).setQuery(value),
        ),
      ),
      body: const _SearchResultsSection(),
    );
  }
}

class _SearchResultsSection extends ConsumerWidget {
  const _SearchResultsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<SearchResults?> results = ref.watch(searchResultsProvider);

    return MxRetainedAsyncState<SearchResults?>(
      value: results,
      skeletonBuilder: (_) => const MxLoadingState(),
      errorBuilder: (Object error, StackTrace? stack) => MxErrorState(
        title: l10n.searchErrorTitle,
        message: l10n.searchErrorMessage,
        retryLabel: l10n.searchRetryLabel,
        onRetry: () => ref.invalidate(searchResultsProvider),
      ),
      data: (SearchResults? value) {
        // Below the 2-char minimum → neutral hint (empty state).
        if (value == null) {
          return MxEmptyState(
            icon: Icons.search_rounded,
            title: l10n.searchEmptyTitle,
            message: l10n.searchEmptyMessage,
          );
        }
        // Query ran but matched nothing in any section.
        if (value.isEmpty) {
          return MxEmptyState(
            icon: Icons.search_off_rounded,
            title: l10n.searchNoResultsTitle,
            message: l10n.searchNoResultsMessage,
          );
        }
        return SearchResultsView(results: value);
      },
    );
  }
}
