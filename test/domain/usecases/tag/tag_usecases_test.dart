import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/usecases/tag/delete_tag_usecase.dart';
import 'package:memox/domain/usecases/tag/merge_tags_usecase.dart';
import 'package:memox/domain/usecases/tag/rename_tag_usecase.dart';
import 'package:memox/domain/usecases/tag/watch_tags_with_count_usecase.dart';

class _TagRepositoryDouble implements TagRepository {
  _TagRepositoryDouble({
    Result<void>? renameResult,
    Result<MergeResult>? mergeResult,
    Result<int>? deleteResult,
  }) : watchResult = const <TagWithCount>[],
       renameResult = renameResult ?? const Result<void>.ok(null),
       mergeResult =
           mergeResult ??
           const Result<MergeResult>.ok(MergeResult(affectedCardCount: 0)),
       deleteResult = deleteResult ?? const Result<int>.ok(0);

  final List<TagWithCount> watchResult;
  final Result<void> renameResult;
  final Result<MergeResult> mergeResult;
  final Result<int> deleteResult;

  String? lastSearchTerm;
  String? lastOldName;
  String? lastNewName;
  List<String>? lastSourceNames;
  String? lastTargetName;
  String? lastDeletedName;

  @override
  Stream<Result<List<TagWithCount>>> watchAllWithCount({String? searchTerm}) {
    lastSearchTerm = searchTerm;
    return Stream<Result<List<TagWithCount>>>.value(
      Result<List<TagWithCount>>.ok(watchResult),
    );
  }

  @override
  Stream<Result<List<String>>> watchTagsForDeck(String deckId) {
    throw UnimplementedError();
  }

  @override
  Stream<Result<List<String>>> watchTagsForCard(String flashcardId) {
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> existsCaseInsensitive(String name) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> rename({
    required String oldName,
    required String newName,
  }) async {
    lastOldName = oldName;
    lastNewName = newName;
    return renameResult;
  }

  @override
  Future<Result<MergeResult>> merge({
    required List<String> sourceNames,
    required String targetName,
  }) async {
    lastSourceNames = sourceNames;
    lastTargetName = targetName;
    return mergeResult;
  }

  @override
  Future<Result<int>> delete({required String name}) async {
    lastDeletedName = name;
    return deleteResult;
  }
}

void main() {
  group('WatchTagsWithCountUseCase', () {
    test('forwards the search term', () async {
      final _TagRepositoryDouble repository = _TagRepositoryDouble();
      final WatchTagsWithCountUseCase useCase = WatchTagsWithCountUseCase(
        repository,
      );

      final Result<List<TagWithCount>> result = await useCase
          .call(searchTerm: 'weak')
          .first;

      expect(result, isA<Ok<List<TagWithCount>>>());
      expect(repository.lastSearchTerm, 'weak');
    });
  });

  group('RenameTagUseCase', () {
    test(
      'rejects invalid target names before calling the repository',
      () async {
        final _TagRepositoryDouble repository = _TagRepositoryDouble();
        final RenameTagUseCase useCase = RenameTagUseCase(repository);

        final Result<void> result = await useCase.call(
          oldName: 'weak',
          newName: '   ',
        );

        expect(result, isA<Err<void>>());
        expect((result as Err<void>).failure, isA<ValidationFailure>());
        expect(repository.lastNewName, isNull);
      },
    );

    test('trims and normalizes before delegating', () async {
      final _TagRepositoryDouble repository = _TagRepositoryDouble();
      final RenameTagUseCase useCase = RenameTagUseCase(repository);

      final Result<void> result = await useCase.call(
        oldName: '  #Weak  ',
        newName: '  Grammar  ',
      );

      expect(result, isA<Ok<void>>());
      expect(repository.lastOldName, 'weak');
      expect(repository.lastNewName, 'grammar');
    });
  });

  group('MergeTagsUseCase', () {
    test('rejects an empty source list', () async {
      final _TagRepositoryDouble repository = _TagRepositoryDouble();
      final MergeTagsUseCase useCase = MergeTagsUseCase(repository);

      final Result<MergeResult> result = await useCase.call(
        sourceNames: const <String>[],
        targetName: 'grammar',
      );

      expect(result, isA<Err<MergeResult>>());
      expect((result as Err<MergeResult>).failure, isA<ValidationFailure>());
    });

    test('normalizes and forwards merge inputs', () async {
      final _TagRepositoryDouble repository = _TagRepositoryDouble();
      final MergeTagsUseCase useCase = MergeTagsUseCase(repository);

      final Result<MergeResult> result = await useCase.call(
        sourceNames: <String>['  Weak  ', '#Topic'],
        targetName: '  Grammar  ',
      );

      expect(result, isA<Ok<MergeResult>>());
      expect(repository.lastSourceNames, <String>['topic', 'weak']);
      expect(repository.lastTargetName, 'grammar');
    });

    test('rejects source equal target', () async {
      final _TagRepositoryDouble repository = _TagRepositoryDouble();
      final MergeTagsUseCase useCase = MergeTagsUseCase(repository);

      final Result<MergeResult> result = await useCase.call(
        sourceNames: <String>['weak'],
        targetName: 'WEAK',
      );

      expect(result, isA<Err<MergeResult>>());
      expect((result as Err<MergeResult>).failure, isA<ValidationFailure>());
    });
  });

  group('DeleteTagUseCase', () {
    test('validates and normalizes before delegating', () async {
      final _TagRepositoryDouble repository = _TagRepositoryDouble();
      final DeleteTagUseCase useCase = DeleteTagUseCase(repository);

      final Result<int> result = await useCase.call(tag: '  #Weak  ');

      expect(result, isA<Ok<int>>());
      expect(repository.lastDeletedName, 'weak');
    });

    test('rejects invalid tags before calling the repository', () async {
      final _TagRepositoryDouble repository = _TagRepositoryDouble();
      final DeleteTagUseCase useCase = DeleteTagUseCase(repository);

      final Result<int> result = await useCase.call(tag: 'bad,tag');

      expect(result, isA<Err<int>>());
      expect((result as Err<int>).failure, isA<ValidationFailure>());
      expect(repository.lastDeletedName, isNull);
    });
  });
}
