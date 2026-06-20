import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/library_overview_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Library Overview — the root content browser: top-level folders with their
/// recursive counts, inline folder search, and folder management via the row
/// overflow sheet. Display + state handling live in [LibraryOverviewBody].
///
/// V1 scope (`docs/design/screens/library-overview.visual-contract.md`): the
/// header filter/sliders affordance is visual-only (disabled); the create-folder
/// FAB + dialog land with WBS 2.1.2 (pending the design color/icon set) and
/// folder-detail navigation with WBS 3.2.2. WBS 3.1.2.
class LibraryOverviewScreen extends StatelessWidget {
  const LibraryOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(
        title: l10n.libraryTitle,
        actions: const <Widget>[
          // Visual-only filter affordance (no approved sort/filter sheet yet).
          MxIconButton(icon: Icons.tune_rounded, onPressed: null),
        ],
      ),
      body: const LibraryOverviewBody(),
    );
  }
}
