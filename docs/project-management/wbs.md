# MemoX v3 Work Breakdown Structure (WBS)

Generated: 2026-06-09  
Last reviewed: 2026-06-10  
Repository: `ntgptit/memox-v3`  
Baseline reviewed: local `main`, latest observed WBS-reviewed commit `dd8688a` (`docs: update WBS and UI kit references for accuracy and traceability`). Prior baseline was `5fbdf96d` (`feat(search): refactor GlobalSearchScreen and SearchAppBarField for improved query handling`); since then deck import gained CSV paste + parse + validation preview (`c1e89cf5`), the flashcard editor gained focus-managed draft handling (`38af6d94`), global search query handling was refactored (`5fbdf96d`), and WBS/UI kit traceability references were corrected (`dd8688a`).

## 0. Purpose

This WBS decomposes MemoX into product, architecture, data, UI, test, and delivery work packages. It is intended for planning, tracking, and creating narrow AI-agent prompts.

MemoX is a local-first flashcard learning app. Core learning must work offline; Google account and Drive backup are optional. The local database is the source of truth, and UI/business behavior must follow the business docs, wireframes, decision tables, and source contracts.

## 1. Status Legend

| Status | Meaning |
| --- | --- |
| Implemented | Confirmed by current docs and/or source route/schema wiring. |
| Partial | Some visible/source pieces exist, but behavior is not complete. |
| Specified | Product/spec docs exist, implementation needs source verification or work. |
| Target | Intended future behavior, not safe to implement without promotion/checklist. |
| Future | Future proposal; do not implement without explicit approval. |
| Blocked | Requires prerequisite schema/contract/product decision. |
| Rejected | Explicitly out of scope; do not implement. |

## 2. Source Evidence Reviewed

### Business / product docs

- `docs/business/system/overview.md`
- `docs/business/navigation/navigation-flow.md`
- `docs/business/folder/folder-management.md`
- `docs/business/deck/deck-management.md`
- `docs/business/flashcard/flashcard-management.md`
- `docs/business/study/study-flow.md`
- `docs/business/srs/srs-review.md`
- `docs/business/study-actions/bury-suspend.md`
- `docs/business/tags/tag-system.md`
- `docs/business/bulk/bulk-operations.md`
- `docs/business/search/global-search.md`
- `docs/business/tts/tts-settings.md`
- `docs/business/account-sync/account-sync.md`

### Architecture / data / checklist docs

- `docs/architecture/clean-architecture-contract.md`
- `docs/database/schema-contract.md`
- `docs/checklist/implementation-checklist.md`

### Design / UI kit

- `docs/system-design/MemoX Design System/ui_kits/mobile/README.md` (23-screen mobile gallery, screens `01`–`23`)
- `docs/system-design/MemoX Design System/ui_kits/mobile/AUDIT.md` (Flutter-handoff audit, token/widget map)
- Note: the UI kit README now points screen sources at the actual path `lib/presentation/features/**` (corrected 2026-06-09, commit `dd8688a`).

### Source files

- `lib/app/router/app_router.dart`
- `lib/app/router/route_paths.dart`
- `lib/presentation/features/dashboard/routes/dashboard_routes.dart`
- `lib/presentation/features/dashboard/screens/dashboard_screen.dart`
- `lib/presentation/features/folders/routes/folder_routes.dart`
- `lib/presentation/features/flashcards/routes/flashcard_routes.dart`
- `lib/presentation/features/study/routes/study_routes.dart`
- `lib/presentation/features/settings/routes/settings_routes.dart`
- `lib/data/datasources/local/app_database.dart`

## 3. Product-Level WBS

### 1. MemoX App

| WBS ID | Work package | Current status | Main evidence / notes |
| --- | --- | --- | --- |
| 1.1 | Product scope and app principles | Specified | Local-first, offline core learning, optional login/backup, mobile-first calm UX. |
| 1.2 | App architecture foundation | Implemented / Ongoing | Clean Architecture layers: `app`, `core`, `domain`, `data`, `presentation`, `l10n`. |
| 1.3 | Navigation foundation | Implemented / Ongoing | GoRouter, `RouteNames`, `RoutePaths`, shell routes, hidden child routes. |
| 1.4 | Drift local database foundation | Implemented / Ongoing | Current schema version 4, `.drift` schema includes folders/decks/flashcards/tags/progress/study tables. |
| 1.5 | Design system and shared UI | Partial / Ongoing | Shared `Mx*` widgets used across screens; continue enforcing stateless/controlled patterns. |
| 1.6 | Localization | Implemented / Ongoing | ARB + generated l10n. Must update on every user-facing copy change. |
| 1.7 | Quality gates | Implemented / Ongoing | Analyzer, tests, build_runner, guard, doc-code parity checklist. |
| 1.8 | Release/platform readiness | Partial | Flutter targets include web/android/windows priority; platform-specific DB/sync require continued verification. |

## 4. Detailed WBS

### 1.1 Product Scope and Governance

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 1.1.1 | Product overview maintenance | Implemented / Ongoing | `docs/business/system/overview.md` reflects current/future capability status. |
| 1.1.2 | Business glossary and terminology | Specified | Entity/type names match source enums and user-facing behavior. |
| 1.1.3 | Feature scope control | Ongoing | Future/Target rows are not implemented without promotion. |
| 1.1.4 | Decision table maintenance | Ongoing | Every new behavior branch has a decision row and test reference. |
| 1.1.5 | WBS maintenance | New | Update this file after major feature promotion or source/doc parity change. |

### 1.2 Architecture Foundation

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 1.2.1 | App layer bootstrap | Implemented | Router, DI, shell are wired only in `lib/app/**`. |
| 1.2.2 | Core utilities/theme/errors | Implemented / Ongoing | Theme tokens, failure/result contracts, constants, id utilities remain reusable. |
| 1.2.3 | Domain layer contracts | Implemented / Ongoing | Entities, types, use cases, repository ports contain no data/presentation dependencies. |
| 1.2.4 | Data layer contracts | Implemented / Ongoing | Drift DAO/repository implementations map storage rows to domain models. |
| 1.2.5 | Presentation feature isolation | Implemented / Ongoing | Feature routes may be imported; private widgets/viewmodels are not imported across feature folders. |
| 1.2.6 | Shared UI promotion rule | Ongoing | Repeated UI patterns become `lib/presentation/shared/**`, not duplicated per feature. |
| 1.2.7 | Generated file discipline | Ongoing | `*.g.dart`, `*.freezed.dart`, l10n generated files, and Drift generated DB files are not manually edited. |

### 1.3 Navigation and Routing

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 1.3.1 | Top-level shell routes | Partial | `/home`, `/library`, `/settings` are wired to real screens; `/progress` remains placeholder. |
| 1.3.2 | Route constants and builders | Implemented | All paths use `RoutePaths`/`RouteNames`; no raw route strings in widgets. |
| 1.3.3 | Library branch routes | Implemented / Partial | Library overview, global search, folder detail, flashcard list are wired. |
| 1.3.4 | Hidden library routes | Partial | Flashcard create/edit are real; deck import remains placeholder. |
| 1.3.5 | Study routes | Partial | Study entry and study session are real; study result is now a real screen. |
| 1.3.6 | Settings routes | Partial | Settings hub, learning, learning/tags, audio-speech are real; account route remains placeholder. |
| 1.3.7 | Route ordering guard | Implemented / Ongoing | Specific study session route stays before generic study entry route. |
| 1.3.8 | Invalid route handling | Ongoing | Invalid params render controlled error/safe route, not crash. |
| 1.3.9 | Push/go semantics | Ongoing | Follow documented push vs go table for back stack behavior. |
| 1.3.10 | First-run / onboarding | Rejected | V1 boots directly into Library; `route_paths.dart` comment explicitly forbids replacing this with an onboarding wizard. UI kit screen 01 is reference-only — do not implement without product promotion. |

### 1.4 Local Database and Persistence

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 1.4.1 | Drift schema version 4 | Implemented | `AppDatabase.currentSchemaVersion = 4`; migrations v2/v3/v4 wired. |
| 1.4.2 | `.drift` table/query layout | Implemented / Ongoing | Schema and SQL stay in `.drift`, not long raw SQL in Dart. |
| 1.4.3 | Folders table | Implemented | Hierarchical folders with content mode and sort order. |
| 1.4.4 | Decks table | Implemented | Folder-owned decks with non-null `folder_id`; root-level decks rejected. |
| 1.4.5 | Flashcards table | Implemented | Front/back and optional detail fields; deck-owned. |
| 1.4.6 | Flashcard tags table | Implemented | Per-card lowercased tags with tag index. |
| 1.4.7 | Flashcard progress table | Implemented | Box/due/review/lapse plus bury/suspend fields. |
| 1.4.8 | Study tables | Implemented | Sessions, session items, attempts are present. |
| 1.4.9 | TTS settings storage | Specified / needs source verification | Docs describe current Drift-backed single-row settings; verify against current schema before task. |
| 1.4.10 | Account link storage | Specified | SharedPreferences, not Drift. |
| 1.4.11 | Per-account DB isolation | Specified / Target implementation | DB filename must depend on guest vs Google subject id. |
| 1.4.12 | Schema migration process | Ongoing | Any schema change bumps version, adds `onUpgrade`, updates docs/tests/generated files. |
| 1.4.13 | Transaction safety | Ongoing | Multi-table writes use transactions: import, session creation/finalization, tags, bulk ops, sync restore. |

## 5. Feature WBS

### 2. Library and Content Organization

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 2.1 | Library overview screen | Implemented / Partial | Shows library entry, top-level content, safe loading/empty/error states. |
| 2.2 | Folder detail screen | Implemented / Partial | Shows child folders/decks and study entry points. |
| 2.3 | Folder create | Specified / needs source verification | Required trimmed name; parent mode locks to subfolders. |
| 2.4 | Folder rename | Specified / needs source verification | Required trimmed name, localized validation/error states. |
| 2.5 | Folder delete | Specified / needs source verification | Safe confirmation; cascade/dependent cleanup according to persistence rules. |
| 2.6 | Folder move | Specified / needs source verification | Prevent cycle; validate parent mode. |
| 2.7 | Folder reorder | Specified / needs source verification | Updates `sort_order` only when current sort mode allows manual reorder. |
| 2.8 | Folder content mode guard | Specified / Partial | Parent may contain subfolders or decks, not both; must be enforced outside UI. |
| 2.9 | Folder due/card counts | Specified / Partial | Counts stream from DB, not computed in widget. |
| 2.10 | Folder empty/error/loading states | Ongoing | Use shared `MxLoadingState`, `MxEmptyState`, `MxErrorState`. |

### 3. Deck Management

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 3.1 | Folder-owned deck invariant | Implemented / Ongoing | Every deck belongs to exactly one folder; root decks are rejected. |
| 3.2 | Deck list inside folder | Implemented / Partial | Folder detail lists decks when folder mode allows decks. |
| 3.3 | Deck create | Specified / needs source verification | Required trimmed name; parent folder locks to `decks`. |
| 3.4 | Deck rename | Specified / needs source verification | Required trimmed name; localized validation. |
| 3.5 | Deck delete | Specified / needs source verification | Deletes flashcards and dependent data through persistence rules. |
| 3.6 | Deck reorder | Specified / needs source verification | Updates `sort_order` only. |
| 3.7 | Deck target language | Implemented in schema / Partial feature | Required by docs; verify create/edit UI and TTS gate coverage before claiming done. |
| 3.8 | Deck import route | Implemented / V1 (CSV paste + commit) | `/library/deck/:deckId/import` opens `DeckImportScreen`. V1 exposes CSV paste input + parse + validation preview + transactional commit; file picker, Excel, and structured text stay deferred. |
| 3.9 | Deck export | Specified / needs source verification | Export belongs to export feature scope. |
| 3.10 | Deck due/card badges | Specified / Partial | Counts stream from DB; due count excludes buried/suspended. |

### 4. Flashcard Management

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 4.1 | Flashcard list screen | Implemented / Partial | `/library/deck/:deckId/flashcards` is real. |
| 4.2 | Flashcard create screen | Implemented | Route opens `FlashcardEditorScreen` with deck id. |
| 4.3 | Flashcard edit screen | Implemented | Route opens `FlashcardEditorScreen` with deck id + flashcard id. |
| 4.4 | Required content validation | Specified / needs source verification | Front/back required after trim. |
| 4.5 | Optional fields | Implemented / Partial | Example, pronunciation, hint are schema-backed and store blank as null. |
| 4.6 | Tag input on flashcard editor | Implemented / Partial | Tags trim, lowercase, validate non-empty, dedupe case-insensitively. |
| 4.7 | Flashcard delete | Specified / needs source verification | Related local data removed by cascade/persistence rules. |
| 4.8 | Flashcard reorder | Specified / needs source verification | Reorder updates `sort_order`. |
| 4.9 | Status filter chips | Pending / Partial | Active/Suspended/Buried/Due filters are specified; verify current UI coverage. |
| 4.10 | Tag filter chips | Specified / Partial | Multi-select AND semantics inside current deck. |
| 4.11 | Suspended/buried badges | Pending / Partial | Docs list as still pending in flashcard list. |
| 4.12 | Flashcard history | Future / Blocked | Requires `last_reset_at`, `box_before`, `box_after`; not V1 current. |

### 5. Import

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 5.1 | Deck import route | Implemented | Route renders `DeckImportScreen` (501-line screen), not `RoutePlaceholder`. |
| 5.2 | CSV import (paste) | Implemented / Partial | V1 parses pasted CSV text through a domain use case and keeps UTF-8 file decoding via picker deferred. |
| 5.3 | Excel import | Specified | Read first sheet; header toggle controls row 1. Still deferred. |
| 5.4 | Structured text import | Specified | Separator supports auto/tab/comma/colon/slash/semicolon/pipe. Still deferred. |
| 5.5 | Import preparation | Implemented / Partial | Preview builds rows + validation issues from pasted CSV via a domain use case. Skipped-duplicate aggregation remains future. |
| 5.6 | Duplicate detection | Specified / needs source verification | Front/back duplicate against import file and existing deck, case-insensitive; verify coverage in current preview. |
| 5.7 | Import preview screen | Implemented / Partial | In-screen preview (rows + issues + summary) renders before commit; clean preview enables the transactional CTA. |
| 5.8 | Import commit transaction | Implemented | Insert valid preview rows, default SRS progress, and timestamps in one transaction. |
| 5.9 | Import result feedback | Implemented / V1 snackbar | V1 uses snackbar and pops back, not a standalone result screen. |
| 5.10 | Import validation tests | Implemented / Partial | `test/.../deck_import_screen_test.dart` covers preview/validation/commit states; rollback tests cover transactional failure. |

### 6. Search

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 6.1 | Global library search route | Implemented | `/library/search` opens `GlobalSearchScreen`. |
| 6.2 | Folder/deck/flashcard search sections | Implemented / Current | Grouped results with per-section cap and counts. |
| 6.3 | Search ranking | Specified / needs source verification | Exact match → starts-with → substring → recency tie-break. |
| 6.4 | LIKE escaping | Specified / critical | Escape `%`, `_`, `\`; no raw query as LIKE pattern. |
| 6.5 | Min query + debounce | Specified / needs source verification | 2-char minimum, 300ms debounce. |
| 6.6 | Result navigation | Specified / Current | Folder → folder detail; deck → flashcard list; flashcard → owning deck. |
| 6.7 | Tags search section | Future / Blocked | Requires tag subsystem promotion. |
| 6.8 | Recent searches | Future / Blocked | Requires approved SharedPreferences dependency usage. |
| 6.9 | Popular tags landing | Future / Blocked | Requires tag subsystem. |
| 6.10 | Inline local search | Implemented / Partial | Library/folder/flashcard/tag management scope-local filters. |

### 7. Tags

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 7.1 | Tag storage | Implemented | `flashcard_tags` table; tag is lowercased text per flashcard. |
| 7.2 | Tag validation | Implemented / Ongoing | Trim, non-empty, max length, comma forbidden, leading `#` handling if supported. |
| 7.3 | Tag filter in flashcard list | Specified / Partial | Multi-select AND semantics; clear filters empty state. |
| 7.4 | Tag management route | Implemented route | `/settings/learning/tags` opens `SettingsTagManagementScreen`. |
| 7.5 | Tag list/count/search | Specified / needs source verification | Distinct tags, usage count, search by substring. |
| 7.6 | Tag rename | Specified / needs source verification | Transactional; conflict behaves as merge with confirmation. |
| 7.7 | Tag merge | Specified / needs source verification | Transactional, dedupe duplicate tag rows. |
| 7.8 | Tag delete | Specified / needs source verification | Confirmation; removes tag rows only, not cards. |
| 7.9 | Study by tag | Blocked / Future | Requires `StudyEntryType.tag`, tag-scope queries, routes/tests. |
| 7.10 | Tag result section in global search | Future | Not current V1. |
| 7.11 | Bulk tag operations | Specified / Future | Add/remove/replace tags on selected cards transactionally. |

### 8. Bulk Operations

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 8.1 | Selection mode | Specified / needs source verification | Long-press/select action enters ephemeral selection mode. |
| 8.2 | Select all visible | Specified | Selects current filtered snapshot, not re-evaluated at action execution. |
| 8.3 | Bulk delete | Specified | Confirmation, single transaction, cascade applies. |
| 8.4 | Bulk move to deck | Specified | Validates target deck/folder mode; preserves progress/tags; recomputes sort order. |
| 8.5 | Bulk add/remove tags | Specified | Transactional; toast undo. |
| 8.6 | Bulk suspend/unsuspend | Specified / Pending | Updates progress state transactionally; toast undo. |
| 8.7 | Bulk bury/unbury | Specified / Pending | Sets/clears `buried_until`; toast undo. |
| 8.8 | Bulk reset progress | Specified / Blocked | Requires `last_reset_at`; must not delete attempts. |
| 8.9 | Bulk export | Specified / needs source verification | Builds CSV/Excel from selected cards. |
| 8.10 | Bulk performance | Specified | Use bulk SQL/chunking; avoid per-row transaction loops. |

### 9. Study Entry and Session

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 9.1 | Study entry route for deck/folder | Implemented | `/library/study/:entryType/:entryRefId`, supports deck/folder. |
| 9.2 | Today study route | Implemented | `/library/study/today`. |
| 9.3 | Study entry parsing | Implemented / Ongoing | Validates entry type/ref id/study type/mode query. |
| 9.4 | Empty scope handling | Implemented / Partial | Deck/folder/today empty states implemented; tag scope blocked. |
| 9.5 | No silent resume | Implemented | Existing resumable session returns controlled `resumeRequired`. |
| 9.6 | Resume/start-over dialog | Implemented | Study Entry now shows explicit Resume / Start over / Back actions; Start over confirms before canceling and restarting the same scope. |
| 9.7 | Session creation | Implemented | Persisted `study_sessions` + `study_session_items`, transactional. |
| 9.8 | Study session route | Implemented V1 shell | Loads persisted session + ordered items, shows the current card with reveal toggle, Forgot / Got it grading, Previous/Next controls, Finish Session when all items are answered, and in-session answer persistence. |
| 9.9 | Study result route | Implemented | `/library/study/session/:sessionId/result` opens `StudyResultScreen` with completed-session summary and controlled fallback states. |
| 9.10 | Protected active-session exit | Implemented | Active session exit requires confirmation; confirmed exit leaves the session resumable without canceling it and falls back to Library when the route cannot pop. |
| 9.11 | Study session persistence recovery | Implemented / Ongoing | Persisted in-progress sessions reload by sessionId, preserve answered items, and enter the review shell safely even when all items are already answered. |
| 9.12 | Study attempt persistence | Specified / Partial | Attempts must be persisted; full mode implementations may still be pending. |
| 9.13 | Study mode strategy V1 | Partial | Recall self-grade is resolved through `StudyModeStrategyFactory`; non-recall modes return a controlled unsupported strategy until persisted mode selection is added. |

### 10. Study Modes

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 10.1 | Review mode | Specified / Partial | Both sides shown; swipe right/left semantics; no reveal step. |
| 10.2 | Match mode | Specified / Partial | 5-pair board, per-pair persistence, one board per 5 cards. |
| 10.3 | Guess mode | Specified / Partial | Front to back, 5 option cards, auto-advance countdown. |
| 10.4 | Recall mode | Implemented / Partial | Flip-card self-grade V1: reveal, Forgot / Got it grading, and next-unanswered advancement; no typed recall in V1. |
| 10.5 | Fill mode | Specified / Partial | Type front, strict character match, mark-correct override, hint taints to recovered. |
| 10.6 | Mode sequence resolution | Specified | New full cycle: review → match → guess → recall → fill; SRS uses fill. |
| 10.7 | Mode UI parity | Ongoing | Wireframes 13-17 and shared study scaffold conventions respected. |
| 10.8 | Current V1 review shell | Implemented | Persisted session review shell with current-card navigation, reveal, Forgot / Got it self-grade, Finish Session after all items are answered, and the real result screen. |
| 10.9 | Mode persistence tests | Needed | Each mode needs attempt/result/state tests when implemented. |

### 11. SRS and Progress

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 11.1 | Flashcard progress state | Implemented | Box/due/review/lapse fields exist. |
| 11.2 | Leitner 8-box transition contract | Specified / Partial | UI does not update SRS directly; finalization computes outcome. |
| 11.3 | Due-card filtering | Implemented / Ongoing | `due_at <= now`, exclude suspended and currently buried. |
| 11.4 | New-card default progress | Implemented / Ongoing | New flashcard starts box 1, due now. |
| 11.5 | Attempt classification | Specified / Partial | `perfect`, `initial_passed`, `recovered`, `forgot`. |
| 11.6 | Session finalization transaction | Implemented | Attempts, progress, and session completion happen in one transaction; failures roll back without partial writes. |
| 11.7 | Finalization failure recovery | Partial | Finish failure keeps the session open with a controlled error; retry remains a future result-screen concern. |
| 11.8 | Progress screen | Placeholder / Partial | `/progress` route currently placeholder. |
| 11.9 | Box distribution chart | Future / Blocked | Requires box history fields if based on attempts. |
| 11.10 | Card history | Future / Blocked | Requires `last_reset_at`, `box_before`, `box_after`. |

### 12. Bury and Suspend

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 12.1 | Bury card | Implemented in study / Partial elsewhere | Sets `buried_until`; no attempt; preserves SRS. |
| 12.2 | Suspend card | Implemented in study / Partial elsewhere | Sets `is_suspended`; no attempt; preserves SRS. |
| 12.3 | Due/new query exclusion | Implemented | Suspended and current buried cards excluded from study queues/due counts. |
| 12.4 | Active-session removal | Implemented | Bury/suspend current card removes from queue and advances/finalizes. |
| 12.5 | Undo for active-session reinsert | Pending | Docs note undo currently reverts progress only, not active-session reinsert. |
| 12.6 | Flashcard list badges | Pending | Suspended/buried badges on cards. |
| 12.7 | Flashcard list filters | Pending / Partial | Active/Suspended/Buried/Due chips. |
| 12.8 | Bulk suspend/unsuspend | Pending | Via bulk operations. |
| 12.9 | Unsuspend from list | Pending | Surface in suspended filter/detail. |

### 13. Dashboard and Engagement

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 13.1 | Dashboard top-level route | Implemented / Partial | `/home` opens `DashboardScreen`. |
| 13.2 | Today study shortcut | Implemented / Partial | `dueToday > 0` routes to `RoutePaths.studyTodayTemplate` through Study Entry; `dueToday == 0` shows caught-up/no-due copy, disables Study CTA, and does not enter study flow. |
| 13.3 | Resume session entry | Implemented / V1 | Dashboard surfaces the latest resumable session as a top card with scope, progress, last active, and Continue CTA; hides the card when no resumable session exists; does not surface discard or a paused-session list in V1. |
| 13.4 | Due count summary | Specified / Partial | Excludes buried/suspended. |
| 13.5 | Streak stat placeholder | Partial | Product overview says simple `0 days` visual/stat placeholder exists. |
| 13.6 | Daily goal | Future / Target | SharedPreferences settings; not current full implementation. |
| 13.7 | Reminders | Future / Target | SharedPreferences settings; no full reminder flow yet. |
| 13.8 | Engagement persistence | Future / Target | Longest streak, last goal-met date stored outside Drift. |
| 13.9 | Stats screen | Future / Specified | UI kit screen 18 (weekly chart + per-deck mastery); distinct from Progress (11.8). No screen/route exists; needs aggregate read model before implementation. |

### 14. Settings

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 14.1 | Settings hub | Implemented | `/settings` opens `SettingsScreen`. |
| 14.2 | Account settings route | Placeholder | `/settings/account` currently RoutePlaceholder. |
| 14.3 | Learning settings route | Implemented | `/settings/learning` opens `LearningSettingsScreen`. |
| 14.4 | Tag management route | Implemented | `/settings/learning/tags` opens `SettingsTagManagementScreen`. |
| 14.5 | Audio/speech settings route | Implemented | `/settings/audio-speech` opens `AudioSpeechSettingsScreen`. |
| 14.6 | Appearance/locale settings | Future | Disabled/future rows on Settings Hub. |
| 14.7 | Study defaults | Partial | Learning settings current V1 defaults; daily goal/reminder future. |
| 14.8 | Settings loading/error states | Ongoing | Use shared `Mx*` states and l10n. |

### 15. TTS / Audio Speech

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 15.1 | TTS service abstraction | Specified / needs source verification | Domain talks through `TtsService`, not Flutter plugin directly. |
| 15.2 | Flutter TTS platform service | Specified / needs source verification | Platform implementation under data/services. |
| 15.3 | Global/front-language settings | Specified / Current V1 | Single settings row, not independent per-language settings. |
| 15.4 | Audio/speech settings screen | Implemented / Partial | Route real; docs say surface follows mock/gallery while data contract remains global/front-language. |
| 15.5 | Voice selection | Specified | Filter by language; clear voice on language change. |
| 15.6 | Rate/pitch/volume normalization | Specified | Clamp on read/write. |
| 15.7 | Speak front only policy | Specified | Back/note are not spoken. |
| 15.8 | Deck target-language TTS gate | Blocked / Partial | Depends on deck target_language flow and source verification. |
| 15.9 | Auto-play on reveal | Specified / Partial | Applies only study-session flashcard reveal. |
| 15.10 | Independent Korean/English setting sets | Target / Future | Do not implement without migration/product decision. |

### 16. Account and Drive Sync

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 16.1 | Account settings route | Placeholder | `/settings/account` not wired to real screen yet. |
| 16.2 | Optional Google account linking | Specified | App works fully offline as guest. |
| 16.3 | Drive AppData authorization | Specified | Only `drive.appdata` scope; cannot access normal Drive files. |
| 16.4 | Cloud account link store | Specified | SharedPreferences, corruption-tolerant. |
| 16.5 | Account statuses | Specified | signedOut/signedIn/needsDriveAuthorization/unconfigured/unsupported/error. |
| 16.6 | Guest → signed-in choice | Specified | User chooses attach guest data or fresh account DB. |
| 16.7 | Per-account database context | Specified | Guest and Google account DB names isolated. |
| 16.8 | Manual backup upload | Specified | Requires linked authorized account. |
| 16.9 | Manual restore | Specified | Conflict/safety protection, platform snapshot gateway. |
| 16.10 | Web snapshot gateway | Specified | Uses WasmDatabase/sqlite3.wasm/drift worker. |
| 16.11 | IO snapshot gateway | Specified | Copy/restore SQLite file via temp file and reopen DB. |
| 16.12 | Sync metadata | Specified | SharedPreferences-backed metadata. |

### 17. Export

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 17.1 | Deck export | Specified / needs source verification | Deck is export unit. |
| 17.2 | Flashcard selection export | Specified / needs source verification | Export selected flashcards. |
| 17.3 | Bulk export | Specified | Builds CSV/Excel from selected. |
| 17.4 | Export with metadata | Out of scope | Use Drive sync for backup; do not add metadata export unless approved. |

### 18. UI / Design System

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 18.1 | MemoX design tokens | Implemented / Ongoing | No raw colors/styles/durations in feature UI. |
| 18.2 | Shared layout scaffolds | Implemented / Ongoing | Use `MxScaffold`, list/form/study scaffolds where applicable. |
| 18.3 | Shared state widgets | Implemented / Ongoing | Loading/empty/error states consistent. |
| 18.4 | Shared action buttons | Implemented / Ongoing | Touch targets and disabled states pass UI contract. |
| 18.5 | Shared dialogs/bottom sheets | Specified / Partial | Confirmation and picker patterns should be reused. |
| 18.6 | Responsive/mobile-first layouts | Ongoing | Avoid overflow on narrow screens. |
| 18.7 | Accessibility/touch target | Ongoing | Touch targets at least 48dp. |
| 18.8 | Dark/light theme parity | Ongoing | Verify every new screen in both themes. |
| 18.9 | UI kit visual contract | Ongoing | `ui_kits/mobile` (23-screen gallery) is the visual reference; implemented screens map below. |

### 18a. UI Kit Screen Traceability (mobile gallery 01–23)

Maps each gallery screen to its WBS work package, implementation status, and source screen file (under `lib/presentation/features/**`). A blank source path means no implemented screen yet.

| UI kit # | Screen | WBS ID | Status | Source screen |
| --- | --- | --- | --- | --- |
| 01 | Onboarding | 1.3.10 | Rejected | — (V1 boots to Library; `route_paths.dart` forbids onboarding wizard) |
| 02 | Dashboard | 13.1–13.8 | Implemented / Partial | `dashboard/screens/dashboard_screen.dart` |
| 03 | Library overview | 2.1 | Implemented / Partial | `folders/screens/library_overview_screen.dart` |
| 04 | Folder detail | 2.2 | Implemented / Partial | `folders/screens/folder_detail_screen.dart` |
| 05 | Library search | 6.1–6.6 | Implemented | `search/screens/global_search_screen.dart` |
| 06 | Flashcard list | 4.1 | Implemented / Partial | `flashcards/screens/flashcard_list_screen.dart` |
| 07 | Flashcard create | 4.2 | Implemented | `flashcards/screens/flashcard_editor_screen.dart` |
| 08 | Flashcard edit | 4.3 | Implemented | `flashcards/screens/flashcard_editor_screen.dart` |
| 09 | Flashcard history | 4.12 | Future / Blocked | — (needs `last_reset_at`, `box_before`, `box_after`) |
| 10 | Deck import | 3.8, 5.1–5.9 | Implemented / Partial (CSV paste) | `flashcards/screens/deck_import_screen.dart` |
| 11 | Tag management | 7.4–7.8 | Implemented / Partial | `settings/screens/tag_management_screen.dart` |
| 12 | Study · Review | 10.1 | Specified / Partial | `study/screens/study_session_screen.dart` (shared shell) |
| 13 | Study · Match | 10.2 | Specified / Partial | — (mode strategy unsupported in V1) |
| 14 | Study · Guess | 10.3 | Specified / Partial | — (mode strategy unsupported in V1) |
| 15 | Study · Recall | 10.4 | Implemented / Partial | `study/screens/study_session_screen.dart` |
| 16 | Study · Fill | 10.5 | Specified / Partial | — (mode strategy unsupported in V1) |
| 17 | Study result | 9.9 | Implemented | `study/screens/study_result_screen.dart` |
| 18 | Stats | 13.9 | Future / Specified | — (no screen/route; distinct from Progress) |
| 19 | Progress | 11.8 | Placeholder | — (`/progress` renders `RoutePlaceholder`) |
| 20 | Settings | 14.1 | Implemented | `settings/screens/settings_screen.dart` |
| 21 | Account sync | 16.1 | Placeholder | — (`/settings/account` renders `RoutePlaceholder`) |
| 22 | Learning settings | 14.3 | Implemented | `settings/screens/learning_settings_screen.dart` |
| 23 | Audio & speech | 15.4 | Implemented / Partial | `settings/screens/audio_speech_settings_screen.dart` |

Study entry (`study/screens/study_entry_screen.dart`, WBS 9.1–9.6) has no dedicated gallery frame; it precedes the study mode screens above.

### 19. Testing and Verification

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 19.1 | Unit tests for domain/use cases | Ongoing | Business rules covered close to domain. |
| 19.2 | Repository/DAO tests | Ongoing | Transactions, migrations, ordering, scope queries covered. |
| 19.3 | Widget tests | Ongoing | Loading/empty/error/saving and key behavior covered. |
| 19.4 | Router tests | Ongoing | Route order, placeholders, invalid routes, RouteNames/RoutePaths. |
| 19.5 | Decision table coverage | Ongoing | Test names reference decision IDs where applicable. |
| 19.6 | Migration tests | Ongoing | Required for every schema change. |
| 19.7 | Guard rules | Ongoing | `code-verification-guard` catches project constraints. |
| 19.8 | Analyzer | Ongoing | `dart fix --apply` and `dart format .` first, then `flutter analyze` must pass. |
| 19.9 | Build runner | Ongoing | `dart run build_runner build --delete-conflicting-outputs`. |
| 19.10 | L10n generation | Ongoing | `flutter gen-l10n` when ARB changes. |
| 19.11 | CI/status checks | Missing / Unknown | GitHub workflow/status checks were not visible in recent review; source-level review only unless CI exists. |

### 20. Documentation and Planning

| WBS ID | Deliverable | Status | Acceptance criteria |
| --- | --- | --- | --- |
| 20.1 | Business docs | Ongoing | Feature behavior, edge cases, status updated with source changes. |
| 20.2 | Wireframes | Ongoing | UI behavior maps to current/target wireframe status. |
| 20.3 | Decision tables | Ongoing | Behavior branches have rows and tests. |
| 20.4 | Contracts | Ongoing | Use case/repository/type/error contracts match source. |
| 20.5 | Database docs | Ongoing | Schema version, migration, storage boundaries updated. |
| 20.6 | WBS document | New | Use this file as planning input, not as implementation approval. |
| 20.7 | Prompt library | Ongoing | Break large features into V1 slices for GPT 5.4 mini high. |
| 20.8 | Risk register | Needed | Track docs/source drift, future rows accidentally implemented, CI gaps. |

## 6. Current Priority Backlog Derived From WBS

This section orders work by product value and risk, not by internal refactor preference.

| Priority | Candidate work package | Why |
| --- | --- | --- |
| P1 | Flashcard list filters/badges for active/suspended/buried/due | Bury/suspend schema and study behavior exist; list visibility is still pending. |
| P1 | Deck import duplicate handling | CSV paste + parse + transactional commit are current; skipped-duplicate handling is still deferred. |
| P1 | Account settings real screen or explicitly defer | Route exists as placeholder; sync/account docs are large but user-facing settings is not wired. |
| P1 | Progress screen V1 | Top-level route is placeholder; users need basic learning feedback. |
| P2 | Bulk operations V1 | High utility but large; split into selection mode + one safe action first. |
| P2 | Tag management behavior hardening | Route exists; verify list/search/rename/merge/delete coverage. |
| P2 | Dashboard V1 | Top-level route placeholder; useful after study result/progress loop works. |
| P3 | Full mode implementations | Review/match/guess/recall/fill are specified; implement as small mode-specific slices. |
| P3 | Drive sync/account linking | Valuable but high-risk; do after core offline learning loop is reliable. |

## 7. Recommended Next Agent Prompt Themes

Use one prompt per work package. Do not combine feature + broad refactor.

1. Flashcard List Status Filters V1: active/suspended/buried/due filters and badges.
2. Progress Screen V1: due count, box distribution from current progress table only.
3. Account Settings Placeholder Replacement V1: display linked/unlinked states without full Drive restore first.

## 8. Known Risks / Review Notes

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Docs can be ahead of source | Agent may implement future behavior accidentally | Always check source + docs; identify Current vs Target/Future. |
| Route comments may drift | Misleading source comments can cause wrong prompt scope | Trust actual route builders and docs over stale comments; update comment in narrow task if touched. |
| Study mode docs are large | Agent may try to implement all modes at once | Split one mode or one session transition per prompt. |
| Schema changes are high risk | Missing migration breaks existing DB | Require version bump, onUpgrade step, migration test, schema doc update. |
| Generated files | Manual edits create drift | Regenerate with build_runner/gen-l10n only. |
| CI not visible | Cannot claim full pass from GitHub checks | Report source-level review unless CI/status checks exist. |
| Future proposals | Can bloat V1 | Do not implement Future/Blocked/Rejection rows without explicit product promotion. |
| Import duplicate handling gap | CSV parse/preview/commit now lives in domain/data, but duplicate detection / skipped-duplicate reporting is still future work. | Keep the CSV commit slice scoped to valid rows only until the duplicate-handling prompt is promoted. |

## 9. WBS Maintenance Rules

Update this WBS when:

- A placeholder route becomes a real screen.
- A Future/Target feature is promoted to Current.
- A schema migration changes current DB version.
- A feature's implementation status changes.
- New docs or decision-table rows materially change scope.
- Source reveals a doc-code parity drift that affects planning.

When updating, include:

- New baseline commit.
- Changed WBS rows only.
- Evidence paths.
- Any new priority/backlog adjustment.

### Commit tracking rule

Every commit that creates, advances, or completes a WBS work package MUST append a row to the **Commit Traceability Log (§10)** in the same commit, listing the short commit id, date, the WBS ID(s) it touches, and a one-line summary. This keeps a bidirectional link (WBS ID ↔ commit id) without bloating the feature tables with a per-row commit column.

- Use the 8-char short hash (e.g. `5fbdf96d`).
- One commit may map to multiple WBS IDs; list them comma-separated.
- Feature/source commits should be logged by the WBS update that reviews them.
- Pure WBS traceability-maintenance commits do not need their own log row.
- Pure tooling/formatting commits that touch no WBS row may be omitted.
- The "Baseline reviewed" line at the top still tracks the latest reviewed commit; the log tracks per-task history.

## 10. Commit Traceability Log

Append-only, newest first. Each row links a landed commit to the WBS work package(s) it advanced. See the Commit tracking rule in §9.

| Commit | Date | WBS IDs | Summary |
| --- | --- | --- | --- |
| `7b3c1691` | 2026-06-10 | 3.8, 5.2, 5.5, 5.7, 5.8, 5.9, 5.10 | Commit deck import with CSV paste preview and transactional insert flow |
| `dd8688a` | 2026-06-09 | 20.6, 18.9, 5.1–5.9, 6.1–6.6 | Update WBS and UI kit references for accuracy and traceability |
| `5fbdf96d` | 2026-06-10 | 6.1–6.6 | Refactor `GlobalSearchScreen` / `SearchAppBarField` query handling |
| `38af6d94` | 2026-06-09 | 4.2, 4.3 | `FlashcardEditorDraft` focus management in editor view |
| `c1e89cf5` | 2026-06-09 | 3.8, 5.2, 5.5, 5.7 | Deck import CSV paste + parse + validation preview |
| `66bf1460` | 2026-06-09 | 3.8, 5.1 | Deck import route shell |
| `0c2b3a50` | 2026-06-09 | 1.3.3 | Fix folder route registry comment (docs/source) |
| `0cd918dd` | 2026-06-09 | 9.11 | Align persistence recovery decision table |
| `93dec233` | 2026-06-09 | 9.11, 19.3 | Test session persistence recovery |
| `7645e9e8` | 2026-06-09 | 13.3 | Simplify continue-studying card v1 |
| `40e3c8b0` | 2026-06-09 | 9.10 | Confirm active-session exit |
| `30075fbf` | 2026-06-09 | 9.13, 10.4 | Study mode strategy v1 |
| `b2ea71ce` | 2026-06-09 | 9.6 | Make start-over restart transactional |
| `5339d8e5` | 2026-06-09 | 9.6 | Resume / start-over choice v1 |
| `4477dd86` | 2026-06-09 | 9.9, 10.8 | Study result screen v1 |
| `d5ae03f0` | 2026-06-09 | 11.6 | Study session finalization |
| `f3740591` | 2026-06-09 | 10.4, 11.5 | Study session self grading |
| `2971d800` | 2026-06-09 | 9.8 | Study session card navigation |
| `41e049af` | 2026-06-09 | 13.2 | Dashboard today CTA |
