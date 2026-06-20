import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'merge_result.freezed.dart';

/// Outcome of merging one tag into another (`docs/business/tags/tag-system.md`
/// §Merge). [destination] is the surviving tag; [affectedCardCount] is the
/// number of cards that carried the source tag (each is now tagged
/// [destination], de-duplicated when it already had it).
@freezed
sealed class MergeResult with _$MergeResult {
  const factory MergeResult({
    required TagName destination,
    required int affectedCardCount,
  }) = _MergeResult;
}
