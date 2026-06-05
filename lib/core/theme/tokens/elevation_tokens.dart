/// Elevation scale (Material 3 tonal).
///
/// Block P of the design-token reference. Hierarchy is carried by the
/// surface-container ladder, not shadows. Cards are flat ([level0]); FAB =
/// [level2]; dialogs = [level3]. Shadows cap at [shadowOpacity].
abstract final class ElevationTokens {
  ElevationTokens._();

  /// Max shadow opacity anywhere in the system.
  static const double shadowOpacity = 0.06;

  static const double level0 = 0;

  /// Raised surface, light mode.
  static const double level1 = 1;

  /// FAB.
  static const double level2 = 3;

  /// Dialog.
  static const double level3 = 6;

  /// Maximum.
  static const double level5 = 12;
}
