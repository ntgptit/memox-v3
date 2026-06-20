---
last_updated: 2026-06-20
applies_to: folder entity and folder management feature
---

# Folder Management

## Source files to inspect

- `lib/presentation/features/folders/**`
- `lib/domain/**folder**`
- `lib/data/**folder**`
- `lib/data/datasources/local/drift/` (folders table + folder queries)

## Data

Folders are stored in `folders`.

Important fields:

- `id`
- `parent_id`
- `name`
- `content_mode`
- `color` (optional) — presentation token chosen via the folder create/edit color picker. `null`
  means no custom color, so the UI falls back to the theme default. Opaque design-system token
  string; not validated by the backend (the allowed palette is an FE concern). WBS 2.22.1.
- `icon` (optional) — presentation token chosen via the folder create/edit icon picker. Same
  null/default and storage semantics as `color`. WBS 2.22.1.
- `sort_order`
- `created_at`
- `updated_at`

## Content mode

See `docs/business/glossary.md` for definitions.

| Mode         | Meaning              | Allowed children  |
|--------------|----------------------|-------------------|
| `unlocked`   | Empty or not locked  | Subfolder or deck |
| `subfolders` | Locked to subfolders | Only subfolders   |
| `decks`      | Locked to decks      | Only decks        |

## Content mode transitions

```mermaid
stateDiagram-v2
    [*] --> unlocked: create
    unlocked --> subfolders: create subfolder
    unlocked --> decks: create deck
    subfolders --> subfolders: add subfolder
    decks --> decks: add deck
    subfolders --> unlocked: delete last subfolder
    decks --> unlocked: delete last deck
```

## Rules

- Folder can contain either subfolders or decks, not both.
- Root folder has `parent_id = null`.
- Child folder must have valid parent.
- Folder name is required after trim.
- Folder name max length follows schema constraint (inspect table).
- Creating subfolder locks parent to `subfolders`.
- Creating deck locks parent to `decks`.
- Folder with `subfolders` cannot create deck.
- Folder with `decks` cannot create subfolder.
- Lock-mode rejection is typed: deck-locked parents use `folder_contains_decks`, subfolder-locked
  parents use `folder_contains_subfolders`. Folder Detail maps these to localized snackbar copy and
  must not show the generic unexpected-error message for this case.
- Moving folder must not create cycle.
- Moving a folder recomputes its `sort_order` (appended in the destination), locks an `unlocked`
  destination to `subfolders`, and reverts the emptied old parent to `unlocked`. Moving into a
  `decks`-locked destination is rejected (typed `folder_contains_decks`); a name that duplicates a
  destination sibling is rejected; moving into the current parent is a no-op.
- The move picker lists every folder (plus Library root) and **disables**, never hides, the folder
  itself, its descendants (cycle) and `decks`-locked folders.
- Reorder accepts the **full** sibling list only; a list with duplicate/missing/extra/cross-parent
  ids is rejected and the previous order is preserved.
- Deleting last child returns folder to `unlocked`.
- Deleting folder deletes nested content according to persistence rules.
- **Delete confirmation must state the blast radius (Specified, WBS 2.21.x):** the confirm dialog
  must show concrete counts ("This deletes {d} decks, {c} cards and all study progress") computed
  from the subtree, not a generic message. When the subtree card count exceeds a threshold (e.g.,
  100), require a stronger confirmation (type folder name or double-confirm). Rationale: MemoX is
  local-first with no working backup/export yet — a one-tap cascade delete is the single biggest
  data-loss risk in the app, and study progress is unrecoverable.
- **Content-mode lock — UX validation flag (2026-06-10):** the subfolders-XOR-decks lock is a
  MemoX-specific constraint that peer apps do not have and users may experience as a "why can't
  I?" error. Keep the rule for now, but treat first-user feedback on the lock-mode snackbar as a
  trigger to revisit (options: allow mixed content, or improve the affordance so the locked
  option is visibly disabled with an inline explanation instead of a rejection snackbar).

## Screen behavior

Folder list/detail should support:

- Loading state (`MxLoadingState`).
- Empty state (`MxEmptyState`).
- Error state (`MxErrorState`).
- Search/sort when supported.
- Manual reorder only when current sort mode allows it.
- Create subfolder/deck actions according to content mode.
- Safe delete confirmation.
- Folder detail and Library overview count cards from the database source of
  truth: `cardCount` includes suspended and buried cards, while `dueCount`
  excludes suspended and currently-buried cards and still counts expired
  buried cards.

## Performance

- Folder list >50 items: use `ListView.builder`.
- Search input: debounce 300ms.
- Subfolder count badge: stream from database, not computed in widget.

## Agent rule

Do not enforce folder content mode only in UI. The rule must be protected by use case/domain/data
flow.

## Related

**Wireframes:**

- `docs/wireframes/02-library.md` — Library root showing top-level folders
- `docs/wireframes/05-folder-detail.md` — folder detail (subfolders / decks / unlocked modes)
- `docs/wireframes/24-shared-dialogs.md` §folder-create, §rename, §delete-confirm
- `docs/wireframes/25-shared-bottom-sheets.md` §folder-picker, §item-context

**Schema:**

- `docs/database/schema-contract.md` → `folders` table (`id`, `parent_id`, `name`, `content_mode`,
  `color?`, `icon?`, `sort_order`, timestamps)

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Folder management" (folder mode
  lock, move cycle prevention, delete cascade)

**Glossary terms:**

- `docs/business/glossary.md` → `content_mode`, `unlocked`, `subfolders`, `decks` modes; folder
  hierarchy

**Related business specs:**

- `docs/business/deck/deck-management.md` — decks live inside folders, share parent rules
- `docs/business/navigation/navigation-flow.md` — `/library/folder/:id` route contract
- `docs/business/bulk/bulk-operations.md` — folder is one of the bulk-move destinations

**Source files to inspect:**

- `lib/data/datasources/local/drift/` (folders table + folder queries)
- `lib/domain/entities/folder.dart`
- `lib/domain/repositories/folder_repository.dart`
- `lib/domain/usecases/folder/**`
- `lib/presentation/features/folders/**` (folder views)
