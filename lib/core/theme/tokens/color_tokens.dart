import 'package:flutter/painting.dart';

/// Primitive color palette — the single source of every hex in the system.
///
/// Mirrors blocks A–I of the design-token reference
/// (`docs/system-design/MemoX Design System/ui_kits/mobile/index.html`):
/// `<role>` = Tokyo Pure (light), `<role>Dark` = Tokyo Nebula (dark). Schemes
/// and theme extensions resolve from here; feature code never reads this class
/// directly (use `colorScheme.*` / `CustomColors.*` instead).
///
/// Raw hex is permitted *only* in token-definition files like this one.
abstract final class ColorTokens {
  ColorTokens._();

  /// Fully transparent — used to suppress M3 surface tint in component themes.
  static const Color transparent = Color(0x00000000);

  // ── A · Brand & core roles ───────────────────────────────────
  static const Color primary = Color(0xFF5265F5);
  static const Color primaryDark = Color(0xFF8B9AFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF0A0E27);
  static const Color primaryContainer = Color(0xFFE0E5FE);
  static const Color primaryContainerDark = Color(0xFF2D346A);
  static const Color onPrimaryContainer = Color(0xFF1A2580);
  static const Color onPrimaryContainerDark = Color(0xFFD9DFFF);
  static const Color secondary = Color(0xFF6E7CD9);
  static const Color secondaryDark = Color(0xFF9DA8E8);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color tertiary = Color(0xFF004E1A);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC2D4E);
  static const Color errorDark = Color(0xFFFF8FA3);
  static const Color onError = Color(0xFFFFFFFF);

  // ── B · Surface ladder ───────────────────────────────────────
  static const Color surface = Color(0xFFF7F9FE);
  static const Color surfaceDark = Color(0xFF0A0E27);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceBrightDark = Color(0xFF232B5A);
  static const Color surfaceDim = Color(0xFFDAE0EF);
  static const Color surfaceDimDark = Color(0xFF060925);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowestDark = Color(0xFF131A3A);
  static const Color surfaceContainerLow = Color(0xFFF1F4FB);
  static const Color surfaceContainerLowDark = Color(0xFF1B2249);
  static const Color surfaceContainer = Color(0xFFE9EDF7);
  static const Color surfaceContainerDark = Color(0xFF232B5A);
  static const Color surfaceContainerHigh = Color(0xFFE2E7F3);
  static const Color surfaceContainerHighDark = Color(0xFF2C356E);
  static const Color surfaceContainerHighest = Color(0xFFDAE0EF);
  static const Color surfaceContainerHighestDark = Color(0xFF353D7E);

  // ── C · Text & outline ───────────────────────────────────────
  static const Color onSurface = Color(0xFF0F1638);
  static const Color onSurfaceDark = Color(0xFFE4E8FA);
  static const Color onSurfaceVariant = Color(0xFF4A5278);
  static const Color onSurfaceVariantDark = Color(0xFFA4ACD0);
  static const Color outline = Color(0xFF7C85AB);
  static const Color outlineDark = Color(0xFF5A6BAE);
  static const Color outlineVariant = Color(0xFFC5CBE3);
  static const Color outlineVariantDark = Color(0xFF2A3267);

  // ── A/D · Accent (violet) & semantic ─────────────────────────
  static const Color accent = Color(0xFF8B6FF5);
  static const Color accentDark = Color(0xFFB5A0FF);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color onAccentDark = Color(0xFF0A0E27);
  static const Color success = Color(0xFF2BA88B);
  static const Color successDark = Color(0xFF6FE0BD);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFFFC658);
  static const Color mastery = Color(0xFF1F8A5B);
  static const Color masteryDark = Color(0xFF6FE0BD);
  static const Color masteryFixed = Color(0xFFC7F2D8);
  static const Color masteryFixedDark = Color(0xFF1F4A37);
  static const Color onMasteryFixed = Color(0xFF04331A);
  static const Color onMasteryFixedDark = Color(0xFFC7F2D8);
  static const Color streak = Color(0xFFF97316);
  static const Color streakDark = Color(0xFFFFAE6E);

  // ── E · Card status ──────────────────────────────────────────
  static const Color statusNew = Color(0xFF8C95B8);
  static const Color statusNewDark = Color(0xFF6B75A3);
  static const Color statusLearning = Color(0xFFF59E0B);
  static const Color statusLearningDark = Color(0xFFFFC658);
  static const Color statusReviewing = Color(0xFF5265F5);
  static const Color statusReviewingDark = Color(0xFF8B9AFF);
  static const Color statusMastered = Color(0xFF1F8A5B);
  static const Color statusMasteredDark = Color(0xFF6FE0BD);

  // ── F · Review ratings ───────────────────────────────────────
  static const Color ratingAgain = Color(0xFFE57373);
  static const Color ratingAgainDark = Color(0xFFFF8FA3);
  static const Color ratingHard = Color(0xFFF59E0B);
  static const Color ratingHardDark = Color(0xFFFFC658);
  static const Color ratingGood = Color(0xFF5265F5);
  static const Color ratingGoodDark = Color(0xFF8B9AFF);
  static const Color ratingEasy = Color(0xFF2BA88B);
  static const Color ratingEasyDark = Color(0xFF6FE0BD);

  // ── G · Recall self-assessment (dark inherits light) ─────────
  static const Color selfMissed = Color(0xFFE57373);
  static const Color selfPartial = Color(0xFFFFB74D);
  static const Color selfGotIt = Color(0xFF4DB6AC);

  // ── H · Mastery gradient ─────────────────────────────────────
  static const Color masteryLow = Color(0xFFE57373);
  static const Color masteryLowDark = Color(0xFF8B4F66);
  static const Color masteryMid = Color(0xFFF59E0B);
  static const Color masteryMidDark = Color(0xFF8B7338);
  static const Color masteryHigh = Color(0xFF1F8A5B);
  static const Color masteryHighDark = Color(0xFF3F8070);

  // ── I · Seeds (user-pickable in Settings) ────────────────────
  static const Color seedIndigo = Color(0xFF5265F5);
  static const Color seedViolet = Color(0xFFA78BFA);
  static const Color seedTeal = Color(0xFF4DB6AC);
  static const Color seedRose = Color(0xFFE57373);
  static const Color seedAmber = Color(0xFFFFB74D);
  static const Color seedSage = Color(0xFF81C784);
}
