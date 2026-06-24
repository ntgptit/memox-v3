import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_body.dart';
import 'package:memox/presentation/features/history/widgets/card_history_breadcrumb.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Card History — a read-only per-card timeline (kit screen 09): a breadcrumb, a
/// header card (preview + Box chip + Reviews/Retention/Avg-time), and an activity
/// feed (graded attempts + lifecycle events). Pushed over the deck flashcard list
/// (`…/flashcards/:flashcardId/history`). WBS 7.6.3.
///
/// The shell stays watch-free: the breadcrumb and body are each `Consumer`s that
/// own their own watch. `useShell: false` because the body owns its scroll
/// padding and the breadcrumb docks under the app bar.
class CardHistoryScreen extends StatelessWidget {
  const CardHistoryScreen({
    required this.deckId,
    required this.flashcardId,
    super.key,
  });

  final String deckId;
  final String flashcardId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(title: l10n.cardHistoryTitle),
      useShell: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CardHistoryBreadcrumb(deckId: deckId),
          Expanded(child: CardHistoryBody(flashcardId: flashcardId)),
        ],
      ),
    );
  }
}
