import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'tag_with_count.freezed.dart';

/// A distinct tag plus the number of cards carrying it, shown on the Tag
/// Management screen (`docs/business/tags/tag-system.md`). [name] is the
/// normalized (lowercased) tag; [cardCount] is the number of `flashcard_tags`
/// rows for it.
@freezed
sealed class TagWithCount with _$TagWithCount {
  const factory TagWithCount({required TagName name, required int cardCount}) =
      _TagWithCount;
}
