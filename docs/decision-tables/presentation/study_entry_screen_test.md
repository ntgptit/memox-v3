---
last_updated: 2026-06-08
applies_to: `test/presentation/features/study/study_entry_screen_test.dart`
---

# Study Entry Screen

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| P1 | Open study entry | Invalid entryType | Show controlled error state | C1 | `test/presentation/features/study/study_entry_screen_test.dart::DT1 onOpen: invalid entryType renders error state` |
| P2 | Open study entry | Deck with zero eligible cards | Render deck empty state and keep the gate on screen | C1 | `test/presentation/features/study/study_entry_screen_test.dart::DT2 onOpen: deck scope with zero eligible cards shows empty state` |
| P3 | Open study entry | Deck with eligible cards | Redirect with `pushReplacement` to the session placeholder route | C0+C1 | `test/presentation/features/study/study_entry_screen_test.dart::DT3 onOpen: deck scope with eligible cards redirects to session route` |
| P4 | Open study entry | Folder with eligible cards | Redirect with `pushReplacement` to the session placeholder route | C0+C1 | `test/presentation/features/study/study_entry_screen_test.dart::DT4 onOpen: folder scope with eligible cards redirects to session route` |
| P5 | Open today study | Zero due cards | Render today all-done empty state and do not create a session | C1 | `test/presentation/features/study/study_entry_screen_test.dart::DT5 onOpen: today route with zero due cards shows all-done empty state` |
| P6 | Deep-link precedence | Session/result routes | Preserve specific session/result routes ahead of the generic study entry route | C0+C1 | `test/presentation/features/study/study_entry_screen_test.dart::DT6 onOpen: session route renders RoutePlaceholder instead of StudyEntryScreen`, `test/presentation/features/study/study_entry_screen_test.dart::DT6a onOpen: session result route renders RoutePlaceholder instead of StudyEntryScreen` |
