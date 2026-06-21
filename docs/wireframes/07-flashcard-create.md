---
last_updated: 2026-06-06
route: /library/deck/:deckId/flashcards/new
source_specs:
  - docs/business/flashcard/flashcard-management.md
  - docs/contracts/usecase-contracts/flashcard.md
---

# 07 - Flashcard Create

> **Shared implementation note (V1 shell, WP-FL2a 2026-06-22).** This route is implemented by the
> shared Flashcard Editor surface at
> `lib/presentation/features/decks/screens/flashcard_editor_screen.dart` (async dispatcher) +
> `lib/presentation/features/decks/widgets/flashcard_editor_body.dart` (`FlashcardEditorForm`).
> Create mode is selected by the absence of `:flashcardId`; the **shell** supports front/back +
> the dirty-discard confirm. The Details expander (example/pronunciation/hint/tags) + the non-base
> `07` states (details-open/saving/save-failed) are **WP-FL2b**. Edit mode is documented
> separately in `docs/wireframes/08-flashcard-edit.md`.

> **Mock-first refinement (2026-06-13).** Create mode keeps the collapsible
> "Add details" toggle (optional example/hint/pronunciation). **Saving:** both the
> app-bar and bottom CTAs read `Saving…` (disabled) and the bottom helper switches
> to `Saving to this device…`. **Save failed:** a text-only failure banner
> (`flashcard_editor_save_failed_banner`) is anchored just above the bottom bar and
> the bottom primary CTA becomes `Retry save` (re-invokes the create use case);
> typed input is preserved. The mock's mic / pronunciation-speaker glyphs are
> decorative (no capture/TTS behavior wired) and the deck-selector dropdown does
> not change the owning deck in V1 — both are visual-only, not faked behavior.

## Purpose

Create a single flashcard in the current deck. The current V1 flow is tuned for
fast manual entry and keeps the surface intentionally small.

## Layout

```
┌────────────────────────────────────────────────┐
│ ✕   New flashcard                    [Save]    │
├────────────────────────────────────────────────┤
│ Library > Korean > N5 > New card               │
│ [N5]  Required                                 │
├────────────────────────────────────────────────┤
│ Front   Required                        0 / 60   │
│ ┌────────────────────────────────────────────┐  │
│ │ The term you want to remember             │  │
│ └────────────────────────────────────────────┘  │
│                                                │
│ Back    Required                       0 / 240   │
│ ┌────────────────────────────────────────────┐  │
│ │ Add the meaning or translation.           │  │
│ └────────────────────────────────────────────┘  │
│                                                │
│ Add details   example · hint · pronunciation    │
│                                                │
│ (collapsed by default; expands to three fields) │
│ Example                                         │
│ ┌────────────────────────────────────────────┐   │
│ │ Add an example sentence.                  │   │
│ └────────────────────────────────────────────┘   │
│ Pronunciation                                   │
│ ┌────────────────────────────────────────────┐   │
│ │ Enter pronunciation guidance.             │   │
│ └────────────────────────────────────────────┘   │
│ Hint                                            │
│ ┌────────────────────────────────────────────┐   │
│ │ Add a mnemonic or reminder.               │   │
│ └────────────────────────────────────────────┘   │
│                                                │
│ TAGS · optional                                 │
│ [TOPIK II ×] [noun ×] [people ×] [+ Add tag]    │
│ ☐ Save and add another                          │
│                                                │
└────────────────────────────────────────────────┘
┌────────────────────────────────────────────────┐
│ Cancel                              Save card  │
│ Front and back are required to save.          │
└────────────────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `deckId` (required path param) | URL | destination deck |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Deck detail (name + breadcrumb) | `decks` lookup + folder breadcrumb | once on screen open |
| Snackbar copy | localization | local |
| Discard dialog copy | localization | local |

## Shared Flashcard Editor contract (V1)

| Aspect | Create route | Edit route |
| --- | --- | --- |
| Runtime widget | `FlashcardEditorScreen(deckId: ...)` | `FlashcardEditorScreen(deckId: ..., flashcardId: ...)` |
| Route input | `deckId` required | `deckId` + `flashcardId` required |
| Initial content | Blank front/back/example/pronunciation/hint/tags | Loaded from the existing card |
| Destination deck | Fixed to the selected deck for the create flow | Read-only; moving a saved card belongs to flashcard list row/bulk actions |
| Save action | Creates one card in the selected deck | Updates the same card |
| Save and add another | Checkbox under Tags; when checked, saving clears the draft and keeps the editor open on the same deck | Hidden |
| Starting status | Hidden | Hidden |
| Delete/history/suspend/bury actions | Not shown | Not shown in the editor in V1 |

## Forbidden

- Auto-correct or normalize user typing in front/back.
- Submit form when Save button is disabled.
- Reset form on save failure. Keep dirty state visible.
- Expose tag management or study-by-tag actions from this route.

## Components

| Component | Spec |
| --- | --- |
| App bar | Close button with unsaved-changes warning, title, and primary Save action. |
| Breadcrumb | Library root → folder chain → deck → New card. |
| Deck context chip | Shows the selected destination deck. |
| Front / Back fields | Multi-line; required validation on save. |
| More details expander | Collapsed by default. Keeps the summary row visible and expands inline example, pronunciation, and hint inputs. |
| Tags row | Shows current chips plus the "+ Add tag" chip. |
| Save failure banner | Shows localized error feedback with retry affordance. |
| Bottom helper copy | Explains save requirements under the action bar. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Empty | Just opened | Front/back blank. Save disabled until both required fields are filled after trim. |
| Editing | User typing | Save becomes enabled when front and back are non-empty after trim. |
| Details collapsed | Default | More details row shows the example / hint / pronunciation summary. |
| Details expanded | Tap More details | Summary row stays visible with an expanded chevron and the example, pronunciation, and hint inputs are shown inline. |
| Tags idle | Default | Tag chips row shows any current chips plus the Add tag chip. |
| Tags add | Tap Add tag | The tag input dialog accepts one tag and appends it if valid. |
| Save and add another off | Default | Checkbox under Tags is unchecked; Save behaves normally. |
| Save and add another on | Checkbox checked | Save clears the draft and keeps the editor open for batch entry. |
| Saving | Save tapped | Save button shows spinner; form stays visible and the buttons disable. |
| Saved | Success | Return to the deck's flashcard list with a success snackbar. |
| Save error | Repository failure | Error banner appears; form contents remain. |
| Dirty close confirm | Close/back with unsaved changes | Show discard confirmation dialog. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap close | Tap | If the draft is dirty, show the discard dialog; otherwise pop immediately. |
| Browser/system back | Back gesture / browser back | Same discard-confirm behavior as close when the draft is dirty. |
| Tap Save | Tap | Validate required fields, save, then pop back to the deck list. |
| Toggle save and add another | Tap checkbox | Turn batch-entry mode on or off for the current create session. |
| Tap More details | Tap | Toggle the inline optional detail inputs while keeping the summary row visible. |
| Tap Add tag | Tap | Open the tag input dialog and append a valid tag chip. |
| Tap tag chip | Tap chip | Remove the tag chip from the draft. |
| Retry after save error | Tap retry | Re-run the save using the current draft. |

## Dialogs used

- Discard changes dialog - `docs/wireframes/24-shared-dialogs.md` §discard-changes.

## Validation rules

| Rule | Inline message |
| --- | --- |
| Front empty after trim | "Front is required." |
| Back empty after trim | "Back is required." |
| Front or back blank | Save stays disabled until both required fields are present. |

## Navigation in

- FAB action sheet from flashcard list → "New flashcard".
- Empty state CTA in flashcard list.

## Navigation out

- Close or back without changes → return to the deck's flashcard list.
- Close or back with unsaved changes → discard confirmation first.
- Save → return to the deck's flashcard list.

## Responsive

- Body scrolls on small screens.
- Front/back/optional details/tags stack vertically on every breakpoint in V1.

## Accessibility

- Required fields are announced with "Required" in the label.
- Save button announces as disabled while the required fields are empty.
- Validation errors are attached to the field that caused them.

## Rules

- Save MUST be disabled until required fields are valid.
- Dirty form MUST require confirmation on close/back.
- Save failure MUST keep the draft visible so the user can retry.

## Agent rule

- Do not auto-uppercase or auto-correct front/back.
- Default focus on screen open MUST be the Front field.

## Related

**Business specs:**

- `docs/business/flashcard/flashcard-management.md`
- `docs/business/navigation/navigation-flow.md`

**Contracts:**

- `docs/contracts/usecase-contracts/flashcard.md` §CreateFlashcardUseCase
- `docs/contracts/repository-contracts/flashcard-repository.md`

**Code paths:**

- `lib/presentation/features/decks/screens/flashcard_editor_screen.dart`
- `lib/presentation/features/decks/widgets/flashcard_editor_body.dart` (`FlashcardEditorForm`)
- `test/presentation/features/decks/flashcard_editor_test.dart`
