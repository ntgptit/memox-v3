/// Motion duration scale.
///
/// Block Q of the design-token reference. `elasticOut`/bounce is an
/// anti-pattern — never use it.
abstract final class DurationTokens {
  DurationTokens._();

  static const Duration instant = Duration(milliseconds: 50);

  /// Color flips / state changes.
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration stateChange = fast;

  /// Fades / content switches.
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration contentSwitch = normal;

  /// Route changes / page transitions.
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration pageTransition = slow;

  static const Duration slower = Duration(milliseconds: 500);

  /// Review card flip.
  static const Duration cardFlip = Duration(milliseconds: 350);

  /// Stat count-up.
  static const Duration countUp = Duration(milliseconds: 400);

  /// Stats chart draw-in.
  static const Duration chartDraw = Duration(milliseconds: 600);
}
