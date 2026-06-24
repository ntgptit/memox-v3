# Screen build-out loop — state (cursor / HINT)

Live cursor for the 12-screen FE+BE build-out. Recipe + done-bar: `plan.md` (same dir).
One screen per iteration, in order. Update this table as each screen lands.

**NEXT: 24-appearance** (kit screen 24, 3 states). 19-progress is 🟡 blocked:Q5 (engagement-approval gate) — skipped.

## Status

| # | Screen | Status | PR | Notes |
| --- | --- | --- | --- | --- |
| 1 | 18-stats | ✅ done | [#32](https://github.com/ntgptit/memox-v3/pull/32) | Stats tab at `/progress`; weekly chart + per-deck mastery; `MxBarChart`/`MxMasteryBar`. Parked Q1–Q4. |
| 2 | 19-progress | 🟡 blocked:Q5 | — | **Skipped (blocked).** Mock hero = daily-goal ring (12/20) + streak chip + insights = engagement BE, which `overview.md` marks Future/Target "No engagement persistence/settings/reminders — pending approval". Can't build the goal ring without approved goal-settings BE (fabricating goal/streak values is forbidden by `engagement.md`). Also route collides with Stats (Q3). Unblock = owner approves engagement BE. |
| 3 | 09-flashcard-history | ✅ done | [#33](https://github.com/ntgptit/memox-v3/pull/33) | Card History (top-level immersive); breadcrumb + header + activity feed; redesign-simplified (CURRENT-PROGRESS card / filter / Edit / overflow / heatmap dropped). Built the full read BE (queries/dao/repo/usecase). Entry affordance Future (Q6). |
| 4 | 11-tag-management | ✅ done | [#34](https://github.com/ntgptit/memox-v3/pull/34) | Global tag list (top-level immersive `/settings/learning/tags`); rename/merge/delete + collision→merge + busy/op-error. Reused 8.3.1 BE; new shared `MxBusyOverlay`. Settings→Learning entry Future (hub unbuilt). |
| 5 | 10-deck-import | ✅ done | [#35](https://github.com/ntgptit/memox-v3/pull/35) | File-picker wizard (top-level immersive); 9-state machine (empty→file→parse→preview→commit→success/partial/failed). Reused 6.2.x/6.4.1 BE. Parked Q7–Q8. |
| 6 | 22-learning-settings | ✅ done | [#36](https://github.com/ntgptit/memox-v3/pull/36) | Daily-goal card (top-level immersive `/settings/learning`); toggle + new-card limit slider/chips over `LearningSettings`; new shared `MxSwitch`/`MxSlider`. Reused 8.2.1 BE. Reminder card = disabled Future affordance. Parked Q9–Q10. |
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

- **Q10 (22-learning-settings) — The kit-22 mock has a Daily-reminder card with `reminder-on`
  (time + repeat rows) and `perm-denied` (OS-permission banner + open-settings) states, but neither
  is buildable now.** Default taken: the reminder card renders as a **disabled Future affordance**
  (off toggle only) and the two reminder states are marked Future in `parity-map.json`. Reason: there
  is no reminder field in `LearningSettings` (engagement reminders are "pending approval" in
  `overview.md`) and OS notification scheduling needs a new dependency (pubspec → approval). Why/source:
  `lib/domain/entities/learning_settings.dart` (no reminder field), kit-22 mock. [blocking? no]
- **Q9 (22-learning-settings) — The kit-22 goal slider exposes a 5..60 range, but the
  `LearningSettings` contract validates `dailyNewLimit` to 5..200 (step 5).** Default taken: the FE
  slider matches the **mock's 5..60** (mock-authoritative visual); the model/validation still accepts
  up to 200, so a larger persisted value stays valid but isn't reachable from this slider (clamped for
  display). Reason: mock↔contract range conflict — mock wins visual, docs win behavior (the validation
  is unchanged). Why/source: kit-22 slider `min=5 max=60` vs `docs/contracts/usecase-contracts/learning-settings.md`
  (5..200). [blocking? no]
- **Q8 (10-deck-import) — The kit-10 mock mentions Anki `.apkg` + the "importing" state shows a
  live "N of M imported" progress counter, but neither is buildable now.** Default taken: the file
  picker accepts `csv`/`tsv`/`txt` only (the CSV parser can't read `.apkg` zip/sqlite) and the
  importing state uses a plain spinner (`MxLoadingState`) — the live counter needs a chunked/progress
  commit stream, but `commitDeckImport` is a single atomic batch (no progress events). Both marked
  **Future**. Why/source: `lib/domain/usecases/flashcard/commit_deck_import_usecase.dart` (atomic
  commit), kit-10 mock copy. [blocking? no]
- **Q7 (10-deck-import) — The kit-10 partial result's primary action is "Review skipped" (a dedicated
  skipped-rows review), but no such surface exists.** Default taken: replaced it with "Import another
  file" (restart the wizard); the skipped rows are already shown in the preview before commit. A
  dedicated post-commit skipped-review screen is **Future**. Why/source: kit-10 partial mock; no
  review surface in scope. [blocking? no]
- **Q6 (09-flashcard-history) — Entry point: the kit-09 mock implies History opens from a card, but
  ALL "View history" surfaces are documented Future (`docs/business/history/card-history.md` §Future
  surfaces) and no flashcard row-action sheet exists.** Default taken: built the screen + a top-level
  route reachable by path/deep-link; left the entry affordance unbuilt (Future). Wiring an entry needs
  either a new flashcard row-action sheet (out of this screen's scope) or an owner decision on which
  surface exposes it. Why/source: `docs/business/history/card-history.md` §Future surfaces; no
  `flashcard_row_actions_sheet.dart` in the repo. [blocking? no]
- **Q5 (19-progress) — BLOCKING: the kit-19 mock's hero is an engagement surface (daily-goal ring
  `12/20` + flame streak chip + goal-driven insights), but engagement (daily goal + streak +
  reminders) is documented Future/Target with "No engagement persistence/settings/reminders" for V1
  and relocating it to Progress is "pending the engagement BE (schema/migration/approval)"
  (`docs/business/system/overview.md`).** The goal ring needs a real goal TARGET from settings;
  `docs/contracts/usecase-contracts/engagement.md` explicitly forbids fabricating goal/streak values,
  so there is no safe default that maps the hero card. Default taken: **parked + marked 19-progress
  🟡 blocked:Q5 + skipped to 09-flashcard-history** (loop blocking protocol — no hard-stop). The
  accuracy/time/cards summary + the week/month chart ARE buildable from `study_attempts`
  (+`duration_ms`), but a Progress screen missing its hero goal-ring/streak/insights cannot reach the
  "mapped to mock" done-bar. **Also note:** the kit-19 mock (goal ring + streak + accuracy/time/cards
  + insights) DIFFERS from `docs/wireframes/03-progress.md` (range tabs + box distribution + study-day
  streak + card states) — a mock↔wireframe conflict to resolve when 19 is unblocked. Unblock = owner
  approves building the engagement BE (SharedPreferences goal/streak per `engagement.md`; no Drift
  migration needed). Why/source: `docs/business/system/overview.md` (line ~69), `docs/contracts/usecase-contracts/engagement.md` (Forbidden: fabricate goal/streak). [blocking? **yes**]
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
