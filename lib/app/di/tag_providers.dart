import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/repositories/tag_repository_impl.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/usecases/tag/delete_tag_usecase.dart';
import 'package:memox/domain/usecases/tag/merge_tags_usecase.dart';
import 'package:memox/domain/usecases/tag/rename_tag_usecase.dart';
import 'package:memox/domain/usecases/tag/watch_tags_with_count_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_providers.g.dart';

@Riverpod(keepAlive: true)
FlashcardDao tagFlashcardDao(Ref ref) =>
    FlashcardDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
TagRepository tagRepository(Ref ref) =>
    TagRepositoryImpl(ref.watch(tagFlashcardDaoProvider));

@Riverpod(keepAlive: true)
WatchTagsWithCountUseCase watchTagsWithCountUseCase(Ref ref) =>
    WatchTagsWithCountUseCase(ref.watch(tagRepositoryProvider));

@Riverpod(keepAlive: true)
RenameTagUseCase renameTagUseCase(Ref ref) =>
    RenameTagUseCase(ref.watch(tagRepositoryProvider));

@Riverpod(keepAlive: true)
MergeTagsUseCase mergeTagsUseCase(Ref ref) =>
    MergeTagsUseCase(ref.watch(tagRepositoryProvider));

@Riverpod(keepAlive: true)
DeleteTagUseCase deleteTagUseCase(Ref ref) =>
    DeleteTagUseCase(ref.watch(tagRepositoryProvider));
