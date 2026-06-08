import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/types/types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_entry_notifier.g.dart';

typedef StudyEntryRouteInput = ({
  String entryType,
  String? entryRefId,
  String? studyTypeQuery,
  String? modeQuery,
});

@immutable
class StudyEntryRouteState {
  const StudyEntryRouteState({
    required this.entryType,
    required this.studyType,
    this.entryRefId,
    this.mode,
  });

  final EntryType entryType;
  final String? entryRefId;
  final StudyType studyType;
  final StudyMode? mode;

  bool get isToday => entryType == EntryType.today;
}

@riverpod
class StudyEntryNotifier extends _$StudyEntryNotifier {
  @override
  Future<StudyEntryRouteState> build(StudyEntryRouteInput input) async {
    await Future<void>.delayed(Duration.zero);

    final EntryType entryType = _parseEntryType(input.entryType);
    final String? entryRefId = _normalizeEntryRefId(
      entryType: entryType,
      entryRefId: input.entryRefId,
    );

    if (entryType != EntryType.today && entryRefId == null) {
      throw const FormatException('Study entryRefId is required.');
    }

    return StudyEntryRouteState(
      entryType: entryType,
      entryRefId: entryRefId,
      studyType: _resolveStudyType(
        entryType: entryType,
        studyTypeQuery: input.studyTypeQuery,
      ),
      mode: _resolveStudyMode(input.modeQuery),
    );
  }

  EntryType _parseEntryType(String value) {
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

  EntryType? _tryParseEntryType(String normalized) {
    for (final EntryType entryType in EntryType.values) {
      if (entryType.name == normalized) {
        return entryType;
      }
    }
    return null;
  }

  String? _normalizeEntryRefId({
    required EntryType entryType,
    required String? entryRefId,
  }) {
    if (entryType == EntryType.today) {
      return null;
    }
    final String normalized = StringUtils.trimmed(entryRefId ?? '');
    return normalized.isEmpty ? null : normalized;
  }

  StudyType _resolveStudyType({
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

  StudyMode? _resolveStudyMode(String? modeQuery) {
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
}
