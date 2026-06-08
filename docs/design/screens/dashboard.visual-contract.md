---
last_updated: 2026-06-09
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

## Current V1 Scope

- Resume card is a current V1 surface.
- Today CTA is a current V1 surface.
- Start new learning CTA is a current V1 surface and must lead into the study scope picker flow.
- Recent decks are a current V1 surface, but the later implementation still needs a dashboard-specific query hook.
- A static streak placeholder may appear as a visual/stat placeholder only. It is not computed.
- Loading, error, offline, onboarding, resume-only, and multi-resume states are all part of the mock contract.
- App launch still defaults to Library; `/home` is not the boot route yet.
- Dashboard search is not a current V1 action.

## Explicitly Excluded

- Computed streak logic.
- Daily goal persistence, goal ring, and goal-history UI.
- Reminder and notification permission surfaces.
- Dashboard global search action.
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
| Search icon | loaded, offline, error | Future/Target | `MxIconButton` hidden or disabled in V1 | None yet | None in V1 | Global search stays on Library; do not wire a Dashboard search action. |
| Settings icon | loaded, offline, error | Current V1 | `MxIconButton` | Route shell | `go` to `RoutePaths.settings` | Shell-visible settings shortcut is allowed. |
| Offline banner | offline | Visual-only | `MxOfflineBanner` | Connectivity state if a shared app-level signal exists later | None | Shared feedback pattern only; Dashboard docs do not define a blocking offline mode. |
| Error card + retry | error | Current V1 | `MxErrorState` or `MxCard` + `MxActionButton` | Dashboard query failure | Retry | Keep the error localized. The mock’s `Open Library` secondary action is excluded because the business docs only require retry. |
| Resume card shell | loaded, resumeOnly, multiResume | Current V1 | `MxCard` + `MxCardActions` + `MxText` | Resumable-session lookup | Continue, Discard | Top placement is required when a resumable session exists. |
| Resume progress block | loaded, resumeOnly | Current V1 | `MxText` + `MxLinearProgress` / `MxStatDisplay` | Session header + items | None | Show scope name, answered count, and relative last-active time. |
| More paused sessions chip | multiResume | Missing data | `MxActionButton` or `MxTextButton` | No list-active-sessions hook yet | Open paused-sessions sheet | The chip is visible in the mock, but the query owner for the list does not exist yet. |
| Static streak placeholder | loaded, goalOff | Current V1 | `MxStatDisplay` or `MxCard` | None; static placeholder only | None | Render as a non-computed placeholder only. Do not show a live streak count. |
| Goal ring / daily-goal card | loaded, goalOff | Future/Target | `MxMasteryRing` / `MxCard` | Engagement prefs + study_attempts aggregate | None | Excluded from current V1 until engagement is promoted. |
| Streak-broken banner | streakBroken | Future/Target | `MxCallout` or `MxCard` | Computed broken-streak signal | Dismiss | Requires computed streak state, so it remains out of current V1. |
| Today CTA / caught-up card | loaded, resumeOnly | Current V1 | `MxCard` + `MxActionButton` | Today due-count provider | `go` to `RoutePaths.studyToday` | The caught-up variant replaces the primary due card when no cards are due. |
| Start new learning CTA | loaded, onboarding, resumeOnly | Current V1 | `MxActionButton` / `MxCardActions` | Study scope picker entry | Open scope picker, then route into study entry | Keep deck, folder, and today scopes only; tag scope remains excluded. |
| Recent decks section header | loaded, resumeOnly | Current V1 | `MxSectionHeader` | None | None | The section title is part of the screen chrome. |
| Recent decks header shortcut | loaded, resumeOnly | Visual-only | `MxTextButton` or `MxIconButton` | None | Optional library navigation | Bottom nav already covers `/library`; this shortcut is not a product requirement. |
| Recent deck rows | loaded, resumeOnly | Missing data | `MxCard` + `MxTappable` + `MxIconTile` | Deck list ordered by `updated_at DESC` | Open deck flashcard list | There is no Dashboard-specific recent-decks query yet. |
| Loading skeletons | loading | Current V1 | `MxRetainedAsyncState` + `MxSkeleton` | Async dashboard providers | None | Keep skeletons per section instead of a full-screen spinner. |
| Onboarding hero card | onboarding | Current V1 | `MxEmptyState` or `MxCard` + `MxActionButton` | Zero decks + zero flashcards | Create first deck, Import deck | The mock’s calm hero and action pair are in scope; legacy sign-in/restore wording is not. |
| Onboarding reassurance cards | onboarding | Visual-only | `MxCard` + `MxIconTile` + `MxText` | None | None | Calm copy only; no business behavior is attached to these cards. |
| Bottom navigation | all | Current V1 | `MxBottomNavigationBar` | Shell route state | Home, Library, Progress, Settings | Home is shell-visible, but the app still boots into Library. |

## State Mapping

| Mock state | Current V1 behavior | Implement now? | Notes |
| ---------- | ------------------- | -------------- | ----- |
| loaded | Resume card first, then static streak placeholder, Today CTA, Start new learning, recent decks, bottom nav | Yes | Keep the overall density compact and card-driven. |
| loading | Section-level skeletons for resume, summary, CTA, and recents | Yes | Do not block the whole screen on one slow provider. |
| onboarding | Zero-content body with create/import actions and calm guidance cards | Yes | Exclude the legacy Google sign-in/restore copy from V1. |
| goal off | Hide live goal/streak surfaces; treat as future engagement state | No | Goal persistence and streak computation are not current V1 features. |
| resume only | Resume card remains visible; Today CTA becomes caught-up | Yes | This is the main no-due / resumable-session combination. |
| streak broken | One-time broken-streak banner above the resume card | No | Requires computed streak history, which is still future/target. |
| error | Inline Dashboard error state with retry | Yes | Keep the message localized and do not surface raw failures. |
| offline | Non-blocking offline banner | No | Visual reference only until the Dashboard has a defined connectivity contract. |
| multi resume | Resume card plus paused-sessions chip entry | No | Missing the list-active-sessions hook and sheet data source. |

## Layout Hierarchy

1. App bar with greeting on the left and shell actions on the right.
2. Inline feedback surfaces, in this order when present: offline banner, error card, streak-broken banner.
3. Resume card at the top of the body when a resumable session exists.
4. Streak placeholder and goal area only when the current V1 placeholder is shown or when future engagement is promoted.
5. Today CTA or caught-up card.
6. Start new learning CTA.
7. Recent decks section.
8. Bottom navigation.

For onboarding, replace steps 3 through 7 with the zero-content hero and guidance cards.

## Shared Component Mapping

| UI need | Shared component | Notes |
| --- | --- | --- |
| Screen shell | `MxScaffold` | Use the design-system shell, not a raw `Scaffold`. |
| App bar | `MxAppBar` | Keep the header compact and localizable. |
| Card surfaces | `MxCard` | Use tokenized surfaces and ghost borders. |
| Resume / today / new-learning actions | `MxCardActions` + `MxActionButton` | Keep the primary action visually dominant and the secondary lighter. |
| Empty state | `MxEmptyState` | Use for onboarding and empty caught-up states. |
| Error state | `MxErrorState` | Use for query failure. |
| Offline state | `MxOfflineBanner` | Non-blocking shared feedback. |
| Loading | `MxRetainedAsyncState` + `MxSkeleton` | Keep skeletons per section. |
| Section header | `MxSectionHeader` | Use for the Recent decks title. |
| Icon tile | `MxIconTile` | Use for resume, deck, and onboarding cards. |
| Text roles | `MxText` | Do not hand-roll typography roles in feature widgets. |
| Bottom navigation | `MxBottomNavigationBar` | Home, Library, Progress, Settings remain shell routes. |
| Confirm discard | `showMxConfirmDialog` | Use for discard-session confirmation in the later coding task. |
| Bottom sheet entry | `showMxBottomSheet` | Use for paused sessions and scope picker flows. |

## Route And Action Mapping

| Mock action | Route / action contract | Notes |
| --- | --- | --- |
| Resume card Continue | `RoutePaths.studySession(sessionId)` / `RouteNames.studySession` via `push` | Resume opens the persisted session directly. |
| Resume card Discard | `showMxConfirmDialog` then `CancelStudySessionUseCase` in the later coding task | Discard is destructive and must confirm. |
| More paused sessions | `showMxBottomSheet` | Opens the paused-sessions list when the list query exists. |
| Today CTA | `RoutePaths.studyToday` / `RouteNames.studyToday` via `push` | The study entry gate then `pushReplacement`s into the session route. |
| Start new learning | Scope picker bottom sheet, then `RoutePaths.studyEntryTemplate` / `RouteNames.studyEntry` | Deck, folder, and today are the supported V1 scopes. |
| Settings icon | `RoutePaths.settings` / `RouteNames.settings` via `go` | Shell-visible and current V1. |
| Search icon | Future `/library/search` action | Keep excluded from Dashboard V1. |
| Recent deck row | `RoutePaths.flashcardList(deckId)` / `RouteNames.flashcardList` via `push` | Open the deck-specific flashcard list. |
| Bottom-nav Home | `RoutePaths.home` / `RouteNames.home` via `go` | The route exists, but it is still a placeholder. |
| Bottom-nav Library / Progress / Settings | `go` to the matching shell route | Shell navigation resets tab stack. |

## Copy Expectations

- Use the existing `dashboard*` ARB namespace in `lib/l10n/app_en.arb` and `lib/l10n/app_vi.arb`.
- Do not hardcode the mock’s sample name/date strings.
- Use `dashboardResumeSectionTitle`, `dashboardContinueSessionAction`, `dashboardDiscardAction`, `dashboardMorePausedSessions`, and `dashboardPausedSessionsSheetTitle` for resume copy.
- Use `dashboardStartNewLearningAction`, `dashboardScopePickerTitle`, `dashboardScopeToday`, `dashboardScopeDeck`, `dashboardScopeFolder`, and their subtitle keys for the scope picker.
- Use the existing `dashboardRecentDecksTitle`, `dashboardDeckDueSummary`, and `dashboardDeckCaughtUpSummary` keys for recent deck rows.
- Use `sharedOfflineTitle`, `sharedOfflineMessage`, and `commonRetry` for offline/error feedback.
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
- Use `MxOfflineBanner` and error surfaces for semantic warning/error feedback; do not copy raw HTML colors into feature widgets.
- The mock’s gradient-heavy resume/today cards are visual inspiration only. Production should use tokenized tonal surfaces and border accents instead of raw CSS gradients.
- `sharedOfflineTitle` / `sharedOfflineMessage` use warning semantics in both themes.

## Open Questions

- None blocking. The remaining gaps are implementation-only: recent decks need a Dashboard query owner, and multi-resume needs the paused-sessions list hook.

## Next implementation task

Implement Home Dashboard V1 from dashboard.visual-contract.md
