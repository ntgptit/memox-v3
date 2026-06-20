import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Rename a folder. Trim/empty/duplicate/no-op rules live in
/// [FolderRepository.renameFolder].
///
/// Contract: `docs/contracts/usecase-contracts/folder.md` §RenameFolderUseCase.
/// Decision rows F20-F22.
class RenameFolderUseCase {
  const RenameFolderUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<Folder>> call({
    required FolderId id,
    required String newName,
    String? color,
    String? icon,
  }) => repository.renameFolder(
    id: id,
    newName: newName,
    color: color,
    icon: icon,
  );
}
