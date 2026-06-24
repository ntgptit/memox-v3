import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/viewmodels/tag_management_viewmodel.dart';
import 'package:memox/presentation/shared/hooks/mx_search_controller_hooks.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_scoped_search_dock.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';

/// The pinned bottom search dock for Tag Management (kit `11`), bound to
/// [tagSearchQueryProvider] (client-side filter). Provider-synced via
/// [useMxSearchController] so the no-results `Clear` CTA can reset the field.
class TagSearchDock extends HookConsumerWidget {
  const TagSearchDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String term = ref.watch(tagSearchQueryProvider);
    final MxSearchControllerState search = useMxSearchController(
      externalText: term,
      clearWhenExternalTextEmpty: true,
    );
    return MxScopedSearchDock(
      key: const ValueKey<String>('mx-node:11-tag-management/search-dock'),
      child: MxSearchField(
        controller: search.controller,
        hintText: l10n.tagManagementSearchHint,
        onChanged: (String value) =>
            ref.read(tagSearchQueryProvider.notifier).setTerm(value),
      ),
    );
  }
}
