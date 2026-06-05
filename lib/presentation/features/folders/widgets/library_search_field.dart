import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';

/// Always-visible inline search below the Library title. Scope-local; it never
/// navigates (`docs/wireframes/02-library.md`). Owns the text controller and
/// pushes changes into [LibraryToolbar].
class LibrarySearchField extends ConsumerStatefulWidget {
  const LibrarySearchField({super.key});

  @override
  ConsumerState<LibrarySearchField> createState() => _LibrarySearchFieldState();
}

class _LibrarySearchFieldState extends ConsumerState<LibrarySearchField> {
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
      hintText: l10n.librarySearchHint,
      clearTooltip: l10n.librarySearchClearTooltip,
      onChanged: (String value) =>
          ref.read(libraryToolbarProvider.notifier).setSearch(value),
    );
  }
}
