import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/settings/screens/appearance_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/language_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/learning_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/tag_management_screen.dart';

/// Route registry for the Settings sub-screens (kit screens 11/20–25; WBS 8.3.2/8.2.2).
///
/// Registered as **top-level** routes (outside the bottom-nav shell) so each
/// settings sub-screen is immersive (shell hidden), per
/// `docs/wireframes/22-settings-tag-management.md`. Composed into `app_router.dart`
/// so it never imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`). The Settings hub +
/// remaining sub-screens land in later screen-build rounds.
List<RouteBase> settingsRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.settingsLearning,
    name: RouteNames.settingsLearning,
    builder: (context, state) => const LearningSettingsScreen(),
  ),
  GoRoute(
    path: RoutePaths.settingsAppearance,
    name: RouteNames.settingsAppearance,
    builder: (context, state) => const AppearanceSettingsScreen(),
  ),
  GoRoute(
    path: RoutePaths.settingsLanguage,
    name: RouteNames.settingsLanguage,
    builder: (context, state) => const LanguageSettingsScreen(),
  ),
  GoRoute(
    path: RoutePaths.settingsLearningTags,
    name: RouteNames.settingsLearningTags,
    builder: (context, state) => const SettingsTagManagementScreen(),
  ),
];
