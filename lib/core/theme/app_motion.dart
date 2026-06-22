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

  /// The brief hold after the last pair of a Match board locks (showing the
  /// green ✓) before the next board appears / the session finalizes (wireframe
  /// `14` §Layout board-clear).
  static const Duration matchBoardAdvance = Duration(milliseconds: 500);

  /// The auto-advance countdown after a **correct** Guess pick — the reveal
  /// holds, then the next card appears (wireframe `15` §States — "0.8s").
  static const Duration guessRevealCorrect = Duration(milliseconds: 800);

  /// The auto-advance countdown after a **wrong** Guess pick — longer so the
  /// learner sees the correct answer before advancing (wireframe `15` — "1.5s").
  static const Duration guessRevealWrong = Duration(milliseconds: 1500);

  /// The auto-advance countdown after a **correct** Fill answer — the ✓ holds,
  /// then the next card appears (tappable to skip; wireframe `17` — "0.8s").
  static const Duration fillAutoAdvance = Duration(milliseconds: 800);
}
