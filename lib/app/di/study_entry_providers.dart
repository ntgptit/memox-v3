import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/study_entry_dao.dart';
import 'package:memox/data/datasources/local/daos/study_scope_dao.dart';
import 'package:memox/data/repositories/study_entry_repository_impl.dart';
import 'package:memox/domain/repositories/study_entry_repository.dart';
import 'package:memox/domain/usecases/study/resolve_eligible_study_cards_usecase.dart';
import 'package:memox/domain/usecases/study/resolve_study_entry_eligibility_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_entry_providers.g.dart';

/// Dependency-injection wiring for study entry eligibility (WBS 4.1.1):
/// DAO → repository → use case. The entry gate (WBS 4.1.2) depends only on the
/// use-case provider.

@Riverpod(keepAlive: true)
StudyEntryDao studyEntryDao(Ref ref) =>
    StudyEntryDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
StudyScopeDao studyScopeDao(Ref ref) =>
    StudyScopeDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
StudyEntryRepository studyEntryRepository(Ref ref) => StudyEntryRepositoryImpl(
  dao: ref.watch(studyEntryDaoProvider),
  scopeDao: ref.watch(studyScopeDaoProvider),
);

@riverpod
ResolveStudyEntryEligibilityUseCase resolveStudyEntryEligibilityUseCase(
  Ref ref,
) => ResolveStudyEntryEligibilityUseCase(
  repository: ref.watch(studyEntryRepositoryProvider),
);

@riverpod
ResolveEligibleStudyCardsUseCase resolveEligibleStudyCardsUseCase(Ref ref) =>
    ResolveEligibleStudyCardsUseCase(
      repository: ref.watch(studyEntryRepositoryProvider),
    );
