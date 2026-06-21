# Loop — Deferred work-packages (FE-completion loop)

Append-only. One line per deferred item: `date · WBS ID · object · reason · suggestion`.
Reasons: needs-dependency / needs-schema / needs-approval / spec-unclear / mock-doc-conflict /
drift / verify-fail / review-blocker.

A DEFERred item does NOT make its object DONE; it is simply not FE-eligible this run.

- 2026-06-21 · (read-model) · Library overview · needs-BE · Due-summary card (`dueToday`) — `FolderSummary` read model lacks `dueToday`; surface the card once the aggregate read model ships the field.
- 2026-06-21 · (read-model) · Library overview · needs-BE · Folder mastery bar (`mastery`) — ~~read model lacks `mastery`~~ **RESOLVED 2026-06-21 (WP-L6b):** `FolderSummary.mastery` shipped (`AVG(COALESCE(box_number,1))/SrsBox.max`); FE `MxLinearProgress` wiring is WP-L8.
- 2026-06-21 · (read-model) · Library overview · needs-BE · Folder new-card badge (`newCount`) — ~~read model lacks `newCount`~~ **RESOLVED 2026-06-21 (WP-L6b):** `FolderSummary.newCount` shipped (active unseen cards, F13 exclusion); FE badge wiring is WP-L8.
- 2026-06-21 · (read-model) · Library overview · needs-BE · Deck-digest subtitle (`subtitle`) — read model lacks `subtitle` (GROUP_CONCAT deck names); show subtitle once shipped.
- 2026-06-21 · (no WBS) · Library overview · needs-schema · `03j` Archive folder action + confirm dialog — no archive use case / repository method / DAO / schema column exists; needs an approved backend task before the overflow action can be exposed.
- 2026-06-21 · 2.19.2 · Folder detail · needs-BE + spec-unclear · Deck move FE — no deck-move-targets read path exists; `deck.md` §MoveDeckUseCase defines no `GetDeckMoveTargetsUseCase`/`DeckMoveTarget` model, and `FolderMoveTarget`/`FolderMoveBlock` are folder-specific (inverted lock). The picker must disable (not hide) decks-disallowed destinations up front (move-eligibility = business logic, must live in a use case/repo, not the widget). Suggestion: spec + build a BE `GetDeckMoveTargetsUseCase` (folders with content_mode ∈ {unlocked, decks}, current parent annotated) + `DeckMoveTarget` model, then FE reuses the picker pattern.

## RULES CHANGE 2026-06-21 — vertical-slice loop (BE/schema may now be added in dev)

The loop switched from FE-only to **vertical slice**: BE (incl. schema/migration with full parity
set) may be added to unblock FE. The following items above are therefore **RE-OPENED** (their sole
blocker was `needs-BE`, no longer a valid DEFER reason) and tracked in the object plans:

- RE-OPENED · Library overview · `dueToday` / `mastery` / `newCount` / `subtitle` read-model fields → WP-L6…L8 (BE query extension, no schema). See `loop-plan/library-overview.md`.
- RE-OPENED · 2.19.2 · Folder detail · Deck move → WP-FD5a (BE deck-move-targets) + WP-FD5b (FE). Rules are unambiguous (analog of folder-move-targets); not spec-unclear. See `loop-plan/folder-detail.md`.

STILL DEFERRED (valid reasons under the new rules):
- Library `03j` Archive → Future / needs-approval (product-scope decision, not just missing BE).
- 3.2.3 Folder new-vs-due split → larger slice, sequenced after deck-move; re-audit when reached.
- 2.10.2 / 2.5.2 reorder FE → mock-doc-conflict (no reorder-state mock; would invent drag design).

## MOCK-PARITY CORRECTION 2026-06-21 — Library enrichments NOT in the rebuilt mock

Verified the Library folder tile against the actual kit mock `shots/03-library-overview--loaded--{light,dark}.png` (not just the prose §Scope Decision table, which is stale prior-iteration target shape). The rebuilt calm-app mock renders minimal folder rows (icon + name + `{n} decks · {m} cards` + chevron). `library_folder_tile.dart` already matches it. So the following RE-OPENED items are now DEFERred (the redesign dropped them):
- 2026-06-21 · (read-model) · Library overview · mock-doc-conflict · Folder mastery bar / new-card badge FE (WP-L8) — not in kit `03a`; the `FolderSummary.mastery`/`newCount` fields shipped (WP-L6b, correct + tested) but have no current FE consumer (kept for a future WBS 3.2.3 / Progress design).
- 2026-06-21 · (read-model) · Library overview · mock-doc-conflict · Deck-digest subtitle (WP-L6c) — kit `03a` shows a `{n} decks · {m} cards` digest, not deck names.
- 2026-06-21 · (read-model) · Library overview · mock-doc-conflict · Due-summary card + `dueToday` total (WP-L6d/L7) — no due-summary card in kit `03a`.

Lesson: check the mock IMAGE before building enrichment BE/FE. Object 1 (Library) is DONE per the current mock.

## MOCK-PARITY AUDIT 2026-06-21 — Folder detail new-vs-due (3.2.3) not in mock

Audited `shots/04-folder-detail--decks--{light,dark}.png`: the rebuilt mock shows a Decks/Cards/Due stats card + deck rows (`{n} cards · last {time} ago` + due badge). No `{n} new` count, new badge, or Study-new/Review-due CTAs.
- 2026-06-21 · 3.2.3 · Folder detail · mock-doc-conflict · New-vs-due split UI (WP-FD8) — new badges + Study-new/Review-due CTAs are prior-iteration design the rebuild dropped; `FolderSummary.newCount` shipped (WP-L6b) but stays read-model-only. Building the badges/CTAs = inventing UI not in the mock.

NOTE: the audit also found a real gap (NOT deferred) — deck rows show `· last {time} ago` in the mock but `deck_tile.dart` omits it → tracked as WP-FD9 (eligible vertical slice, build next) in `loop-plan/folder-detail.md`.

## PRE-EXISTING DRIFT + parity gaps surfaced during WP-FD9 (2026-06-21)

- DRIFT (pre-existing, not WP-FD9) · `docs/business/srs/srs-review.md` (§44/§196/§243/§276) + `docs/contracts/usecase-contracts/study.md` §319 spec a persistent `flashcard_progress.last_studied_at` column updated at study finalization, but the column was **never added** and finalization never wrote it. WP-FD9 computes last-studied **read-time** (`MAX(study_session_items.answered_at)`) instead, so the persistent column is not needed for the Folder-detail display. Resolving the SRS-contract refs (drop the persistent column, or build it + wire finalization) is an **SRS-contract decision** — out of WP-FD9 scope; needs an srs-reviewer pass. schema-contract noted the supersession for the display surface.
- 2026-06-21 · (no WBS) · Folder detail / Library · needs-schema · **Deck color/icon** — `deck_tile` / deck-move picker render a uniform `Icons.style_outlined` + accent tint, but the mock shows per-deck icon/color variety. `Deck` has no color/icon field (folders got them via WBS 2.22.1). Needs a deck color/icon schema + BE (analog of 2.22.1) before per-deck visuals; deferred.
- 2026-06-21 · (no WBS) · Folder detail · mock-doc-conflict · **Deck due-badge solid vs soft fill** — the mock's highest-due row uses a solid accent fill, others a soft tint; no threshold rule is documented. `_DueBadge` renders soft for all. Needs a design decision (count threshold?) before varying — don't guess.
