import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/usecases/folder/get_folder_move_targets_usecase.dart';
import 'package:memox/domain/usecases/folder/move_folder_usecase.dart';

final Folder _folder = Folder(
  id: 'f',
  parentId: null,
  name: 'F',
  contentMode: ContentMode.unlocked,
  sortOrder: 0,
  createdAt: DateTime.utc(2024),
  updatedAt: DateTime.utc(2024),
);

/// Records move / move-target calls and returns canned [Result]s; the rest of
/// [FolderRepository] is unused (routed through [noSuchMethod]).
class _FakeFolderRepository implements FolderRepository {
  String? movedId;
  String? movedNewParentId;
  String? targetsFolderId;
  Result<Folder> moveResponse = (failure: null, data: _folder);
  Result<List<FolderMoveTarget>> targetsResponse = (
    failure: null,
    data: <FolderMoveTarget>[],
  );

  @override
  Future<Result<Folder>> moveFolder({
    required String id,
    required String? newParentId,
  }) async {
    movedId = id;
    movedNewParentId = newParentId;
    return moveResponse;
  }

  @override
  Future<Result<List<FolderMoveTarget>>> getFolderMoveTargets({
    required String folderId,
  }) async {
    targetsFolderId = folderId;
    return targetsResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeFolderRepository repo;

  setUp(() => repo = _FakeFolderRepository());

  group('MoveFolderUseCase', () {
    test('forwards id and newParentId and returns the moved folder', () async {
      final useCase = MoveFolderUseCase(repository: repo);

      final result = await useCase.call(id: 'f', newParentId: 'p');

      expect(repo.movedId, 'f');
      expect(repo.movedNewParentId, 'p');
      expect(result.data, _folder);
    });
  });

  group('GetFolderMoveTargetsUseCase', () {
    test('forwards folderId and returns the target list', () async {
      repo.targetsResponse = (
        failure: null,
        data: <FolderMoveTarget>[
          const FolderMoveTarget(
            id: null,
            name: '',
            breadcrumb: <String>[],
            isCurrentParent: true,
            block: null,
          ),
        ],
      );
      final useCase = GetFolderMoveTargetsUseCase(repository: repo);

      final result = await useCase.call(folderId: 'f');

      expect(repo.targetsFolderId, 'f');
      expect(result.data, hasLength(1));
      expect(result.data!.single.isSelectable, isTrue);
    });
  });
}
