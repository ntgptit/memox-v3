import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/presentation/features/study/screens/fill_session_screen.dart';
import 'package:memox/presentation/features/study/screens/guess_session_screen.dart';
import 'package:memox/presentation/features/study/screens/match_session_screen.dart';
import 'package:memox/presentation/features/study/screens/recall_session_screen.dart';
import 'package:memox/presentation/features/study/screens/study_entry_screen.dart';
import 'package:memox/presentation/features/study/screens/study_result_screen.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';

/// Route registry for the Study feature.
///
/// Registered as **top-level** routes (outside the bottom-nav shell) so the
/// entry gate + session are immersive (no bottom nav), per
/// `docs/wireframes/12-study-entry-gate.md` + `13-study-session-review.md`.
/// Composed into `app_router.dart` so it never imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`). The `session/:sessionId`
/// route is listed **before** the `:entryType/:entryRefId` gate so the literal
/// `session` segment wins over the `:entryType` parameter. WBS 4.1.2 / 4.2.2.
List<RouteBase> studyRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.studySession,
    name: RouteNames.studySession,
    // `?mode=` selects the mode surface — `match` (board), `guess` (multiple
    // choice), `recall` (flip-card self-grade), `fill` (typed production); any
    // other / absent value falls back to the default Review session.
    builder: (context, state) {
      final String sessionId =
          state.pathParameters[RouteParams.sessionId] ?? '';
      final String? mode =
          state.uri.queryParameters[RouteParams.modeQueryParam];
      if (mode == StudyMode.match.name) {
        return MatchSessionScreen(sessionId: sessionId);
      }
      if (mode == StudyMode.guess.name) {
        return GuessSessionScreen(sessionId: sessionId);
      }
      if (mode == StudyMode.recall.name) {
        return RecallSessionScreen(sessionId: sessionId);
      }
      if (mode == StudyMode.fill.name) {
        return FillSessionScreen(sessionId: sessionId);
      }
      return StudySessionScreen(sessionId: sessionId);
    },
  ),
  // The result summary — `session/:sessionId/result`, listed near the session
  // route. The Finish action finalizes then `pushReplacement`s here.
  GoRoute(
    path: RoutePaths.studyResult,
    name: RouteNames.studyResult,
    builder: (context, state) => StudyResultScreen(
      sessionId: state.pathParameters[RouteParams.sessionId] ?? '',
    ),
  ),
  // Global `today` entry — literal route, no `:entryRefId` (a `today` scope has
  // a null ref id). Distinct segment count from the `:entryType/:entryRefId`
  // gate, so there is no ambiguity.
  GoRoute(
    path: RoutePaths.studyToday,
    name: RouteNames.studyToday,
    builder: (context, state) => StudyEntryScreen(
      entryType: EntryType.today.name,
      studyTypeRaw: state.uri.queryParameters[RouteParams.studyTypeQueryParam],
    ),
  ),
  GoRoute(
    path: RoutePaths.studyEntry,
    name: RouteNames.studyEntry,
    builder: (context, state) => StudyEntryScreen(
      entryType: state.pathParameters[RouteParams.entryType] ?? '',
      entryRefId: state.pathParameters[RouteParams.entryRefId],
      studyTypeRaw: state.uri.queryParameters[RouteParams.studyTypeQueryParam],
    ),
  ),
];
