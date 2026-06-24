import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/history/screens/card_history_screen.dart';

/// Route registry for Card History (kit screen 09; WBS 7.6.3).
///
/// Registered as a **top-level** route (outside the bottom-nav shell) so the
/// per-card timeline is immersive — no bottom nav, matching the mock and
/// `docs/business/navigation/navigation-flow.md` (pushed from the root navigator,
/// shell hidden). The full path `…/flashcards/:flashcardId/history` does not
/// collide with the Library-branch flashcard-list children (`new`, `:id/edit`).
/// Composed into `app_router.dart` so it never imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`).
List<RouteBase> historyRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.flashcardHistory,
    name: RouteNames.flashcardHistory,
    builder: (context, state) => CardHistoryScreen(
      deckId: state.pathParameters[RouteParams.deckId] ?? '',
      flashcardId: state.pathParameters[RouteParams.flashcardId] ?? '',
    ),
  ),
];
