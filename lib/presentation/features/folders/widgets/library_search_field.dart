import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/shared/hooks/mx_search_controller_hooks.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';

/// Inline Library folder search. Owns the search controller via
/// [useMxSearchController] (the sanctioned text-controller hook) and mirrors the
/// term into [LibrarySearchQuery] so the body can filter. Scope-local; never
/// routes to Global Search. WBS 3.1.2.
class LibrarySearchField extends HookConsumerWidget {
  const LibrarySearchField({this.autofocus = false, super.key});

  /// Focus the field on mount (used when entering search mode from the app bar).
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String term = ref.watch(librarySearchQueryProvider);
    final MxSearchControllerState search = useMxSearchController(
      externalText: term,
      clearWhenExternalTextEmpty: true,
    );
    return MxSearchField(
      controller: search.controller,
      hintText: l10n.librarySearchHint,
      autofocus: autofocus,
      onChanged: (String value) =>
          ref.read(librarySearchQueryProvider.notifier).setTerm(value),
    );
  }
}
