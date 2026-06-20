import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/usecases/tag/delete_tag_usecase.dart';
import 'package:memox/domain/usecases/tag/merge_tags_usecase.dart';
import 'package:memox/domain/usecases/tag/rename_tag_usecase.dart';

class _FakeTagRepository implements TagRepository {
  String? renameOld;
  String? renameNew;
  String? mergeSource;
  String? mergeDest;
  String? deleted;
  Result<void> renameResponse = (failure: null, data: null);
  Result<MergeResult> mergeResponse = (
    failure: null,
    data: const MergeResult(destination: 'dest', affectedCardCount: 0),
  );
  Result<int> deleteResponse = (failure: null, data: 0);

  @override
  Stream<List<TagWithCount>> watchAllWithCount() =>
      const Stream<List<TagWithCount>>.empty();

  @override
  Future<Result<bool>> existsCaseInsensitive(String normalizedName) async =>
      (failure: null, data: false);

  @override
  Future<Result<void>> rename({
    required String normalizedOldName,
    required String normalizedNewName,
  }) async {
    renameOld = normalizedOldName;
    renameNew = normalizedNewName;
    return renameResponse;
  }

  @override
  Future<Result<MergeResult>> merge({
    required String normalizedSource,
    required String normalizedDestination,
  }) async {
    mergeSource = normalizedSource;
    mergeDest = normalizedDestination;
    return mergeResponse;
  }

  @override
  Future<Result<int>> delete(String normalizedName) async {
    deleted = normalizedName;
    return deleteResponse;
  }
}

void main() {
  group('TagValidator', () {
    test('trims, lowercases, and accepts a valid tag', () {
      final result = TagValidator.validate('  Grammar  ');
      expect(result.isSuccess, isTrue);
      expect(result.data, 'grammar');
    });

    test('TG1: strips a leading # before storing', () {
      expect(TagValidator.validate('#Weak').data, 'weak');
      expect(TagValidator.validate('  ## grammar ').data, 'grammar');
    });

    test('rejects empty, comma, and over-length', () {
      expect(
        TagValidator.validate('   ').failure,
        isA<ValidationFailure>().having(
          (f) => f.code,
          'code',
          ValidationCode.empty,
        ),
      );
      expect(
        TagValidator.validate('a,b').failure,
        isA<ValidationFailure>().having(
          (f) => f.code,
          'code',
          ValidationCode.invalidCharacter,
        ),
      );
      expect(
        TagValidator.validate('x' * 51).failure,
        isA<ValidationFailure>().having(
          (f) => f.code,
          'code',
          ValidationCode.tooLong,
        ),
      );
    });
  });

  group('RenameTagUseCase', () {
    test('validates + normalizes both names before delegating', () async {
      final repo = _FakeTagRepository();
      final result = await RenameTagUseCase(
        repository: repo,
      ).call(oldName: '  Grammar ', newName: '  Syntax ');

      expect(result.isSuccess, isTrue);
      expect(repo.renameOld, 'grammar');
      expect(repo.renameNew, 'syntax');
    });

    test(
      'rejects an invalid new name without touching the repository',
      () async {
        final repo = _FakeTagRepository();
        final result = await RenameTagUseCase(
          repository: repo,
        ).call(oldName: 'a', newName: 'x,y');

        expect(result.failure, isA<ValidationFailure>());
        expect(repo.renameNew, isNull);
      },
    );
  });

  group('MergeTagsUseCase', () {
    test('rejects merging a tag into itself', () async {
      final repo = _FakeTagRepository();
      final result = await MergeTagsUseCase(
        repository: repo,
      ).call(sourceName: 'Grammar', destinationName: 'grammar');

      expect(
        result.failure,
        isA<ValidationFailure>().having(
          (f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );
      expect(repo.mergeDest, isNull);
    });

    test('delegates normalized names on success', () async {
      final repo = _FakeTagRepository();
      await MergeTagsUseCase(
        repository: repo,
      ).call(sourceName: ' Grammar ', destinationName: ' Syntax ');

      expect(repo.mergeSource, 'grammar');
      expect(repo.mergeDest, 'syntax');
    });
  });

  group('DeleteTagUseCase', () {
    test('normalizes the tag and returns the affected count', () async {
      final repo = _FakeTagRepository()
        ..deleteResponse = (failure: null, data: 3);
      final result = await DeleteTagUseCase(
        repository: repo,
      ).call(tag: ' Grammar ');

      expect(repo.deleted, 'grammar');
      expect(result.data, 3);
    });
  });
}
