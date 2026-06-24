import 'package:memox/app/di/tag_providers.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_management_viewmodel.g.dart';

/// Streams all tags with their card counts for the Tag-Management screen
/// (kit screen 11; WBS 8.3.2). The Drift watch refreshes after every
/// rename/merge/delete, so the list stays live.
@riverpod
Stream<List<TagWithCount>> tagsWithCount(Ref ref) =>
    ref.watch(watchTagsWithCountUseCaseProvider).call();

/// The Tag-Management search term (client-side filter over the watched list —
/// the tag set is small). Empty = no filter.
@riverpod
class TagSearchQuery extends _$TagSearchQuery {
  @override
  String build() => '';

  void setTerm(String value) => state = value;
}
