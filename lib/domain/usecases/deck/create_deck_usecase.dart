import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';

/// Create a folder-owned deck. Trim/empty/duplicate validation, the
/// content-mode guard, and the atomic insert + parent-mode lock live in
/// [FolderRepository.createDeck].
///
/// Contract: `docs/contracts/usecase-contracts/deck.md` §CreateDeckUseCase.
/// Decision rows D1, D2.
class CreateDeckUseCase {
  const CreateDeckUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<Deck>> call({
    required FolderId parentFolderId,
    required String name,
    required TargetLanguage targetLanguage,
  }) => repository.createDeck(
    folderId: parentFolderId,
    name: name,
    targetLanguage: targetLanguage,
  );
}
