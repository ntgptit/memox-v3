import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/library_search_field.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// The Library search-mode app bar (mock `03e`): an autofocused folder search
/// field with a trailing Cancel that clears the term and leaves search mode.
/// Replaces the title app bar while [LibrarySearchActive] is on.
///
/// Built on a real [AppBar] so Material handles the status-bar (safe-area) inset
/// and inherits the theme `systemOverlayStyle` — the field never collides with
/// the OS clock/battery and the app background fills behind them. WBS 3.1.2.
class LibrarySearchAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  const LibrarySearchAppBar({super.key});

  /// A touch taller than a standard toolbar so the boxed search field keeps
  /// breathing room below the status bar instead of hugging the screen edge.
  static const double _toolbarHeight = kToolbarHeight + MxSpacing.space4;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    void cancel() {
      ref.read(librarySearchQueryProvider.notifier).clear();
      ref.read(librarySearchActiveProvider.notifier).deactivate();
    }

    return MxAppBar(
      automaticallyImplyLeading: false,
      titleSpacing: MxSpacing.screen,
      toolbarHeight: _toolbarHeight,
      titleWidget: const LibrarySearchField(autofocus: true),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: MxSpacing.space2),
          child: MxSecondaryButton(
            label: l10n.commonCancel,
            variant: MxSecondaryVariant.text,
            onPressed: cancel,
          ),
        ),
      ],
    );
  }
}
