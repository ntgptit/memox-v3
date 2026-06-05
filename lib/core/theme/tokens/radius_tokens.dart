import 'package:flutter/widgets.dart';

/// Corner-radius scale.
///
/// Block L of the design-token reference. Cards/dialogs/sheets = [lg] (16),
/// buttons/inputs = [md] (12), chips/avatars/FAB = [full]/[xxl].
abstract final class RadiusTokens {
  RadiusTokens._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 28;
  static const double full = 999;

  // Convenience BorderRadius for the common roles.
  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brFull = BorderRadius.all(Radius.circular(full));
}
