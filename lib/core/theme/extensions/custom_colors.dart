import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';

/// Semantic colors that have no Material `ColorScheme` slot.
///
/// Blocks D–H of the token reference: semantic (success/warning/mastery/
/// streak), card-status palette, SRS rating palette, recall self-assessment,
/// and the mastery gradient. Resolve via
/// `Theme.of(context).extension<CustomColors>()!`.
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.destructiveFill,
    required this.onDestructiveFill,
    required this.warning,
    required this.mastery,
    required this.masteryFixed,
    required this.onMasteryFixed,
    required this.streak,
    required this.statusNew,
    required this.statusLearning,
    required this.statusReviewing,
    required this.statusMastered,
    required this.ratingAgain,
    required this.ratingHard,
    required this.ratingGood,
    required this.ratingEasy,
    required this.selfMissed,
    required this.selfPartial,
    required this.selfGotIt,
    required this.masteryLow,
    required this.masteryMid,
    required this.masteryHigh,
  });

  static const CustomColors light = CustomColors(
    accent: ColorTokens.accent,
    onAccent: ColorTokens.onAccent,
    success: ColorTokens.success,
    destructiveFill: ColorTokens.errorFill,
    onDestructiveFill: ColorTokens.onError,
    warning: ColorTokens.warning,
    mastery: ColorTokens.mastery,
    masteryFixed: ColorTokens.masteryFixed,
    onMasteryFixed: ColorTokens.onMasteryFixed,
    streak: ColorTokens.streak,
    statusNew: ColorTokens.statusNew,
    statusLearning: ColorTokens.statusLearning,
    statusReviewing: ColorTokens.statusReviewing,
    statusMastered: ColorTokens.statusMastered,
    ratingAgain: ColorTokens.ratingAgain,
    ratingHard: ColorTokens.ratingHard,
    ratingGood: ColorTokens.ratingGood,
    ratingEasy: ColorTokens.ratingEasy,
    selfMissed: ColorTokens.selfMissed,
    selfPartial: ColorTokens.selfPartial,
    selfGotIt: ColorTokens.selfGotIt,
    masteryLow: ColorTokens.masteryLow,
    masteryMid: ColorTokens.masteryMid,
    masteryHigh: ColorTokens.masteryHigh,
  );

  static const CustomColors dark = CustomColors(
    accent: ColorTokens.accentDark,
    onAccent: ColorTokens.onAccentDark,
    success: ColorTokens.successDark,
    destructiveFill: ColorTokens.errorFillDark,
    onDestructiveFill: ColorTokens.onError,
    warning: ColorTokens.warningDark,
    mastery: ColorTokens.masteryDark,
    masteryFixed: ColorTokens.masteryFixedDark,
    onMasteryFixed: ColorTokens.onMasteryFixedDark,
    streak: ColorTokens.streakDark,
    statusNew: ColorTokens.statusNewDark,
    statusLearning: ColorTokens.statusLearningDark,
    statusReviewing: ColorTokens.statusReviewingDark,
    statusMastered: ColorTokens.statusMasteredDark,
    ratingAgain: ColorTokens.ratingAgainDark,
    ratingHard: ColorTokens.ratingHardDark,
    ratingGood: ColorTokens.ratingGoodDark,
    ratingEasy: ColorTokens.ratingEasyDark,
    // Self-assessment inherits the light values in dark.
    selfMissed: ColorTokens.selfMissed,
    selfPartial: ColorTokens.selfPartial,
    selfGotIt: ColorTokens.selfGotIt,
    masteryLow: ColorTokens.masteryLowDark,
    masteryMid: ColorTokens.masteryMidDark,
    masteryHigh: ColorTokens.masteryHighDark,
  );

  final Color accent;
  final Color onAccent;
  final Color success;
  final Color destructiveFill;
  final Color onDestructiveFill;
  final Color warning;
  final Color mastery;
  final Color masteryFixed;
  final Color onMasteryFixed;
  final Color streak;
  final Color statusNew;
  final Color statusLearning;
  final Color statusReviewing;
  final Color statusMastered;
  final Color ratingAgain;
  final Color ratingHard;
  final Color ratingGood;
  final Color ratingEasy;
  final Color selfMissed;
  final Color selfPartial;
  final Color selfGotIt;
  final Color masteryLow;
  final Color masteryMid;
  final Color masteryHigh;

  @override
  CustomColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? success,
    Color? destructiveFill,
    Color? onDestructiveFill,
    Color? warning,
    Color? mastery,
    Color? masteryFixed,
    Color? onMasteryFixed,
    Color? streak,
    Color? statusNew,
    Color? statusLearning,
    Color? statusReviewing,
    Color? statusMastered,
    Color? ratingAgain,
    Color? ratingHard,
    Color? ratingGood,
    Color? ratingEasy,
    Color? selfMissed,
    Color? selfPartial,
    Color? selfGotIt,
    Color? masteryLow,
    Color? masteryMid,
    Color? masteryHigh,
  }) => CustomColors(
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    success: success ?? this.success,
    destructiveFill: destructiveFill ?? this.destructiveFill,
    onDestructiveFill: onDestructiveFill ?? this.onDestructiveFill,
    warning: warning ?? this.warning,
    mastery: mastery ?? this.mastery,
    masteryFixed: masteryFixed ?? this.masteryFixed,
    onMasteryFixed: onMasteryFixed ?? this.onMasteryFixed,
    streak: streak ?? this.streak,
    statusNew: statusNew ?? this.statusNew,
    statusLearning: statusLearning ?? this.statusLearning,
    statusReviewing: statusReviewing ?? this.statusReviewing,
    statusMastered: statusMastered ?? this.statusMastered,
    ratingAgain: ratingAgain ?? this.ratingAgain,
    ratingHard: ratingHard ?? this.ratingHard,
    ratingGood: ratingGood ?? this.ratingGood,
    ratingEasy: ratingEasy ?? this.ratingEasy,
    selfMissed: selfMissed ?? this.selfMissed,
    selfPartial: selfPartial ?? this.selfPartial,
    selfGotIt: selfGotIt ?? this.selfGotIt,
    masteryLow: masteryLow ?? this.masteryLow,
    masteryMid: masteryMid ?? this.masteryMid,
    masteryHigh: masteryHigh ?? this.masteryHigh,
  );

  @override
  CustomColors lerp(covariant CustomColors? other, double t) {
    if (other == null) {
      return this;
    }
    return CustomColors(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      destructiveFill: Color.lerp(destructiveFill, other.destructiveFill, t)!,
      onDestructiveFill: Color.lerp(
        onDestructiveFill,
        other.onDestructiveFill,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      mastery: Color.lerp(mastery, other.mastery, t)!,
      masteryFixed: Color.lerp(masteryFixed, other.masteryFixed, t)!,
      onMasteryFixed: Color.lerp(onMasteryFixed, other.onMasteryFixed, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
      statusNew: Color.lerp(statusNew, other.statusNew, t)!,
      statusLearning: Color.lerp(statusLearning, other.statusLearning, t)!,
      statusReviewing: Color.lerp(statusReviewing, other.statusReviewing, t)!,
      statusMastered: Color.lerp(statusMastered, other.statusMastered, t)!,
      ratingAgain: Color.lerp(ratingAgain, other.ratingAgain, t)!,
      ratingHard: Color.lerp(ratingHard, other.ratingHard, t)!,
      ratingGood: Color.lerp(ratingGood, other.ratingGood, t)!,
      ratingEasy: Color.lerp(ratingEasy, other.ratingEasy, t)!,
      selfMissed: Color.lerp(selfMissed, other.selfMissed, t)!,
      selfPartial: Color.lerp(selfPartial, other.selfPartial, t)!,
      selfGotIt: Color.lerp(selfGotIt, other.selfGotIt, t)!,
      masteryLow: Color.lerp(masteryLow, other.masteryLow, t)!,
      masteryMid: Color.lerp(masteryMid, other.masteryMid, t)!,
      masteryHigh: Color.lerp(masteryHigh, other.masteryHigh, t)!,
    );
  }
}
