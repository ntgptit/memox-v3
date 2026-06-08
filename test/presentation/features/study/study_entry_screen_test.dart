import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/routes/study_routes.dart';
import 'package:memox/presentation/features/study/screens/study_entry_screen.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:riverpod/misc.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository(this.result, {Result<StudySessionReview>? reviewResult})
    : reviewResult =
          reviewResult ??
          const Result<StudySessionReview>.err(
            Failure.notFound(entity: 'study_session', id: 'session-1'),
          );

  Result<StudyEntryStartResult> result;
  final Result<StudySessionReview> reviewResult;
  int startCalls = 0;

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    StudyMode? mode,
  }) async {
    startCalls++;
    return result;
  }

  @override
  Future<Result<StudySession?>> findResumableSession({
    required StudyScope scope,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<StudySessionReview>> loadStudySessionReview({
    required SessionId sessionId,
  }) async => reviewResult;

  @override
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
  }) async {
    throw UnimplementedError();
  }
}

Widget _appShell(
  Widget child, {
  List<Override> overrides = const <Override>[],
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

Widget _routerShell(
  GoRouter router, {
  List<Override> overrides = const <Override>[],
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  ),
);

GoRouter _studyRouter(String initialLocation) {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: studyRoutes(rootNavigatorKey),
  );
}

GoRouter _appRouter(String initialLocation) {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.library,
        name: RouteNames.library,
        builder: (_, _) =>
            const RoutePlaceholder(routeName: RouteNames.library),
      ),
      ...studyRoutes(rootNavigatorKey),
    ],
  );
}

String _studyLocation({
  required String entryType,
  required String entryRefId,
  String? studyType,
  String? mode,
}) {
  final Map<String, String> queryParameters = <String, String>{};
  if (studyType != null) {
    queryParameters[RoutePaths.studyTypeQueryParam] = studyType;
  }
  if (mode != null) {
    queryParameters[RoutePaths.modeQueryParam] = mode;
  }
  return Uri(
    path: RoutePaths.studyEntry(entryType, entryRefId),
    queryParameters: queryParameters.isEmpty ? null : queryParameters,
  ).toString();
}

String _studySessionLocation(String sessionId) =>
    RoutePaths.studySession(sessionId);

String _studyResultLocation(String sessionId) =>
    RoutePaths.studyResult(sessionId);

void main() {
  testWidgets('DT1 onOpen: invalid entryType renders error state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appShell(
        const StudyEntryScreen.scoped(entryType: 'bogus', entryRefId: 'deck-1'),
      ),
    );
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(StudyEntryScreen)),
    );

    expect(find.text(l10n.studyEntryInvalidTitle), findsOneWidget);
    expect(find.text(l10n.studyEntryInvalidMessage), findsOneWidget);
    expect(find.text(l10n.commonBack), findsOneWidget);
  });

  testWidgets(
    'DT2 onOpen: deck scope with zero eligible cards shows empty state',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudyEntryStartResult>.ok(
          StudyEntryStartResult.empty(
            emptyState: StudyEntryEmptyState(
              variant: StudyEntryEmptyVariant.deckNoCards,
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _appShell(
          const StudyEntryScreen.scoped(
            entryType: 'deck',
            entryRefId: 'deck-1',
          ),
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyEntryScreen)),
      );

      expect(find.byType(MxEmptyState), findsOneWidget);
      expect(find.text(l10n.studyEmpty_deck_noCards_title), findsOneWidget);
      expect(find.text(l10n.studyEmpty_deck_noCards_cta), findsOneWidget);
      expect(repository.startCalls, 1);
    },
  );

  testWidgets(
    'resume-required state shows controlled empty state and does not redirect',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudyEntryStartResult>.ok(
          StudyEntryStartResult.resumeRequired(sessionId: 'session-1'),
        ),
      );

      await tester.pumpWidget(
        _appShell(
          const StudyEntryScreen.scoped(
            entryType: 'deck',
            entryRefId: 'deck-1',
          ),
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyEntryScreen)),
      );

      expect(find.byType(MxEmptyState), findsOneWidget);
      expect(find.text(l10n.studyEntryResumeRequiredTitle), findsOneWidget);
      expect(find.text(l10n.studyEntryResumeRequiredMessage), findsOneWidget);
      expect(find.text(l10n.studyEntryResumeRequiredCta), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
      expect(repository.startCalls, 1);
    },
  );

  testWidgets(
    'resume-required back action falls back to Library when the navigator cannot pop',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudyEntryStartResult>.ok(
          StudyEntryStartResult.resumeRequired(sessionId: 'session-1'),
        ),
      );
      final GoRouter router = _appRouter(
        _studyLocation(entryType: 'deck', entryRefId: 'deck-1'),
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

      final MxActionButton button = tester.widget(find.byType(MxActionButton));
      button.onPressed!.call();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        router.routeInformationProvider.value.uri.toString(),
        RoutePaths.library,
      );
      expect(find.byType(StudyEntryScreen), findsNothing);
      expect(find.byType(MxEmptyState), findsNothing);
      expect(repository.startCalls, 1);
    },
  );

  testWidgets(
    'DT3 onOpen: deck scope with eligible cards redirects to session route',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudyEntryStartResult>.ok(
          StudyEntryStartResult.started(sessionId: 'session-1'),
        ),
      );
      final GoRouter router = _studyRouter(
        _studyLocation(entryType: 'deck', entryRefId: 'deck-1'),
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

      expect(find.byType(StudyEntryScreen), findsNothing);
      expect(find.byType(StudySessionScreen), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
      expect(
        find.widgetWithText(AppBar, RouteNames.studySession),
        findsNothing,
      );
      expect(repository.startCalls, 1);
    },
  );

  testWidgets(
    'DT4 onOpen: folder scope with eligible cards redirects to session route',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudyEntryStartResult>.ok(
          StudyEntryStartResult.started(sessionId: 'session-2'),
        ),
      );
      final GoRouter router = _studyRouter(
        _studyLocation(entryType: 'folder', entryRefId: 'folder-1'),
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

      expect(find.byType(StudyEntryScreen), findsNothing);
      expect(find.byType(StudySessionScreen), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
      expect(
        find.widgetWithText(AppBar, RouteNames.studySession),
        findsNothing,
      );
      expect(repository.startCalls, 1);
    },
  );

  testWidgets(
    'DT5 onOpen: today route with zero due cards shows all-done empty state',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudyEntryStartResult>.ok(
          StudyEntryStartResult.empty(
            emptyState: StudyEntryEmptyState(
              variant: StudyEntryEmptyVariant.todayAllDone,
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _appShell(
          const StudyEntryScreen.today(),
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyEntryScreen)),
      );

      expect(find.byType(MxEmptyState), findsOneWidget);
      expect(find.text(l10n.studyEmpty_today_allDone_title), findsOneWidget);
      expect(find.text(l10n.studyEmpty_today_allDone_message), findsOneWidget);
      expect(find.text(l10n.studyEmpty_today_allDone_cta), findsOneWidget);
      expect(repository.startCalls, 1);
    },
  );

  testWidgets(
    'DT6 onOpen: session route renders StudySessionScreen instead of StudyEntryScreen',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudyEntryStartResult>.ok(
          StudyEntryStartResult.started(sessionId: 'session-1'),
        ),
      );
      final GoRouter router = _studyRouter(_studySessionLocation('session-1'));

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StudyEntryScreen), findsNothing);
      expect(find.byType(StudySessionScreen), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
    },
  );

  testWidgets(
    'DT6a onOpen: session result route renders RoutePlaceholder instead of StudyEntryScreen',
    (tester) async {
      final GoRouter router = _studyRouter(_studyResultLocation('session-1'));

      await tester.pumpWidget(_routerShell(router));
      await tester.pumpAndSettle();

      expect(find.byType(StudyEntryScreen), findsNothing);
      expect(find.byType(RoutePlaceholder), findsOneWidget);
      expect(
        find.widgetWithText(AppBar, RouteNames.studyResult),
        findsOneWidget,
      );
      expect(find.text('sessionId: session-1'), findsOneWidget);
    },
  );
}
