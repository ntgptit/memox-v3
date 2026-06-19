import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_paths.dart';

/// Top-level GoRouter redirect.
///
/// Sends the bare root (`/`) to [RouteDefaults.initialLocation] so app boot
/// lands on the Library, per `docs/business/navigation/navigation-flow.md`
/// §Top-level destinations. Returns `null` (no redirect) for every other
/// location so feature routes resolve normally.
String? rootRedirect(BuildContext context, GoRouterState state) {
  if (state.matchedLocation == RoutePaths.root) {
    return RouteDefaults.initialLocation;
  }
  return null;
}
