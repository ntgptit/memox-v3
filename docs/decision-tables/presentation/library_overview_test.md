---
last_updated: 2026-06-06
applies_to: `test/presentation/features/folders/library_overview_test.dart`
---

# Library Overview presentation decision table

This table captures the rendering branches covered by the Library Overview
widget tests after the mock-parity refresh.

| ID | Condition | Expected UI | Test coverage |
|---|---|---|---|
| DT1 | Loaded root row with only counts (`subtitle == null`, `newCount == null`, `mastery == null`) | Title, counts row, due badge when present, progress bar fallback, kebab, no chevron | `folder row renders title, metadata, kebab, and no chevron` |
| DT2 | Loaded root row with subtitle + new count + mastery score | Subtitle line, `n new` token, tinted progress bar | `folder row renders subtitle and new count when available` |
| DT3 | Due summary with `dueToday > 0` | Gradient summary card with title, derived subtitle, and chevron | `due summary card renders only when dueToday > 0` |
| DT4 | Due summary with `dueToday == 0` | Summary card hidden | `due summary card renders only when dueToday > 0` |
| DT5 | Retained data query refresh fails after data was visible | Previous folder list remains visible and a localized error snackbar appears | `retained data query error shows a localized snackbar` |

## Notes

- `subtitle` comes from the library overview aggregate and is rendered as a
  mock-aligned direct-child preview string when available.
- `newCount` and `mastery` are read-model hints derived from `flashcard_progress`
  aggregates; they keep the root list visually close to the mock without adding
  schema fields.
