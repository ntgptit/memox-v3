# Overnight Loop Log

Append-only, newest-last. One line per task: `[time] commit-hash · WBS ID · summary · status`.

- [loop-1] ce978d1 · 4.0.1 · Study persistence enabler (B1): schema v6 study_sessions/items/attempts + StudyRepository skeleton (expireOldSessions only) + DAO + DI + SessionId typedef; schema/migration/WBS docs synced, stale study "DONE" markers corrected · **DONE**
- [loop-2] 640ef46 · 4.1.1 · Study entry eligibility BE: EntryType/StudyType/StudyScope + StudyEntryEligibility/StudyScopeEmptyReason; StudyEntryRepository classifies deck/folder-recursive/today scope counts vs empty-scope matrix (suspended/buried excluded); ResolveStudyEntryEligibilityUseCase + DI; 16+1 tests; study-flow/study.md/decision-table/WBS synced · **DONE**
- [loop-3] 201fe72 · 4.2.1 · Session creation BE: StudySession entity + SessionStatus enum + StudySessionMapper; StudyRepository.createSession + StudySessionDao.createSessionWithItems (transactional session+ordered items, in_progress, rolls back as unit); CreateStudySessionUseCase (validates empty list) + DI; 6+2 tests; StudyType token→new_cards per catalog; study.md/study-repository/decision-table/WBS synced · **DONE**
