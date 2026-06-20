import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/domain/repositories/tag_repository.dart';

/// Stream all tags with their card counts for the Tag-Management screen.
///
/// Contract: `docs/contracts/usecase-contracts/tag.md` §WatchAllTagsWithCount.
class WatchTagsWithCountUseCase {
  const WatchTagsWithCountUseCase({required this.repository});

  final TagRepository repository;

  Stream<List<TagWithCount>> call() => repository.watchAllWithCount();
}
