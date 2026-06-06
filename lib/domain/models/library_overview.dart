import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/folder.dart';

part 'library_overview.freezed.dart';

/// A library row: a [folder] plus its **recursive subtree** aggregates
/// (`docs/wireframes/02-library.md` §Count semantics).
///
/// Counts include descendants: [subfolderCount] descendant folders,
/// [deckCount] decks anywhere in the subtree, [cardCount] flashcards in those
/// decks, and [dueCount] of those cards due now. Optional presentation hints
/// ([subtitle], [newCount], [mastery]) let Library Overview mirror the mock
/// without inventing extra tables. Sibling root trees are isolated — counts
/// never leak across roots.
@freezed
abstract class FolderWithCount with _$FolderWithCount {
  const factory FolderWithCount({
    required Folder folder,
    required int subfolderCount,
    required int deckCount,
    required int cardCount,
    required int dueCount,
    String? subtitle,
    int? newCount,
    double? mastery,
  }) = _FolderWithCount;
}

/// The Library Overview read model (`docs/wireframes/02-library.md`).
///
/// Carries **folders only** — root-level decks are Rejected / Out of Scope.
/// [totalFolderCount] is the count of *all* folders in the database and lets
/// the screen tell a true-empty library (`== 0`) apart from a search that
/// matched nothing (`> 0`). [dueToday] is the global due aggregate.
@freezed
abstract class LibraryOverviewReadModel with _$LibraryOverviewReadModel {
  const factory LibraryOverviewReadModel({
    required List<FolderWithCount> folders,
    required int dueToday,
    required int totalFolderCount,
  }) = _LibraryOverviewReadModel;
}
