import 'package:freezed_annotation/freezed_annotation.dart';

part 'box_distribution.freezed.dart';

/// Card counts per Leitner box (WBS 7.2.1), for the Progress box-distribution
/// chart (`docs/business/srs/srs-review.md`; decision row P9).
///
/// [countsByBox] always has exactly one entry per box `SrsBox.min..SrsBox.max`
/// (1..8), zero-filled, so the chart renders a stable axis. Counts come from
/// `flashcard_progress` (every flashcard has a progress row from creation), so a
/// brand-new card counts in box 1.
@freezed
sealed class BoxDistribution with _$BoxDistribution {
  const factory BoxDistribution({required Map<int, int> countsByBox}) =
      _BoxDistribution;
  const BoxDistribution._();

  /// Total cards across all boxes.
  int get total => countsByBox.values.fold<int>(0, (sum, c) => sum + c);

  /// The count in [box] (0 when absent, though boxes are zero-filled).
  int countFor(int box) => countsByBox[box] ?? 0;
}
