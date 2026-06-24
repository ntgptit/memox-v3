---
last_updated: 2026-06-19
applies_to: index of all MemoX decision tables
---

# MemoX Decision Tables — Index

Behavior branches are split into per-feature files. Read only the file(s) your task touches.

## Files

| File | Feature | Row IDs |
|------|---------|---------|
| `docs/decision-tables/folder.md` | Folder CRUD, reorder, content-mode guard | F1–F13 |
| `docs/decision-tables/deck.md` | Deck CRUD, reorder, move | D1–D10 |
| `docs/decision-tables/flashcard.md` | Flashcard CRUD + Import | C1–C46, I1–I8 |
| `docs/decision-tables/study-srs.md` | Study modes, SRS, Bury/Suspend, Resume, Result | S1–S79, BS1–BS16, R1–R18, RES1–RES8 |
| `docs/decision-tables/tags-bulk-export.md` | Tags, Bulk ops, Export | TG1–TG11, BK1–BK8, EX1–EX7 |
| `docs/decision-tables/search.md` | Global + scope-local search | SR1–SR10, SR-rank, SR-cap, SR-empty, SR-err |
| `docs/decision-tables/progress-history.md` | Progress, Stats, Card history, Engagement | P1–P21, H1–H9, EN1–EN18 |
| `docs/decision-tables/navigation-ui.md` | Navigation, UI state | N1–N13, U1–U5 |
| `docs/decision-tables/tts.md` | TTS / Audio playback | T1–T15 |
| `docs/decision-tables/account-sync.md` | Google account, Drive sync | AC1–AC12, SY1–SY24 |

## Convention
- `ID` is stable across all files. Tests reference ID (e.g. `// decision: F1`).
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` column: `TBD` = test not yet written. Written by the implementing agent from the `Expected` column.
- **Tests must be derived from docs/Expected, NOT from code.** Writing tests from code validates current behavior, not business rules.

## Usage
- Before implementing a feature: read the relevant file(s) above.
- Add new rows when adding business logic branches.
- Update `Test` column when writing the test (format: `test/path/file.dart::RowID`).

## Update rule

When implementing a new behavior:

1. Add the row in the appropriate per-feature file with ID and expected behavior.
2. Add the test referenced.
3. Implement.
4. Verify the test passes.

When changing existing behavior:

1. Update the row (do not delete; mark deprecated if needed).
2. Update the test.
3. Update related business doc in the same commit.

## Related

This index cross-references every behavior branch. When a row is added or modified, the
corresponding business doc and test MUST be updated in the same commit (per `CLAUDE.md` §Doc-code
parity rule).

**Business specs (rows reference these for "Source of truth"):**

- All of `docs/business/**`

**Wireframes (rows reference for UI verification):**

- All of `docs/wireframes/**`

**Schema:**

- `docs/database/schema-contract.md` — column-level rows under "Schema"

**Checklists:**

- `docs/checklist/implementation-checklist.md` — "Tests" section requires a test per touched
  decision row
- `docs/checklist/recursive-agent-review.md` — verifies row coverage

**Maintenance rule:**

- Every C0 row MUST have at least one test referenced by ID.
- Every new branch logic in code MUST add a row before merge.
