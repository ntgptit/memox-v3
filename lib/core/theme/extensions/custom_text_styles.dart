import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

/// Text styles with no Material `TextTheme` slot.
///
/// `statDisplay` (48, block J) is the oversized number used on dashboard/result
/// stats; `overline` is the ALL-CAPS section label. Resolve via
/// `Theme.of(context).extension<CustomTextStyles>()!`.
@immutable
class CustomTextStyles extends ThemeExtension<CustomTextStyles> {
  const CustomTextStyles({required this.statDisplay, required this.overline});

  /// Builds the styles for a given foreground [onSurface] color.
  factory CustomTextStyles.fromOnSurface(Color onSurface) => CustomTextStyles(
    statDisplay: TextStyle(
      fontFamily: TypographyTokens.fontFamily,
      color: onSurface,
      fontSize: 48,
      fontWeight: TypographyTokens.semiBold,
      height: 1.1,
      letterSpacing: TypographyTokens.tightSpacing,
    ),
    overline: TextStyle(
      fontFamily: TypographyTokens.fontFamily,
      color: onSurface,
      fontSize: 12,
      fontWeight: TypographyTokens.bold,
      height: 1.4,
      letterSpacing: TypographyTokens.sectionSpacing,
    ),
  );

  final TextStyle statDisplay;
  final TextStyle overline;

  @override
  CustomTextStyles copyWith({TextStyle? statDisplay, TextStyle? overline}) =>
      CustomTextStyles(
        statDisplay: statDisplay ?? this.statDisplay,
        overline: overline ?? this.overline,
      );

  @override
  CustomTextStyles lerp(covariant CustomTextStyles? other, double t) {
    if (other == null) {
      return this;
    }
    return CustomTextStyles(
      statDisplay: TextStyle.lerp(statDisplay, other.statDisplay, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
    );
  }
}
