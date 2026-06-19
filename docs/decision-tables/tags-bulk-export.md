---
last_updated: 2026-06-19
source: split from memox-core-decision-table.md
applies_to: Tags, Bulk operations, and Export behavior branches
---

# MemoX Decision Table — Tags + Bulk Operations + Export

## Convention
- `ID` is stable. Tests reference it by ID (e.g. `// decision: TG1`).
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` column: `TBD` until the implementing agent writes the test.
  Tests must be derived from the Expected column, NOT from code.

## Tags

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| TG1 | Tag input | Leading `#` typed | Strip before store | C1 | TBD |
| TG2 | Tag dedup | Same tag different case | Keep one (case-insensitive) | C0+C1 | TBD |
| TG3 | Tag filter | Multi-select chips | Apply AND filter | C0+C1 | TBD |
| TG4 | Study by tag | `entry_type=tag` | Resolve cards across decks | C0+C1 | TBD |
| TG5 | Tag rename | Collides with existing tag | Return conflict on direct rename; use explicit merge action for intentional combination | C1 | TBD |
| TG6 | Tag merge | Source has cards target also has | Dedup tag rows on merge | C1 | TBD |
| TG7 | Tag delete | Confirmation | Remove from all cards in transaction | C0+C1 | TBD |
| TG8 | Bulk add tag | 1000 cards | Single transaction, dedup per card | C1 | TBD |
| TG9 | Tag input | Contains comma `,` | Reject with inline error; do not strip silently | C0+C1 | TBD |
| TG10 | Tag input | Exceeds 50 chars after trim | Reject with inline error | C1 | TBD |
| TG11 | Study-by-tag entry_ref_id | Constructed from selected tags | Lowercased, comma-joined, sorted alphabetically | C0+C1 | TBD |

## Bulk Operations

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| BK1 | Long-press card | Normal mode | Enter selection mode | C0 | TBD |
| BK2 | Bulk delete | Confirm, selected snapshot, some missing IDs | Atomic delete in one transaction; missing rows are skipped and reported; tags/progress cascade as in single delete | C0+C1 | TBD |
| BK3 | Bulk move | Target deck valid | Cards moved; SRS + tags preserved | C0+C1 | TBD |
| BK4 | Bulk move | Target folder mode = subfolders | Reject | C1 | TBD |
| BK5 | Bulk suspend | Toast appears | Undo within 5s reverts | C1 | TBD |
| BK6 | Bulk reset progress | Confirm | Reset progress but retain attempts | C0+C1 | TBD |
| BK7 | Filter then select-all | Filter = "Suspended" | Selects only filtered cards (snapshot IDs) | C1 | TBD |
| BK8 | Bulk with >999 rows | SQLite param limit | Chunk IN clauses, still atomic | C1 | TBD |

## Export

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| EX1 | Pick format | User dismisses sheet | No-op, no error | C1 | TBD |
| EX2 | Export deck | Format=csv | CSV text with `front,back` only + `.csv` filename = sanitized deck name | C0+C1 | TBD |
| EX3 | Export deck | Format=excel | XLSX bytes + `.xlsx` filename = sanitized deck name | C0+C1 | TBD |
| EX4 | Export selection | Non-empty IDs | Bytes + filename `flashcards_export.{csv\|xlsx}` | C0+C1 | TBD |
| EX5 | Export | Always | Columns are `front,back` only (header row first) | C0+C1 | TBD |
| EX6 | Export delivery | Build success | Hand off via `shareFlashcardExport` → platform share sheet | C0 | TBD |
| EX7 | Export filename | Deck has unsafe chars | Filename sanitized via `sanitizeFileName` | C1 | TBD |
