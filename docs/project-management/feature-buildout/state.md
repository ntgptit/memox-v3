# Feature build-out loop — state (cursor / HINT)

Live cursor for the **post-screen feature backlog** (after the 12-screen build-out hit 10/12, the 2
remaining being owner-blocked — see `docs/project-management/screen-buildout/state.md`). Same loop
discipline: build the next unchecked work package FE+BE until it meets its done-bar, verify, fan out
reviewers, fix blockers, commit → PR → merge, mark ✅, advance.

**Done-bar (per WP):** `node tool/verify/run.mjs` full chain PASS (gen-l10n + build_runner + guard
0-errors + doc_guard 0-new + dart fix/format + analyze + targeted tests) → fan out `code-reviewer` +
`docs-drift-detector` (+ `srs-reviewer` if SRS/study, `ui-parity-checker` if a screen) → FIX every
blocker → docs/wireframe/decision-table/overview/l10n + WBS row + §10 updated in the same commits →
commit → PR → squash-merge main → mark the row ✅ + PR# here.

## 🔒 Locked decisions (owner-delegated 2026-06-25 — DO NOT re-ask)

The owner reviewed the parked Q&A (`screen-buildout/state.md` §Parked questions) and delegated:
"decide and do." These are binding for this loop:

| Item | Decision |
| --- | --- |
| **Q5 — Engagement BE** | ✅ **APPROVED.** Build SharedPreferences goal/streak BE (NO Drift migration). Then build 19-progress. |
| **TTS 8.4.3** | ✅ Build (engine + settings already shipped #41/#42; 0 new deps). |
| **Q4 — `03-progress.md` drift** | ✅ Fix: mark the unbuilt Progress-detail wireframe as Future (don't claim implemented). |
| **C5 orphan `settingsValueSoon` / C1 golden CJK+serif font** | ✅ Do (cheap debt). |
| **Q1, Q3, Q6, Q7, Q8, Q11, Q12, Q2** | 🔒 **Keep current defaults** (mock wins visual, docs win behavior; path stays `progress`, no rename). Record any newly-touched one in `tool/parity/intent-ledger.json`. |
| **Q9 + TTS Speed/Pitch slider range** | 🔒 Keep: slider visual range follows mock where it doesn't break validation; TTS uses the **contract** engine range (rate 0.3–0.7, pitch 0.7–1.5) — that's a real engine constraint. |
| **Q14 — Account/Drive sync (8.6.1/8.6.2)** | ⛔ **GATED — do NOT build in this loop.** Needs `googleapis` pubspec dep (hard-rule stop-and-ask) + OAuth + high risk. Park; requires a separate explicit owner go. |
| **Q16 — Onboarding** | ⛔ **GATED — keep Future.** Do not build (overview Future-Proposal scope). |
| **Q10 — Daily reminder / C2 voice-metadata / C3 loading skeleton / C4 waveform animation** | ⛔ **GATED/defer** — polish or dep-gated; not in this loop unless a WP explicitly reaches them. |

If a NON-gated WP surfaces a new question, follow the parking protocol below (default + continue).
If work would require touching a ⛔ GATED item (new pubspec dep, OAuth, onboarding route, a Future
promotion not listed above), **park it + skip to the next WP** — never add a dep or build a gated
feature autonomously.

## Work packages

| # | WP | Status | PR | Done-bar notes |
| --- | --- | --- | --- | --- |
| 1 | **TTS 8.4.3 — study playback** | 🟡 in-progress | — | `TtsPlaybackPolicy` (TargetLanguage→TtsLanguageCode?, unsupported→skip) + `SpeakFlashcardUseCase` (front-only; load+apply global settings then `speak`; blank/unsupported → silent success; engine fail → `StorageFailure`, log + no popup) + `StopSpeechUseCase` + DI. Wire **auto-play on card reveal** (gated by `TtsSettings.autoPlay` + deck language) **and a manual speaker button** into the 5 study modes (review/match/guess/recall/fill) — needs the deck `target_language` reachable from the study read model (extend `LoadStudySessionReviewUseCase`/query/entity + test if absent). Stop playback on advance/leave. Unit tests (policy + use case via fake `TtsService`+settings) + widget test for the speaker button + auto-play trigger. Update `tts.md` (flip policy/use cases → Current, refine `speakFlashcardSide` signature to the realized one with rationale), `tts-settings.md` (lift the 8.4.3 Future banner for what's now built), `study-flow.md`, decision table, WBS 8.4.3 + §10. NEVER speak `back`. |
| 2 | **Q4 — fix `03-progress.md` drift** | ⬜ todo | — | The wireframe claims `ProgressScreen`/`LoadProgressOverviewUseCase`/goldens P1–P18 are implemented, but none exist. Rewrite its status to Future (Progress **detail** = kit 19, unbuilt) so docs stop mis-describing code. Docs-only; `--docs` verify. |
| 3 | **C5 + C1 — debt** | ⬜ todo | — | C5: remove orphaned `settingsValueSoon` from both ARB files + `flutter gen-l10n`. C1: load a CJK + serif font in `test/flutter_test_config.dart` so the kit-23 Korean/serif sample renders in goldens (not tofu), then regen ALL goldens (`node tool/verify/run.mjs --full --update-goldens`) and re-check `tool/parity/report.mjs --ssim`. |
| 4 | **Q5 — Engagement BE → 19-progress** | ⬜ todo | — | Build the engagement BE (SharedPreferences daily-goal target + study-day streak per `docs/contracts/usecase-contracts/engagement.md`; NO fabricated values; no Drift migration) → flip the `overview.md` engagement row from "pending approval" to Implemented (owner approved, Q5) + WBS → then build **19-progress** (kit 19): goal ring + streak chip + accuracy/time/cards + insights, all states from `shots/INDEX.md`. Resolve **Q3** (route: 18-stats stays the `/progress` tab root; 19 is a pushed detail → own route) and the **kit-19 ↔ `03-progress.md` mock-vs-wireframe conflict** toward the mock (mock-authoritative). Full screen done-bar incl. `ui-parity-checker` + goldens + parity-map. |
| 5 | **Phase-3 — confirm-default ledger** | ⬜ todo | — | Record the kept defaults (Q1/Q2/Q3/Q6/Q7/Q8/Q9/Q11/Q12 + the TTS-23 decisions: contract slider range, install-voices no-op Future, voice-metadata Future, static waveform, generic loading) in `tool/parity/intent-ledger.json` + the relevant docs so they're documented exceptions, not silent drift. Docs/ledger-only. |

Status legend: ⬜ todo · 🟡 in-progress · ✅ done (done-bar met + merged).

## ⛔ Gated — NOT in this loop (owner go needed)

- **Q14** Account/Drive sync (8.6.1/8.6.2) — `googleapis` dep + OAuth, high-risk. Separate session.
- **Q16** Onboarding — Future-Proposal scope; needs explicit V1 promotion.
- **Q10** Daily reminder — notification dep + engagement reminder field.
- **C2/C3/C4** voice metadata / loading skeleton / waveform animation — optional polish.

## Parking protocol (same as screen-buildout — DO NOT stop the loop)

When a NON-gated WP hits a question/ambiguity/decision a default can cover: append it to **Parked
questions** below with the safe default taken, and continue. If it's genuinely blocking (would need a
gated action), park it, mark the WP 🟡 `blocked`, and skip to the next WP. If ALL remaining WPs are
blocked/gated → stop the loop + report (don't spin). Between rounds: `ScheduleWakeup delaySeconds=60`
with the verbatim `/loop` prompt.

## Parked questions (newest first)

- **WP1 (TTS 8.4.3) — Match mode excluded from TTS.** The match board shows many front/back tiles at
  once with no single front prompt and no reveal step, and `MatchCell` carries neither the front nor a
  per-card `targetLanguage`; the match-board mock has no speaker affordance. **Default taken:** wire TTS
  into the 4 prompt-based modes (review/guess/recall/fill) and exclude match. Recorded in
  `tts.md`/`tts-settings.md`/`study-flow.md`.
- **WP1 — Fill speaks the revealed answer only (no auto-play).** Fill's front is the hidden answer the
  learner types; auto-playing or a front-prompt speaker would leak the answer. **Default taken:** no
  auto-play in fill; the speaker button appears only on the revealed correct/wrong answer card.
- **WP1 — `ListVoicesUseCase` + `TtsService.state` (`Stream<TtsState>`) NOT built.** The contract listed
  both as 8.4.3 targets, but the settings screen already calls `TtsService.availableVoices` directly and
  the study UI only needs a binary speaking/idle marker. **Default taken:** `StudyTtsController` holds the
  speaking-card id directly (no stream); both remain Future. Recorded in `tts.md`/`tts-settings.md`.

## Automation fixes made during the loop
_(append findings so the next iteration doesn't relearn them.)_
