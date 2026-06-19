import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/ids.dart';

part 'folder.freezed.dart';

/// A node in the content tree.
///
/// A folder is either a **root** (`parentId == null`) or a **subfolder**
/// (self-FK to another folder). Its [contentMode] locks whether it may hold
/// subfolders or decks. See `docs/business/folder/folder-management.md` and the
/// `folders` table in `docs/database/schema-contract.md`.
///
/// Timestamps are UTC epoch milliseconds (as persisted); the mapper converts to
/// [DateTime] at the data boundary.
@freezed
sealed class Folder with _$Folder {
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
