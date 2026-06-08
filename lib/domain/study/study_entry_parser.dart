import 'package:memox/core/error/failure.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_type.dart';

EntryType parseStudyEntryType(String value) {
  final String normalized = StringUtils.trimmed(value);
  if (normalized.isEmpty) {
    throw const FormatException('Study entryType is required.');
  }
  final EntryType? parsed = _tryParseEntryType(normalized);
  if (parsed == null) {
    throw FormatException('Unsupported study entryType: $normalized.');
  }
  return parsed;
}

String? normalizeStudyEntryRefId({
  required EntryType entryType,
  required String? entryRefId,
}) {
  if (entryType == EntryType.today) {
    return null;
  }
  final String normalized = StringUtils.trimmed(entryRefId ?? '');
  return normalized.isEmpty ? null : normalized;
}

StudyType resolveStudyType({
  required EntryType entryType,
  required String? studyTypeQuery,
}) {
  final String normalized = StringUtils.trimmed(studyTypeQuery ?? '');
  if (normalized.isEmpty) {
    return switch (entryType) {
      EntryType.today => StudyType.srsReview,
      EntryType.deck || EntryType.folder => StudyType.newCards,
    };
  }
  final StudyType? parsed = _tryParseStudyType(normalized);
  if (parsed == null) {
    throw FormatException('Unsupported study_type: $normalized.');
  }
  return parsed;
}

StudyMode? resolveStudyMode(String? modeQuery) {
  final String normalized = StringUtils.trimmed(modeQuery ?? '');
  if (normalized.isEmpty) {
    return null;
  }
  final StudyMode? parsed = _tryParseStudyMode(normalized);
  if (parsed == null) {
    throw FormatException('Unsupported study mode: $normalized.');
  }
  return parsed;
}

class StudyEntryFailureException implements Exception {
  const StudyEntryFailureException(this.failure);

  final Failure failure;
}

EntryType? _tryParseEntryType(String normalized) {
  for (final EntryType entryType in EntryType.values) {
    if (entryType.name == normalized) {
      return entryType;
    }
  }
  return null;
}

StudyType? _tryParseStudyType(String normalized) => switch (normalized) {
  'new' => StudyType.newCards,
  'srs_review' => StudyType.srsReview,
  _ => null,
};

StudyMode? _tryParseStudyMode(String normalized) => switch (normalized) {
  'review' => StudyMode.review,
  'match' => StudyMode.match,
  'guess' => StudyMode.guess,
  'recall' => StudyMode.recall,
  'fill' => StudyMode.fill,
  _ => null,
};
