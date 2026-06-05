import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Creates a subfolder (`docs/contracts/usecase-contracts/folder.md`
/// §CreateSubfolderUseCase).
///
/// Trims the name and rejects blanks here; the repository enforces the parent
/// mode lock, sibling-name uniqueness, and the atomic parent mode update.
class CreateSubfolderUseCase {
  const CreateSubfolderUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<Folder>> call({
    required FolderId parentId,
    required String name,
  }) {
    final String trimmed = StringUtils.trimmed(name);
    if (trimmed.isEmpty) {
      return Future<Result<Folder>>.value(
        const Result<Folder>.err(
          Failure.validation(field: 'name', code: ValidationCode.empty),
        ),
      );
    }
    return _repository.createSubfolder(parentId: parentId, name: trimmed);
  }
}
