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

## Spacing notes

- The section header sits on a very tight local inset inside the shared screen
  shell so it reads as `18dp` from the mock edge, not a doubled outer padding.
- Folder cards use `14dp` internal padding on all sides and `14dp` between the
  leading tile, the text block, and the trailing action button.
- Inside the text block, the subtitle → counts row and counts row → progress bar
  rhythm is `8dp`.
- The folder list uses a `10dp` vertical rhythm between rows and a `12dp`
  gap between the due summary strip and the section header.

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
