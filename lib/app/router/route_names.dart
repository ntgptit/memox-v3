/// Named-route identifiers for GoRouter.
///
/// Route names are the single source of truth for `goNamed`/`pushNamed` call
/// sites — never pass a raw string literal (see `memox.routing.no_raw_route_name_string`).
/// Top-level destinations mirror `docs/business/navigation/navigation-flow.md`
/// §Top-level destinations.
abstract final class RouteNames {
  static const String root = 'root';
  static const String home = 'home';
  static const String library = 'library';
  static const String progress = 'progress';
  static const String settings = 'settings';
}
