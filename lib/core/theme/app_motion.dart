/// Animation / transition / flash duration tokens.
///
/// Presentation surfaces MUST source motion durations here (or another approved
/// constant), never raw `Duration(...)` literals — see the guard rule
/// `memox.design_token.no_raw_duration_value`. Domain/data durations (SRS
/// intervals, timeouts) are a separate concern and stay in their own layers.
abstract final class AppMotion {
  /// The transient red flash shown on a wrong Match pair before the two cells
  /// deselect (wireframe `14` §Components — "~600ms").
  static const Duration matchWrongFlash = Duration(milliseconds: 600);
}
