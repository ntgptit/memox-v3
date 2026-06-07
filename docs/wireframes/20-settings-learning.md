---
last_updated: 2026-06-07
route: /settings/learning
source_specs:
  - docs/business/engagement/dashboard-engagement.md
  - docs/business/navigation/navigation-flow.md
---

# 20 - Settings: Learning

## Purpose

Learning settings is the sub-page opened from Settings hub. The screen is a mock/preview of the
Learning settings design from the mobile UI kit: daily goal, reminder, tags, and a future
study-defaults block. Changes are shown as an auto-save surface, so there is no Save button.

## V1 verification status

| Aspect                    | Status  | Notes |
|--------------------------|---------|-------|
| Route `/settings/learning` | Current | Opens as a shell-hidden sub-screen from Settings hub. |
| App bar                  | Current | Title `Learning`, back button, and transient `Saved` chip in the `saving` variant. |
| Daily goal section       | Current | Goal toggle, cards-per-day slider preview, and streak toggle preview. |
| Reminder section         | Current | Reminder toggle, reminder time row, and permission-denied banner variant. |
| Tags section             | Current | Navigate to `/settings/learning/tags`. |
| Study defaults section   | Current/Future | Disabled preview rows marked `Soon`. |

## Layout

```
┌───────────────────────────────────────┐
│ ← Learning                    [Saved] │
├───────────────────────────────────────┤
│ DAILY GOAL                            │
│ ┌───────────────────────────────────┐ │
│ │ Set a daily goal            [On]  │ │
│ ├───────────────────────────────────┤ │
│ │ Cards per day                    │ │
│ │ 20 cards                         │ │
│ │  ━━━●━━━━━━━━━━━━━━━━━━━━━━       │ │
│ │ 5   50   100   150   200         │ │
│ ├───────────────────────────────────┤ │
│ │ Show streak counter         [On]   │ │
│ └───────────────────────────────────┘ │
│                                       │
│ REMINDER                              │
│ ┌───────────────────────────────────┐ │
│ │ Daily reminder            [Off]   │ │
│ ├───────────────────────────────────┤ │
│ │ Reminder time            20:00 ▸  │ │
│ ├───────────────────────────────────┤ │
│ │ Notifications are blocked         │ │
│ │ Allow MemoX ...                    │ │
│ │ [ Open system settings ]          │ │
│ └───────────────────────────────────┘ │
│                                       │
│ TAGS                                  │
│ ┌───────────────────────────────────┐ │
│ │ Manage tags          14 tags ... ▸│ │
│ └───────────────────────────────────┘ │
│                                       │
│ STUDY DEFAULTS                        │
│ ┌───────────────────────────────────┐ │
│ │ Default shuffle             Soon  │ │
│ ├───────────────────────────────────┤ │
│ │ Default study mode          Soon  │ │
│ ├───────────────────────────────────┤ │
│ │ Show example sentence       Soon  │ │
│ └───────────────────────────────────┘ │
└───────────────────────────────────────┘
```

## States

| State      | Behavior |
|-----------|----------|
| `goalOn`   | Goal toggle on, slider enabled, streak toggle enabled. |
| `goalOff`  | Goal toggle off, slider dimmed/locked, streak row dimmed, off hint visible. |
| `reminderOn` | Reminder toggle on, reminder time row enabled. |
| `permDenied` | Reminder toggle on, reminder time row dimmed, permission banner visible. |
| `saving`   | Same layout as the current preview state, plus the app-bar `Saved` chip. |

## Navigation in

- Settings hub -> Learning row.

## Navigation out

- Back -> Settings hub.
- Manage tags -> `/settings/learning/tags`.
- Open system settings -> OS settings entry point placeholder in the mock.

## Notes

- No Save button.
- Daily goal range in the mock is 5-200 with step 5.
- Reminder time in the mock is `20:00`.
- The future study-defaults rows are disabled preview content only.
