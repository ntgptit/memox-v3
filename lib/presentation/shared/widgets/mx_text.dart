import 'package:flutter/material.dart';

/// Semantic text roles mapped onto the MemoX type scale (`MxTypography.textTheme`).
///
/// Feature code selects intent (`MxTextRole`) rather than a raw Material
/// text-theme slot, so the same UI intent resolves to the same scale across
/// screens (`memox.design_system.no_direct_text_theme`).
enum MxTextRole {
  displayLarge,
  displayMedium,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

/// The sanctioned text widget — routes semantic typography through a
/// [MxTextRole] instead of `Theme.of(context).textTheme.*`. Colour comes from
/// the active theme unless [color] overrides it. WBS 1.2.7.
///
/// Purpose:
/// One place that maps UI text intent to the type scale, so screens stay
/// consistent and the type scale can evolve centrally.
///
/// Use when:
/// Rendering any text in a feature screen.
///
/// Do not use when:
/// A shared widget already owns its own text styling.
///
/// Category:
/// display
///
/// Public API:
/// - data: the string to render.
/// - role: the semantic type role.
/// - color: optional colour override.
/// - maxLines / overflow / textAlign: standard text layout controls.
class MxText extends StatelessWidget {
  const MxText(
    this.data, {
    this.role = MxTextRole.bodyMedium,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  });

  final String data;
  final MxTextRole role;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  TextStyle? _style(TextTheme t) => switch (role) {
    MxTextRole.displayLarge => t.displayLarge,
    MxTextRole.displayMedium => t.displayMedium,
    MxTextRole.titleLarge => t.titleLarge,
    MxTextRole.titleMedium => t.titleMedium,
    MxTextRole.titleSmall => t.titleSmall,
    MxTextRole.bodyLarge => t.bodyLarge,
    MxTextRole.bodyMedium => t.bodyMedium,
    MxTextRole.bodySmall => t.bodySmall,
    MxTextRole.labelLarge => t.labelLarge,
    MxTextRole.labelMedium => t.labelMedium,
    MxTextRole.labelSmall => t.labelSmall,
  };

  @override
  Widget build(BuildContext context) {
    final TextStyle? base = _style(Theme.of(context).textTheme);
    final Color? color = this.color;
    return Text(
      data,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: color == null ? base : base?.copyWith(color: color),
    );
  }
}
