import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Renames a deck inside its current folder.
///
/// Trims the name and rejects blanks here; the repository enforces sibling
/// uniqueness, preserves the folder ownership, and keeps `sort_order` intact.
class RenameDeckUseCase {
  const RenameDeckUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<Deck>> call({required DeckId deckId, required String name}) {
    final String trimmed = StringUtils.trimmed(name);
    if (trimmed.isEmpty) {
      return Future<Result<Deck>>.value(
        const Result<Deck>.err(
          Failure.validation(field: 'name', code: ValidationCode.empty),
        ),
      );
    }
    return _repository.renameDeck(deckId: deckId, name: trimmed);
  }
}
