import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/deck_move_target.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/usecases/deck/get_deck_move_targets_usecase.dart';

final List<DeckMoveTarget> _targets = <DeckMoveTarget>[
  const DeckMoveTarget(
    id: 'f1',
    name: 'Languages',
    breadcrumb: <String>['Languages'],
    isCurrentParent: true,
    block: null,
  ),
];

class _FakeFolderRepository implements FolderRepository {
  String? deckId;
  Result<List<DeckMoveTarget>> response = (failure: null, data: _targets);

  @override
  Future<Result<List<DeckMoveTarget>>> getDeckMoveTargets({
    required String deckId,
  }) async {
    this.deckId = deckId;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('GetDeckMoveTargetsUseCase', () {
    test('forwards deckId and returns the annotated targets', () async {
      final repo = _FakeFolderRepository();
      final useCase = GetDeckMoveTargetsUseCase(repository: repo);

      final result = await useCase.call(deckId: 'd');

      expect(repo.deckId, 'd');
      expect(result.data, _targets);
    });
  });
}
