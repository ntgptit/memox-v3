# MemoX — Mobile UI Kit

An interactive click-through gallery of MemoX mobile screens, built in HTML/JSX as a
visual reference for the Flutter implementation in `lib/presentation/features/**`.

## How AI agents consume this kit (read this first)

`index.html` is a single ~10.5k-line JSX file whose real output is **pixels** — do NOT try to
"read the design" from its source. The consumable artifacts are:

1. **`shots/` — canonical visual reference.** Every screen × state × theme is exported as a PNG
   (390px frame, light + dark). `shots/INDEX.md` maps screen/state → file. For any UI task, the
   mock reference is the PNG(s) for that screen — open the image, not the HTML.
2. **`AUDIT.md`** — Flutter-handoff notes, token/widget map, and flagged product decisions.
3. **Line index below** — when you must consult the JSX source (exact copy text, control order,
   conditional visibility), jump straight to the component's line range instead of scanning the
   whole file.

Regenerate shots after any `index.html` change:
`cd tool/ui_kit_shots && npm install && npm run export` (needs Chrome + network).

### Source line index (`index.html`)

Ranges drift when the file is edited — re-derive with
`grep -n "^function .*Screen" index.html` and update this table in the same commit.

| # | Screen | Component | Lines | Shots prefix |
|---|--------|-----------|-------|--------------|
| 01 | Onboarding | `OnboardingScreen` | 9632–10254 | `shots/01-onboarding--*` |
| 02 | Dashboard | `DashboardScreen` | 8081–8649 | `shots/02-dashboard--*` |
| 03 | Library overview | `LibraryOverviewScreen` | 3267–4165 | `shots/03-library-overview--*` |
| 04 | Folder detail | `FolderDetailScreen` | 4166–4836 | `shots/04-folder-detail--*` |
| 05 | Library search | `LibrarySearchScreen` | 7606–8080 | `shots/05-library-search--*` |
| 06 | Flashcard list | `FlashcardListScreen` | 4837–5483 | `shots/06-flashcard-list--*` |
| 07 | Flashcard create | `FlashcardCreateScreen` | 5484–5891 | `shots/07-flashcard-create--*` |
| 08 | Flashcard edit | `FlashcardEditScreen` | 5892–6479 | `shots/08-flashcard-edit--*` |
| 09 | Flashcard history | `FlashcardHistoryScreen` | 6480–6963 | `shots/09-flashcard-history--*` |
| 10 | Deck import | `DeckImportScreen` | 6964–7605 | `shots/10-deck-import--*` |
| 11 | Tag management | `TagManagementScreen` | 2599–3266 | `shots/11-tag-management--*` |
| 12 | Study · Review | `StudyScreen` | 483–634 | `shots/12-study-review--*` |
| 13 | Study · Match | `MatchScreen` | 635–706 | `shots/13-study-match--*` |
| 14 | Study · Guess | `GuessScreen` | 707–815 | `shots/14-study-guess--*` |
| 15 | Study · Recall | `RecallScreen` | 816–892 | `shots/15-study-recall--*` |
| 16 | Study · Fill | `FillScreen` | 893–1005 | `shots/16-study-fill--*` |
| 17 | Study result | `StudyResultScreen` | 9150–9631 | `shots/17-study-result--*` |
| 18 | Stats | `StatsScreen` | 10255–10330 | `shots/18-stats--*` |
| 19 | Progress | `ProgressScreen` | 8650–9149 | `shots/19-progress--*` |
| 20 | Settings | `SettingsScreen` | 1006–1233 | `shots/20-settings--*` |
| 21 | Account sync | `AccountSyncScreen` | 1234–1728 | `shots/21-account-sync--*` |
| 22 | Learning settings | `LearningSettingsScreen` | 1729–2072 | `shots/22-learning-settings--*` |
| 23 | Audio & speech | `AudioSpeechScreen` | 2073–2598 | `shots/23-audio-speech--*` |

State registry (`GROUPS` array, screen → state values/labels): lines 10409–10433.

`index.html` renders every screen as a static phone frame on one scrollable stage, with a
**Light / Dark** toggle in the header (dark mode is the scoped *Tokyo Nebula* theme). Screens
are visual-only — `go()` is a no-op, so frames don't navigate; each frame just shows one state.

> **Audit pass:** see [`AUDIT.md`](./AUDIT.md) for the Flutter-handoff review — what was
> fixed (apostrophe-escape content bug, icon/nav/focus accessibility, 44px hit targets,
> reduced-motion, a new reusable `OfflineBanner` + Dashboard `offline` state) and what is
> flagged for a product decision (gradients in chrome, self-hosted fonts/icons).

## Screens

The gallery is ordered by **user journey** — first-run → home → browse → manage a deck →
study → result → insights → settings — and numbered `01`–`23` in that flow. Most screens ship
several labelled **state variants** so every empty / loading / error / overlay case is visible
side by side.

| # | Screen | States shown |
|---|--------|--------------|
| **1 · First run** | | |
| 01 | **Onboarding** | welcome · zero state · create deck · deck for import · signing in · restore prompt · restoring · restore failed · import handoff |
| **2 · Home** | | |
| 02 | **Dashboard** | loaded · loading · onboarding · goal off · resume only · streak broken · error · offline · multi resume |
| **3 · Library** | | |
| 03 | **Library overview** | loaded · loading · empty · error · search · overflow sheet |
| 04 | **Folder detail** | decks · subfolders · unlocked · search empty · loading · error · delete · move sheet |
| 05 | **Library search** | empty · loading · results · no results · error |
| **4 · Deck & cards** | | |
| 06 | **Flashcard list** | loaded · empty · search empty · loading · error · delete card · delete deck · reorder |
| 07 | **Flashcard create** | empty · valid · details open · validation · saving · save failed |
| 08 | **Flashcard edit** | loaded · loading · load error · validation · saving · save failed · delete |
| 09 | **Flashcard history** | loaded · empty · loading · error · partial |
| 10 | **Deck import** | empty · file selected · parsing · preview all · preview mixed · importing · success · partial · failed |
| 11 | **Tag management** | loaded · loading · empty · search empty · action sheet · rename · rename→merge · merge sheet · delete · busy · op error |
| **5 · Study** | | |
| 12 | **Study · Review** | term + meaning, swipe-to-next |
| 13 | **Study · Match** | pair fronts & backs |
| 14 | **Study · Guess** | multiple choice A–E |
| 15 | **Study · Recall** | hidden · revealed |
| 16 | **Study · Fill** | input · wrong |
| 17 | **Study result** | loaded · loading · goal off · save failed · defensive · tough empty |
| **6 · Insights** | | |
| 18 | **Stats** | weekly chart + per-deck mastery |
| 19 | **Progress** | week · month · loading · empty · insufficient · partial · error |
| **7 · Settings** | | |
| 20 | **Settings** | populated · loading · signed out · signing in · sync error |
| 21 | **Account sync** | signed out · signing in · failed · no backup · ready · uploading · restore warn · restoring · token expired |
| 22 | **Learning settings** | goal on/off · reminder on · perm denied · saving |
| 23 | **Audio & speech** | Korean · English · loading · no voices · engine error · playing · saving |

## Conventions

- `StatusBar`, `BottomNav`, `Breadcrumb`, `StudyTopBar` and `Ic` are shared layout/icon
  primitives; everything else is a screen-level component that takes a `state` prop.
- `masteryColor(pct)` maps a 0–1 mastery value to a card-status token (learning → reviewing → mastered).
- `Phone` wraps each frame; `App` builds the `screens` array and the theme toggle.
- Icons via the Lucide CDN (substitute for Flutter's Material Symbols).
- All colour / spacing / radius / type values come from `../../colors_and_type.css`. Dark mode is
  applied through the scoped `.memox-dark` block in `index.html` (the in-page Light/Dark toggle),
  which mirrors the Tokyo Nebula dark tokens from the shared stylesheet.

## Source mapping

Each screen mirrors a feature page under `lib/presentation/features/**` (e.g. study modes →
`lib/presentation/features/study/**`, library/folder/flashcard screens →
`lib/presentation/features/folders/**` and `lib/presentation/features/flashcards/**`, search →
`lib/presentation/features/search/**`, settings/audio →
`lib/presentation/features/settings/**`). Use the Flutter feature folders as the source of truth
for behaviour; this kit only fixes the visual language.
