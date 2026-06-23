import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/search/viewmodels/global_search_viewmodel.dart';
import 'package:memox/presentation/features/search/widgets/global_search_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_dock.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Global Search — the top-level `/search` destination (design redesign).
///
/// Search lives in a **bottom dock** (`MxSearchDock`) so it stays thumb-reachable
/// on tall phones; the body above it ([GlobalSearchBody]) renders the search
/// states over the `GlobalSearchUseCase` read model. The shell itself stays
/// provider-watch-free — the dock drives the query via `ref.read`, and the body
/// owns the results watch.
///
/// WBS 3.5.2. See `docs/wireframes/11-library-search.md` and
/// `docs/business/search/global-search.md`.
class GlobalSearchScreen extends ConsumerWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MxScaffold(
      // The dock is full-bleed (its border-top spans the screen); the body and
      // result sections manage their own gutters, so the page gutter is off.
      useShell: false,
      appBar: MxAppBar(title: l10n.searchTitle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Expanded(child: GlobalSearchBody()),
          MxSearchDock(
            key: const ValueKey<String>(
              'mx-node:05-library-search/search-dock',
            ),
            hintText: l10n.searchDockHint,
            onChanged: (String term) =>
                ref.read(globalSearchQueryProvider.notifier).setTerm(term),
          ),
        ],
      ),
    );
  }
}
