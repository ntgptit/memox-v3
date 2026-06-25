---
last_updated: 2026-06-20
applies_to: product scope
note: Rebuild reset — all implementation statuses reset to Specified on 2026-06-19.
---

# MemoX Product Overview

## Product

MemoX is a local-first flashcard learning app.

It helps users:

- Manage folders (create, rename, move, delete, reorder).
- Manage decks (create, rename, move, delete, reorder, import, export). Each deck declares a target language.
- Manage flashcards (create, edit, delete, reorder, tag, import, export selected, bulk operations).
- Organize content hierarchically through folders.
- Tag cards and filter inside current card/tag-management surfaces. Study-by-tag remains Blocked/Future in V1.
- Study cards through multiple modes.
- Review due cards via spaced repetition (Leitner 8-box).
- Bury cards until tomorrow or suspend them indefinitely.
- Resume paused sessions from Dashboard.
- See a simple Dashboard streak stat placeholder in V1; full daily goal/streak/reminder engagement remains Future/Target. Per the design redesign, daily goal + streak surfaces move onto the Progress screen (Dashboard stays a quiet "refer to work" surface).
- Search the whole Library (folders, decks, flashcards) from a dedicated top-level Search destination (`/search`, bottom search dock), plus filter inside the current screen scope. Tags-in-search, recent searches, and popular tags remain Future Proposal.
- View per-card review history (timeline of attempts, lifetime stats, reset progress with divider) from a card's row action → `/library/deck/:deckId/flashcards/:flashcardId/history`.
- Configure audio/speech (TTS) preferences for Korean and English.
- Optionally link a Google account for Drive AppData backup and restore with conflict protection.

## Feature spec coverage

This overview lists product capabilities. The detailed contract for each lives in a feature doc.

| Capability| Status| Spec location|
| ---| ---| ---|
| Folder CRUD + move| FE Current (WBS 2.1.2/2.2.2/2.3.2/2.4.2 + 3.1.2/3.2.2 — create/rename/move/delete from Library + Folder Detail; reorder Future)| `docs/business/folder/folder-management.md`|
| Folder reorder| Specified| `docs/business/folder/folder-management.md`|
| Deck create + target language column| Specified (BE Current — WBS 2.7.1)| `docs/business/deck/deck-management.md`|
| Deck delete| Specified (deferred — WBS 2.9.x, blocked on flashcards/progress)| `docs/business/deck/deck-management.md`|
| Deck rename / reorder| Specified (BE Current — WBS 2.8.1 / 2.10.1)| `docs/business/deck/deck-management.md`|
| Deck target-language picker UI| Specified| `docs/business/deck/deck-management.md`|
| Deck import| Implemented (WBS 6.1.1 + 6.3.1, kit screen 10) — `DeckImportScreen` file-picker wizard (CSV/TSV): empty → file → parse → preview (valid/skip) → commit → success/partial/failed. Anki `.apkg` Future.| `docs/business/flashcard/flashcard-management.md` (import section), `docs/wireframes/10-deck-import.md`|
| Deck export| Specified| `docs/business/export/export.md`|
| Flashcard CRUD + tag| Specified (BE Current — WBS 2.11.1/2.12.1/2.13.1/2.14.1; create/update/delete/reorder + create-time tags + tag filter WBS 2.18.1. `move`, bulk, and status filter (WBS 2.17.1, blocked on suspend/bury columns) Future)| `docs/business/flashcard/flashcard-management.md`|
| Flashcard import preview/validation| Implemented (WBS 6.2.x BE + 6.3.1 FE) — combined valid/skip preview (rows + parse issues + duplicate detection), per-row reasons, found/valid/skip summary.| `docs/business/flashcard/flashcard-management.md` (import section), `docs/wireframes/10-deck-import.md`|
| Flashcard selection export| Specified| `docs/business/export/export.md`|
| Study session| Specified| `docs/business/study/study-flow.md`|
| Resume / continue session| Specified| `docs/business/resume/resume-session.md`|
| Empty scope handling| Specified| `docs/business/study/study-flow.md` (empty scope matrix)|
| SRS review (Leitner 8-box)| Specified (BE box transition + interval + finalization Implemented — WBS 4.6.1/4.6.2/4.6.4; study FE pending)| `docs/business/srs/srs-review.md`|
| Bury / suspend cards| Partial (BE Current — queue exclusion WBS 4.11.1 + in-session bury/suspend WBS 4.11.2; flashcard-list / bulk / undo FE Specified)| `docs/business/study-actions/bury-suspend.md`|
| Tag filter + study-by-tag + management| Partial (tag management BE+FE Current — WBS 8.3.1 BE + **8.3.2 FE (kit screen 11): `SettingsTagManagementScreen` list/search + rename/merge/delete + busy/op-error**; **per-card tag assignment on the editor Current — WBS 2.15.2, WP-FL2b2b**; tag-filter chips + study-by-tag Future)| `docs/business/tags/tag-system.md`, `docs/wireframes/22-settings-tag-management.md`|
| Bulk operations on flashcards| Specified| `docs/business/bulk/bulk-operations.md`|
| Deck move between folders| Specified (BE Current — WBS 2.19.1)| `docs/business/deck/deck-management.md`|
| Session batch limit (`maxSessionItems`)| Implemented (BE — WBS 4.2.4, cap in `CreateStudySessionUseCase`)| `docs/business/study/study-flow.md`|
| Daily new-card limit| Implemented (BE — WBS 4.5.10; new-card eligibility cap per local day)| `docs/business/srs/srs-review.md`|
| Answer re-grade before finalize| Specified (ships with first retry mode)| `docs/business/study/study-flow.md`|
| Manual-create duplicate soft-warning| Specified (BE Implemented — WBS 2.20.1)| `docs/business/flashcard/flashcard-management.md`|
| Due-time local-midnight normalization| Implemented (BE — WBS 4.6.4, finalization `dueAtFor`)| `docs/business/srs/srs-review.md`|
| Card history view| Implemented (V1 redesign-simplified, WBS 7.6.1–7.6.3) — `CardHistoryScreen` (top-level immersive route): breadcrumb + header (front/deck + `Box n` + Reviews/Retention/Avg-time) + activity feed, over `GetCardHistoryUseCase`. Read-only; CURRENT-PROGRESS card / filter / Edit / overflow / heatmap dropped (mock-authoritative); entry affordance Future.| `docs/business/history/card-history.md`, `docs/wireframes/09-flashcard-history.md`|
| Inline/scope-local search| V1 guideline| `docs/business/search/global-search.md`|
| Global search screen (folders/decks/flashcards)| Implemented (WBS 3.5.1 BE + 3.5.2/3.5.3 FE) — top-level `/search` with a bottom search dock (design redesign)| `docs/business/search/global-search.md`, `docs/wireframes/11-library-search.md`|
| Bottom-nav primary destinations| Redesign: 5 tabs — Home · Library · Search · Stats · Settings (was 4; Search promoted from app-bar icon to a thumb-reachable destination)| `docs/business/navigation/navigation-flow.md`|
| Breadcrumb trail on nested screens| Redesign — Specified (Library › Folder › Deck › Card, docked under app bar)| `docs/business/navigation/navigation-flow.md`|
| Global search: tags section + recent + popular| Future Proposal — needs tag subsystem + `shared_preferences`| `docs/business/search/global-search.md`, `docs/wireframes/11-library-search.md`|
| Zero-content guidance / thin onboarding| V1 guideline — owner-split across current empty states and Account Settings restore| `docs/wireframes/23-onboarding.md`, `docs/wireframes/01-dashboard.md`, `docs/wireframes/02-library.md`, `docs/wireframes/19-settings-account.md`|
| Full onboarding flow| Future Proposal — no standalone route/feature/first-launch wizard in V1| `docs/wireframes/23-onboarding.md`|
| Dashboard `/home` (redesign)| Current V1 — quiet due snapshot (`MxDueSummary`: cards due + decks, or caught-up) + shortcut rows to Progress/Library, over `LoadDashboardSummaryUseCase`. No app-bar search, no Today CTA, no goal/streak (a quiet "refer to work" surface).| `docs/business/engagement/dashboard-engagement.md`, `docs/wireframes/01-dashboard.md`|
| Daily goal setting (new-card limit)| Implemented (WBS 8.2.2, kit screen 22) — `LearningSettingsScreen` daily-goal card: on/off toggle (`goalDisabledSince`) + new-card limit slider/presets over `LearningSettings.dailyNewLimit`. Persists via `UpdateLearningSettingsUseCase`.| `docs/wireframes/20-settings-learning.md`, `docs/contracts/usecase-contracts/learning-settings.md`|
| Streak + reminders + goal-progress surfaces| Future/Target for V1; target spec only. No streak/reminder persistence. The reminder card on screen 22 is a disabled Future affordance (needs a notification dependency + permission flow). Redesign relocates goal/streak READ surfaces (`GoalRing`, `Insight`) onto the Progress screen — pending the engagement BE (schema/migration/approval).| `docs/business/engagement/dashboard-engagement.md`, `docs/wireframes/01-dashboard.md`, `docs/wireframes/03-progress.md`|
| Stats tab (screen 18)| Implemented (WBS 7.5.3 BE + 7.5.4 FE) — `/progress` branch renders `StatsScreen`: weekly review activity (`MxBarChart`) + per-deck mastery (`MxMasteryBar`), over `LoadStatsOverviewUseCase`. Read-only.| `docs/wireframes/18-stats.md`, `docs/business/srs/srs-review.md`|
| Progress analytics detail (screen 19)| Specified — deeper analytics (range tabs, accuracy, box distribution, streak). Not built; the `03-progress.md` wireframe describes this Future detail, not the Stats tab.| `docs/wireframes/03-progress.md`, `docs/business/srs/srs-review.md`|
| TTS / audio settings| Implemented (WBS 8.4.1 BE + 8.4.2 screen + 8.4.3 study playback, kit 23) — `tts_settings` (schema v9) + `TtsService`/`FlutterTtsService` (`flutter_tts`) engine + `AudioSpeechSettingsScreen` (voice/language picker + sample preview + speed/pitch over `TtsSettings`; 7 states) + study playback (`TtsPlaybackPolicy` front-only + `SpeakFlashcardUseCase`/`StopSpeechUseCase` + `StudyTtsController` + `StudySpeakButton`/`StudyTtsAutoPlay` into review/guess/recall/fill, per-card deck-language gated; match excluded).| `docs/business/tts/tts-settings.md`, `docs/contracts/usecase-contracts/tts.md`, `docs/contracts/repository-contracts/tts-settings-repository.md`|
| Settings hub| Implemented (WBS 8.1.1, kit screen 20) — `SettingsScreen` (`/settings` shell branch): account card (signed-out V1) + category rows → the sub-screens (Account/Learning/Audio&Speech/Appearance/Language), with live row values (goal/theme/language).| `docs/wireframes/04-settings-hub.md`|
| Account linking (Google)| Implemented (display-only V1, WBS 8.5.1, kit screen 21) — `AccountSettingsScreen` signed-out sign-in hero over `AccountLinkStatus` (SharedPreferences `account.cloudAccountLink`, always `signedOut`); CTA disabled. Interactive sign-in pending (8.6.1).| `docs/business/account-sync/account-sync.md`, `docs/contracts/repository-contracts/account-repository.md`|
| Drive sync (backup/restore with safety)| Specified| `docs/business/account-sync/account-sync.md`|
| Per-deck TTS override| Planned| not yet specified|
| Export with metadata (tags, SRS, etc.)| Out of scope| use Drive sync for backup|
| Multi-language TTS| Out of scope (current phase)| English/Korean only; deck `target_language` gates playback|

Agents must not implement capabilities outside this table without first creating or extending a spec doc. Agents also must not implement rows marked Future Proposal without an explicit promotion: update this table's status AND the corresponding row in the Deferred / Future / Rejected register of `docs/project-management/wbs.md` (§6) in the same commit. (The former gate file `v1-implementation-scope-2026-05-29.md` no longer exists; the WBS register is the promotion record.)

## Product principles

- Local database is the source of truth.
- Login and backup are optional.
- Core learning must work offline.
- UX must be calm, fast, and mobile-first.
- UI must follow MemoX Design System.
- Business rules must live outside widgets.

## Main entities

See `docs/business/glossary.md` for full definitions.

| Entity| Meaning|
| ---| ---|
| Folder| Organizes subfolders or decks|
| Deck| Contains flashcards|
| Flashcard| Learning unit|
| Flashcard progress| SRS state|
| Study session| Persisted learning/review session|
| Study session item| One queued card task|
| Study attempt| One answer attempt|
| TTS settings| Audio/speech preferences|

## Main app areas

| Area| Responsibility|
| ---| ---|
| Dashboard| Daily summary and quick actions|
| Library| Content management and study entry|
| Progress| Learning progress|
| Settings| Hub for sub-areas below|

Settings sub-areas:

| Sub-area| Responsibility| Spec|
| ---| ---| ---|
| Account| Google account linking + Drive sync| `docs/business/account-sync/account-sync.md`|
| Learning| Current V1 study defaults; daily-goal/streak/reminder controls remain Target/Future| `docs/business/study/study-flow.md`, `docs/wireframes/20-settings-learning.md`|
| Audio/Speech| Current V1 global/front-language TTS settings; independent per-language tabs remain Target/Future| `docs/business/tts/tts-settings.md`, `docs/wireframes/21-settings-audio-speech.md`|
| Appearance (theme mode)| Implemented (WBS 8.8.1 theme half, kit screen 24) — `AppearanceSettingsScreen` Light/Dark/System picker over `AppThemeMode` (SharedPreferences `appearance.themeMode`); drives `MaterialApp.themeMode`.| `docs/wireframes/04-settings-hub.md`, `docs/contracts/repository-contracts/appearance-settings-repository.md`|
| Locale (app language)| Implemented (WBS 8.8.1 language half, kit screen 25) — `LanguageSettingsScreen` System/English/Tiếng Việt picker over `AppLanguage` (SharedPreferences `language.appLanguage`); drives `MaterialApp.locale` (live re-localize, no restart).| `docs/wireframes/04-settings-hub.md`, `docs/contracts/repository-contracts/language-settings-repository.md`|

## Study modes

See `docs/business/glossary.md` for the distinction between mode/type/flow.

- `review`
- `match`
- `guess`
- `recall`
- `fill`

## Agent rule

Do not add new product behavior without updating business docs, decision table, and tests.

## Related

**Wireframes:**

- `docs/wireframes/index.md` — screen map for all 25 wireframes corresponding to features here

**Schema:**

- `docs/database/schema-contract.md` — full schema including 6 pending migrations

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` — full event-condition-expected matrix

**Related contracts:**

- `docs/architecture/clean-architecture-contract.md`
- `docs/state/state-management-contract.md`
- `docs/ui-ux/ui-ux-contract.md`
- `docs/database/storage-boundaries.md`
- `docs/database/migration-contract.md`

**Per-feature business spec:**

- See "Feature status" table above; each row links to its dedicated business doc.

**Source files to inspect:**

- `lib/main.dart`, `lib/app/**` (app shell, theme, router boot)
