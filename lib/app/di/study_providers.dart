import 'dart:async';

import 'package:memox/app/di/database_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_parser.dart';
import 'package:memox/domain/study/study_entry_route_input.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/study/usecases/study_usecases.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_providers.g.dart';

@Riverpod(keepAlive: true)
StudySessionDao studySessionDao(Ref ref) =>
    StudySessionDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
StudyRepository studyRepository(Ref ref) =>
    StudyRepositoryImpl(ref.watch(studySessionDaoProvider));

@Riverpod(keepAlive: true)
StartStudySessionUseCase startStudySessionUseCase(Ref ref) =>
    StartStudySessionUseCase(ref.watch(studyRepositoryProvider));

@riverpod
Future<StudyEntryStartResult> studyEntry(
  Ref ref,
  StudyEntryRouteInput input,
) async {
  await Future<void>.delayed(Duration.zero);

  final EntryType entryType = parseStudyEntryType(input.entryType);
  final String? entryRefId = normalizeStudyEntryRefId(
    entryType: entryType,
    entryRefId: input.entryRefId,
  );
  if (entryType != EntryType.today && entryRefId == null) {
    throw const FormatException('Study entryRefId is required.');
  }

  final StudyType studyType = resolveStudyType(
    entryType: entryType,
    studyTypeQuery: input.studyTypeQuery,
  );
  final StudyMode? mode = resolveStudyMode(input.modeQuery);
  final StudyScope scope = StudyScope(
    entryType: entryType,
    entryRefId: entryRefId,
    studyType: studyType,
  );

  final Result<StudyEntryStartResult> result = await ref
      .read(startStudySessionUseCaseProvider)
      .call(scope: scope, mode: mode);

  return switch (result) {
    Ok<StudyEntryStartResult>(:final value) => value,
    Err<StudyEntryStartResult>(:final failure) =>
      throw StudyEntryFailureException(failure),
  };
}
