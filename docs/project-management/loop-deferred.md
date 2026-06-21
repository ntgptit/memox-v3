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
