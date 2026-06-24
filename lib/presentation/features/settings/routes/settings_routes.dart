import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/settings/screens/tag_management_screen.dart';

/// Route registry for the Settings sub-screens (kit screens 11/20–25; WBS 8.3.2).
///
/// Registered as **top-level** routes (outside the bottom-nav shell) so each
/// settings sub-screen is immersive (shell hidden), per
/// `docs/wireframes/22-settings-tag-management.md`. Composed into `app_router.dart`
/// so it never imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`). Tag Management is the
/// first; the Settings hub + other sub-screens land in later screen-build rounds.
List<RouteBase> settingsRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.settingsLearningTags,
    name: RouteNames.settingsLearningTags,
    builder: (context, state) => const SettingsTagManagementScreen(),
  ),
];
