import 'package:flutter/material.dart';

/// MemoX elevation tokens, exposed as a [ThemeExtension] so they flip with the
/// active [Brightness].
///
/// Mirrors `--memox-shadow-sm/md/lg` in
/// `docs/system-design/MemoX Design System/colors_and_type.css`. MemoX is a
/// calm learning app: shadows are **neutral only** — never colored or glowing.
/// Use [sm] for cards, [md] for floating controls (FAB/popover), [lg] for
/// sheets/dialogs. Prefer a border over a shadow when either would do.
@immutable
class MxShadows extends ThemeExtension<MxShadows> {
  const MxShadows({required this.sm, required this.md, required this.lg});

  /// Cards — the quietest elevation.
  final List<BoxShadow> sm;

  /// Floating controls (FAB, popover).
  final List<BoxShadow> md;

  /// Sheets and dialogs.
  final List<BoxShadow> lg;

  /// Light scheme shadows (neutral warm-grey, low opacity).
  static const MxShadows light = MxShadows(
    sm: [
      BoxShadow(color: Color(0x0D1B1A17), offset: Offset(0, 1), blurRadius: 2),
    ],
    md: [
      BoxShadow(color: Color(0x0F1B1A17), offset: Offset(0, 2), blurRadius: 8),
    ],
    lg: [
      BoxShadow(color: Color(0x1A1B1A17), offset: Offset(0, 8), blurRadius: 28),
    ],
  );

  /// Dark scheme shadows (pure black, higher opacity to read on dark surfaces).
  static const MxShadows dark = MxShadows(
    sm: [
      BoxShadow(color: Color(0x4D000000), offset: Offset(0, 1), blurRadius: 2),
    ],
    md: [
      BoxShadow(color: Color(0x61000000), offset: Offset(0, 2), blurRadius: 8),
    ],
    lg: [
      BoxShadow(color: Color(0x7A000000), offset: Offset(0, 8), blurRadius: 28),
    ],
  );

  @override
  MxShadows copyWith({
    List<BoxShadow>? sm,
    List<BoxShadow>? md,
    List<BoxShadow>? lg,
  }) => MxShadows(sm: sm ?? this.sm, md: md ?? this.md, lg: lg ?? this.lg);

  @override
  MxShadows lerp(covariant ThemeExtension<MxShadows>? other, double t) {
    if (other is! MxShadows) {
      return this;
    }
    return MxShadows(
      sm: BoxShadow.lerpList(sm, other.sm, t)!,
      md: BoxShadow.lerpList(md, other.md, t)!,
      lg: BoxShadow.lerpList(lg, other.lg, t)!,
    );
  }
}

/// Convenience access to [MxShadows] from a [BuildContext].
extension MxShadowsContext on BuildContext {
  /// The active MemoX elevation tokens.
  MxShadows get mxShadows => Theme.of(this).extension<MxShadows>()!;
}
