import 'package:flutter/widgets.dart';

/// Border tokens.
///
/// Block N of the design-token reference. The "ghost border" (primary at
/// [ghostOpacity]) replaces shadows on every card.
abstract final class BorderTokens {
  BorderTokens._();

  /// Default hairline.
  static const double width = 1;

  /// Accent edge.
  static const double widthThick = 4;

  /// Focus ring width.
  static const double focusWidth = 2;

  /// Focus ring offset.
  static const double focusOffset = 2;

  /// Ghost border = primary tinted to this opacity.
  static const double ghostOpacity = 0.14;

  /// 1px primary @14% — the card border across the system.
  static BorderSide ghostSide(Color primary) => BorderSide(
    color: primary.withValues(alpha: ghostOpacity),
    width: width,
  );

  /// 1px outlineVariant — a stronger separator than [ghostSide].
  static BorderSide strongSide(Color outlineVariant) =>
      BorderSide(color: outlineVariant, width: width);

  /// 4px solid primary — left accent edge.
  static BorderSide accentSide(Color primary) =>
      BorderSide(color: primary, width: widthThick);
}
