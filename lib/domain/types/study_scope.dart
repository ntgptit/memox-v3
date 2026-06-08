import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_type.dart';

part 'study_scope.freezed.dart';

/// Resolved study scope for a session start or resume operation.
@freezed
abstract class StudyScope with _$StudyScope {
  const factory StudyScope({
    required EntryType entryType,
    required EntryRefId entryRefId,
    required StudyType studyType,
  }) = _StudyScope;
}
