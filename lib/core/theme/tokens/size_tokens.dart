/// Component sizing scale.
///
/// Block M of the design-token reference. Minimum touch target is [touch]
/// (48dp). Icons at [iconSm] (20, inline) and [iconMd] (24, standard).
abstract final class SizeTokens {
  SizeTokens._();

  /// Minimum hit target (accessibility floor).
  static const double touch = 48;

  // Icon glyph sizes.
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 64;

  // Button heights.
  static const double buttonSm = 36;
  static const double button = 48;
  static const double buttonLg = 52;

  /// Text-field height.
  static const double input = 52;

  // Chip heights.
  static const double chip = 32;
  static const double chipSm = 24;

  // App bar.
  static const double appbar = 56;
  static const double appbarLg = 64;

  /// M3 NavigationBar height.
  static const double bottomNav = 80;

  /// Floating action button.
  static const double fab = 56;
}
