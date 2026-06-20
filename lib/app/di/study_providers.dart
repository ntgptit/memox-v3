import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_providers.g.dart';

/// Dependency-injection wiring for study persistence (ENABLER — WBS 4.0.1):
/// DAO → repository. The study use-case providers land with WBS 4.1.x+ and
/// depend on [studyRepositoryProvider].

@Riverpod(keepAlive: true)
StudySessionDao studySessionDao(Ref ref) =>
    StudySessionDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
StudyRepository studyRepository(Ref ref) =>
    StudyRepositoryImpl(dao: ref.watch(studySessionDaoProvider));
