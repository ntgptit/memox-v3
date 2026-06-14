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
  static const double iconTiny = 11;
  static const double iconMini = 12;
  static const double iconMinor = 18;
  static const double iconBadge = 22;
  static const double iconTile = 30;
  static const double dot = 2;
  static const double surfaceBadge = 26;
  static const double surfaceBadgeSm = 28;
  static const double surfaceTileSm = 38;

  // Button heights.
  static const double buttonSm = 36;
  static const double button = 48;
  static const double buttonLg = 52;
  static const double controlMd = 40;
  static const double avatar = 44;
  static const double dialogActionWidth = 128;

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

  /// Compact in-card placeholder line.
  static const double bar = 4;

  /// In-card data visualization height (Progress bar chart / sparkline —
  /// kit `19-progress` measures both plot areas at 80px).
  static const double chart = 80;
}
