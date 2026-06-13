import 'package:flutter/material.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/presentation/features/history/widgets/card_history_header_card.dart';
import 'package:memox/presentation/features/history/widgets/card_history_timeline.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';

/// Card History body: a fixed header card above the scrollable timeline. The
/// timeline owns its own scroll/skeleton/empty/error surfaces, so they get a
/// bounded height from [Expanded] instead of nesting scrollables.
class CardHistoryBody extends StatelessWidget {
  const CardHistoryBody({
    required this.deckId,
    required this.flashcardId,
    required this.header,
    super.key,
  });

  final String deckId;
  final String flashcardId;
  final CardHistoryHeader header;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: SpacingTokens.md),
        child: MxContentShell(
          child: CardHistoryHeaderCard(header: header, now: DateTime.now()),
        ),
      ),
      Expanded(
        child: CardHistoryTimelineSection(
          flashcardId: flashcardId,
          lastResetAt: header.lastResetAt,
          onStartStudy: () => context.goStudyEntry(
            entryType: EntryType.deck,
            entryRefId: deckId,
          ),
        ),
      ),
    ],
  );
}
