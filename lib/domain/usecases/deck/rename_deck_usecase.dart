import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Rename a deck. Trim/empty/duplicate/no-op rules and the preserved folder
/// ownership + `sort_order` live in [FolderRepository.renameDeck].
///
/// Contract: `docs/contracts/usecase-contracts/deck.md` §RenameDeckUseCase.
/// Decision rows D6, D7.
class RenameDeckUseCase {
  const RenameDeckUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<Deck>> call({required DeckId deckId, required String name}) =>
      repository.renameDeck(deckId: deckId, newName: name);
}
