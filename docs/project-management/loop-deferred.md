# Loop — Deferred work-packages (FE-completion loop)

Append-only. One line per deferred item: `date · WBS ID · object · reason · suggestion`.
Reasons: needs-dependency / needs-schema / needs-approval / spec-unclear / mock-doc-conflict /
drift / verify-fail / review-blocker.

A DEFERred item does NOT make its object DONE; it is simply not FE-eligible this run.

- 2026-06-21 · (read-model) · Library overview · needs-BE · Due-summary card (`dueToday`) — `FolderSummary` read model lacks `dueToday`; surface the card once the aggregate read model ships the field.
- 2026-06-21 · (read-model) · Library overview · needs-BE · Folder mastery bar (`mastery`) — read model lacks `mastery` (AVG(box)/8 over subtree); wire `MxLinearProgress` row once shipped.
- 2026-06-21 · (read-model) · Library overview · needs-BE · Folder new-card badge (`newCount`) — read model lacks `newCount`; show badge once shipped.
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
