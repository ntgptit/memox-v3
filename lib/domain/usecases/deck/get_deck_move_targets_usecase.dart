import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/deck_move_target.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// List every move destination for the deck [deckId]: all folders (no Library
/// root — a deck always belongs to a folder), each annotated with
/// `isCurrentParent` and a `block` reason when it cannot accept the deck
/// (a subfolders-locked folder is [DeckMoveBlock.lockedToSubfolders]). Pure
/// read — see [FolderRepository.getDeckMoveTargets].
///
/// Contract: `docs/contracts/usecase-contracts/deck.md` §GetDeckMoveTargetsUseCase.
/// Decision rows D9, D10.
class GetDeckMoveTargetsUseCase {
  const GetDeckMoveTargetsUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<List<DeckMoveTarget>>> call({required DeckId deckId}) =>
      repository.getDeckMoveTargets(deckId: deckId);
}
