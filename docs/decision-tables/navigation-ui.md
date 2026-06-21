---
last_updated: 2026-06-19
source: split from memox-core-decision-table.md
applies_to: Navigation and UI state behavior branches
---

# MemoX Decision Table — Navigation / UI

## Convention
- `ID` is stable. Tests reference it by ID (e.g. `// decision: N1`).
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` column: `TBD` until the implementing agent writes the test.
  Tests must be derived from the Expected column, NOT from code.

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| N1 | Open route | Valid params | Show screen | C0+C1 | TBD |
| N2 | Open route | Missing/deleted entity | Show shared error state | C1 | TBD |
| N3 | Navigate | From widget | Use route constants | C0 | TBD |
| N4 | Push vs Go | Form → list | Use push, return on pop | C1 | TBD |
| N5 | Push vs Go | Session → result | Use pushReplacement | C1 | TBD |
| N6 | Deep link | Private route | Redirect to safe ancestor | C1 | TBD |
| N7 | Settings hub → sub-screen | Tap row | Push to sub-screen, back returns to hub | C0+C1 | TBD |
| N8 | Future route smoke lock | Direct Future/Blocked paths requested (`/onboarding`, reminder/daily-goal settings paths) | Resolve to router error state, not to a live V1 screen/action. NOTE: top-level `/search` (design redesign — placeholder until the Search screen ships, then its real screen) and flashcard history `/library/deck/:deckId/flashcards/:flashcardId/history` (promoted 2026-06-13, Current) render their registered destinations, not the error state | C1 | TBD |
| N9 | Future route registry lock | Route constants/navigation helpers inspected | No onboarding, daily-goal, or reminder Future route constant/action is promoted. `RouteNames.search` (top-level `/search`, design redesign) and `RouteNames.flashcardHistory` (with its `RoutePaths` template) ARE intentionally promoted. There is no `RouteNames.librarySearch` constant (search is a top-level destination, not a `/library` child) | C1 | TBD |
| N10 | Onboarding feature lock | Feature folder inspected | No standalone onboarding presentation feature folder exists in V1 | C1 | TBD |
| N11 | Open study session route | Valid `sessionId` | Show `StudySessionScreen`; missing session shows a controlled not-found/error state; result route opens the real result screen | C0+C1 | TBD |
| N12 | Dashboard Today CTA | `dueToday > 0` | Tap routes to `RoutePaths.studyTodayTemplate` via the study entry gate | C1 | TBD |
| N13 | Dashboard Today CTA | `dueToday == 0` | Show caught-up/no-due copy, disable the study CTA, and do not enter study flow | C1 | TBD |
| N14 | Bottom-nav destinations | Shell rendered | Exactly five tabs in order Home · Library · Search · Progress · Settings; tapping a tab uses `goBranch`; re-tapping the active tab returns it to its branch root (`initialLocation: true`) | C0+C1 | TBD |
| N15 | Breadcrumb trail | Folder detail loaded | Trail `Library › …ancestors › {currentFolder}`; last crumb (current folder) non-tappable; `Library` + each ancestor tappable; hidden in search mode | C1 | TBD |
| N16 | Breadcrumb trail | Flashcard list loaded | Trail `Library › …folders › {deckName}`; deck is the non-tappable current leaf; every folder crumb is a tappable ancestor; hidden in reorder mode and until loaded (flashcard-list search is a persistent bottom dock, WP-D2, so the trail stays during search) | C1 | TBD |
| U1 | Load | Loading | Show shared loading/retained state | C0 | TBD |
| U2 | Load | Empty | Show shared empty state | C0+C1 | TBD |
| U3 | Load | Error | Show shared error state | C0+C1 | TBD |
| U4 | Submit | Saving | Prevent double submit | C1 | TBD |
| U5 | Delete | Destructive | Require confirmation | C1 | TBD |
