import 'package:flutter/material.dart';

/// MemoX semantic color palette, exposed as a [ThemeExtension] so it flips with
/// the active [Brightness].
///
/// These mirror the base palette + contract layer in
/// `docs/system-design/MemoX Design System/colors_and_type.css`. Material's
/// [ColorScheme] covers the core roles (primary/surface/error/outline); this
/// extension carries the MemoX-specific tokens Material cannot express — soft
/// tints, secondary semantics, divider/focus, and the note/status/mastery
/// scales. Read it via `Theme.of(context).extension<MxColors>()!` (or the
/// `context.mxColors` helper) — never hardcode a hex.
@immutable
class MxColors extends ThemeExtension<MxColors> {
  const MxColors({
    required this.accent,
    required this.accentSoft,
    required this.accentContrast,
    required this.bg,
    required this.surface,
    required this.surfaceMuted,
    required this.overlay,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.focusRing,
    required this.success,
    required this.successSoft,
    required this.warn,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.noteYellow,
    required this.noteAmber,
    required this.noteGreen,
    required this.noteTeal,
    required this.noteBlue,
    required this.noteViolet,
    required this.notePink,
    required this.noteClay,
  });

  // ---- Brand / accent ----
  final Color accent;
  final Color accentSoft;
  final Color accentContrast;

  // ---- Surfaces ----
  final Color bg;
  final Color surface;
  final Color surfaceMuted;
  final Color overlay;

  // ---- Text ----
  final Color text;
  final Color textSecondary;
  final Color textTertiary;

  // ---- Lines ----
  final Color border;
  final Color borderStrong;
  final Color divider;
  final Color focusRing;

  // ---- Semantic ----
  final Color success;
  final Color successSoft;
  final Color warn;
  final Color danger;
  final Color dangerSoft;
  final Color info;

  // ---- Note label colors ----
  final Color noteYellow;
  final Color noteAmber;
  final Color noteGreen;
  final Color noteTeal;
  final Color noteBlue;
  final Color noteViolet;
  final Color notePink;
  final Color noteClay;

  // ---- Contract aliases (resolved from the base palette, matching the
  // `var()` aliases in colors_and_type.css; no extra storage so they stay in
  // lockstep with the base tokens) ----

  // Spaced-repetition card status.
  Color get statusNew => info;
  Color get statusLearning => warn;
  Color get statusReviewing => noteTeal;
  Color get statusMastered => success;

  // Per-deck mastery scale (low → mid → high).
  Color get masteryLow => danger;
  Color get masteryMid => warn;
  Color get masteryHigh => success;

  // Study rating (an answer scored right / wrong).
  Color get ratingCorrect => success;
  Color get ratingCorrectSoft => successSoft;
  Color get ratingWrong => danger;
  Color get ratingWrongSoft => dangerSoft;

  // Recall self-assessment.
  Color get selfMissed => danger;
  Color get selfPartial => warn;
  Color get selfGot => success;

  /// Light scheme tokens (`:root` / `.memox-light`).
  static const MxColors light = MxColors(
    accent: Color(0xFF5569FF),
    accentSoft: Color(0xFFEEF0FF),
    accentContrast: Color(0xFFFFFFFF),
    bg: Color(0xFFF2F5F9),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEDEFF4),
    overlay: Color(0x73223354),
    text: Color(0xFF223354),
    textSecondary: Color(0xFF5A6378),
    textTertiary: Color(0xFF9098AC),
    border: Color(0xFFE6E8EE),
    borderStrong: Color(0xFFD5D8E1),
    divider: Color(0xFFEEEFF3),
    focusRing: Color(0x4D5569FF),
    success: Color(0xFF2E9E5B),
    successSoft: Color(0xFFE9F4EE),
    warn: Color(0xFFFFA319),
    danger: Color(0xFFDD4257),
    dangerSoft: Color(0xFFFBEAEC),
    info: Color(0xFF33C2FF),
    noteYellow: Color(0xFFFFD75E),
    noteAmber: Color(0xFFFFB454),
    noteGreen: Color(0xFF8FD79A),
    noteTeal: Color(0xFF6FD3C4),
    noteBlue: Color(0xFF84B6F7),
    noteViolet: Color(0xFFB9A4F0),
    notePink: Color(0xFFF6A8C4),
    noteClay: Color(0xFFE2917A),
  );

  /// Dark scheme tokens (`.memox-dark`).
  static const MxColors dark = MxColors(
    accent: Color(0xFF5E72FF),
    accentSoft: Color(0xFF1A2350),
    accentContrast: Color(0xFFFFFFFF),
    bg: Color(0xFF070C27),
    surface: Color(0xFF111633),
    surfaceMuted: Color(0xFF191E3B),
    overlay: Color(0x99000000),
    text: Color(0xFFCBCCD2),
    textSecondary: Color(0xFF9EA4C1),
    textTertiary: Color(0xFF6F7490),
    border: Color(0xFF272C48),
    borderStrong: Color(0xFF353B5C),
    divider: Color(0xFF1F243F),
    focusRing: Color(0x668C7CF0),
    success: Color(0xFF46B87C),
    successSoft: Color(0xFF14301F),
    warn: Color(0xFFFFA319),
    danger: Color(0xFFF26B79),
    dangerSoft: Color(0xFF2E1620),
    info: Color(0xFF33C2FF),
    noteYellow: Color(0xFFC9A93E),
    noteAmber: Color(0xFFC98A3C),
    noteGreen: Color(0xFF5FA76C),
    noteTeal: Color(0xFF4AA396),
    noteBlue: Color(0xFF5687C4),
    noteViolet: Color(0xFF8B79C0),
    notePink: Color(0xFFC47B97),
    noteClay: Color(0xFFB36C57),
  );

  @override
  MxColors copyWith({
    Color? accent,
    Color? accentSoft,
    Color? accentContrast,
    Color? bg,
    Color? surface,
    Color? surfaceMuted,
    Color? overlay,
    Color? text,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? borderStrong,
    Color? divider,
    Color? focusRing,
    Color? success,
    Color? successSoft,
    Color? warn,
    Color? danger,
    Color? dangerSoft,
    Color? info,
    Color? noteYellow,
    Color? noteAmber,
    Color? noteGreen,
    Color? noteTeal,
    Color? noteBlue,
    Color? noteViolet,
    Color? notePink,
    Color? noteClay,
  }) => MxColors(
    accent: accent ?? this.accent,
    accentSoft: accentSoft ?? this.accentSoft,
    accentContrast: accentContrast ?? this.accentContrast,
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    overlay: overlay ?? this.overlay,
    text: text ?? this.text,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    border: border ?? this.border,
    borderStrong: borderStrong ?? this.borderStrong,
    divider: divider ?? this.divider,
    focusRing: focusRing ?? this.focusRing,
    success: success ?? this.success,
    successSoft: successSoft ?? this.successSoft,
    warn: warn ?? this.warn,
    danger: danger ?? this.danger,
    dangerSoft: dangerSoft ?? this.dangerSoft,
    info: info ?? this.info,
    noteYellow: noteYellow ?? this.noteYellow,
    noteAmber: noteAmber ?? this.noteAmber,
    noteGreen: noteGreen ?? this.noteGreen,
    noteTeal: noteTeal ?? this.noteTeal,
    noteBlue: noteBlue ?? this.noteBlue,
    noteViolet: noteViolet ?? this.noteViolet,
    notePink: notePink ?? this.notePink,
    noteClay: noteClay ?? this.noteClay,
  );

  @override
  MxColors lerp(covariant ThemeExtension<MxColors>? other, double t) {
    if (other is! MxColors) {
      return this;
    }
    return MxColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentContrast: Color.lerp(accentContrast, other.accentContrast, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      noteYellow: Color.lerp(noteYellow, other.noteYellow, t)!,
      noteAmber: Color.lerp(noteAmber, other.noteAmber, t)!,
      noteGreen: Color.lerp(noteGreen, other.noteGreen, t)!,
      noteTeal: Color.lerp(noteTeal, other.noteTeal, t)!,
      noteBlue: Color.lerp(noteBlue, other.noteBlue, t)!,
      noteViolet: Color.lerp(noteViolet, other.noteViolet, t)!,
      notePink: Color.lerp(notePink, other.notePink, t)!,
      noteClay: Color.lerp(noteClay, other.noteClay, t)!,
    );
  }
}

/// Convenience access to [MxColors] from a [BuildContext].
extension MxColorsContext on BuildContext {
  /// The active MemoX color tokens. Asserts the extension is registered (it is,
  /// for any theme built by `MxTheme`).
  MxColors get mxColors => Theme.of(this).extension<MxColors>()!;
}
