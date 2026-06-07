import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

/// Account identity — image, initials, or placeholder glyph.
///
/// Section C of the handoff. Provide [imageProvider] for a photo, [initials]
/// for an initials fallback, or neither for the placeholder icon. Sizes
/// 32 / 40 / 48.
///
/// Purpose:
/// Provides a reusable MemoX display widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared display surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - imageProvider: public property.
/// - initials: public property.
/// - size: public configuration.
/// - backgroundColor: public property.
/// - foregroundColor: public property.
/// Category:
/// display
class MxAvatar extends StatelessWidget {
  const MxAvatar({
    this.imageProvider,
    this.initials,
    this.size = SizeTokens.button,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final ImageProvider<Object>? imageProvider;
  final String? initials;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    if (imageProvider != null) {
      return CircleAvatar(radius: size / 2, backgroundImage: imageProvider);
    }
    final Color bg = backgroundColor ?? scheme.primary;
    final Color fg = foregroundColor ?? scheme.onPrimary;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bg,
      child: initials == null || initials!.isEmpty
          ? Icon(Icons.person_outline, size: size * 0.5, color: fg)
          : Text(
              initials!,
              style: TextStyle(
                color: fg,
                fontSize: size * 0.36,
                fontWeight: TypographyTokens.bold,
                fontFamily: TypographyTokens.fontFamily,
              ),
            ),
    );
  }
}
