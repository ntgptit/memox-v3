import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/widgets/deck_import_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Deck Import — a file-picker wizard that imports CSV/TSV cards into a deck
/// (kit screen 10). A top-level immersive route (`/library/deck/:deckId/import`,
/// shell hidden), reached from the flashcard list. The body owns the wizard
/// state; the shell stays watch-free. WBS 6.3.1.
class DeckImportScreen extends StatelessWidget {
  const DeckImportScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(title: l10n.deckImportTitle),
      useShell: false,
      body: DeckImportBody(deckId: deckId),
    );
  }
}
