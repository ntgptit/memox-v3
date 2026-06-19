import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/models/folder_summary.dart';

part 'library_overview.freezed.dart';

/// The Library root read model — the top-level content shown on the Library
/// screen (`docs/wireframes/02-library.md`).
///
/// [folders] are the root folders (`parent_id IS NULL`) in stable order, each
/// annotated with its [FolderSummary] counts.
///
/// > V1 scope (WBS 3.1.1): root-level **decks** are not represented yet — the
/// > `decks` table lands with WBS 2.7.x. A `decks` field is added to this model
/// > at that point; until then the Library root surfaces folders only.
@freezed
sealed class LibraryOverview with _$LibraryOverview {
  const factory LibraryOverview({required List<FolderSummary> folders}) =
      _LibraryOverview;
}
