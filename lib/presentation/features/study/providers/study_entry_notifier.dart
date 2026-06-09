import 'package:memox/core/error/failure.dart';

export 'package:memox/domain/study/study_entry_parser.dart'
    show
        normalizeStudyEntryRefId,
        parseStudyEntryType,
        resolveStudyMode,
        resolveStudyType;

class StudyEntryFailureException implements Exception {
  const StudyEntryFailureException(this.failure);

  final Failure failure;
}
