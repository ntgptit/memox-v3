# Screen build-out loop — state (cursor / HINT)

Live cursor for the 12-screen FE+BE build-out. Recipe + done-bar: `plan.md` (same dir).
One screen per iteration, in order. Update this table as each screen lands.

**NEXT: 19-progress** (the deeper Progress analytics detail — kit screen 19, 9 states).

## Status

| # | Screen | Status | PR | Notes |
| --- | --- | --- | --- | --- |
| 1 | 18-stats | ✅ done | [#32](https://github.com/ntgptit/memox-v3/pull/32) | Stats tab at `/progress`; weekly chart + per-deck mastery; `MxBarChart`/`MxMasteryBar`. Parked Q1–Q4. |
| 2 | 19-progress | ⬜ todo | — | Pushed detail (back + Week/Month); needs its own route or `/progress` rename (Q3) + `ProgressOverview` BE (7.4.2). `03-progress.md` drift corrected but screen still unbuilt. |
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

- **Q4 (18-stats / 19-progress) — `docs/wireframes/03-progress.md` claims Progress V1 is fully
  implemented (`ProgressScreen`, `LoadProgressOverviewUseCase`, `lib/presentation/features/progress/**`,
  goldens, P1–P18) but NONE of it exists in code** (the `/progress` branch was a `RoutePlaceholder`;
  no `progress` feature dir; `ProgressRepository` has no `loadProgressOverview`). Default taken: treated
  that wireframe as describing the *future* Progress **detail** (kit screen 19), not the Stats tab;
  built 18-stats independently with its own read model + `docs/wireframes/18-stats.md`. Marked 7.5.1/7.5.2
  as the unbuilt detail in WBS. **The 03-progress wireframe is still drifted** (describes unbuilt code as
  "implemented") — needs an owner pass to mark it Future or build screen 19. Why/source: code vs
  `docs/wireframes/03-progress.md:16-23`. [blocking? no]
- **Q3 (18-stats) — Stats tab vs Progress detail both target `/progress`.** Default taken: 18-stats is
  the tab root at `/progress` (no back, shell nav); screen 19 (Progress detail, pushed, back + Week/Month)
  will get a pushed route or a rename when it lands. Why/source: 18 mock has bottom nav + no back; 19 mock
  has a back arrow + range toggle. [blocking? no]
- **Q2 (18-stats) — Bottom-nav 4th tab label: kit/overview say "Stats" (bar-chart) vs nav-flow said
  "Progress" (insights).** Default taken: followed the mock + `overview.md` → tab labelled **Stats**,
  icon `bar_chart`; kept the route name/path `progress` (rename deferred — avoids churn); fixed nav-flow
  drift. Why/source: `overview.md:63` + kit `18-stats` spec; mock-authoritative ([[fe-loop-complete-mock-authoritative]]). [blocking? no]
- **Q1 (18-stats) — Per-deck row icon/colour: the mock shows distinct per-deck glyphs but decks carry no
  stored icon/colour (only folders do).** Default taken: one generic deck glyph (`Icons.style_outlined`)
  + cycle the four SRS-status tints by row index to echo the mock's varied chips. A real per-deck
  icon/colour needs a `decks.icon`/`decks.color` migration (schema gap). Why/source: `lib/domain/entities/deck.dart`
  has no icon/colour field. [blocking? no]

## Automation fixes made during the loop
(append findings here so the next iteration doesn't relearn them.)
