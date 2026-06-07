import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/app_shell.dart';
import 'package:memox/app/router/redirect.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/presentation/features/flashcards/routes/flashcard_routes.dart';
import 'package:memox/presentation/features/folders/routes/folder_routes.dart';
import 'package:memox/presentation/features/settings/routes/settings_routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'home',
);
final GlobalKey<NavigatorState> _libraryNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'library');
final GlobalKey<NavigatorState> _progressNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'progress');
final GlobalKey<NavigatorState> _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

/// Application router.
///
/// Kept alive for the app lifetime. Feature screens are wired in as the
/// presentation layer is built; until then routes render [RoutePlaceholder].
/// Route structure and shell visibility follow
/// `docs/business/navigation/navigation-flow.md`.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteDefaults.initialLocation,
  debugLogDiagnostics: true,
  redirect: (context, state) => AppRedirect.resolve(state),
  routes: <RouteBase>[
    _shellRoute(),
    ..._libraryHiddenRoutes(),
    ..._studyRoutes(),
    ..._settingsRoutes(),
  ],
);

/// Bottom-nav shell with one branch per top-level destination.
StatefulShellRoute _shellRoute() => StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      MxAppShell(navigationShell: navigationShell),
  branches: <StatefulShellBranch>[
    StatefulShellBranch(
      navigatorKey: _homeNavigatorKey,
      routes: <RouteBase>[
        GoRoute(
          path: RoutePaths.home,
          name: RouteNames.home,
          builder: (context, state) =>
              const RoutePlaceholder(routeName: RouteNames.home),
        ),
      ],
    ),
    StatefulShellBranch(
      navigatorKey: _libraryNavigatorKey,
      // Library Overview + folder tree, composed from the feature registry.
      routes: libraryBranchRoutes(),
    ),
    StatefulShellBranch(
      navigatorKey: _progressNavigatorKey,
      routes: <RouteBase>[
        GoRoute(
          path: RoutePaths.progress,
          name: RouteNames.progress,
          builder: (context, state) =>
              const RoutePlaceholder(routeName: RouteNames.progress),
        ),
      ],
    ),
    StatefulShellBranch(
      navigatorKey: _settingsNavigatorKey,
      routes: settingsRoutes(_rootNavigatorKey),
    ),
  ],
);

/// Flashcard create/edit + import — pushed over the shell (shell hidden).
List<RouteBase> _libraryHiddenRoutes() => <RouteBase>[
  ...flashcardRoutes(_rootNavigatorKey),
];

/// Study entry/today/session/result — full-screen, shell hidden.
///
/// Literal `today` and `session/:id` routes are declared before the generic
/// `:entryType/:entryRefId` so GoRouter matches them first.
List<RouteBase> _studyRoutes() => <RouteBase>[
  GoRoute(
    parentNavigatorKey: _rootNavigatorKey,
    path: RoutePaths.studyTodayTemplate,
    name: RouteNames.studyToday,
    builder: (context, state) =>
        const RoutePlaceholder(routeName: RouteNames.studyToday),
  ),
  GoRoute(
    parentNavigatorKey: _rootNavigatorKey,
    path: RoutePaths.studySessionTemplate,
    name: RouteNames.studySession,
    builder: (context, state) => RoutePlaceholder(
      routeName: RouteNames.studySession,
      params: <String, String>{
        RoutePaths.sessionIdParam:
            state.pathParameters[RoutePaths.sessionIdParam] ?? '',
      },
    ),
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.resultSegment,
        name: RouteNames.studyResult,
        builder: (context, state) => RoutePlaceholder(
          routeName: RouteNames.studyResult,
          params: <String, String>{
            RoutePaths.sessionIdParam:
                state.pathParameters[RoutePaths.sessionIdParam] ?? '',
          },
        ),
      ),
    ],
  ),
  GoRoute(
    parentNavigatorKey: _rootNavigatorKey,
    path: RoutePaths.studyEntryTemplate,
    name: RouteNames.studyEntry,
    builder: (context, state) => RoutePlaceholder(
      routeName: RouteNames.studyEntry,
      params: <String, String>{
        RoutePaths.entryTypeParam:
            state.pathParameters[RoutePaths.entryTypeParam] ?? '',
        RoutePaths.entryRefIdParam:
            state.pathParameters[RoutePaths.entryRefIdParam] ?? '',
      },
    ),
  ),
];

/// Settings sub-screens — pushed over the shell to keep the hub on the stack.
List<RouteBase> _settingsRoutes() => <RouteBase>[
  ...settingsRoutes(_rootNavigatorKey),
];
