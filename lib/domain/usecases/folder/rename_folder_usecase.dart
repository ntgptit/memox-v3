import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Renames a folder (`docs/contracts/usecase-contracts/folder.md`
/// §RenameFolderUseCase).
///
/// Trims the name and rejects blanks here; the repository enforces
/// case-insensitive sibling-name uniqueness and treats an unchanged name as a
/// no-op.
class RenameFolderUseCase {
  const RenameFolderUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<Folder>> call({required FolderId id, required String name}) {
    final String trimmed = StringUtils.trimmed(name);
    if (trimmed.isEmpty) {
      return Future<Result<Folder>>.value(
        const Result<Folder>.err(
          Failure.validation(field: 'name', code: ValidationCode.empty),
        ),
      );
    }
    return _repository.renameFolder(folderId: id, name: trimmed);
  }
}
