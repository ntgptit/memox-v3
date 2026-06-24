# Screen build-out loop — state (cursor / HINT)

Live cursor for the 12-screen FE+BE build-out. Recipe + done-bar: `plan.md` (same dir).
One screen per iteration, in order. Update this table as each screen lands.

**NEXT: 18-stats** (nothing started yet).

## Status

| # | Screen | Status | PR | Notes |
| --- | --- | --- | --- | --- |
| 1 | 18-stats | ⬜ todo | — | |
| 2 | 19-progress | ⬜ todo | — | |
| 3 | 09-flashcard-history | ⬜ todo | — | |
| 4 | 11-tag-management | ⬜ todo | — | |
| 5 | 10-deck-import | ⬜ todo | — | |
| 6 | 22-learning-settings | ⬜ todo | — | |
| 7 | 24-appearance | ⬜ todo | — | |
| 8 | 25-language | ⬜ todo | — | |
| 9 | 23-audio-speech | ⬜ todo | — | new TTS BE |
| 10 | 20-settings | ⬜ todo | — | after 21–25 routes exist |
| 11 | 21-account-sync | ⬜ todo | — | new Drive-sync BE (largest) |
| 12 | 01-onboarding | ⬜ todo | — | new first-run flag |

Status legend: ⬜ todo · 🟡 in-progress · ✅ done (mock-mapped + gates green + merged).

## Parked questions / decisions — resolve in BATCH later, DO NOT stop the loop

When the loop hits a question, ambiguity, or decision that would normally need the user
(mock↔doc conflict, unclear scope, a "Future vs build-now" call, a wanted-but-absent
token, etc.): **do not interrupt.** Append it here, **proceed with the safest reasonable
default**, and keep going. The user resolves these in one pass afterwards.

- **Genuinely blocking** items that a default can't cover (a new `pubspec` dependency
  needing approval, a destructive/irreversible action, a hard-rule conflict): still park
  the question here, mark that screen's row 🟡 with `blocked: Q#`, **skip to the next
  screen**, and continue the loop — never hard-stop the whole run.

Format (newest first): `Q<n> (<screen>) — <question>. Default taken: <what you did so the
loop could continue>. Why/source: <ref>. [blocking? yes/no]`

_(none yet)_

## Automation fixes made during the loop
(append findings here so the next iteration doesn't relearn them.)
