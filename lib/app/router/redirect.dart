import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_paths.dart';

/// Top-level GoRouter redirect rules.
///
/// Keeps redirect policy out of the route table. See
/// `docs/business/navigation/navigation-flow.md` §Invalid route / Deep link.
abstract final class AppRedirect {
  AppRedirect._();

  /// Route prefixes that must not be entered via deep link. Accessing one
  /// cold (e.g. shared URL, app restart) redirects to a safe public ancestor.
  static const List<String> _privatePrefixes = <String>[
    // Study session lifecycle is created in-app, never deep-linked.
    '${RoutePaths.library}/${RoutePaths.studySegment}/${RoutePaths.sessionSegment}',
    '${RoutePaths.library}/${RoutePaths.studySegment}/${RoutePaths.todaySegment}',
  ];

  /// Returns the location to redirect to, or `null` to proceed as-is.
  static String? resolve(GoRouterState state) {
    final location = state.uri.path;

    // Boot / bare root → V1 initial location.
    if (location == RoutePaths.root) {
      return RouteDefaults.initialLocation;
    }

    // Private routes reached cold → fall back to a safe public ancestor.
    for (final prefix in _privatePrefixes) {
      if (location.startsWith(prefix)) {
        return RouteDefaults.initialLocation;
      }
    }

    return null;
  }
}
