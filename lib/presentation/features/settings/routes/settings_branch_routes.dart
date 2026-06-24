import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/settings/screens/settings_screen.dart';

/// Route registry for the Settings tab (`/settings` shell branch; kit screen 20).
///
/// Composed into the app router's fifth (Settings) shell branch so
/// `app_router.dart` never imports feature screens directly
/// (`memox.routing.app_router_no_feature_screen_imports`). The hub keeps the
/// bottom-nav shell; its rows push the immersive settings sub-screens
/// (`settingsRoutes()`). WBS 8.1.x.
List<RouteBase> settingsBranchRoutes() => <RouteBase>[
  GoRoute(
    path: RoutePaths.settings,
    name: RouteNames.settings,
    builder: (context, state) => const SettingsScreen(),
  ),
];
