import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/domain/repositories/tag_repository.dart';

/// Streams the global tag list with usage counts.
class WatchTagsWithCountUseCase {
  const WatchTagsWithCountUseCase(this._repository);

  final TagRepository _repository;

  Stream<Result<List<TagWithCount>>> call({String? searchTerm}) =>
      _repository.watchAllWithCount(searchTerm: searchTerm);
}
