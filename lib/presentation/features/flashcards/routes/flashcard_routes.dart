import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/flashcards/screens/deck_import_screen.dart';

/// Route registry for immersive flashcard sub-screens (kit screen 10; WBS 6.3.1).
///
/// Registered as **top-level** routes (outside the bottom-nav shell) so the
/// import wizard is immersive (shell hidden), per `docs/wireframes/10-deck-import.md`.
/// Composed into `app_router.dart` so it never imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`). The flashcard editor
/// (`07`/`08`) stays a Library-branch child; only the import wizard is immersive.
List<RouteBase> flashcardImmersiveRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.deckImport,
    name: RouteNames.deckImport,
    builder: (context, state) => DeckImportScreen(
      deckId: state.pathParameters[RouteParams.deckId] ?? '',
    ),
  ),
];
