import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_type.dart';

part 'study_scope.freezed.dart';

/// The resolved scope of a study session (`docs/contracts/types-catalog.md`
/// §StudyScope): which cards a session draws from and with what intent.
///
/// Equality is value-based on all three fields and is used by resume matching
/// (`docs/business/resume/resume-session.md`). `entryRefId` is the deck/folder
/// id, or `null` for the global `today` entry.
@freezed
sealed class StudyScope with _$StudyScope {
  const factory StudyScope({
    required EntryType entryType,
    required EntryRefId entryRefId,
    required StudyType studyType,
  }) = _StudyScope;
}
