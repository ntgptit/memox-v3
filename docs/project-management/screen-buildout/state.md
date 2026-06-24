# Screen build-out loop — state (cursor / HINT)

Live cursor for the 12-screen FE+BE build-out. Recipe + done-bar: `plan.md` (same dir).
One screen per iteration, in order. Update this table as each screen lands.

**LOOP PAUSED — 9/12 ✅, 3 remaining all owner-blocked (no feasible next screen).** The remaining
unbuilt screens each need an owner decision, not more autonomous code:
- **19-progress** (Q5) — needs the engagement BE (daily-goal ring + streak), gated on approval in
  `overview.md`.
- **23-audio-speech** (Q13) — TTS first slice = a Drift `tts_settings` table + **v9 schema
  migration** (breaks app boot if wrong) + a `flutter_tts` engine adapter (unverifiable headless) +
  7 engine states; warrants a focused build with a human migration review.
- **01-onboarding** (Q16) — `overview.md` marks the full onboarding flow *"Future Proposal — not in
  V1"*; the scope gate (overview:80) forbids building it without an explicit owner promotion.

Unblock one + re-invoke `/loop` to resume. **Built this session: 9 screens (#32–#40).**

## Status

| # | Screen | Status | PR | Notes |
| --- | --- | --- | --- | --- |
| 1 | 18-stats | ✅ done | [#32](https://github.com/ntgptit/memox-v3/pull/32) | Stats tab at `/progress`; weekly chart + per-deck mastery; `MxBarChart`/`MxMasteryBar`. Parked Q1–Q4. |
| 2 | 19-progress | 🟡 blocked:Q5 | — | **Skipped (blocked).** Mock hero = daily-goal ring (12/20) + streak chip + insights = engagement BE, which `overview.md` marks Future/Target "No engagement persistence/settings/reminders — pending approval". Can't build the goal ring without approved goal-settings BE (fabricating goal/streak values is forbidden by `engagement.md`). Also route collides with Stats (Q3). Unblock = owner approves engagement BE. |
| 3 | 09-flashcard-history | ✅ done | [#33](https://github.com/ntgptit/memox-v3/pull/33) | Card History (top-level immersive); breadcrumb + header + activity feed; redesign-simplified (CURRENT-PROGRESS card / filter / Edit / overflow / heatmap dropped). Built the full read BE (queries/dao/repo/usecase). Entry affordance Future (Q6). |
| 4 | 11-tag-management | ✅ done | [#34](https://github.com/ntgptit/memox-v3/pull/34) | Global tag list (top-level immersive `/settings/learning/tags`); rename/merge/delete + collision→merge + busy/op-error. Reused 8.3.1 BE; new shared `MxBusyOverlay`. Settings→Learning entry Future (hub unbuilt). |
| 5 | 10-deck-import | ✅ done | [#35](https://github.com/ntgptit/memox-v3/pull/35) | File-picker wizard (top-level immersive); 9-state machine (empty→file→parse→preview→commit→success/partial/failed). Reused 6.2.x/6.4.1 BE. Parked Q7–Q8. |
| 6 | 22-learning-settings | ✅ done | [#36](https://github.com/ntgptit/memox-v3/pull/36) | Daily-goal card (top-level immersive `/settings/learning`); toggle + new-card limit slider/chips over `LearningSettings`; new shared `MxSwitch`/`MxSlider`. Reused 8.2.1 BE. Reminder card = disabled Future affordance. Parked Q9–Q10. |
| 7 | 24-appearance | ✅ done | [#37](https://github.com/ntgptit/memox-v3/pull/37) | Theme picker (top-level immersive `/settings/appearance`); Light/Dark/System radio + themed swatches; **new SharedPreferences theme BE** (`AppThemeMode`) wired to `MaterialApp.themeMode` via app-level `AppearanceController`; new shared `MxRadio`. No parked questions. |
| 8 | 25-language | ✅ done | [#38](https://github.com/ntgptit/memox-v3/pull/38) | App-language picker (top-level immersive `/settings/language`); System/English/Tiếng Việt radio + icon leads; **new SharedPreferences language BE** (`AppLanguage`) wired to `MaterialApp.locale` (live re-localize) via app-level `LanguageController`. Reused `MxRadio`. WBS 8.8.1 now fully done. Parked Q11–Q12. |
| 9 | 23-audio-speech | 🟡 deferred:Q13 | — | **Deferred (not dependency-blocked — `flutter_tts ^4.2.5` is in pubspec).** The full TTS first slice (WBS 8.4.1) = a Drift `tts_settings` table + **v9 schema migration** + `TtsService`/`FlutterTtsService` engine adapter + voice-listing + 7 engine-dependent states (Korean/English/Playing/Loading/No-voices/Engine-error/Saving). ~30 files, high blast radius (a wrong migration breaks app boot) + a platform engine that can't be verified headless → warrants a focused build with a human checkpoint on the migration, not a single autonomous 60s pass. Contracts: `docs/contracts/usecase-contracts/tts.md`, `docs/business/tts/tts-settings.md`, `docs/wireframes/21-settings-audio-speech.md`. |
| 10 | 20-settings | ✅ done | [#40](https://github.com/ntgptit/memox-v3/pull/40) | Settings hub (the `/settings` shell branch); account card (signed-out V1) + grouped category rows with live trailing values (goal/theme/language) → the built sub-screens; Audio & speech a disabled "Soon" Future row. No new BE (reuses 4 controllers). Account card Populated/Signing-in/Sync-error stay Future (WBS 8.6.x). Replaced the last `RoutePlaceholder`. |
| 11 | 21-account-sync | ✅ done (V1) | [#39](https://github.com/ntgptit/memox-v3/pull/39) | **Display-only V1** (owner-picked): signed-out sign-in hero (top-level immersive `/settings/account`) over a minimal account BE (`AccountLinkStatus` + `CloudAccountStore` + presence→status repo + `AccountController`); "Continue with Google" CTA disabled. New `account.cloudAccountLink` key. The other 8 states (signing-in/failed/no-backup/ready/uploading/restore-warn/restoring/token-expired) stay **Future** (Q14, WBS 8.6.1/8.6.2 — OAuth + Drive REST, "high-risk; defer"). Unblocks 20-settings. |
| 12 | 01-onboarding | 🟡 blocked:Q16 | — | **Blocked on V1-scope decision.** `docs/business/system/overview.md` marks the full onboarding flow *"Future Proposal — no standalone route/feature/first-launch wizard in V1"*, and overview:80 forbids implementing Future-Proposal rows without an explicit owner promotion (update overview + WBS §6 register in the same commit). Building it would expose a Future feature (parity rule violation). Unblock = owner promotes onboarding to V1. |

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

- **Q16 (01-onboarding) — Full onboarding is "Future Proposal — not in V1".** Default taken:
  **blocked** (not built). `docs/business/system/overview.md:67` marks the full onboarding flow a
  Future Proposal with no first-launch wizard in V1, and overview:80 forbids implementing
  Future-Proposal rows without an explicit owner promotion (table status + WBS §6 register, same
  commit). Building it would expose a Future feature (UI-parity rule). Unblock = owner promotes
  onboarding to V1 scope. Why/source: `docs/business/system/overview.md:67,80`. [blocking? yes —
  owner scope decision]
- **Q15 (20-settings) — The hub's dominant states are the account-sync card, which has no BE.**
  Default taken: **blocked on 21**. 4 of 5 states (Populated/Signed-out/Signing-in/Sync-error)
  render the Drive account/sync card; that BE (21-account-sync) is unbuilt + owner-deferred. The
  setting rows are buildable but the screen can't map the mock without the account card. Unblock =
  21 lands its signed-out display-only slice. Why/source: kit-20 states (account-centric), no
  account BE in tree. [blocking? yes — depends on 21]
- **Q14 (21-account-sync) — 8 of 9 states need owner-deferred high-risk OAuth + Drive-sync infra.**
  Default taken: **blocked**. Only `signed-out` is display-only (WBS 8.5.1); the rest need Google
  OAuth (WBS 8.6.1) + Drive AppData REST backup/restore (8.6.2), both *"High-risk; defer until core
  loop complete"* in the WBS, with only the `GoogleAuthGateway` port + config present. Drive REST
  likely also needs a `googleapis` dep (pubspec → stop-and-ask). Unblock = owner approves building
  8.6.1/8.6.2. Why/source: `docs/project-management/wbs.md:377-378` (8.6.1/8.6.2 deferred),
  `docs/contracts/repository-contracts/sync-repository.md` (nothing implemented). [blocking? yes —
  owner approval for high-risk infra]
- **Q13 (23-audio-speech) — The full TTS slice is too large/high-risk for a single autonomous loop
  pass.** Default taken: **deferred** (screen 🟡), cursor skipped to 20-settings. NOT
  dependency-blocked — `flutter_tts ^4.2.5` is already in `pubspec.yaml`. The blocker is scope +
  blast radius: the first slice (WBS 8.4.1, per `docs/contracts/usecase-contracts/tts.md`) needs a
  Drift `tts_settings` single-row table + a **v9 schema migration** (version bump + migration +
  migration test + schema/migration/storage-boundaries doc updates), a `TtsService` abstraction +
  `FlutterTtsService` (`flutter_tts`) adapter that **cannot be verified headless**, voice-listing,
  and 7 engine-dependent states. A wrong migration breaks app boot, so it should land via a focused
  build with a human review of the migration — not a 60s-cadence autonomous pass. Unblock = a
  dedicated TTS build session (or owner approval to proceed autonomously with the schema migration).
  Why/source: `pubspec.yaml:45` (`flutter_tts`), `docs/contracts/usecase-contracts/tts.md` (target
  slice), schema at v8 (`lib/data/datasources/local/migrations/` v2–v8). [blocking? deferred — large]
- **Q12 (25-language) — The kit-25 footnote says "Changing the language restarts the app.", but
  the FE re-localizes live.** Default taken: the FE wires `MaterialApp.locale` reactively
  (`AppLanguageX.locale`), so changing the language applies **immediately, no restart**; the footnote
  copy is "Changes apply across the app right away." (accurate). The kit shot/spec keep the original
  "restarts" copy (not regenerated to avoid a 280-shot pass); the divergence is recorded in
  `tool/parity/intent-ledger.json` (behavior exception). Why/source: `lib/app/memox_app.dart`
  (locale wiring), kit-25 footnote. [blocking? no]
- **Q11 (25-language) — The kit-25 System row subtitle shows the resolved device locale
  ("English (United States)"), but resolving + pretty-printing the live device locale is out of
  scope.** Default taken: the System row subtitle is a static localized "Match device language"
  (parallel to the appearance System option). The resolved-locale display name is Future. Why/source:
  kit-25 system row; no device-locale display-name resolver in scope. [blocking? no]
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
