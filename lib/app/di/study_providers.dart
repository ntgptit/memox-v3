import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/usecases/study/cancel_study_session_usecase.dart';
import 'package:memox/domain/usecases/study/create_study_session_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_providers.g.dart';

/// Dependency-injection wiring for study persistence: DAO → repository → use
/// cases (WBS 4.0.1 sweep + WBS 4.2.1 session creation).

@Riverpod(keepAlive: true)
StudySessionDao studySessionDao(Ref ref) =>
    StudySessionDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
StudyRepository studyRepository(Ref ref) =>
    StudyRepositoryImpl(dao: ref.watch(studySessionDaoProvider));

@riverpod
CreateStudySessionUseCase createStudySessionUseCase(Ref ref) =>
    CreateStudySessionUseCase(repository: ref.watch(studyRepositoryProvider));

@riverpod
CancelStudySessionUseCase cancelStudySessionUseCase(Ref ref) =>
    CancelStudySessionUseCase(repository: ref.watch(studyRepositoryProvider));
