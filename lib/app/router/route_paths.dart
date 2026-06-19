/// URL path constants for GoRouter.
///
/// Paths are the single source of truth for `go`/`push`/`replace` call sites —
/// never pass a raw path literal (see `memox.routing.no_raw_route_path_string`).
/// Top-level destinations mirror `docs/business/navigation/navigation-flow.md`
/// §Top-level destinations.
abstract final class RoutePaths {
  static const String root = '/';
  static const String home = '/home';
  static const String library = '/library';
  static const String progress = '/progress';
  static const String settings = '/settings';
}

/// Router-level defaults.
///
/// `initialLocation` is where app boot lands after the root (`/`) redirect — the
/// Library, per `docs/business/navigation/navigation-flow.md` §Top-level
/// destinations ("Current V1 app boot redirects `/` to
/// `RouteDefaults.initialLocation = RoutePaths.library`").
abstract final class RouteDefaults {
  static const String initialLocation = RoutePaths.library;
}
