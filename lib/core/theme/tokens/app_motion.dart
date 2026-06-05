import 'package:flutter/animation.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/easing_tokens.dart';

/// A duration + curve pair for a single animation.
class MotionSpec {
  const MotionSpec(this.duration, this.curve);

  final Duration duration;
  final Curve curve;
}

/// Named motion presets pairing [DurationTokens] with [EasingTokens].
///
/// Use these instead of assembling `Duration` + `Curve` ad hoc so motion stays
/// consistent across the app. Bounce/elastic curves are an anti-pattern.
abstract final class AppMotion {
  AppMotion._();

  /// Tap acknowledgements / immediate feedback.
  static const MotionSpec instant = MotionSpec(
    DurationTokens.instant,
    EasingTokens.standard,
  );

  /// Color flips / state changes.
  static const MotionSpec stateChange = MotionSpec(
    DurationTokens.fast,
    EasingTokens.standard,
  );

  /// Content fades / cross-switches.
  static const MotionSpec contentSwitch = MotionSpec(
    DurationTokens.normal,
    EasingTokens.standard,
  );

  /// Element entering the screen.
  static const MotionSpec enter = MotionSpec(
    DurationTokens.normal,
    EasingTokens.enter,
  );

  /// Element leaving the screen.
  static const MotionSpec exit = MotionSpec(
    DurationTokens.fast,
    EasingTokens.exit,
  );

  /// Route / page transition.
  static const MotionSpec page = MotionSpec(
    DurationTokens.slow,
    EasingTokens.emphasized,
  );

  /// Review card flip.
  static const MotionSpec cardFlip = MotionSpec(
    DurationTokens.cardFlip,
    EasingTokens.standard,
  );
}
