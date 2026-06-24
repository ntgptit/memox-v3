import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/history/screens/card_history_screen.dart';
import 'package:memox/presentation/features/history/viewmodels/card_history_viewmodel.dart';

import '../../../support/parity_contract.dart';

/// Spec-driven parity contract for Card History (09), identity by STABLE KEY
/// (`tool/parity/contracts/contracts.json`). The breadcrumb stream is overridden
/// to an empty stream (breadcrumb hidden — no DI); the contract covers the body
/// nodes (header + activity).
Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

CardHistory _sample() {
  final int created = DateTime(2026, 2, 24).millisecondsSinceEpoch;
  return CardHistory(
    header: CardHistoryHeader(
      front: '日本 — Japan',
      deckName: 'Japanese · N5',
      boxNumber: 4,
      reviewCount: 18,
      lapseCount: 1,
      createdAt: created,
      avgDurationMs: 5400,
    ),
    events: <CardHistoryEvent>[
      CardHistoryEvent.attempt(
        occurredAt: DateTime(2026, 3, 2).millisecondsSinceEpoch,
        result: AttemptResult.perfect,
        mode: StudyMode.review,
        boxBefore: 3,
        boxAfter: 4,
        durationMs: 4200,
      ),
      CardHistoryEvent.lifecycle(
        occurredAt: created,
        kind: CardEventKind.created,
      ),
    ],
  );
}

void main() {
  testWidgets('09-flashcard-history parity contract (loaded)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardHistoryProvider(
            'c1',
          ).overrideWith((ref) => (failure: null, data: _sample())),
          flashcardListStreamProvider('d1').overrideWith(
            (ref) => const Stream<Result<FlashcardListDetail>>.empty(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CardHistoryScreen(deckId: 'd1', flashcardId: 'c1'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expectParityContract('09-flashcard-history', <String, Finder>{
      'header card': _node('09-flashcard-history/header'),
      'activity feed card': _node('09-flashcard-history/activity'),
    });
  });
}
