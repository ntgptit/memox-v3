part of 'study_session_screen_test.dart';

void defineStudySessionScreenGuessTests() {
  testWidgets('DT3 onOpen: guess mode renders the prompt and 5 rich options', (
    tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      Result<StudySessionReview>.ok(
        _review(
          sessionId: 'session-guess-open',
          cards: <({String front, String back})>[
            (front: '도서관', back: 'library'),
            (front: '주방', back: 'kitchen'),
            (front: '학교', back: 'school'),
            (front: '사무실', back: 'office'),
            (front: '병원', back: 'hospital'),
          ],
        ),
      ),
    );
    final GoRouter router = _studyRouter(
      _studySessionLocationWithMode(
        'session-guess-open',
        mode: StudyMode.guess,
      ),
    );

    await tester.pumpWidget(
      _routerShell(
        router,
        overrides: <Override>[
          studyRepositoryProvider.overrideWithValue(repository),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(StudySessionScreen)),
    );

    expect(find.text(l10n.studySessionGuessModeLabel), findsOneWidget);
    expect(
      find.text(StringUtils.uppercased(l10n.studySessionGuessPromptLabel)),
      findsOneWidget,
    );
    expect(find.text('도서관'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>('guess-option-card-session-guess-open-0'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('guess-option-card-session-guess-open-1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('guess-option-card-session-guess-open-2'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('guess-option-card-session-guess-open-3'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('guess-option-card-session-guess-open-4'),
      ),
      findsOneWidget,
    );

    final Finder openOptionFinder = find.byKey(
      const ValueKey<String>('guess-option-card-session-guess-open-1'),
    );
    await tester.ensureVisible(openOptionFinder);
    await tester.longPress(openOptionFinder);
    await tester.pumpAndSettle();

    expect(find.text(l10n.commonEdit), findsOneWidget);
    expect(find.text(l10n.studySessionBuryUntilTomorrowAction), findsOneWidget);
    expect(find.text(l10n.studySessionSuspendAction), findsOneWidget);
  });

  testWidgets(
    'DT3a onTap: guess mode records the answer immediately and the footer skips',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-guess-wrong',
            cards: <({String front, String back})>[
              (front: '도서관', back: 'library'),
              (front: '주방', back: 'kitchen'),
              (front: '학교', back: 'school'),
              (front: '사무실', back: 'office'),
              (front: '병원', back: 'hospital'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocationWithMode(
          'session-guess-wrong',
          mode: StudyMode.guess,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      final Finder wrongOptionFinder = find.byKey(
        const ValueKey<String>('guess-option-card-session-guess-wrong-1'),
      );
      await tester.ensureVisible(wrongOptionFinder);
      await tester.tap(wrongOptionFinder);
      await tester.pump();

      expect(repository.recordCalls, 1);
      expect(repository.recordedAnswers.single.result, AttemptResult.forgot);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.textContaining('NEXT CARD IN'), findsOneWidget);

      await tester.tap(find.textContaining('NEXT CARD IN'));
      await tester.pumpAndSettle();

      expect(find.text('주방'), findsOneWidget);
      expect(find.textContaining('NEXT CARD IN'), findsNothing);
      expect(find.text(l10n.studySessionGuessSkipAction), findsNothing);
    },
  );

  testWidgets(
    'DT3b onComplete: guess mode auto-finalizes after the last answer',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-guess-complete',
            cards: <({String front, String back})>[
              (front: '도서관', back: 'library'),
              (front: '주방', back: 'kitchen'),
              (front: '학교', back: 'school'),
              (front: '사무실', back: 'office'),
              (front: '병원', back: 'hospital'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocationWithMode(
          'session-guess-complete',
          mode: StudyMode.guess,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final List<String> correctAnswers = <String>[
        'library',
        'kitchen',
        'school',
        'office',
        'hospital',
      ];

      for (int index = 0; index < correctAnswers.length; index++) {
        final Finder correctOptionFinder = find.byKey(
          ValueKey<String>('guess-option-card-session-guess-complete-$index'),
        );
        await tester.ensureVisible(correctOptionFinder);
        await tester.tap(correctOptionFinder);
        await tester.pump();
        expect(repository.recordCalls, index + 1);
        expect(repository.recordedAnswers[index].result, AttemptResult.perfect);

        if (index < correctAnswers.length - 1) {
          await tester.pump(
            DurationTokens.guessCorrectCountdown +
                const Duration(milliseconds: 20),
          );
          await tester.pumpAndSettle();
        }
      }

      await tester.pump(
        DurationTokens.guessCorrectCountdown + const Duration(milliseconds: 20),
      );
      await tester.pumpAndSettle();

      expect(repository.finalizeCalls, 1);
      expect(find.byType(StudyResultScreen), findsOneWidget);
    },
  );

  testWidgets(
    'DT4 onOpen: fill mode renders the typed input surface and hides TTS during typing',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-fill-open',
            cards: <({String front, String back})>[
              (front: '행복하다', back: 'Be happy'),
              (front: '가다', back: 'To go'),
            ],
            hints: <String?>['gây vui', null],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocationWithMode(
          'session-fill-open',
          mode: StudyMode.fill,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );
      final ThemeData theme = Theme.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      expect(find.byType(StudySessionFillModeView), findsOneWidget);
      expect(find.text(l10n.studySessionFillModeLabel), findsOneWidget);
      expect(find.text('Be happy (gây vui)'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Be happy (gây vui)')).style?.fontSize,
        theme.textTheme.bodyMedium?.fontSize,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).style?.fontSize,
        theme.textTheme.displayLarge?.fontSize,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).style?.fontWeight,
        TypographyTokens.bold,
      );
      expect(
        tester
            .widget<MxActionButton>(
              find.widgetWithText(
                MxActionButton,
                l10n.studySessionFillCheckAction,
              ),
            )
            .onPressed,
        isNull,
      );
      expect(
        find.widgetWithText(MxActionButton, l10n.studySessionFillHintAction),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(MxActionButton, l10n.studySessionFillCheckAction),
        findsOneWidget,
      );
      expect(
        find.byTooltip(l10n.studySessionFillSpeakCorrectAnswerAction),
        findsNothing,
      );
      expect(repository.reviewCalls, 1);
      expect(repository.recordCalls, 0);
    },
  );

  testWidgets(
    'DT5 onCheck: fill mode exact match without hint auto-advances as perfect',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-fill-perfect',
            cards: <({String front, String back})>[
              (front: '행복하다', back: 'Be happy'),
              (front: '가다', back: 'To go'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocationWithMode(
          'session-fill-perfect',
          mode: StudyMode.fill,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await tester.enterText(find.byType(TextField), '  행복하다  ');
      await tester.pump();
      await _tapVisible(
        tester,
        find.widgetWithText(MxActionButton, l10n.studySessionFillCheckAction),
      );
      await tester.pumpAndSettle();

      expect(repository.recordCalls, 1);
      expect(repository.recordedAnswers.single.result, AttemptResult.perfect);
      expect(repository.recordedAnswers.single.studyMode, StudyMode.fill);
      expect(
        find.byTooltip(l10n.studySessionFillSpeakCorrectAnswerAction),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(MxActionButton, l10n.studyNextAction),
        findsOneWidget,
      );

      await tester.pump(
        DurationTokens.guessCorrectCountdown + const Duration(milliseconds: 20),
      );
      await tester.pumpAndSettle();

      expect(find.text('To go'), findsOneWidget);
      expect(
        find.byTooltip(l10n.studySessionFillSpeakCorrectAnswerAction),
        findsNothing,
      );
    },
  );

  testWidgets(
    'DT6 onCheck: fill mode exact match after hint is recorded as recovered',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-fill-hint',
            cards: <({String front, String back})>[
              (front: '행복하다', back: 'Be happy'),
              (front: '가다', back: 'To go'),
            ],
            hints: <String?>['gây vui'],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocationWithMode(
          'session-fill-hint',
          mode: StudyMode.fill,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await _tapVisible(
        tester,
        find.widgetWithText(MxActionButton, l10n.studySessionFillHintAction),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration?.hintText,
        '행',
      );

      await tester.enterText(find.byType(TextField), '행복하다');
      await tester.pump();
      await _tapVisible(
        tester,
        find.widgetWithText(MxActionButton, l10n.studySessionFillCheckAction),
      );
      await tester.pumpAndSettle();

      expect(repository.recordCalls, 1);
      expect(repository.recordedAnswers.single.result, AttemptResult.recovered);
      expect(repository.recordedAnswers.single.studyMode, StudyMode.fill);
      expect(
        find.byTooltip(l10n.studySessionFillSpeakCorrectAnswerAction),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'DT7 onCheck: fill mode wrong feedback stays local until committed',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-fill-wrong',
            cards: <({String front, String back})>[
              (front: '행복하다', back: 'Be happy'),
              (front: '가다', back: 'To go'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocationWithMode(
          'session-fill-wrong',
          mode: StudyMode.fill,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await tester.enterText(find.byType(TextField), '행복해');
      await tester.pump();
      await _tapVisible(
        tester,
        find.widgetWithText(MxActionButton, l10n.studySessionFillCheckAction),
      );
      await tester.pumpAndSettle();

      expect(repository.recordCalls, 0);
      expect(
        find.byTooltip(l10n.studySessionFillSpeakCorrectAnswerAction),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(
          MxActionButton,
          l10n.studySessionFillMarkCorrectAction,
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(
          MxActionButton,
          l10n.studySessionFillTryAgainAction,
        ),
        findsOneWidget,
      );
      expect(
        find.text(l10n.studySessionFillWrongAnnouncement('행복해', '행복하다')),
        findsOneWidget,
      );
      await _tapVisible(
        tester,
        find.byTooltip(l10n.studySessionFillSpeakCorrectAnswerAction),
      );
      await tester.pump();

      await tester.pump(
        DurationTokens.guessCorrectCountdown + const Duration(milliseconds: 20),
      );
      await tester.pumpAndSettle();

      expect(repository.recordCalls, 0);
      expect(
        find.widgetWithText(
          MxActionButton,
          l10n.studySessionFillMarkCorrectAction,
        ),
        findsOneWidget,
      );
      expect(
        find.byTooltip(l10n.studySessionFillSpeakCorrectAnswerAction),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'DT8 onRetry: try again clears input and keeps the hint-tainted retry available',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-fill-retry',
            cards: <({String front, String back})>[
              (front: '행복하다', back: 'Be happy'),
              (front: '가다', back: 'To go'),
            ],
            hints: <String?>['gây vui'],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocationWithMode(
          'session-fill-retry',
          mode: StudyMode.fill,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await _tapVisible(
        tester,
        find.widgetWithText(MxActionButton, l10n.studySessionFillHintAction),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration?.hintText,
        '행',
      );

      await tester.enterText(find.byType(TextField), '행복해');
      await tester.pump();
      await _tapVisible(
        tester,
        find.widgetWithText(MxActionButton, l10n.studySessionFillCheckAction),
      );
      await tester.pumpAndSettle();
      await _tapVisible(
        tester,
        find.widgetWithText(
          MxActionButton,
          l10n.studySessionFillTryAgainAction,
        ),
      );
      await tester.pumpAndSettle();

      final TextField textField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(textField.controller?.text, isEmpty);
      expect(textField.decoration?.hintText, '행');
      expect(repository.recordCalls, 0);
      expect(
        tester
            .widget<MxActionButton>(
              find.widgetWithText(
                MxActionButton,
                l10n.studySessionFillCheckAction,
              ),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<MxActionButton>(
              find.widgetWithText(
                MxActionButton,
                l10n.studySessionFillHintAction,
              ),
            )
            .onPressed,
        isNotNull,
      );
      expect(
        find.byTooltip(l10n.studySessionFillSpeakCorrectAnswerAction),
        findsNothing,
      );
    },
  );

  testWidgets(
    'DT9 onCommit: mark correct records recovered from wrong feedback',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-fill-mark-correct',
            cards: <({String front, String back})>[
              (front: '행복하다', back: 'Be happy'),
              (front: '가다', back: 'To go'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocationWithMode(
          'session-fill-mark-correct',
          mode: StudyMode.fill,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await tester.enterText(find.byType(TextField), '행복해');
      await tester.pump();
      final Finder checkButton = find.widgetWithText(
        MxActionButton,
        l10n.studySessionFillCheckAction,
      );
      await tester.ensureVisible(checkButton);
      await tester.tap(checkButton);
      await tester.pumpAndSettle();
      final Finder markCorrectButton = find.widgetWithText(
        MxActionButton,
        l10n.studySessionFillMarkCorrectAction,
      );
      await tester.ensureVisible(markCorrectButton);
      await tester.tap(markCorrectButton);
      await tester.pumpAndSettle();

      expect(repository.recordCalls, 1);
      expect(repository.recordedAnswers.single.result, AttemptResult.recovered);
      expect(repository.recordedAnswers.single.studyMode, StudyMode.fill);
      expect(
        find.byTooltip(l10n.studySessionFillSpeakCorrectAnswerAction),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(MxActionButton, l10n.studyNextAction),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'DT10 onDisplay: last fill card shows finish session after the final answer',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-fill-finish-ready',
            cards: <({String front, String back})>[
              (front: '행복하다', back: 'Be happy'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocationWithMode(
          'session-fill-finish-ready',
          mode: StudyMode.fill,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await tester.enterText(find.byType(TextField), '행복하다');
      await tester.pump();
      final Finder checkButton = find.widgetWithText(
        MxActionButton,
        l10n.studySessionFillCheckAction,
      );
      await tester.ensureVisible(checkButton);
      await tester.tap(checkButton);
      await tester.pumpAndSettle();
      await tester.pump(
        DurationTokens.guessCorrectCountdown + const Duration(milliseconds: 20),
      );
      await tester.pumpAndSettle();

      expect(repository.recordCalls, 1);
      expect(
        find.text(l10n.studySessionFillReadyToFinishMessage),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(MxActionButton, l10n.studyFinalizeAction),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'DT11 onComplete: fill mode finalizes the session and navigates to result',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-fill-finalize-success',
            cards: <({String front, String back})>[
              (front: '행복하다', back: 'Be happy'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyResultRouter(
        _studySessionLocationWithMode(
          'session-fill-finalize-success',
          mode: StudyMode.fill,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await tester.enterText(find.byType(TextField), '행복하다');
      await tester.pump();
      final Finder checkButton = find.widgetWithText(
        MxActionButton,
        l10n.studySessionFillCheckAction,
      );
      await tester.ensureVisible(checkButton);
      await tester.tap(checkButton);
      await tester.pumpAndSettle();
      await tester.pump(
        DurationTokens.guessCorrectCountdown + const Duration(milliseconds: 20),
      );
      await tester.pumpAndSettle();
      final Finder finalizeButton = find.widgetWithText(
        MxActionButton,
        l10n.studyFinalizeAction,
      );
      await tester.ensureVisible(finalizeButton);
      await tester.tap(finalizeButton);
      await tester.pumpAndSettle();

      expect(repository.finalizeCalls, 1);
      expect(find.byType(StudyResultScreen), findsOneWidget);
      expect(find.byType(StudySessionScreen), findsNothing);
    },
  );

  testWidgets(
    'DT12 onComplete: fill mode finalize failure keeps the session open',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-fill-finalize-fail',
            cards: <({String front, String back})>[
              (front: '행복하다', back: 'Be happy'),
            ],
          ),
        ),
        finalizeResult: const Result<void>.err(
          Failure.finalization(sessionId: 'session-fill-finalize-fail'),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocationWithMode(
          'session-fill-finalize-fail',
          mode: StudyMode.fill,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await tester.enterText(find.byType(TextField), '행복하다');
      await tester.pump();
      final Finder checkButton = find.widgetWithText(
        MxActionButton,
        l10n.studySessionFillCheckAction,
      );
      await tester.ensureVisible(checkButton);
      await tester.tap(checkButton);
      await tester.pumpAndSettle();
      await tester.pump(
        DurationTokens.guessCorrectCountdown + const Duration(milliseconds: 20),
      );
      await tester.pumpAndSettle();
      final Finder finalizeButton = find.widgetWithText(
        MxActionButton,
        l10n.studyFinalizeAction,
      );
      await tester.ensureVisible(finalizeButton);
      await tester.tap(finalizeButton);
      await tester.pumpAndSettle();

      expect(repository.finalizeCalls, 1);
      expect(find.byType(StudySessionScreen), findsOneWidget);
      expect(find.text(l10n.studySessionFinalizeFailedMessage), findsOneWidget);
      expect(
        find.widgetWithText(MxActionButton, l10n.studyFinalizeAction),
        findsOneWidget,
      );
    },
  );
}
