import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/types/content_sort_mode.dart';

/// Orders [items] by [mode] for display — the one presentation-side sort core
/// shared by Library / Folder detail / Deck / Flashcard (WBS 2.23.1).
///
/// `manual` and the deferred `lastStudied` keep the read-model order (DB
/// `sort_order`); `name` is a case-folded A→Z on [name]; `newest` is [createdAt]
/// descending. Never mutates [items]. The read models are already-loaded small
/// lists, so a Dart-side sort avoids any `.drift`/repository ordering change.
List<T> sortByContentMode<T>(
  List<T> items,
  ContentSortMode mode, {
  required String Function(T) name,
  required DateTime Function(T) createdAt,
}) {
  switch (mode) {
    case ContentSortMode.manual:
    case ContentSortMode.lastStudied:
      return items;
    case ContentSortMode.name:
      return <T>[...items]..sort(
        (T a, T b) => StringUtils.caseFold(
          name(a),
        ).compareTo(StringUtils.caseFold(name(b))),
      );
    case ContentSortMode.newest:
      return <T>[...items]
        ..sort((T a, T b) => createdAt(b).compareTo(createdAt(a)));
  }
}
