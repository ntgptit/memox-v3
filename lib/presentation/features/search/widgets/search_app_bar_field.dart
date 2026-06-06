import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/search/viewmodels/search_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';

/// The global-search input, hosted in the screen app bar. Owns the text
/// controller, autofocuses on open, and pushes keystrokes into [SearchQuery].
///
/// One-directional per edge: keystrokes drive controller → provider; the field
/// clear button wipes both. There is no external clear source on this screen,
/// so no provider → controller listener is needed.
class SearchAppBarField extends ConsumerStatefulWidget {
  const SearchAppBarField({super.key});

  @override
  ConsumerState<SearchAppBarField> createState() => _SearchAppBarFieldState();
}

class _SearchAppBarFieldState extends ConsumerState<SearchAppBarField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxSearchField(
      controller: _controller,
      autofocus: true,
      hintText: l10n.searchFieldHint,
      clearTooltip: l10n.searchClearTooltip,
      onChanged: (String value) =>
          ref.read(searchQueryProvider.notifier).setQuery(value),
    );
  }
}
