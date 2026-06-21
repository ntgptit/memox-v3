---
last_updated: 2026-06-15
status: contract
route: /home
screen: Dashboard
---

# Dashboard Visual Contract

This is the source of truth for mapping the approved Dashboard mock to Flutter implementation. It narrows the HTML mock through current MemoX product scope, wireframes, business docs, shared components, and design tokens.

## Source Inputs

- Source mock path: `docs/system-design/MemoX Design System/ui_kits/mobile/index.html`
- Source mock section: `02 · Dashboard`
- Related wireframe: `docs/wireframes/01-dashboard.md`
- Related business docs: `docs/business/engagement/dashboard-engagement.md`, `docs/business/resume/resume-session.md`, `docs/business/study/study-flow.md`, `docs/business/navigation/navigation-flow.md`
- Mock-doc bridge: `docs/system-design/mock-design-doc-mapping.md`
- Design token contract: `docs/design/design-token-mapping.md`
- Shared component contract: `docs/design/component-visual-contract.md`
- UI/UX contract: `docs/ui-ux/ui-ux-contract.md`

## Current V1 Scope (updated 2026-06-15 — fidelity pass)

- Resume card (with Discard) is a current V1 surface.
- Today's-review card is a current V1 surface (due count + due-deck count + estimated minutes, with a caught-up state when `dueToday == 0`).
- **Computed streak chip** is current V1 — reads `LoadDashboardProgressSummaryUseCase`; hidden when streak `< 1`.
- **Daily-goal ring** is current V1 — reads the same use case; hidden when the goal is disabled/unknown, but the goal tile still stays visible in the disabled state.
- **Recent decks** and the **never-studied "new" count** are current V1 — read `LoadDashboardDeckHighlightsUseCase`.
- **Start new learning** is current V1 — routes to the global new-cards study entry (deck/folder scope picker still deferred).
- **Dashboard has no search shortcut** (design redesign): global search is the top-level `/search`
  bottom-nav destination, so the former Dashboard app-bar search action is removed (WBS 5.8.1 Rejected).
- Loading, error, onboarding, resume-only, offline, streak-broken, and multi-resume visual chrome states are part of the current fidelity pass.
- The paused-session chip is currently visual chrome only; the source-backed paused-session list sheet remains deferred.
- App launch still defaults to Library; `/home` renders Dashboard V1 but is not the boot route.

## Explicitly Excluded

- Reminder and notification permission surfaces.
- Streak-history sheet and daily-goal slider.
- The two-step deck/folder scope picker for "Start new learning" (V1 routes straight to global new cards).
- Paused-sessions multi-resume sheet.
- Changing app boot default to Dashboard.
- Any Google sign-in or Drive-restore onboarding copy that appears in older mock prose.

## Implementation Files Likely Touched Later

| Concern | Likely file |
| --- | --- |
| Dashboard screen shell | `lib/presentation/features/dashboard/screens/dashboard_screen.dart` |
| Dashboard state/view model | `lib/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart` |
| Resume card | `lib/presentation/features/dashboard/widgets/dashboard_resume_card.dart` |
| Today CTA / caught-up card | `lib/presentation/features/dashboard/widgets/dashboard_today_card.dart` |
| Onboarding state | `lib/presentation/features/dashboard/widgets/dashboard_onboarding_state.dart` |
| Loading skeletons | `lib/presentation/features/dashboard/widgets/dashboard_loading_state.dart` |
| Recent decks section | `lib/presentation/features/dashboard/widgets/dashboard_recent_decks_section.dart` |
| Error/offline surfaces | `lib/presentation/features/dashboard/widgets/dashboard_feedback.dart` |
| Dashboard data/query owner | `lib/domain/usecases/engagement/**`, `lib/data/repositories/**`, `lib/data/datasources/local/daos/**` |

## Element Mapping

| Mock element | Mock state(s) | Product status | Flutter mapping | Data source | Action | Notes |
| ------------ | ------------- | -------------- | --------------- | ----------- | ------ | ----- |
| App bar greeting + subtitle | loaded, loading, onboarding | Current V1 | `MxAppBar` + `MxText` | Local time and localized dashboard copy | None | Use localized greeting copy; the sample name/date in the HTML are visual-only. |
| Search icon | — | Rejected (redesign) | — | — | — | Removed: Search is the top-level `/search` tab; no Dashboard app-bar search (WBS 5.8.1 Rejected). |
| Settings icon | loaded, offline, error | Current V1 | `MxIconButton` | Route shell | `go` to `RoutePaths.settings` | Shell-visible settings shortcut is allowed. |
| Offline banner | offline | Current V1 | `MxCard` + inline warning surface | Connectivity state if a shared app-level signal exists later | None | Non-blocking feedback; the Dashboard stays visible behind the banner. |
| Error card + retry | error | Current V1 | `MxErrorState` or `MxCard` + `MxActionButton` | Dashboard query failure | Retry | Keep the error localized. The mock’s `Open Library` secondary action is excluded because the business docs only require retry. |
| Resume card shell | loaded, resumeOnly, multiResume | Current V1 | `MxCard` + `MxCardActions` + `MxText` | Resumable-session lookup | Continue, Discard | Top placement is required when a resumable session exists. |
| Resume progress block | loaded, resumeOnly | Current V1 | `MxText` + `MxLinearProgress` / `MxStatDisplay` | Session header + items | None | Show scope name, answered count, and relative last-active time. |
| More paused sessions chip | multiResume | Visual chrome | `MxSecondaryButton` / `MxTextButton` | No list-active-sessions hook yet | Open paused-sessions sheet | The chip is visible in the parity pass, but the list/sheet remains deferred. |
| Static streak placeholder | loaded, goalOff | Current V1 | `MxStatDisplay` or `MxCard` | None; goal-disabled placeholder only | None | Render the disabled goal state without a streak count. |
| Goal ring / daily-goal card | loaded, goalOff | Current V1 | `MxMasteryRing` / `MxCard` | Engagement prefs + study_attempts aggregate | None | The disabled goal state stays visible, but the streak chip stays hidden when streak is 0. |
| Streak-broken banner | streakBroken | Visual chrome | `MxCard` | Computed broken-streak signal | None | The fidelity pass shows the banner inline; dismiss behavior remains future. |
| Today CTA / caught-up card | loaded, resumeOnly | Future (WP-SR1b) | `MxCard` + `MxActionButton` | Today due-count provider | `go` to the `today` study entry gate (`/library/study/today`) only when `dueToday > 0`; otherwise render the caught-up/disabled state and keep the user out of study flow. The `today` route constant is WP-SR1b (not yet defined) | The caught-up variant replaces the primary due card when no cards are due, and the primary action must be disabled or replaced with a non-study action. |
| Start new learning CTA | loaded, onboarding, resumeOnly | Current V1 | `MxPrimaryButton` / `MxSecondaryButton` | No scope picker source yet | `goStudyEntry(entryType: today, studyType: newCards)` | The prompt routes straight to the global new-cards entry; the scope picker remains deferred. |
| Recent decks section header | loaded, resumeOnly | Current V1 | `MxSectionHeader` | None | None | The section title is part of the screen chrome. |
| Recent decks header shortcut | loaded, resumeOnly | Visual-only | `MxTextButton` or `MxIconButton` | None | Optional library navigation | Bottom nav already covers `/library`; this shortcut is not a product requirement. |
| Recent deck rows | loaded, resumeOnly | Missing data | `MxCard` + `MxTappable` + `MxIconTile` | Deck list ordered by `updated_at DESC` | Open deck flashcard list | There is no Dashboard-specific recent-decks query yet. |
| Loading skeletons | loading | Current V1 | `MxRetainedAsyncState` + `MxSkeleton` | Async dashboard providers | None | Keep skeletons per section instead of a full-screen spinner. |
| Onboarding hero card | onboarding | Current V1 | `MxCard` + `MxPrimaryButton` + `MxSecondaryButton` | Zero decks + zero flashcards | Open library | Keep the hero minimal until a source-backed onboarding action exists. |
| Onboarding reassurance cards | onboarding | Current V1 | `MxCard` + `MxIconTile` + `MxText` | None | None | Calm copy only; no business behavior is attached to these cards. |
| Bottom navigation | all | Current V1 | `MxBottomNavigationBar` | Shell route state | Home, Library, Progress, Settings | Home is shell-visible, but the app still boots into Library. |

## State Mapping

| Mock state | Current V1 behavior | Implement now? | Notes |
| ---------- | ------------------- | -------------- | ----- |
| loaded | Resume card, streak chip, goal card, Today CTA, start-new-learning CTA, and recent decks | Yes | Keep the overall density compact and card-driven. |
| loading | Section-level skeletons for resume and today cards | Yes | Do not block the whole screen on one slow provider. |
| onboarding | Zero-content body with the richer hero, primary CTA, secondary CTA, and reassurance cards | Yes | Exclude the legacy Google sign-in/restore copy from V1. |
| goal off | Hide the streak chip and keep the goal card visible in disabled state | Yes | Goal persistence and streak computation are current V1 features. |
| resume only | Resume card remains visible; Today CTA becomes caught-up and disabled | Yes | This is the main no-due / resumable-session combination. The Today action must not enter study flow when no cards are due. |
| streak broken | One-time broken-streak banner above the resume card | Yes | The fidelity pass shows the banner inline; dismiss behavior remains future. |
| error | Inline Dashboard error state with retry | Yes | Keep the message localized and do not surface raw failures. |
| offline | Non-blocking offline banner | Yes | Visual chrome only; the Dashboard stays visible behind the banner. |
| multi resume | Resume card plus paused-sessions chip entry | Yes | The chip is visible in the parity pass, but the list/sheet remains deferred. |

## Layout Hierarchy

1. App bar with greeting on the left and shell actions on the right.
2. Inline feedback surfaces, in this order when present: offline banner, error card, streak-broken banner.
3. Resume card at the top of the body when a resumable session exists.
4. Streak chip and goal card only when the current engagement summary is available.
5. Today CTA or caught-up card.
6. Onboarding hero when zero content exists.
7. Bottom navigation.

For onboarding, render the zero-content hero only.

## Shared Component Mapping

| UI need | Shared component | Notes |
| --- | --- | --- |
| Screen shell | `MxScaffold` | Use the design-system shell, not a raw `Scaffold`. |
| App bar | `MxAppBar` | Keep the header compact and localizable. |
| Card surfaces | `MxCard` | Use tokenized surfaces and ghost borders. |
| Resume / today actions | `MxPrimaryButton` + `MxSecondaryButton` | Keep the primary action visually dominant and the secondary lighter. |
| Empty state | `MxCard` / `MxIconTile` / `MxText` | Use for onboarding and empty caught-up states. |
| Error state | `MxErrorState` | Use for query failure. |
| Offline state | `MxCard` + warning surface | Non-blocking shared feedback. |
| Loading | `MxRetainedAsyncState` + `MxSkeleton` | Keep skeletons per section. |
| Section header | `MxSectionHeader` | Use for the Recent decks title. |
| Icon tile | `MxIconTile` | Use for resume, deck, and onboarding cards. |
| Text roles | `MxText` | Do not hand-roll typography roles in feature widgets. |
| Bottom navigation | `MxBottomNavigationBar` | Home, Library, Progress, Settings remain shell routes. |
| Confirm discard | `showMxConfirmDialog` | Use for discard-session confirmation in the later coding task. |
| Bottom sheet entry | `showMxBottomSheet` | Use for paused sessions when that list flow exists. |

## Route And Action Mapping

| Mock action | Route / action contract | Notes |
| --- | --- | --- |
| Resume card Continue | `RoutePaths.studySession(sessionId)` / `RouteNames.studySession` via `go` | Resume opens the persisted session directly. |
| Resume card Discard | `showMxConfirmDialog` then `CancelStudySessionUseCase` | Discard is destructive and must confirm. |
| More paused sessions | `showMxBottomSheet` | Opens the paused-sessions list when the list query exists. |
| Offline banner | visual chrome | Non-blocking warning surface on top of the dashboard body. |
| Streak-broken banner | visual chrome | One-time inline banner above the resume card when the chrome bridge marks it broken. |
| Today CTA | the `today` study entry gate (`/library/study/today`) via `go` — **WP-SR1b** (route constant not yet defined) | The study entry gate then `pushReplacement`s into the session route. |
| Start new learning | Deferred | No source-backed scope picker exists yet. |
| Settings icon | `RoutePaths.settings` / `RouteNames.settings` via `go` | Shell-visible and current V1. |
| Search icon | Removed (redesign) — search is the top-level `/search` tab | No Dashboard search affordance (WBS 5.8.1 Rejected). |
| Recent deck row | `RoutePaths.flashcardList(deckId)` / `RouteNames.flashcardList` via `push` | Open the deck-specific flashcard list. |
| Bottom-nav Home | `RoutePaths.home` / `RouteNames.home` via `go` | The route exists and now renders Dashboard V1. |
| Bottom-nav Library / Progress / Settings | `go` to the matching shell route | Shell navigation resets tab stack. |

## Copy Expectations

- Use the existing `dashboard*` ARB namespace in `lib/l10n/app_en.arb` and `lib/l10n/app_vi.arb`.
- Do not hardcode the mock’s sample name/date strings.
- Use `dashboardResumeSectionTitle`, `dashboardContinueSessionAction`, `dashboardDiscardAction`, and `dashboardMorePausedSessions` for resume copy.
- `dashboardStartNewLearningAction`, `dashboardScopePickerTitle`, and the scope-picker subtitle keys remain reserved for a future source-backed picker.
- Use the existing `dashboardRecentDecksTitle`, `dashboardDeckDueSummary`, and `dashboardDeckCaughtUpSummary` keys for recent deck rows.
- Use `dashboardOfflineTitle`, `dashboardOfflineMessage`, `sharedErrorTitle`, and `commonRetry` for offline/error feedback.
- Use `studyEntryResumeRequiredTitle`, `studyEntryResumeRequiredMessage`, and `studyEntryResumeRequiredCta` for the controlled resume-required fallback.
- Keep the legacy Google sign-in / restore copy out of Dashboard V1.

## Accessibility Notes

- Every tappable surface needs a 48dp minimum hit target.
- Resume and discard actions must each have separate semantics.
- The paused-sessions chip needs an accessible count label, not just a chevron.
- Disabled or hidden search affordances must not advertise fake behavior.
- Loading skeletons should remain decorative and not be read as content.
- Bottom-nav selected state must be announced.
- Numeric labels in resume/progress cards should use tabular-friendly typography.

## Light And Dark Visual Notes

- The mock is rendered in both Tokyo Pure Light and Tokyo Nebula; the contract applies to both themes.
- Use `surface`, `surfaceContainerLowest`, `surfaceContainerLow`, and `outlineVariant` ghost borders for cards.
- Use `MxCard` warning surfaces and error surfaces for semantic warning/error feedback; do not copy raw HTML colors into feature widgets.
- The mock’s gradient-heavy resume/today cards are visual inspiration only. Production should use tokenized tonal surfaces and border accents instead of raw CSS gradients.
- `dashboardOfflineTitle` / `dashboardOfflineMessage` use warning semantics in both themes.

## Open Questions

- None blocking. The remaining gap is implementation-only: the paused-session list sheet still needs a source-backed owner.

## Next implementation task

Implement Home Dashboard V1 from dashboard.visual-contract.md
