import 'package:memox/app/di/tag_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_action_controller.g.dart';

/// Stateless presentation controller for tag mutations (kit screen 11; WBS
/// 8.3.2). Methods delegate to the use cases and return the [Result]; the Drift
/// watch stream refreshes the list automatically. Rename surfaces a
/// `ConflictFailure` on a name collision so the UI can offer a merge.
@riverpod
class TagActionController extends _$TagActionController {
  @override
  void build() {}

  Future<Result<void>> rename({
    required String oldName,
    required String newName,
  }) => ref
      .read(renameTagUseCaseProvider)
      .call(oldName: oldName, newName: newName);

  Future<Result<MergeResult>> merge({
    required String sourceName,
    required String destinationName,
  }) => ref
      .read(mergeTagsUseCaseProvider)
      .call(sourceName: sourceName, destinationName: destinationName);

  Future<Result<int>> delete({required String tag}) =>
      ref.read(deleteTagUseCaseProvider).call(tag: tag);
}
