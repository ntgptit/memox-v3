import 'package:flutter/animation.dart';

/// Motion easing curves (Material 3).
///
/// Block R of the design-token reference.
abstract final class EasingTokens {
  EasingTokens._();

  /// Most UI (easeInOut).
  static const Cubic standard = Cubic(0.2, 0, 0, 1);

  /// Large transitions.
  static const Cubic emphasized = Cubic(0.05, 0.7, 0.1, 1);

  /// Elements arriving.
  static const Cubic enter = Cubic(0, 0, 0.2, 1);

  /// Elements leaving.
  static const Cubic exit = Cubic(0.4, 0, 1, 1);
}
