import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/ids.dart';

part 'folder.freezed.dart';

/// A content folder in the library tree
/// (`docs/business/folder/folder-management.md`).
///
/// [parentId] is `null` for a root folder. [contentMode] gates whether the
/// folder may hold subfolders or decks.
@freezed
abstract class Folder with _$Folder {
  const factory Folder({
    required FolderId id,
    required FolderId? parentId,
    required String name,
    required ContentMode contentMode,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Folder;
}
