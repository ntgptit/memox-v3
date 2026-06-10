import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';

/// Semantic typography role — feature code selects intent, not a Material slot
/// (`memox.design_system.no_direct_text_theme`).
enum MxTextRole {
  displaySmall,
  headlineMedium,
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

/// The sanctioned way for feature code to render text: pick an [MxTextRole] and
/// the same UI intent resolves to the same scale everywhere. This is the one
/// shared widget allowed to expose a public role API
/// (`memox.shared_widget.no_public_mx_text_role_api` excludes this file).
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
/// - data: public content.
/// - role: public property.
/// - color: public content.
/// - fontWeight: public property.
/// - maxLines: public property.
/// - overflow: public property.
/// - textAlign: public property.
/// Category:
/// display
class MxText extends StatelessWidget {
  const MxText(
    this.data, {
    required this.role,
    this.color,
    this.fontWeight,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  });

  final String data;
  final MxTextRole role;
  final Color? color;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = _baseStyle(context.textTheme) ?? const TextStyle();
    return Text(
      data,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: base.copyWith(color: color, fontWeight: fontWeight),
    );
  }

  TextStyle? _baseStyle(TextTheme t) => switch (role) {
    MxTextRole.displaySmall => t.displaySmall,
    MxTextRole.headlineMedium => t.headlineMedium,
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
}
