import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';

/// Always-visible inline search below the Library title. Scope-local; it never
/// navigates (`docs/wireframes/02-library.md`). Owns the text controller and
/// pushes changes into [LibraryToolbar].
///
/// The controller is the source of truth for what the user types, but the
/// toolbar search term can also be cleared from elsewhere (e.g. the search
/// no-results "Clear" CTA calls `LibraryToolbar.clearSearch()`). To keep the
/// visible field in sync with that, this widget watches the provider's
/// `searchTerm` and clears the controller when it goes empty while the field
/// still shows text. The data flow stays one-directional per edge —
/// keystrokes drive controller → provider, external clears drive
/// provider → controller — so there is no feedback loop:
/// `TextEditingController.clear()` does not invoke `onChanged`.
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

    // Provider → controller: when the search term is cleared elsewhere, wipe
    // the visible text so the field and provider state stay in sync.
    ref.listen<String>(
      libraryToolbarProvider.select((LibraryToolbarState s) => s.searchTerm),
      (String? previous, String next) {
        if (next.isEmpty && _controller.text.isNotEmpty) {
          _controller.clear();
        }
      },
    );

    return MxSearchField(
      controller: _controller,
      hintText: l10n.librarySearchHint,
      clearTooltip: l10n.librarySearchClearTooltip,
      onChanged: (String value) =>
          ref.read(libraryToolbarProvider.notifier).setSearch(value),
    );
  }
}
