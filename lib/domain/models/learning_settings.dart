/// Persisted learning settings used by study eligibility and engagement.
class LearningSettings {
  const LearningSettings({
    required this.dailyNewLimit,
    required this.goalDisabledSince,
  });

  static const int defaultDailyNewLimit = 20;
  static const int minDailyNewLimit = 5;
  static const int maxDailyNewLimit = 200;
  static const int dailyNewLimitStep = 5;

  static const LearningSettings defaults = LearningSettings(
    dailyNewLimit: defaultDailyNewLimit,
    goalDisabledSince: null,
  );

  final int dailyNewLimit;
  final DateTime? goalDisabledSince;

  static bool isValidDailyNewLimit(int value) =>
      value >= minDailyNewLimit &&
      value <= maxDailyNewLimit &&
      (value - minDailyNewLimit) % dailyNewLimitStep == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningSettings &&
          other.dailyNewLimit == dailyNewLimit &&
          other.goalDisabledSince == goalDisabledSince;

  @override
  int get hashCode => Object.hash(dailyNewLimit, goalDisabledSince);

  @override
  String toString() =>
      'LearningSettings(dailyNewLimit: $dailyNewLimit, goalDisabledSince: $goalDisabledSince)';
}
