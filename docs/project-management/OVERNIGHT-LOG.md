# Overnight Loop Log

Append-only, newest-last. One line per task: `[time] commit-hash · WBS ID · summary · status`.

- [loop-1] ce978d1 · 4.0.1 · Study persistence enabler (B1): schema v6 study_sessions/items/attempts + StudyRepository skeleton (expireOldSessions only) + DAO + DI + SessionId typedef; schema/migration/WBS docs synced, stale study "DONE" markers corrected · **DONE**
- [loop-2] 640ef46 · 4.1.1 · Study entry eligibility BE: EntryType/StudyType/StudyScope + StudyEntryEligibility/StudyScopeEmptyReason; StudyEntryRepository classifies deck/folder-recursive/today scope counts vs empty-scope matrix (suspended/buried excluded); ResolveStudyEntryEligibilityUseCase + DI; 16+1 tests; study-flow/study.md/decision-table/WBS synced · **DONE**
