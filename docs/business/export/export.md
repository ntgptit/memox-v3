---
last_updated: 2026-06-21
applies_to: deck export, flashcard selection export, CSV/Excel formats
---

# Export

> **Status: BE V1 implemented (WBS 8.7.1, 2026-06-21 — rebuilt after the 2026-06-19 reset).** Deck
> CSV export is present in the backend slice (`FlashcardRepository.exportDeckCsv` +
> `FlashcardExportWriter` + `ExportDeckCsvUseCase`); FE share/save wiring (8.7.2) remains deferred and
> still requires approval for `share_plus`. Excel format and selection-scope export are Future.
>
> **Priority note (BA review 2026-06-10):** MemoX is local-first with NO working backup path —
> export CSV is currently the only cheap way for users to get their content out, and the data-loss
> guard until Drive sync lands. Deck-level CSV export (BE) is scheduled early in the WBS next-10
> (8.7.1) ahead of Drive sync. V1 cut: CSV only, deck scope only; Excel and selection-scope follow.

## Target source structure

- `lib/domain/models/deck_csv_export.dart`
- `lib/domain/usecases/flashcard/export_deck_csv_usecase.dart`
- `lib/data/repositories/flashcard_export_writer.dart`
- `lib/data/repositories/flashcard_repository_impl.dart`
- `lib/presentation/features/flashcards/**` export trigger on deck actions sheet
- Share/save via `share_plus` (`XFile.fromData`) remains FE-only and still requires dependency approval

## Scope

Two export entry points exist:

| Entry | Scope | Source repository |
| --- | --- | --- |
| Deck export | All flashcards in one deck | `FlashcardRepository.exportDeckCsv` |
| Flashcard selection export | Selected flashcard IDs | `FlashcardRepository.exportFlashcards` |

Both produce the same file format. The difference is only the source scope and file name.

## Formats

| Format | MIME type | Extension |
| --- | --- | --- |
| `ExportFormat.csv` | `text/csv` | `.csv` |
| `ExportFormat.excel` | `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` | `.xlsx` |

User picks format via `pickFlashcardExportFormat(context)` bottom sheet (`MxBottomSheet` with `MxActionSheetList`).

## Exported columns

V1 deck CSV exports exactly two columns in this order:

| Column | Source | Empty handling |
| --- | --- | --- |
| `front` | Flashcard front | Always present (required field) |
| `back` | Flashcard back | Always present (required field) |
Row 1 is the header row.

NOT exported:

- `example`, `pronunciation`, `hint` (additional flashcard fields)
- Tags
- SRS progress (`current_box`, `due_at`, etc.)
- Deck/folder metadata
- Timestamps

This intentionally produces a portable, study-content-only file. Round-tripping (export then import) preserves only front/back.

## File naming

| Entry | Base name | Final name |
| --- | --- | --- |
| Deck export | `sanitizeFileName(deck.name)` | `{sanitized_deck_name}.csv` |
| Flashcard selection export | `'flashcards_export'` (literal) | `flashcards_export.csv` or `.xlsx` |

`sanitizeFileName` (in `flashcard_export_writer.dart`) trims whitespace, replaces path separators and unsafe characters, collapses repeats, and falls back to a deterministic deck-id-based name when the title sanitizes to blank.

## CSV format details

- Encoding: UTF-8.
- Line separator: `\n` (Unix line ending).
- Header row: `front,back`.
- Cells escaped via `escapeCsvCell` (inspect `flashcard_export_writer.dart`).
- No BOM.

Standard CSV escaping applies (quote cells containing comma, newline, or quote; double inner quotes).

## Excel (.xlsx) format details

- Minimal valid Office Open XML workbook (zip of XML parts).
- Built with `archive` + `xml` packages (no extra dependency beyond what import already uses).
- Single sheet named `'Flashcards'`.
- All cells use inline string type (`t="inlineStr"`) — no `sharedStrings.xml`, no styling.
- Verified to open in Excel and LibreOffice.

This is intentionally minimal. Do not add styling, formulas, or multi-sheet output without justification.

## Output delivery

Export does NOT write to a fixed path. Instead:

1. Repository returns `Result<DeckCsvExport>` containing `deckId`, `deckName`, `fileName`, `csvText`, and `exportedRowCount`.
2. Presentation layer share/save wiring remains FE-only and deferred.
3. The backend export itself is read-only and does not write to disk.

Rationale: lets the user choose destination per export, no permission to write to user file system, works uniformly across iOS/Android/desktop/web.

## Rules

- Export source MUST be a deck scope. Empty deck export still produces a valid CSV with header only.
- Export does NOT mutate any data. Read-only operation.
- Format conversion lives in `FlashcardExportWriter.buildCsv`. Do not duplicate.
- Repository builds CSV rows from flashcard content only.
- File extension MUST be `.csv` for the deck CSV V1 slice.

## UI behavior

Trigger surfaces:

- Deck quick actions: long-press or actions menu on a deck → "Export deck".
- Flashcard list selection: select N cards → bulk action → "Export selected".

Flow:

```mermaid
flowchart TD
    Trigger[User triggers export] --> Picker[pickFlashcardExportFormat bottom sheet]
    Picker -->|dismissed| Cancel[No-op]
    Picker -->|csv or excel| Build[Repository builds ExportData]
    Build -->|success| Share[shareFlashcardExport via share_plus]
    Build -->|failure| Error[Show error via shared error UI]
    Share --> Done[User picks destination in share sheet]
```

## Required UI states

- Picker dismissed: no-op (no error).
- Build in progress: show loading indicator on trigger (deck quick action button or bulk action bar).
- Build failure: show shared error feedback.
- Share invocation failure: log and surface message (rare; share_plus handles most cases).

## Performance

- Build is synchronous in-memory operation. Acceptable for typical decks (≤ 10,000 cards).
- For very large decks: consider streaming write, but not required at current scale.
- CSV build is faster than Excel; Excel involves XML serialization and zip encoding.

## Agent rule

- Do not add new export columns (example/pronunciation/hint/tags/SRS) without updating this doc, both export use cases, both repository impls, the writer, and tests.
- Do not write export files to disk directly in this slice. FE share/save wiring remains deferred.
- Do not introduce a new export format (JSON, Anki .apkg, etc.) without updating `ExportFormat` enum, picker, writer, and this doc.
- File name MUST come from `sanitizeFileName` for deck export and the literal `'flashcards_export'` for selection export. Do not let user-provided names skip sanitization.

## Related

**Wireframes:**

- `docs/wireframes/06-flashcard-list.md` — Export action in deck overflow ⋮
- `docs/wireframes/25-shared-bottom-sheets.md` §item-context (deck variant adds Export action)

**Schema:**

- `docs/database/schema-contract.md` → exports read from `flashcards` (front, back only — per V1 scope decision); SRS progress not exported

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Export" (format support, field set, encoding)

**Glossary terms:**

- `docs/business/glossary.md` → "export", "CSV", "Excel/XLSX"

**Related business specs:**

- `docs/business/flashcard/flashcard-management.md` — fields that travel
- `docs/business/deck/deck-management.md` — deck is the export unit
- `docs/business/account-sync/account-sync.md` — full backup via Drive sync (the "backup" path; export is the "share" path)

**Source files to inspect:**

- `lib/data/repositories/flashcard_export_writer.dart`
- `lib/data/repositories/flashcard_repository_impl.dart` (`exportDeckCsv`)
- `lib/domain/usecases/flashcard/export_deck_csv_usecase.dart`
- `lib/domain/models/deck_csv_export.dart`
