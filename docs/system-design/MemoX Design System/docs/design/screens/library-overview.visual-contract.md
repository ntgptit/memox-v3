---
last_updated: 2026-06-06
applies_to: Library Overview `/library`
---

# Library Overview visual contract

This screen is the root Library browser for top-level folders only.

## Current visual blocks

- Large title app bar with `Library` on the left and a disabled filter affordance
  on the right.
- Always-visible inline search below the title.
- Due summary strip when `dueToday > 0`.
- Section header row with folder count on the left and the mock-style `Recent`
  sort pill on the right.
- Folder list rows with:
  - accent leading tile
  - title
  - optional subtitle sourced from the folder's direct children
  - counts row
  - optional `new` count
  - progress bar
  - due badge
  - kebab action button
- Extended `New folder` FAB in the lower-right.
- Bottom navigation stays fixed.

## Data mapping

| Mock block | Implementation source |
| --- | --- |
| Due summary title | `LibraryOverviewReadModel.dueToday` |
| Due summary subtitle | `dueToday` + count of due folders |
| Sort pill | Visual-only header pill (`Recent`) |
| Folder subtitle | Direct child names joined from the root aggregate |
| New count | `flashcard_progress.due_at IS NULL` aggregate |
| Progress bar | `flashcard_progress.box_number` aggregate |

## Notes

- This contract intentionally mirrors the HTML UI kit mock more closely than the
  older wireframe text.
- The sort sheet interaction remains Future; the header pill is current visual
  parity only.
