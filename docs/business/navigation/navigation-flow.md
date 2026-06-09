---
last_updated: 2026-06-01
applies_to: routing, navigation, deep links
---

# Navigation Flow

## Source files to inspect

- `lib/app/router/app_router.dart`
- `lib/app/router/route_names.dart`
- `lib/presentation/features/**/routes/*.dart`
- `lib/app/app_shell.dart`

## Router contract

- Use GoRouter.
- Use existing `RouteNames` and `RoutePaths`.
- Do not hardcode route strings in widgets.
- Add route constants before adding new routes.
- Keep shell navigation visibility correct.

## Top-level destinations

| Path        | Responsibility | Shell visible |
|-------------|----------------|---------------|
| `/home`     | Dashboard      | Yes           |
| `/library`  | Library        | Yes           |
| `/progress` | Progress       | Yes           |
| `/settings` | Settings hub   | Yes           |

Current V1 app boot redirects `/` to `RouteDefaults.initialLocation = RoutePaths.library`. This is
the existing app entry and must not be replaced by an onboarding wizard in V1. Dashboard remains a
top-level destination, but changing the default entry to `/home` requires a dedicated navigation
task with route tests and doc updates.

## Settings routes

| Path                      | Responsibility                                                                                                             | Shell visible |
|---------------------------|----------------------------------------------------------------------------------------------------------------------------|---------------|
| `/settings/account`       | Account linking + Drive sync                                                                                               | No            |
| `/settings/learning`      | Learning settings (daily goal, reminder, tags, future study defaults)                                                     | No            |
| `/settings/learning/tags` | Tag management (new; see `docs/business/tags/tag-system.md` and wireframe `docs/wireframes/22-settings-tag-management.md`) | No            |
| `/settings/audio-speech`  | Audio & speech settings (Korean / English tabs, voice list, sliders, preview)                                             | No            |

Route name constants (from `lib/app/router/route_names.dart`): `RouteNames.settings`,
`RouteNames.settingsAccount`, `RouteNames.settingsLearning`, `RouteNames.settingsLearningTags`,
`RouteNames.settingsAudioSpeech`. Path segment constants: `RoutePaths.settingsAccountSegment`,
`RoutePaths.settingsLearningSegment`, `RoutePaths.settingsLearningTagsSegment`,
`RoutePaths.settingsAudioSpeechSegment`.

## Library routes

| Route responsibility      | Route pattern                                                                                                                                                                                                                                                                           | Shell visible |
|---------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| Folder detail             | `/library/folder/:id`                                                                                                                                                                                                                                                                   | Yes           |
| Flashcard list            | `/library/deck/:deckId/flashcards`                                                                                                                                                                                                                                                      | Yes           |
| Flashcard list (filtered) | `/library/deck/:deckId/flashcards?filter={active\|suspended\|buried\|due}&tag={t1,t2}`                                                                                                                                                                                                  | Yes           |
| Flashcard create          | `/library/deck/:deckId/flashcards/new`                                                                                                                                                                                                                                                  | No            |
| Flashcard edit            | `/library/deck/:deckId/flashcards/:flashcardId/edit`                                                                                                                                                                                                                                    | No            |
| Flashcard history         | Future Proposal; no live V1 route                                                                                                                                                                                                                                                       | No            |
| Deck import               | `/library/deck/:deckId/import`                                                                                                                                                                                                                                                          | No            |
| Library search            | `/library/search` (Current — global search over folders/decks/flashcards; tags section + recent/popular are Future). Exposed as a separate route, not from the Library Overview app bar                                                                                                  | Yes           |
| Study entry               | `/library/study/:entryType/:entryRefId` (Current entryType: `deck` \| `folder`; `tag` is Blocked/Future). Current V1 opens `StudyEntryScreen`, validates params, resolves the scope, renders empty states for zero eligible cards, and `pushReplacement`s to `/library/study/session/:sessionId` when eligible cards exist. Optional `?study_type=srs_review` requests a deck-scoped (Current, Prompt 46) or folder-scoped (Current, Prompt 45) due review; optional `?mode=` selects a single study mode | No            |
| Today study               | `/library/study/today` (Current V1 opens `StudyEntryScreen.today` and follows the same gate behavior as scoped study, including empty states and session redirect)                                                                                                                                                                                                    | No            |
| Study session             | `/library/study/session/:sessionId` (Current V1 review screen; opens `StudySessionScreen` with current-card navigation, shows Finish Session only after every card is answered, and `pushReplacement`s to the placeholder result route on explicit finish)                                                                                                                                                          | No            |
| Study result              | `/library/study/session/:sessionId/result`                                                                                                                                                                                                                                              | No            |

Notes:

- Query-string filters on the flashcard list are application conventions; verify GoRouter
  declarations in `lib/presentation/features/**/routes/*.dart`.
- The `tag` entry type is Blocked/Future until `StudyEntryType.tag` and tag-scope queries are
  promoted. Flashcard history route is Future Proposal — add its route constants in `RouteNames` /
  `RoutePaths` and wire it only when its scope guard promotes it.
- Library search is Current: `RouteNames.librarySearch` / `RoutePaths.librarySearchTemplate`
  (`/library/search`), registered as a child of the Library branch (shell visible). The promoted V1
  scope covers folders/decks/flashcards only; the Library Overview screen no longer exposes a search
  affordance in the app bar. The tags result section, recent searches, and popular-tags landing
  remain Future Proposal pending the tag subsystem + a `shared_preferences` dependency
  (`docs/business/search/global-search.md`).
- Folder Detail surfaces Study folder / Today / Resume entry points (Current, Prompt 45). Study
  folder and Today route through the Study Entry gate (`entry_type=folder`, with
  `study_type=srs_review` for Today); the Resume banner opens the existing `study/session/:id`
  directly without re-entering the gate or creating a session. Folder Detail never creates a session
  itself.
- Flashcard List surfaces Study deck / Today / Resume entry points (Current, Prompt 46). Study deck
  and Today route through the Study Entry gate (`entry_type=deck`, with `study_type=srs_review` for
  Today — never global `entry_type=today`); the Resume banner opens the existing `study/session/:id`
  directly without re-entering the gate or creating a session. Flashcard List never creates a
  session itself.
- Study Session is a real review screen in V1: it loads a persisted session and ordered session
  items, shows the current card with a reveal toggle, supports Previous/Next navigation with
  reveal reset on move, and keeps `/library/study/session/:sessionId/result` as the placeholder
  route.
- Current V1 note: the Study Entry routes are now real screens that start or resume persisted
  sessions, render the empty-scope matrix when no eligible cards exist, and use
  `pushReplacement` for the session redirect. The create/resume edges in the diagram remain the
  target contract for the deferred dialog flow.

## Push vs Go rules

| Scenario                                                  | Method             | Reason                        |
|-----------------------------------------------------------|--------------------|-------------------------------|
| Folder → subfolder                                        | `push`             | Need back stack               |
| Folder → deck flashcards                                  | `push`             | Need back                     |
| Flashcard list → create                                   | `push`             | Return result                 |
| Flashcard list → edit                                     | `push`             | Return result                 |
| Deck → import                                             | `push`             | Return result                 |
| Settings hub → sub-screen (account/learning/audio-speech) | `push`             | Need back to hub              |
| Bottom nav switch                                         | `go`               | Reset tab stack               |
| Study entry → session                                     | `pushReplacement`  | No back into entry screen     |
| Session → result                                          | `pushReplacement`  | Session is done, do not stack |
| Result → origin                                           | `go`               | Reset, do not stack result    |
| Invalid route                                             | `go` to safe route | Recover, do not stack error   |

## Navigation flow diagram

```mermaid
stateDiagram-v2
    [*] --> Dashboard
    Dashboard --> Library: tab switch (go)
    Library --> FolderDetail: tap folder (push)
    FolderDetail --> FolderDetail: tap subfolder (push)
    FolderDetail --> FlashcardList: tap deck (push)
    FlashcardList --> FlashcardCreate: + button (push)
    FlashcardList --> FlashcardEdit: tap card (push)
    FlashcardList --> DeckImport: import action (push)
    FlashcardCreate --> FlashcardList: save or cancel (pop)
    FlashcardEdit --> FlashcardList: save or cancel (pop)
    DeckImport --> FlashcardList: complete (pop)

    Library --> StudyEntry: start study (push)
    Dashboard --> TodayStudy: today action (push)
    StudyEntry --> StudySession: create session (pushReplacement)
    TodayStudy --> StudySession: create session (pushReplacement)
    StudySession --> StudyResult: finalize (pushReplacement)
    StudyResult --> Library: continue (go)
    StudyResult --> Dashboard: home (go)

    StudySession --> ConfirmExit: back gesture
    ConfirmExit --> StudySession: cancel
    ConfirmExit --> Library: confirm (go)
```

## Navigation behavior

- Library opens root content.
- Folder detail opens child folders or decks.
- Deck opens flashcard list.
- Flashcard create/edit returns to flashcard list.
- Import returns to deck/folder context.
- Study entry creates or resumes persisted session.
- Study session route protects accidental exit and waits for explicit Finish Session before leaving the review screen.
- Study result returns to relevant origin when available.

## Invalid route behavior

When params are invalid or entity is deleted:

- Show shared error state (`MxErrorState`).
- Do not crash.
- Do not create fake fallback data.
- Provide safe navigation action (`go` to nearest valid ancestor).

## Deep link rules

- Public routes (deep linkable): `/home`, `/library`, `/library/search`, `/library/folder/:id`,
  `/library/deck/:deckId/flashcards`, `/progress`, `/settings`.
- Private routes (not deep linkable): study session routes, create/edit forms, import.
- Private routes accessed via deep link must redirect to safe public ancestor.

## Back behavior

| Screen           | Back behavior                                    |
|------------------|--------------------------------------------------|
| Top-level        | System exit (or to Dashboard)                    |
| Folder detail    | Pop to parent folder or library root             |
| Flashcard list   | Pop to deck's folder                             |
| Create/edit form | Pop with confirm if dirty                        |
| Study session    | Confirm dialog, then pop with `cancelled` status |
| Study result     | Go to origin, do not allow back into session     |

## Agent checklist

- Route constants updated.
- Route file updated.
- Navigation call sites updated.
- Push vs go matches table.
- Shell hide/show behavior checked.
- Deep link rules respected.
- Tests or decision table updated.

## Related

**Wireframes:**

- All wireframes — each documents its `route:` in frontmatter and Navigation in/out section
- `docs/wireframes/index.md` — index of screens grouped by tree

**Schema:**

- No direct schema dependency. Routes operate on entity IDs.

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Navigation" (push vs go, invalid
  route recovery, deep link rules)

**Glossary terms:**

- `docs/business/glossary.md` → "push", "go", "pushReplacement" semantics

**Related business specs:**

- Every business spec that introduces a route (most of `docs/business/**`)
- `docs/business/resume/resume-session.md` — entry gate uses `pushReplacement` so back returns to
  caller
- `docs/business/study/study-flow.md` — `/library/study/...` family

**Source files to inspect:**

- `lib/app/router/route_names.dart`
- `lib/app/router/route_paths.dart`
- `lib/app/router/app_router.dart`
- `lib/app/router/redirect.dart`
