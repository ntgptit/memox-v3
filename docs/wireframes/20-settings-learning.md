---
last_updated: 2026-06-24
route: /settings/learning
source_specs:
  - docs/business/engagement/dashboard-engagement.md
  - docs/business/navigation/navigation-flow.md
---

# 20 - Settings: Learning

> **Status (2026-06-24): Daily-goal card Implemented (WBS 8.2.2, kit screen 22).**
> `LearningSettingsScreen` (`lib/presentation/features/settings/screens/learning_settings_screen.dart`)
> renders at `/settings/learning` as a **top-level immersive route** (shell hidden). The **Daily
> goal** card is Current: an on/off toggle (`goalDisabledSince`) and, when on, the "N cards / day"
> count with a slider + quick-pick chips (10/20/30/50) over `LearningSettings.dailyNewLimit`, saved
> through `UpdateLearningSettingsUseCase` with an inline saving overlay. Shared `MxSwitch`/`MxSlider`
> primitives were added. Goldens: `test/presentation/features/settings/goldens/learning_settings_*`.
>
> **Future (parked):** the **Daily reminder** card renders as a disabled affordance only — the
> reminder feature (enable + time + repeat + OS notification permission, kit states `reminder-on` /
> `perm-denied`) needs reminder persistence (not in `LearningSettings`) and a notification-scheduling
> dependency, both pending approval (`docs/business/system/overview.md`). The **tags** entry and the
> **study-defaults** block below are also Future. **Mock note:** the kit slider exposes a 5..60 range
> (the common daily range); `LearningSettings` validates up to 200, so larger persisted values stay
> valid but are not reachable from this slider.

## Purpose

Learning settings is the sub-page opened from Settings hub. The screen is a mock/preview of the
Learning settings design from the mobile UI kit: daily goal, reminder, tags, and a future
study-defaults block. Changes are shown as an auto-save surface, so there is no Save button.

## V1 verification status

> The kit-22 **redesign** (status block at the top) supersedes the pre-redesign static-preview
> layout/states/notes below (kept for reference). The redesign drops the streak toggle, the tags
> row, and the study-defaults block, and narrows the goal slider to 5..60. The table below reflects
> the **redesign** build.

| Aspect                    | Status  | Notes |
|--------------------------|---------|-------|
| Route `/settings/learning` | Current | Top-level immersive `LearningSettingsScreen` (`settingsRoutes()`), shell hidden. |
| App bar                  | Current | Title `Learning` + back button. |
| Daily goal card          | Current | Goal on/off toggle (`goalDisabledSince`) + "N cards / day" + slider (5..60) + quick-pick chips (10/20/30/50) over `dailyNewLimit`. |
| Saving overlay           | Current | Inline busy overlay (`saving` state) while a change persists. |
| Daily reminder card      | Future  | Renders disabled only — reminder enable/time/repeat + OS permission (`reminder-on` / `perm-denied`) need reminder persistence + a notification dependency (pending approval). |
| Streak toggle            | Dropped | Not in the redesign mock. |
| Tags row                 | Future  | Not in the redesign mock; tag management lives at `/settings/learning/tags` (kit screen 11). |
| Study defaults section   | Future  | Not in the redesign mock. |

## Layout (pre-redesign preview — superseded; see the status block above)

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
