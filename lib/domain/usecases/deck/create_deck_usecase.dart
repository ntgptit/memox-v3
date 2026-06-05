import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';

/// Creates a deck inside a folder (`docs/contracts/usecase-contracts/deck.md`
/// §CreateDeckUseCase).
///
/// Trims the name and rejects blanks here; the repository enforces the parent
/// mode lock, sibling-name uniqueness, and the atomic parent mode update (the
/// deck create + folder `content_mode` lock run in one transaction).
class CreateDeckUseCase {
  const CreateDeckUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<Deck>> call({
    required FolderId parentFolderId,
    required String name,
    TargetLanguage targetLanguage = TargetLanguage.korean,
  }) {
    final String trimmed = StringUtils.trimmed(name);
    if (trimmed.isEmpty) {
      return Future<Result<Deck>>.value(
        const Result<Deck>.err(
          Failure.validation(field: 'name', code: ValidationCode.empty),
        ),
      );
    }
    return _repository.createDeck(
      parentFolderId: parentFolderId,
      name: trimmed,
      targetLanguage: targetLanguage,
    );
  }
}
