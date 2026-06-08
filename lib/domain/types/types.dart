/// Barrel for the domain type registry (`docs/contracts/types-catalog.md`).
///
/// Import enums/typedefs from here, never redeclare per feature. Freezed value
/// objects (CardState, StudyScope, …) are added as the features that need them
/// land.
library;

export 'attempt_result.dart';
export 'box_number.dart';
export 'content_mode.dart';
export 'content_sort_mode.dart';
export 'entry_type.dart';
export 'ids.dart';
export 'session_status.dart';
export 'study_mode.dart';
export 'study_scope.dart';
export 'study_type.dart';
export 'target_language.dart';
export 'tts_language_code.dart';
