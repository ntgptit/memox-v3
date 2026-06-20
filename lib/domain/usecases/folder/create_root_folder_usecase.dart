import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/repositories/folder_repository.dart';

/// Create a root folder. Orchestration only — validation, duplicate checks and
/// persistence live in [FolderRepository.createRootFolder].
///
/// Contract: `docs/contracts/usecase-contracts/folder.md` §CreateRootFolderUseCase.
/// Decision rows F1, F2.
class CreateRootFolderUseCase {
  const CreateRootFolderUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<Folder>> call({
    required String name,
    String? color,
    String? icon,
  }) => repository.createRootFolder(name: name, color: color, icon: icon);
}
