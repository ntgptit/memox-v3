---
last_updated: 2026-06-08
applies_to: `test/domain/study/start_study_session_usecase_test.dart`
---

# Start Study Session Use Case

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| U1 | Start study | Valid scope + mode | Forward scope/mode to repository and return repository result unchanged | C0+C1 | `test/domain/study/start_study_session_usecase_test.dart::forwards scope and mode to the repository` |
| U2 | Start study | Repository returns empty | Preserve the empty gate result unchanged | C1 | `test/domain/study/start_study_session_usecase_test.dart::returns an empty outcome unchanged` |
