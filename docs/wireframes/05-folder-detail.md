---
last_updated: 2026-06-06
route: /library/folder/:id
source_specs:
  - docs/business/folder/folder-management.md
  - docs/business/deck/deck-management.md
  - docs/business/resume/resume-session.md
  - docs/business/study/study-flow.md
---

# 05 — Folder Detail

## V1 verification status (2026-06-06)

This screen is partially Current. The folder **browser** (subfolders / decks /
unlocked modes, breadcrumb, search/sort affordances, true-empty vs
search-no-results, mode-constrained create FAB, folder-scope summary, and the
overflow rename/move/delete actions) is Current. The **study layer** (mastery
source of truth, due-based study routing, resume banner) is **not built** and
is Future here. Per-deck last-studied metadata and compact progress bars are
Current because they are derived from the existing deck read model, not the
study UI.

> Drift correction (2026-06-06): earlier revisions of this file described a
> `FolderHeroCard` (`folder_hero_card.dart`), `FolderSectionTitle`
> (`folder_section_title.dart`), `FolderStudyEntrySection`
> (`folder_study_entry_section.dart`), a Resume banner, a data-backed mastery
> ring, and Study/Today CTAs as Current ("Prompts 45/47/50"). **None of those
> widget files exist in this codebase** and the study layer is not built. Those
> claims were doc drift and are corrected here to match the actual code.

### Current

- `/library/folder/:id` opens Folder Detail. Invalid/missing `folderId` shows a
  safe error surface (`MxErrorState`) with Retry.
- Breadcrumb/back navigation is Current.
- Subfolder-mode renders subfolders only; deck-mode renders decks only; unlocked
  mode renders the dual-CTA mode-choice empty state (`FolderUnlockedEmpty`).
- **Folder-scope summary is Current** (`folder_detail_summary.dart`), shown only
  when the folder has children (hidden for the empty-locked and unlocked states):
    - decks mode → `FolderDecksSummary`: a card with a non-numeric mastery
      shell, the `{deckCount} decks · {cardCount} cards` line, the real due
      line, and a Start study CTA that enables when `dueTotal > 0`. Totals are
      summed from the loaded decks (`DeckWithCount.cardCount` / `dueCount`) —
      no placeholder mastery percentage or new count.
    - subfolders mode → `FolderSubfoldersSummary`: a three-stat strip
      (subfolders · cards · due total) summed from the direct children
      (`FolderWithCount.cardCount` / `dueCount`).
- Section-header overline (`{n} subfolders` / `{n} decks`) via `MxSectionHeader`
  above the children list.
- Search affordance and sort pill are visible in the header and open controlled
  sheets. The Folder Detail sort sheet only exposes `manual`, `name`, and
  `newest`; `lastStudied` is hidden here because the current query path does
  not support truthful last-studied ordering. True-empty vs search no-results
  is Current (true empty = no unfiltered direct children; no-results = active
  search hides existing children).
- The PNG/spec values in `docs/system-design/MemoX Design System/ui_kits/mobile/shots/04-folder-detail--*.png`
  are approved visual variance where they exceed current support: the decks shot
  may label `newest` as `Recent`, while the `62%`, `6 new`, and `Most due`
  artifacts remain mock-only and are not V1 source of truth. Start study is
  Current in decks mode when real due data exists.
- Per-folder sort state exists on the toolbar (`ContentSortMode`) but this
  screen normalizes unsupported values back to `manual`.
- Create subfolder/deck by content mode is Current. Typed lock-mode snackbar is
  Current.
- **App-bar overflow ⋮ is Current**: opens the folder action sheet
  (`showLibraryFolderActions`) for the **current** folder with Rename / Move /
  Delete, reusing the Library folder action flow
  (`libraryActionControllerProvider` → `{rename,move,delete,getFolderMoveTargets}`
  use cases). Rename now uses `showMxFolderRenameDialog` from
  `docs/wireframes/24-shared-dialogs.md` §folder-form. Import is hidden here
  (it targets a specific deck, not the folder).
  Move opens `showFolderMovePicker` (mock state `moveSheet`); Delete opens the
  shared destructive confirm dialog (`showMxConfirmDialog`, mock state
  `delConfirm`) and, on success, leaves the now-stale detail screen for its parent.
- **Long-press child row is Current**: subfolder rows open the shared folder
  action sheet (`showLibraryFolderActions`) and deck rows open the shared deck
  action sheet (`showDeckActions`). Child-folder actions reuse the existing
  folder use cases; child-deck actions reuse the existing deck delete/reorder
  flow plus deck import.

### Future / not built (MUST NOT be rendered with placeholder values)

- Per-folder / per-deck mastery ring & "{n} new" / fresh counts (no mastery read model).
- Folder-level Today CTA and the Resume banner (study layer not built).
- Global Search route, Flashcard History, tag-scoped study, root-level decks.
- The decks-mode FAB stays a minimal icon button with `New deck` tooltip (not the mock's `New card`):
  creating a card needs a specific `deckId` and decks mode has many decks, so auto-picking is unsafe
  and not an approved flow.

## Purpose

Browse a folder's children: either subfolders or decks, never both. V1 focuses on folder/deck
browsing, a folder-scope summary, search/sort affordances, create actions, and current-folder
overflow actions (rename / move / delete). Folder-level Today routing and the Resume banner are
**Future** (the study layer is not built).

## Layout — folder in `subfolders` mode

```
┌───────────────────────────────────────┐
│ ← Korean                       🔍  ⋮  │  ← App bar; back to parent
├───────────────────────────────────────┤
│ Library / Korean                      │  ← Breadcrumb
├───────────────────────────────────────┤
│                                       │
│ ⚠ You have a paused study session     │  ← RESUME BANNER (Future in V1; study layer not built)
│   for this folder.                    │
│   [Resume]  [Discard]                 │
├───────────────────────────────────────┤
│                                       │
│ ┌─────────────────┐  ┌─────────────┐ │
│ │ Study folder    │  │ Today (12)  │ │  ← Folder-level CTAs (Future in V1)
│ │ ▸               │  │ ▸           │ │     "Today" shown if due > 0 (Future in V1)
│ └─────────────────┘  └─────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 📁 Grammar          3 decks    ▸ │ │  ← Subfolder rows
│ ├───────────────────────────────────┤ │
│ │ 📁 Vocabulary       5 decks    ▸ │ │
│ ├───────────────────────────────────┤ │
│ │ 📁 Honorifics       2 decks    ▸ │ │
│ └───────────────────────────────────┘ │
│                                       │
│                            ┌───┐      │
│                            │ + │      │  ← FAB → "New subfolder" only
│                            └───┘      │     (decks blocked in subfolders mode)
└───────────────────────────────────────┘
```

## Layout — folder in `decks` mode

```
┌───────────────────────────────────────┐
│ ← Korean                       🔍  ⋮  │
├───────────────────────────────────────┤
│ Library / Korean                      │
├───────────────────────────────────────┤
│                                       │
│ ┌─────────────────┐  ┌─────────────┐ │
│ │ Study folder    │  │ Today (8)   │ │  ← Folder-level CTAs (Future in V1)
│ │ ▸               │  │ ▸           │ │
│ └─────────────────┘  └─────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 📚 Korean N5         42 cards  ▸ │ │  ← Deck rows
│ ├───────────────────────────────────┤ │
│ │ 📚 Korean N4         60 cards  ▸ │ │
│ ├───────────────────────────────────┤ │
│ │ 📚 Common phrases    25 cards  ▸ │ │
│ └───────────────────────────────────┘ │
│                                       │
│                            ┌───┐      │
│                            │ + │      │  ← FAB → "New deck" only
│                            └───┘      │     (subfolders blocked here)
└───────────────────────────────────────┘
```

## Layout — folder in `unlocked` mode (just created, empty)

```
┌───────────────────────────────────────┐
│ ← New folder                   ⋮      │
├───────────────────────────────────────┤
│ Library / New folder                  │
├───────────────────────────────────────┤
│                                       │
│              📁                        │
│                                       │
│      This folder is empty.            │
│                                       │
│   Choose how to fill it:              │
│                                       │
│   ┌──────────────────────────────┐   │
│   │ + New subfolder              │   │  ← Picks subfolders mode
│   └──────────────────────────────┘   │
│   ┌──────────────────────────────┐   │
│   │ + New deck                   │   │  ← Picks decks mode
│   └──────────────────────────────┘   │
│                                       │
│   You can have subfolders OR decks    │  ← Mode-lock explanation
│   inside, not both.                   │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param                            | Source | Notes                                      |
|----------------------------------|--------|--------------------------------------------|
| `folderId` (required path param) | URL    | resolves to a `folders.id`; 404 if invalid |

## Data to load

| Data                                                            | Source                                                                                                               | Refresh trigger                                           |
|-----------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|
| Folder detail (name, content_mode, parent chain for breadcrumb) | `folders` lookup + recursive parent join                                                                             | watch                                                     |
| Breadcrumb path                                                 | derived from parent chain                                                                                            | follows folder detail                                     |
| Child folders (when mode=subfolders)                            | `folders WHERE parent_id = :folderId ORDER BY sort_order`                                                            | stream                                                    |
| Child decks (when mode=decks)                                   | `decks WHERE folder_id = :folderId ORDER BY sort_order`                                                              | stream                                                    |
| Deck last-studied aggregate                                     | `MAX(flashcard_progress.last_studied_at)` per deck                                                                    | follows the children stream                               |
| Folder-scope card total (summary line)                          | **Current.** Summed from the loaded `decks[]` / `subfolders[]` (`cardCount`)                                         | follows the children stream                               |
| Folder-scope due total (summary line)                           | **Current.** Summed from the loaded `decks[]` / `subfolders[]` (`dueCount`)                                          | follows the children stream                               |
| Recursive count / resumable session for folder-level study CTAs | **Future.** Study layer not built; no `GetFolderStudyEntryUseCase` exists                                            | n/a                                                       |

## Forbidden

- ❌ Show both "New subfolder" and "New deck" in FAB for a locked folder.
- ❌ Allow tapping past mode-lock without explicit user choice in unlocked mode.
- ❌ Display "Today (0)" — hide the Today CTA when 0 due (Future rule; CTA not built).
- ❌ Truncate breadcrumb so user loses location. Past 3 levels, use middle ellipsis but keep first
  and last.
- ❌ Auto-unlock a locked-but-empty folder. Wait for explicit user action.
- ❌ Start a session directly from Folder Detail unless the real folder-scoped Study Entry
  route is being used.

## Components

| Component                       | Spec                                                                                                                                                                                                                                                                                                                                                                                                             |
|---------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| App bar back                    | Returns to parent folder or Library.                                                                                                                                                                                                                                                                                                                                                                             |
| Breadcrumb                      | Full path from Library to current. Tap any segment to jump.                                                                                                                                                                                                                                                                                                                                                      |
| Folder-scope summary            | **Current.** `FolderDecksSummary` (non-numeric mastery shell + decks · cards + due + Start study CTA enabled when due > 0) or `FolderSubfoldersSummary` (subfolders · cards · due-total strip). Counts summed from loaded children; no fake mastery percentage or new-count placeholder. |
| Resume banner                   | **Future.** Study layer not built. No resumable-session read for this scope.                                                                                                                                                                                                                                                                                                                                    |
| Study folder CTA                | **Future.** Study entry gate / study layer not built.                                                                                                                                                                                                                                                                                                                                                           |
| Today CTA                       | **Future.** Study entry gate / study layer not built.                                                                                                                                                                                                                                                                                                                                                           |
| Subfolder row (subfolders mode) | Folder icon + name + optional `{m} due` badge + `{n} decks · {c} cards` subtitle + compact progress bar + chevron.                                                                                                                                                                                                                                                                                                |
| Deck row (decks mode)           | Icon + name + optional "{m} due" badge + `{n} cards · last {relative time}` subtitle + compact progress bar + chevron.                                                                                                                                                                                                                                                                                    |
| FAB                             | **Current.** Plus icon button with mode-specific tooltip. Action depends on mode: New subfolder (subfolders mode), New deck (decks mode), choice both (unlocked mode).                                                                                                                                                                                                                                 |
| Empty state                     | When `unlocked` and zero children: show choice layout.                                                                                                                                                                                                                                                                                                                                                           |
| Search + section header         | **Current.** Search icon + sort pill above the list plus an `MxSectionHeader` overline (`{n} subfolders` / `{n} decks`). Search opens a controlled sheet; sort opens a controlled picker with only `manual`, `name`, and `newest`. Per-folder search + sort state lives on `FolderDetailToolbar` (`ContentSortMode` at `lib/domain/types/content_sort_mode.dart`), and unsupported values normalize back to `manual`. |

## States

| State            | Trigger                                                                         | Behavior                                                             |
|------------------|---------------------------------------------------------------------------------|----------------------------------------------------------------------|
| Loading          | Initial fetch                                                                   | Skeleton rows.                                                       |
| Populated        | Has children                                                                    | List shown.                                                          |
| Empty (unlocked) | Zero children                                                                   | Empty state with mode-choice buttons.                                |
| Empty (locked)   | Locked but empty (shouldn't happen normally; can occur if all children deleted) | Show "This folder is empty" with FAB action only. Don't auto-unlock. |
| Resume present   | **Future.** Study layer not built                                               | (Future) show Resume banner above CTAs.                             |
| Folder not found | `:id` invalid or deleted                                                        | Show error "Folder not found" with back button.                      |

## Actions

| Action                    | Trigger    | Result                                                                                                                                                                                                                                      |
|---------------------------|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Tap back                  | Back       | Pop to parent.                                                                                                                                                                                                                              |
| Tap breadcrumb segment    | Tap        | Go to that segment's folder; deep stack if needed.                                                                                                                                                                                          |
| Tap subfolder row         | Tap        | **Current.** `push` to `/library/folder/:childId`.                                                                                                                                                                                          |
| Tap deck row              | Tap        | **Current.** `push` to `/library/deck/:deckId/flashcards`.                                                                                                                                                                                  |
| Long-press child row      | Long-press | **Current.** Subfolder rows open the shared folder action sheet; deck rows open the shared deck action sheet.                                                                                                                              |
| Tap "Study folder"        | Tap        | **Future.** Study entry gate / study layer not built.                                                                                                                                                                                       |
| Tap "Today (n)"           | Tap        | **Future.** Study entry gate / study layer not built.                                                                                                                                                                                       |
| Tap resume banner         | Tap        | **Future.** Study layer not built.                                                                                                                                                                                                          |
| Tap FAB                   | Tap        | **Current.** Action depends on `content_mode`: New subfolder dialog (subfolders) OR New deck dialog (decks) OR the dual-CTA picker in the unlocked body. The FAB itself is icon-only; the tooltip/semantics carry the mode label.                                                                                  |
| Tap overflow ⋮            | Tap        | **Current.** Opens the folder action sheet for the current folder: Rename / Move / Delete (reuses the Library folder action flow). Import hidden; Sort by is Future.                                                                          |

## Dialogs and bottom-sheets used

- Resume banner discard dialog — **Future.** Study layer not built.
- New folder dialog — `docs/wireframes/24-shared-dialogs.md` §folder-form.
- New deck bottom-sheet — `docs/wireframes/25-shared-bottom-sheets.md` §deck-create.
- Folder rename dialog — `docs/wireframes/24-shared-dialogs.md` §folder-form.
- Move-to-folder picker — `docs/wireframes/25-shared-bottom-sheets.md` §folder-picker.
- Delete folder dialog — `docs/wireframes/24-shared-dialogs.md` §delete-confirm (strong folder-delete variant with typed confirmation and reassurance copy).
- Item context sheet — `docs/wireframes/25-shared-bottom-sheets.md` §item-context.

## Navigation in

- Tap folder row from Library.
- Breadcrumb tap from descendant.
- Search result tap.

## Navigation out

- Subfolder row → child folder detail.
- Deck row → flashcard list.
- Study CTAs → **Future in V1.** Target: study entry gate / session.
- Back/breadcrumb → ancestor.

## Responsive

- ≥600dp: 2-col grid for rows. CTAs become inline buttons above grid.

## Performance

- Stream-based query for children based on `folder_id = :id`.
- Target/Future: recursive card count for folder-level Today CTA cached for 30s; recalculated after
  content changes.

## Accessibility

- Breadcrumb is a single accessibility region; segments are buttons.
- Start study is Current in decks mode when due > 0; it routes to folder-scoped
  Study Entry (`EntryType.folder`, `StudyType.srsReview`).

## Rules

- Folder shows EITHER subfolders OR decks based on `content_mode`. Never mixed.
- FAB action constrained by `content_mode`; the visible FAB remains icon-only.
- Creating the first child in `unlocked` mode locks the folder to the corresponding mode.
- If a stale UI path or concurrent update attempts the incompatible action, the operation is
  rejected and the screen shows a localized snackbar, not a generic error:
    - folder already containing decks + create-subfolder attempt → "This folder already contains
      decks. Create a deck here or choose another folder for subfolders."
    - folder already containing subfolders + create-deck attempt → "This folder already contains
      subfolders. Create a subfolder here or choose another folder for decks."
- Deleting the last child can unlock back to `unlocked` (per
  `docs/business/folder/folder-management.md` state diagram).
- Empty folder in `unlocked` mode MUST show mode-choice empty state (not generic empty).
- Resume banner MUST appear above all other CTAs when present (Future; banner not built).

## Agent rule

- Do NOT show both "New subfolder" and "New deck" as visible FAB text in a locked folder.
- Do NOT navigate user past mode-lock without explicit choice in unlocked mode.
- Breadcrumb MUST not become so long it overlaps title; truncate middle segments with ellipsis
  past ~3 levels.
- "Today (n)" CTA hidden when n = 0 (don't show "Today (0)") (Future; CTA not built).
- Folder Detail MUST NOT bypass the Study Entry Gate for folder-scoped study actions.

## Implementation refs

**Business specs:**

- `docs/business/folder/folder-management.md`
- `docs/business/deck/deck-management.md`
- `docs/business/resume/resume-session.md` (resume banner is Future for this screen)

**Decision rows:**

- Folder management (mode lock, mode-choice empty state)
- Resume section (Future for this screen; when built: Resume opens session, Discard cancels it)

**Schema / storage:**

- `folders.content_mode`, `folders.parent_id`
- Resume (Future for this screen): `study_sessions` filtered by entry_type=folder; Discard cancels
  via `CancelStudySessionUseCase` (no new session)

**Contracts:** `docs/contracts/usecase-contracts/folder.md`,
`docs/contracts/usecase-contracts/deck.md`,
`docs/contracts/repository-contracts/folder-repository.md`

**Code paths:**

- `lib/presentation/features/folders/screens/folder_detail_screen.dart` (overflow ⋮ → rename/move/delete)
- `lib/presentation/features/folders/widgets/folder_detail_body.dart`
- `lib/presentation/features/folders/widgets/folder_detail_summary.dart` (decks/subfolders summary)
- `lib/presentation/features/folders/widgets/folder_unlocked_empty.dart`
- `lib/presentation/features/folders/widgets/folder_move_picker_sheet.dart`,
  `lib/presentation/features/folders/widgets/library_folder_actions_sheet.dart` (reused for overflow)
- `lib/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart`
- `lib/app/router/route_names.dart` → `RouteNames.folderDetail`

**Related wireframes:**

- `docs/wireframes/02-library.md` (parent)
- `docs/wireframes/06-flashcard-list.md` (deck child)
- `docs/wireframes/12-study-entry-gate.md` (folder-scoped study)
- `docs/wireframes/24-shared-dialogs.md` §folder-form, §rename, §delete-confirm, §discard-session
- `docs/wireframes/25-shared-bottom-sheets.md` §deck-create, §folder-picker, §item-context
