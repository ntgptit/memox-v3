import 'package:flutter/widgets.dart';

import 'package:memox/core/theme/extensions/custom_colors.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';

/// Card lifecycle stage — drives the status family colors.
///
/// Section E of the handoff: new ▸ learning ▸ reviewing ▸ mastered. This is a
/// presentation-level visual enum; the domain `CardState` (when it exists) maps
/// onto it at the call site.
enum MxCardStatus {
  newCard,
  learning,
  reviewing,
  mastered;

  /// Resolves the matching `status*` color from [CustomColors].
  Color color(BuildContext context) {
    final CustomColors colors = context.customColors;
    return switch (this) {
      MxCardStatus.newCard => colors.statusNew,
      MxCardStatus.learning => colors.statusLearning,
      MxCardStatus.reviewing => colors.statusReviewing,
      MxCardStatus.mastered => colors.statusMastered,
    };
  }
}

/// Maps a 0–1 mastery value to a status color.
///
/// `masteryColor(pct)` from the kit: thresholds `< 0.34` (learning) /
/// `< 0.67` (reviewing) / `≥ 0.67` (mastered).
Color masteryColor(BuildContext context, double pct) {
  if (pct < 0.34) {
    return MxCardStatus.learning.color(context);
  }
  if (pct < 0.67) {
    return MxCardStatus.reviewing.color(context);
  }
  return MxCardStatus.mastered.color(context);
}
