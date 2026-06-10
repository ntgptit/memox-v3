---
last_updated: 2026-06-02
applies_to: deck entity and deck management feature
---

# Deck Management

> **Status: Partial — schema + rename/reorder backend Current; FE wiring and language picker UI
> Specified; root-level decks Rejected / Out of Scope (verified 2026-06-10).**
>
> The `decks.target_language TEXT NOT NULL DEFAULT 'korean'` column **exists in the current
> schema** (`lib/data/datasources/local/drift/`; the create path persists it) — no migration is
> pending for it. Deck rename and reorder **backends are implemented** (`RenameDeckUseCase`,
> `ReorderDecksUseCase` over `FolderRepository.renameDeck/reorderDecks`, commit `48e55584`, with
> tests). What remains Specified: wiring rename/reorder into the deck actions UI, the
> target-language picker in deck create/edit UI, and TTS gating (blocked on the TTS service, WBS
> 8.4.x — not on schema).
>
> Product ownership rejected root-level decks: every deck must belong to exactly one folder,
> `decks.folder_id` stays non-null, and deck create/move/reorder/duplicate APIs remain
> folder-bound. The historical nullable-deck-parent design is Rejected and its design note no
> longer exists in this repo; do not reintroduce it.

## Source files to inspect

- `lib/presentation/features/folders/**`
- `lib/presentation/features/flashcards/**`
- `lib/domain/**deck**`
- `lib/data/**deck**`
- `lib/data/datasources/local/drift/` (decks table definition)

## Data

Decks are stored in `decks`.

Important fields:

- `id`
- `folder_id`
- `name`
- `target_language` (TEXT, see below)
- `sort_order`
- `created_at`
- `updated_at`

## Target language

Every deck has a target language indicating what language the FRONT side of its cards is in. This
drives TTS behavior and sets explicit expectations about content type.

| Value         | Meaning                                        | TTS supported now? |
|---------------|------------------------------------------------|--------------------|
| `korean`      | Korean (ko-KR) front content                   | Yes                |
| `english`     | English (en-US) front content                  | Yes                |
| `unsupported` | Any other language; TTS disabled for this deck | No                 |

When user creates or edits a deck, they MUST pick a target language. Default: `korean`.

Rationale: Without explicit language tagging, TTS would attempt to speak Vietnamese/Japanese/etc.
with an English voice → wrong pronunciation. Forcing a per-deck declaration prevents silent failure.

### Effects of target language

| Surface                           | Behavior                                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------------------|
| TTS speak action on study session | Enabled only when `targetLanguage` is `korean` or `english`. Disabled (greyed out) for `unsupported`. |
| TTS auto-play                     | Skipped silently when deck's `targetLanguage = unsupported`.                                          |
| Deck create/edit form             | Required field (defaults to `korean`).                                                                |
| TTS settings screen               | Voice/language picker remains global; future per-deck override planned.                               |

### Migration

No migration is pending: the column shipped with the current schema and defaults to `'korean'`.
Users can edit each deck to set the correct value once the deck edit form exposes the picker.

## Rules

- A deck belongs to exactly one folder.
- Root-level decks are Rejected / Out of Scope.
- `decks.folder_id` must not be made nullable under the rejected root-deck
  direction.
- Deck name is required after trim.
- Deck name max length follows schema constraint.
- Deck target language is required (default `korean`).
- Deck can be created only in folder mode `unlocked` or `decks`.
- Creating deck sets parent folder mode to `decks`.
- **Move deck to another folder (Specified, WBS 2.19.x):** a deck may move to any folder whose
  mode is `unlocked` or `decks`; the move sets the target folder's mode to `decks`, appends the
  deck at the end of the target's `sort_order`, may return the source folder to `unlocked` when
  it loses its last deck, and never touches flashcards/progress/tags. Folders and flashcards both
  have move; decks — the unit most often filed in the wrong place — must too.
- Empty deck cannot start study.
- Deleting deck deletes related flashcards and local dependent data through persistence rules.
- Reorder updates `sort_order` only.
- Changing `target_language` does NOT modify flashcards. It only updates TTS behavior going forward.

## Screen behavior

Deck appears through Library/Folder/Flashcard list flows.

Deck actions may include:

- Open flashcard list.
- Create flashcard.
- Import flashcards.
- Start study.
- Rename deck.
- Delete deck.
- Reorder deck inside folder.

## Performance

- Decks list >50 items in a folder: use `ListView.builder`.
- Card count badge: stream from database.
- Due count badge: stream from database, not recomputed in widget.

## Agent rule

Do not add a separate deck detail route unless route contract and navigation docs are updated.

## Related

**Wireframes:**

- `docs/wireframes/02-library.md` — Current V1 Library does not render root-level decks; top-level
  deck rows are Rejected / Out of Scope
- `docs/wireframes/05-folder-detail.md` — decks listed inside a folder (decks mode)
- `docs/wireframes/06-flashcard-list.md` — deck content view + deck-level CTAs
- `docs/wireframes/10-deck-import.md` — import flow into a deck
- `docs/wireframes/25-shared-bottom-sheets.md` §deck-create, §deck-picker

**Schema:**

- `docs/database/schema-contract.md` → `decks` table (`id`, `folder_id`, `name`, `target_language`,
  `sort_order`, timestamps). All columns including `target_language` are in the current schema.
- Nullable `decks.folder_id` is Rejected / Not Applicable while the folder-owned deck invariant
  holds (the historical design note file no longer exists in this repo).

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Deck management" and "TTS
  gating" (target_language influences TTS UI in study modes)

**Glossary terms:**

- `docs/business/glossary.md` → `target_language`, `korean`, `english`, `unsupported`

**Related business specs:**

- `docs/business/folder/folder-management.md` — folder mode lock affects whether deck can be created
  here
- `docs/business/flashcard/flashcard-management.md` — deck owns flashcards
- `docs/business/tts/tts-settings.md` — `target_language` gates TTS at deck level
- `docs/business/export/export.md` — deck is the export unit
- `docs/business/navigation/navigation-flow.md` — `/library/deck/:deckId/...` routes

**Source files to inspect (verified 2026-06-10):**

- `lib/data/datasources/local/drift/` (decks table definition)
- `lib/domain/entities/deck.dart`
- `lib/domain/repositories/folder_repository.dart` — deck operations live on the folder
  repository (`createDeck`, `deleteDeck`, `renameDeck`, `reorderDecks`); there is NO separate
  `deck_repository.dart`
- `lib/domain/usecases/deck/**` (`create_deck_usecase.dart`, `delete_deck_usecase.dart`,
  `rename_deck_usecase.dart`, `reorder_decks_usecase.dart`)
- `lib/presentation/features/folders/**` (deck tiles in Folder Detail) and
  `lib/presentation/features/flashcards/**` (deck actions sheet)
