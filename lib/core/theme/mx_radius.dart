import 'package:flutter/widgets.dart';

/// MemoX corner-radius tokens (theme-neutral).
///
/// Mirrors the `--memox-radius-*` scale and radius roles in
/// `docs/system-design/MemoX Design System/colors_and_type.css`. Radii do not
/// change between light and dark, so these are plain compile-time constants.
///
/// Feature/shared widgets must reference the ready-made [BorderRadius] values
/// below (`MxRadius.mdAll`, `MxRadius.cardAll`, …) rather than constructing
/// `BorderRadius.circular(...)` themselves — raw `BorderRadius`/`Radius`
/// constructors are confined to this token layer (guard
/// `flutter.no_hardcoded_radius`).
abstract final class MxRadius {
  const MxRadius._();

  // ---- Scale (--memox-radius-*) ----
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;

  /// Fully rounded ends (`--memox-radius-pill`); use for pills/chips/buttons.
  static const double pill = 999;

  // ---- Semantic radius roles ----
  /// Default card surface radius (`--memox-radius-card`).
  static const double card = lg;

  /// Pill-shaped buttons (`--memox-radius-button`).
  static const double button = pill;

  /// Floating action button radius (`--memox-radius-fab`).
  static const double fab = 18;

  // ---- Ready-made BorderRadius values (built here in the token layer so
  // widgets reference a token instead of constructing BorderRadius) ----
  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));

  /// Default card surface border radius (`--memox-radius-card`).
  static const BorderRadius cardAll = lgAll;

  /// Floating action button border radius (`--memox-radius-fab`).
  static const BorderRadius fabAll = BorderRadius.all(Radius.circular(fab));

  /// Top-only rounding for bottom sheets / modal hosts.
  static const BorderRadius topSheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
