---
last_updated: 2026-06-01
source_specs:
  - docs/business/study/study-flow.md
  - docs/business/resume/resume-session.md
  - docs/business/account-sync/account-sync.md
  - docs/business/bulk/bulk-operations.md
  - docs/business/folder/folder-management.md
  - docs/business/deck/deck-management.md
  - docs/business/flashcard/flashcard-management.md
  - docs/business/history/card-history.md
---

# 24 — Shared Dialogs Catalog

## Purpose

Reusable dialog patterns referenced across screens. Each dialog is identified by anchor (`§name`) and used by multiple screens. Defining them here once prevents drift.

## V1 implementation status — Prompt 27, 2026-06-01

Current V1 shared primitives are `MxDialog`, `MxConfirmationDialog`, `MxNameDialog`, `MxDialogResumeOrStartOver`, and the folder-specific `showMxFolderCreateDialog` / `showMxFolderRenameDialog` pair.

Current V1 return contracts are intentionally mixed:
- `MxConfirmationDialog.show(...)` returns `Future<bool>` where `true` means confirmed and `false` means Cancel/system dismissal.
- `MxNameDialog.show(...)` returns `Future<String?>` where a trimmed name means confirmed and `null` means Cancel/system dismissal.
- `MxDialogResumeOrStartOver.show(...)` returns typed `Future<MxResumeChoice?>` for the current multi-branch resume choice.

Future/Target complex multi-branch dialogs should prefer typed result classes or sealed variants instead of ambiguous raw primitives.

Current composed usages include destructive confirmations for flashcard/folder/deck/tag deletion, tag merge, study-session cancel/discard, account sign-out/disconnect, manual Drive upload/restore confirmation, Prompt 41 destructive Drive restore warning copy, dirty-editor discard, and resume/start-over conflict handling. These reuse existing owner screens and use cases; there is no standalone dialog gallery.

Target/Partial catalog items remain documented below but are not Current unless named in the Current list above. Strong-confirm typed input for account removal is Target only. The full restore-warning two-tier flow, Upload local first branch, second destructive confirmation, and pre-restore snapshot flow remain Partial/Target per `docs/business/account-sync/account-sync.md` and `docs/wireframes/19-settings-account.md`. V1 has no onboarding dialog or wizard flow.

## Invocation inputs

Shared dialogs and bottom-sheets receive only prepared view data and callbacks from the caller screen/notifier.

They must not load persistent data by themselves.

## Data dependencies

The caller owns data loading and mutation orchestration.

Shared dialogs and bottom-sheets may receive:
- immutable display data
- selected ids or labels
- validation state prepared by the caller
- callbacks for confirm/cancel/selection actions

They must not call DAO, repository, or use case directly.

## Catalog index

| Anchor | Use case |
| --- | --- |
| §resume-or-start-over | Resumable session detected when starting new |
| §discard-session | Discard a paused study session |
| §discard-changes | Unsaved form changes |
| §exit-session | Mid-session exit confirmation |
| §delete-confirm | Generic destructive delete |
| §bulk-delete | Multi-card delete |
| §reset-progress | Reset SRS for one card or in bulk |
| §rename | Rename an entity (folder, deck, device label) |
| §folder-form | Create or rename a folder |
| §restore-warning | Drive restore with fingerprint mismatch |

## Dialog patterns

All dialogs share the same Material 3 structure: title, body, optional inline warning region, and a right-aligned action row. Name/confirm dialogs use a single horizontal action row with equal-width buttons. All shared dialogs are modal-locked; tapping outside or pressing back does not dismiss them. Most destructive actions use theme `error` color; the documented folder-delete strong variant uses the dedicated destructive fill token from the mock (`error-fill`) for its solid button. Primary safe action is on the right; cancel on the left.

---

## §resume-or-start-over

Used by: study entry gate (12), Dashboard resume card secondary tap.

```
┌───────────────────────────────────────┐
│  Resume your last session?            │
├───────────────────────────────────────┤
│                                       │
│  You started a study session for      │
│  Korean N5 2 hours ago and answered   │
│  12 / 24 cards. Resume where you left │
│  off or start over?                   │
│                                       │
├───────────────────────────────────────┤
│  [ Start over ]  [ Cancel ]  [Resume] │
└───────────────────────────────────────┘
```

- Primary: Resume (right, default-focused).
- Secondary: Start over → triggers §discard-session next.
- Cancel → pop back to caller.

---

## §discard-session

Used by: §resume-or-start-over (Start over path), Dashboard resume card Discard, deck/folder banner Discard.

```
┌───────────────────────────────────────┐
│  Discard this session?                │
├───────────────────────────────────────┤
│                                       │
│  Your progress for these 12 answered  │
│  cards will be kept (they updated     │
│  your SRS), but the remaining 12      │
│  cards in this session will be reset. │
│                                       │
├───────────────────────────────────────┤
│        [ Cancel ]  [ Discard ]        │
└───────────────────────────────────────┘
```

- Primary destructive: Discard (right, theme error color).
- Confirm sets `study_sessions.status = cancelled`. Already-recorded `study_attempts` are preserved.

---

## §discard-changes

Used by: flashcard create (07), flashcard edit (08), deck import (10) cancel, any form with unsaved changes.

```
┌───────────────────────────────────────┐
│  Discard changes?                     │
├───────────────────────────────────────┤
│                                       │
│  You have unsaved changes. Leave      │
│  without saving?                      │
│                                       │
├───────────────────────────────────────┤
│       [ Keep editing ]  [ Discard ]   │
└───────────────────────────────────────┘
```

- Primary safe (default-focused): Keep editing.
- Destructive: Discard (theme error color).

---

## §exit-session

Used by: study session screens (13-17), tap ✕.

```
┌───────────────────────────────────────┐
│  Exit study session?                  │
├───────────────────────────────────────┤
│                                       │
│  Your progress is saved and you can  │
│  resume later. Leave this session?    │
│                                       │
├───────────────────────────────────────┤
│       [ Keep studying ]  [ Exit ]     │
└───────────────────────────────────────┘
```

- On Exit: session stays `in_progress` and remains resumable.
- Exit always shows a confirmation dialog before leaving the screen.

---
## §delete-confirm

Used by: deck delete, folder delete, flashcard delete, tag delete, switch/remove account.

Generic shape:

```
┌───────────────────────────────────────┐
│  Delete {entity name}?                │
├───────────────────────────────────────┤
│                                       │
│  {entity-specific body copy}          │
│                                       │
│  This cannot be undone.               │
│                                       │
├───────────────────────────────────────┤
│        [ Cancel ]  [ Delete ]         │
└───────────────────────────────────────┘
```

### Variants

| Entity | Body copy |
| --- | --- |
| Folder | Strong folder-delete variant — "Delete this folder?" + "{name} and its {n} subfolders / {m} decks will be removed from your library." + reassurance note + typed confirmation input + solid destructive-fill confirm button. |
| Deck | "Deck {name} ({n} cards) will be deleted. All cards and their history will be deleted." |
| Flashcard | "This flashcard and its study history will be deleted." |
| Tag | "Tag #{name} will be removed from {n} cards. The cards themselves will be kept." |
| Switch/remove account | Strong variant — requires typed confirmation. |

### Strong variant (account removal)

**Target only.** This typed-confirm variant is not implemented in V1 and must not be exposed until account removal/switch-account scope is promoted with code, tests, and docs.

```
┌───────────────────────────────────────┐
│  ⚠ Remove account and erase data?     │
├───────────────────────────────────────┤
│                                       │
│  This will erase ALL data on this     │
│  device for giap@gmail.com.           │
│                                       │
│  Your Drive backup is NOT affected.   │
│                                       │
│  Type ERASE to confirm:               │
│  ┌─────────────────────────────────┐  │
│  │                                 │  │
│  └─────────────────────────────────┘  │
│                                       │
├───────────────────────────────────────┤
│  [ Cancel ]            [ Erase ]      │
└───────────────────────────────────────┘
```

Erase button disabled until the user types `ERASE` exactly.

---

## §bulk-delete

Used by: flashcard list (06) bulk delete.

```
┌───────────────────────────────────────┐
│  Delete {n} flashcards?               │
├───────────────────────────────────────┤
│                                       │
│  These cards and their study history  │
│  will be deleted. This cannot be      │
│  undone.                              │
│                                       │
├───────────────────────────────────────┤
│        [ Cancel ]  [ Delete {n} ]     │
└───────────────────────────────────────┘
```

Delete button shows count. Single transaction.

---

## §reset-progress

Used by: flashcard edit (08), flashcard history (09), bulk flashcard list (06).

Single variant:

```
┌───────────────────────────────────────┐
│  Reset progress for this card?        │
├───────────────────────────────────────┤
│                                       │
│  The card will return to box 1 and    │
│  be due immediately.                  │
│                                       │
│  Its study history is kept and        │
│  marked as "before reset" in the      │
│  card history timeline.               │
│                                       │
├───────────────────────────────────────┤
│        [ Cancel ]  [ Reset ]          │
└───────────────────────────────────────┘
```

Bulk variant:

```
┌───────────────────────────────────────┐
│  Reset progress for {n} cards?        │
├───────────────────────────────────────┤
│                                       │
│  All selected cards return to box 1   │
│  and are due immediately. Their       │
│  history is preserved.                │
│                                       │
├───────────────────────────────────────┤
│       [ Cancel ]  [ Reset {n} ]       │
└───────────────────────────────────────┘
```

On confirm: set `box = 1`, `due_at = now`, `last_reset_at = now` for each. Attempts unchanged.

---

## §rename

Used by: folder rename, deck rename, device label rename.

```
┌───────────────────────────────────────┐
│  Rename {entity}                      │
├───────────────────────────────────────┤
│                                       │
│  Name *                               │
│  ┌─────────────────────────────────┐  │
│  │ {current name}                  │  │  ← Pre-filled, full-selected
│  └─────────────────────────────────┘  │
│                                       │
├───────────────────────────────────────┤
│        [ Cancel ]  [ Rename ]         │
└───────────────────────────────────────┘
```

### Validation

| Rule | Message |
| --- | --- |
| Empty after trim | "{Entity} name is required." |
| Exceeds max length (per schema; current convention: folder/deck ≤ 100 chars, device label ≤ 50 chars; verify against `decks`/`folders` table constraints) | "Name too long (max {N})." |
| Duplicate name in same parent (folder/deck) | "A {entity} with this name already exists here." |

Rename button disabled until name is valid AND different from current.

---

## §folder-form

Used by: Library FAB, folder-detail FAB, Library rename action, folder-detail rename action.

`showMxFolderCreateDialog(...)` returns `Future<String?>` where the trimmed name means confirm and
`null` means cancel/dismiss. `showMxFolderRenameDialog(...)` uses the same return contract.
Unlike the generic `MxNameDialog`, this folder-specific dialog is mock-aligned and includes the
preview/choice affordances from the design kit.

### Create variant

```
┌───────────────────────────────────────┐
│  [icon] New folder                    │
│          Group related decks together.│
├───────────────────────────────────────┤
│  FOLDER NAME                          │
│  ┌─────────────────────────────────┐  │
│  │ Vietnamese                        │  │
│  └─────────────────────────────────┘  │
│                                       │
│  COLOR                                │
│  ○ ○ ○ ○ ○ ○                         │
│                                       │
│  ICON                                 │
│  [ ] [ ] [ ] [ ] [ ]                 │
├───────────────────────────────────────┤
│ [Cancel]              [Create folder] │
└───────────────────────────────────────┘
```

- Top preview tile reflects the selected color/icon and is visual preview only until the folder
  model stores those attributes.
- The name field is 44dp tall and uses the primary border treatment from the mock.
- The dialog shell uses the same outer inset / width treatment as the shared delete dialog so the
  form does not feel cramped on mobile.
- Footer buttons are 40dp high, keep the dialog-side 18dp inset, and use an equal-width pair
  grouped toward the trailing side; `Create folder` uses a leading folder-plus icon.
- The create and rename variants are modal-locked: tapping outside or pressing back does not
  dismiss them; only the `Cancel` action closes the dialog.

### Rename variant

```
┌───────────────────────────────────────┐
│  Rename folder                        │
│  Only the folder name changes — ...   │
├───────────────────────────────────────┤
│  NEW NAME                             │
│  ┌─────────────────────────────────┐  │
│  │ Korean                           │  │
│  └─────────────────────────────────┘  │
│  8 decks · 412 cards will keep ...    │
├───────────────────────────────────────┤
│ [Cancel]                     [Rename] │
└───────────────────────────────────────┘
```

- The initial name is pre-filled and fully selected so the user can overwrite it immediately.
- The helper line below the field is derived by the caller from the current folder summary.
- The dialog shell uses the same outer inset / width treatment as the shared delete dialog so the
  rename body stays comfortably wide.
- Footer buttons reuse the same 40dp/rounded shape treatment as create, with a visible
  `Cancel` action on the left and `Rename` on the right in an equal-width pair.
- The create and rename variants are modal-locked: tapping outside or pressing back does not
  dismiss them; only the `Cancel` action closes the dialog.

---

## §folder-create

Legacy label retained for older references only. The Current folder create
experience is documented in `§folder-form`, which includes the mock-aligned
name + color/icon picker dialog.

If you are updating code or docs for the current product surface, prefer
`§folder-form` and keep this section as a compatibility note only.

---

## §restore-warning

Used by: settings account (19) Restore button when fingerprint differs.

**Partial/Target only.** Current V1 Account Settings has manual Drive upload/restore confirmation and a busy progress dialog. Prompt 41 adds stronger destructive restore warning copy, cancel/confirm protection, duplicate-running guard, and visible success/failure feedback, but it does not implement this two-tier restore-warning, Upload local first branch, second destructive confirmation, or pre-restore snapshot path.

Two-tier confirmation: primary "Upload local first" CTA + secondary "Restore anyway" requires second tap.

```
┌───────────────────────────────────────┐
│  ⚠  Restore from a different device?  │
├───────────────────────────────────────┤
│                                       │
│  This backup was made on:             │
│    Pixel 8 Pro · 2025-12-01 · 12.4 MB │
│                                       │
│  Your local data (last edited today)  │
│  will be REPLACED. This cannot be     │
│  undone.                              │
│                                       │
│  We recommend uploading your local    │
│  data to Drive first.                 │
│                                       │
│  ┌──────────────────────────────┐    │
│  │ ⬆ Upload local first         │    │  ← Primary (safe)
│  └──────────────────────────────┘    │
│                                       │
│  [ Restore anyway ]                   │  ← Tap once: button shifts to
│  [ Cancel ]                           │     "Tap again to confirm restore"
└───────────────────────────────────────┘
```

After first "Restore anyway" tap:

```
│  [ Tap again to confirm restore ]     │  ← Theme error color
│  [ Cancel ]                           │
```

Only the second tap triggers the destructive flow. Auto-revert to original "Restore anyway" after 5s timeout if not tapped again.

Then the snapshot phase modal (see 19-settings-account.md) runs. If snapshot fails, restore aborts.

When fingerprints match, this dialog still appears but the warning is softer and the "Upload first" CTA is replaced with "Restore now" as primary:

```
┌───────────────────────────────────────┐
│  Restore from Drive?                  │
├───────────────────────────────────────┤
│  This backup matches your device      │
│  (made 2h ago). Restoring will        │
│  replace your current data.           │
│                                       │
│  ┌──────────────────────────────┐    │
│  │ ⬇ Restore now                │    │
│  └──────────────────────────────┘    │
│                                       │
│  [ Cancel ]                           │
└───────────────────────────────────────┘
```

---

## Accessibility (cross-cutting)

- Each dialog MUST have an accessible name announced when it opens (the title).
- Body text MUST be in the dialog's accessibility tree, read after the title.
- Action buttons MUST have unique labels (no two "OK" buttons; use action verbs: "Delete", "Discard", "Reset").
- Destructive actions MUST be announced with their destructiveness, e.g., "Delete folder, destructive action".
- Focus order: title → body → safe action (Cancel/Keep) → destructive action.
- Default focus: safe action when dialog opens (so screen-reader users don't accidentally fire destructive).
- System back gesture MUST trigger Cancel, not the destructive action.
- For strong-variant destructive (typed confirmation): the input field MUST be focused after title is announced, with hint "Type ERASE to confirm".
- For §restore-warning two-tier confirmation, when that Target flow is implemented: the "Tap again to confirm" state MUST be announced via live region when it appears.

## Forbidden (catalog-level)

- ❌ Introduce a new dialog pattern without adding it to this catalog first.
- ❌ Promote §restore-warning to Current without the two-tier confirmation and 5s timeout.
- ❌ Use generic "Are you sure?" copy. Each dialog states the specific consequence.
- ❌ Apply strong-variant destructive (typed confirmation) outside account removal or the documented folder-delete exception without a spec update.
- ❌ Hardcode dialog copy in widget. All strings from ARB (`error_*`, `dialog_*`).
- ❌ Show dialog from build method. Always from callback.
- ❌ Change Current V1 return contracts for catalog purity: `MxConfirmationDialog` returns `bool`, `MxNameDialog` returns `String?`, and `MxDialogResumeOrStartOver` returns typed `MxResumeChoice?`. For new complex dialogs, avoid ambiguous raw primitives when a typed result class or sealed variant is needed.

## Cross-cutting rules

- Default focus: safe action (Cancel or primary safe).
- Destructive actions: theme error color, right-aligned, secondary visual weight unless the dialog is explicitly destructive-first (e.g., §bulk-delete). The documented folder-delete strong variant uses the dedicated destructive fill token from the mock for its filled CTA.
- All dialogs respect system back button (= Cancel).
- All dialogs are dismissible by tapping outside ONLY for non-destructive ones; destructive dialogs require explicit Cancel.
- Counts in titles MUST be live (recomputed on open) not stale.

## Agent rule

- Do NOT introduce new dialog patterns without adding them to this catalog first.
- Do NOT promote §restore-warning to Current without the two-tier confirmation and 5s timeout.
- Do NOT use generic "Are you sure?" copy. Each dialog states the specific consequence.
- Strong-variant destructive (typed confirmation) is reserved for account removal, except for the documented folder-delete mock variant. Don't apply it elsewhere without spec update.
- Keep Current V1 shared dialog return contracts as documented above. For new complex multi-branch dialogs, prefer typed result classes or sealed variants when a primitive would be ambiguous.

## Implementation refs

**Business specs (per dialog):**
- §resume-or-start-over → `docs/business/resume/resume-session.md`
- §discard-session → `docs/business/resume/resume-session.md`
- §discard-changes → `docs/business/flashcard/flashcard-management.md` (and any form)
- §exit-session → `docs/business/study/study-flow.md`
- §delete-confirm → varies by entity (folder/deck/flashcard/tag/account)
- §bulk-delete → `docs/business/bulk/bulk-operations.md`
- §reset-progress → `docs/business/history/card-history.md`
- §rename → folder/deck/`docs/business/account-sync/account-sync.md` (device label)
- §folder-form → `docs/business/folder/folder-management.md`
- §restore-warning → `docs/business/account-sync/account-sync.md`

**Decision rows:**
- Dialog interaction rules (default focus, system-back semantics, 5s timeout for restore secondary confirm)

**Contracts:** Dialogs invoke use cases listed per spec above; primary refs: `docs/contracts/usecase-contracts/study.md` (resume/discard/finalize), `docs/contracts/usecase-contracts/folder.md`/`docs/contracts/usecase-contracts/deck.md`/`docs/contracts/usecase-contracts/flashcard.md` (delete + rename), `docs/contracts/usecase-contracts/bulk.md` (bulk-delete), `docs/contracts/usecase-contracts/history.md` (reset progress), `docs/contracts/usecase-contracts/account-sync.md` (restore-warning). UI behavior shaped by `docs/contracts/error-contract.md` recovery rules.

**Code paths (verified 2026-06-10):**
- Shared dialogs live under `lib/presentation/shared/dialogs/**` (each as its own widget file).
- Implemented so far: `mx_confirm_dialog.dart` (`MxConfirmDialog`), `mx_folder_delete_dialog.dart`,
  `mx_folder_form_dialog.dart` (+ parts), `mx_name_dialog.dart`, `mx_bottom_sheet.dart`.
- The resume/start-over choice is NOT a shared dialog: the Study Entry gate renders inline
  Resume / Start over / Back actions (`study_entry_screen.dart` `_resumeBody`, WP-SR1a); the
  start-over confirmation will compose the shared confirm dialog (WP-SR1b — not yet wired; WP-SR1a
  starts over without a confirm).
- The naming set `MxDialogResumeOrStartOver`, `MxDialogDiscardSession`, `MxDialogExitSession`,
  `MxDialogBulkDelete`, `MxDialogResetProgress`, `MxDialogRestoreWarning` and the
  `confirmAndDiscardResumeSession` flow are **target names from a previous iteration** — none of
  those files exist; create them only when their owning features are built.
- Return contracts: confirmation dialogs use `bool`, name dialogs use `String?`.

**Related wireframes:**
- Used by virtually every screen; see "Used by:" list in each dialog section
