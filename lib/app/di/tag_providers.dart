import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/flashcard_tag_dao.dart';
import 'package:memox/data/repositories/tag_repository_impl.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/usecases/tag/delete_tag_usecase.dart';
import 'package:memox/domain/usecases/tag/merge_tags_usecase.dart';
import 'package:memox/domain/usecases/tag/rename_tag_usecase.dart';
import 'package:memox/domain/usecases/tag/watch_tags_with_count_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_providers.g.dart';

/// Dependency-injection wiring for tag management: DAO → repository → use cases
/// (`docs/contracts/code-style.md` §Providers).

@riverpod
FlashcardTagDao flashcardTagDao(Ref ref) =>
    FlashcardTagDao(ref.watch(appDatabaseProvider));

@riverpod
TagRepository tagRepository(Ref ref) =>
    TagRepositoryImpl(dao: ref.watch(flashcardTagDaoProvider));

@riverpod
WatchTagsWithCountUseCase watchTagsWithCountUseCase(Ref ref) =>
    WatchTagsWithCountUseCase(repository: ref.watch(tagRepositoryProvider));

@riverpod
RenameTagUseCase renameTagUseCase(Ref ref) =>
    RenameTagUseCase(repository: ref.watch(tagRepositoryProvider));

@riverpod
MergeTagsUseCase mergeTagsUseCase(Ref ref) =>
    MergeTagsUseCase(repository: ref.watch(tagRepositoryProvider));

@riverpod
DeleteTagUseCase deleteTagUseCase(Ref ref) =>
    DeleteTagUseCase(repository: ref.watch(tagRepositoryProvider));
