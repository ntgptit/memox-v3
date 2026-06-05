import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/repositories/folder_repository.dart';

/// Creates a root folder (`docs/contracts/usecase-contracts/folder.md`
/// §CreateRootFolderUseCase).
///
/// Trims the name and rejects blanks here; the repository enforces
/// case-insensitive sibling-name uniqueness and assigns `sort_order`.
class CreateRootFolderUseCase {
  const CreateRootFolderUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<Folder>> call({required String name}) {
    final String trimmed = StringUtils.trimmed(name);
    if (trimmed.isEmpty) {
      return Future<Result<Folder>>.value(
        const Result<Folder>.err(
          Failure.validation(field: 'name', code: ValidationCode.empty),
        ),
      );
    }
    return _repository.createRootFolder(name: trimmed);
  }
}
