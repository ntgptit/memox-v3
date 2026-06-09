import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/study/screens/study_entry_screen.dart';
import 'package:memox/presentation/features/study/screens/study_result_screen.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';

/// Study routes, composed by `app_router.dart`.
///
/// Today and scoped study entry are real screens that start persisted sessions
/// when eligible cards exist. Session and result routes are real screens too.
List<RouteBase> studyRoutes(
  GlobalKey<NavigatorState> rootNavigatorKey,
) => <RouteBase>[
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: RoutePaths.studyTodayTemplate,
    name: RouteNames.studyToday,
    builder: (context, state) => StudyEntryScreen.today(
      studyTypeQuery: state.uri.queryParameters[RoutePaths.studyTypeQueryParam],
      modeQuery: state.uri.queryParameters[RoutePaths.modeQueryParam],
    ),
  ),
  // Declare specific study session routes before the generic scoped entry
  // route. Otherwise `/library/study/session/:sessionId` can be consumed
  // as `entryType=session` + `entryRefId=<sessionId>`.
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: RoutePaths.studySessionTemplate,
    name: RouteNames.studySession,
    builder: (context, state) => StudySessionScreen(
      sessionId: state.pathParameters[RoutePaths.sessionIdParam] ?? '',
    ),
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.resultSegment,
        name: RouteNames.studyResult,
        builder: (context, state) => StudyResultScreen(
          sessionId: state.pathParameters[RoutePaths.sessionIdParam] ?? '',
        ),
      ),
    ],
  ),
  GoRoute(
    parentNavigatorKey: rootNavigatorKey,
    path: RoutePaths.studyEntryTemplate,
    name: RouteNames.studyEntry,
    builder: (context, state) => StudyEntryScreen.scoped(
      entryType: state.pathParameters[RoutePaths.entryTypeParam] ?? '',
      entryRefId: state.pathParameters[RoutePaths.entryRefIdParam],
      studyTypeQuery: state.uri.queryParameters[RoutePaths.studyTypeQueryParam],
      modeQuery: state.uri.queryParameters[RoutePaths.modeQueryParam],
    ),
  ),
];
