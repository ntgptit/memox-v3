import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_session_result_provider.dart';
import 'package:memox/presentation/features/study/screens/study_result_screen.dart';

import '../../../support/parity_contract.dart';

/// Spec-driven parity contract for the study-result screen (identity by KEY). The
/// Done button is the primary action present across the loaded/save-failed states.
void main() {
  const String sid = 's1';
  final DateTime t = DateTime.utc(2026);
  final StudySessionResult result = StudySessionResult(
    session: StudySession(
      id: sid,
      scope: const StudyScope(
        entryType: EntryType.deck,
        entryRefId: 'd1',
        studyType: StudyType.srsReview,
      ),
      status: SessionStatus.completed,
      startedAt: t,
      updatedAt: t,
    ),
    items: const <StudySessionResultItem>[
      StudySessionResultItem(
        sessionItemId: 'i0',
        flashcardId: 'c0',
        front: 'front',
        back: 'back',
        sortOrder: 0,
        result: AttemptResult.perfect,
      ),
    ],
  );

  Finder node(String i) => find.byKey(ValueKey<String>('mx-node:$i'));

  testWidgets('17-study-result parity contract (loaded)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionResultProvider(sid).overrideWith((ref) async => result),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StudyResultScreen(sessionId: sid),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expectParityContract('17-study-result', <String, Finder>{
      'Done button': node('17-study-result/done-button'),
    });
  });
}
