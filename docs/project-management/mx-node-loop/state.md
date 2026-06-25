# mx-node rollout loop — state (cursor / HINT)

> **LOOP TERMINAL 2026-06-24**: all 13 FE-built screens now carry mx-node coverage —
> 03/04/05/06/07/08 + 17 via kit `data-mx-node` → spec `id:` → `gen_contract` (18
> nodes / 12 screens) + a parity-contract test each; 12–16 study modes via the shared
> `StudyShell` chrome (exit + progress) keyed per mode + golden assertions; 02-dashboard
> now flows through the generated contract too (2026-06-25: kit-02 regenerated to the
> redesign — due-summary + Progress/Library shortcut rows — tagged with `data-mx-node`,
> spec `id:` re-exported, `gen_contract` emits `02-dashboard`, and its parity test uses
> `expectGeneratedParityContract` — no more hand-written special case). Remaining screens
> (00/01/09/10/11/18–25) have NO FE → out
> of scope. Gates green: gen_contract --check, design_watch --check, all parity tests.
> Re-open by: (a) regenerating kit-02 to the redesign then tagging it; (b) deepening any
> screen's contract with more nodes; (c) pushing the tagged kit to Claude Design "v3".
>
> **Coverage gauge (`tool/parity/mxnode_coverage.mjs`) — now 100%:** deeper rollout
> 2026-06-24 took singleton coverage from ~28% to **23/23 (100%)** by (a) giving 13
> shared `_shared.jsx` primitives an optional `node` prop (common-layer first:
> IconTile/TileLg/Chip/Overline/SectionHead/ListRow/HeroCard/EmptyState/Banner/InfoRow/
> DueSummary/StatSummary/ListGroup) and (b) tagging the raw singletons (03 sort, 07/08
> back/save/delete/deck-picker/details, 12–16 study content-card + action, 17 close).
> The **4 intentionally-untagged cases live in `intent-ledger.json.coverageExempt`**
> (02 settings-icon + section-head = kit pre-redesign deferred; 13 Shuffle = Future;
> 08 icon-tile = child of the tagged deck-picker) — the coverage tool reads the ledger,
> drops them from gaps + the `--check` denominator, and CI gates `--check --min 100`
> (a new candidate must be tagged or ledger-exempted).
>
> **FE keys + parity tests for the new nodes — DONE 2026-06-24:** the 36-node contract
> is now honoured on the FE. Added `ValueKey`s + test assertions: 03 sort-btn, 04
> stat-card, editor back-btn/save-button/delete-btn/details-toggle (07/08), study
> content-card (12/14/15/16) + action (15 Show-answer, 16 Check). The remaining 4
> contract nodes are FE-side **`exceptions`** in `intent-ledger.json` (not built by
> design): 07/08 `deck-picker` (Future — deck retargeting), 14 `action` (guess
> AUTO-ADVANCES, no manual button), 17 `close-btn` (mock↔doc conflict resolved toward
> wireframe 18 — the result screen has ONE exit, scope-aware `Done`, not kept in the
> back stack; a second close-x would break that nav contract, so it stays Rejected).
> All parity + study tests pass.

Autonomous loop: tag the kit JSX with `data-mx-node` on required singleton nodes,
re-export specs, regenerate the parity contract, add matching Flutter `ValueKey`s +
a parity test per screen, fix any missing/divergent screen, and fix automation
problems as they surface. One screen per iteration. Branch:
`feat/parity-contract-flashcard-list`.

## Per-screen recipe (what each iteration does)

1. Pick the next screen with FE (table below). Read its kit `screens/NN-*.jsx` +
   the FE screen widget.
2. Tag **singleton** required nodes (FAB, search dock, key header/empty CTA) with
   `data-mx-node="<screen-id>/<node>"`. `Fab` already spreads `...rest` → tag at the
   call site; primitives without rest (e.g. `SearchDock`) take a `node` prop added in
   `_shared.jsx` (common layer). **Never tag repeated list items** (duplicate keys
   crash Flutter).
3. `npm --prefix tool/ui_kit_shots run export:specs` (shots are visually unchanged by
   invisible attrs — only re-run `export:all` if a real visual fix is made).
4. `node tool/parity/gen_contract.mjs` → `contracts/contracts.json`.
5. FE: matching `key: ValueKey('mx-node:<screen-id>/<node>')` on the widget.
6. Parity test `..._parity_test.dart` asserting each node **in the state it renders**
   (loaded vs search vs empty). Helper `test/support/parity_contract.dart`.
7. `node tool/parity/design_watch.mjs --update` (the screen's spec changed).
8. Fix any missing/divergent element found vs the mock while here.
9. `node tool/verify/run.mjs --test "<parity test> <golden test>"` (golden must still
   pass — keys don't change render).
10. Commit. Update this table.

## Conventions / gotchas

- `<screen-id>` in the id = the JSX num-name (`03-library`, `06-flashcard-list`); the
  **spec filename can differ** (`03-library-overview.md`) — fine, the `mx-node:` key is
  what the FE matches, gen_contract just groups by spec file.
- Tag loaded-state singletons first; state-only nodes (search dock, empty CTA) get
  asserted in a toggled/empty pump.
- `check-ui-kit.js` must stay 0 errors; specs must stay fresh.

## Screen status

| Screen | FE | mx-node tagged | nodes | status |
| --- | --- | --- | --- | --- |
| 02-dashboard | yes (redesigned) | kit✅ + FE✅ | due-summary, shortcut-progress, shortcut-library | DONE (generated) — kit-02 regenerated to the redesign (due-summary + Progress/Library shortcut rows), tagged `data-mx-node`, spec `id:` re-exported, `gen_contract` emits `02-dashboard` (3 keys); `dashboard_parity_test` uses `expectGeneratedParityContract` (no hand-written list). 2026-06-25. |
| 03-library-overview | yes | ✅ | new-folder-fab, search-dock | DONE |
| 04-folder-detail | yes | ✅ | create-deck-fab, new-subfolder-fab, search-dock | DONE |
| 05-library-search | yes | ✅ | search-dock | DONE |
| 06-flashcard-list | yes | ✅ | add-card-fab, search-dock | DONE |
| 07-flashcard-create | yes | ✅ | flashcard-editor/front-field, back-field | DONE |
| 08-flashcard-edit | yes | ✅ | (reuses flashcard-editor/front-field, back-field) | DONE |
| 12-study-review | yes (behavior) | ✅ | study-session/exit, study-session/progress (shared StudyShell) | DONE |
| 13-study-match | yes | ✅ | study-session/exit, progress (FE keyed + golden assertion) | DONE |
| 14-study-guess | yes | ✅ | study-session/exit, progress (FE keyed + golden assertion) | DONE |
| 15-study-recall | yes | ✅ | study-session/exit, progress (FE keyed + golden assertion) | DONE |
| 16-study-fill | yes | ✅ | study-session/exit, progress (FE keyed + golden assertion) | DONE |
| 17-study-result | yes | ✅ | done-button | DONE |
| 00,01,09,10,11,18–25 | no FE | n/a | — | out of scope (no-FE-yet) |

## Automation fixes made during the loop

- (pipeline built pre-loop: export_specs id-carry, gen_contract regex `id:\s*`,
  SearchDock `node` prop.)
- **Test gotcha (04):** re-pumping the SAME tester after a state toggle (e.g. tap
  search, then `pumpWidget` a new seed) can leave stale provider/search state → a
  later state's node reads as missing. Fix: one `testWidgets` PER state (fresh
  tester), not multiple pumps in one test.
- For a screen with a parametrized local FAB helper (04 `FabSlot`), add a `node`
  prop to the helper and pass a distinct id per call site (decks vs subfolders).
- **Shared study chrome (12–16):** the kit `StudyShell` (common layer) owns the exit
  + progress; tagging it once gives `study-session/exit` + `study-session/progress` to
  ALL 5 study specs. Each FE mode screen builds its OWN chrome, so key exit+progress
  per mode (study_session=12 review, fill=16, guess=14, match=13, recall=15). The
  study session pump is heavy (review/controller stubs), so for study modes the parity
  assertions are added to the existing golden test's loaded case (reuse the pump),
  not a separate parity test.
- **Shared-screen ids (07/08):** 07-create and 08-edit are ONE Flutter screen
  (`flashcard_editor_*`). A shared widget can hold only one key, so editor nodes use a
  shared prefix `flashcard-editor/<node>` tagged in BOTH kit 07 + kit 08; the FE keys
  once. gen_contract lists the same key under both spec files; each screen's test
  finds it. `TextArea` spreads `...rest` → tag at the call site.

## Notes for push

When pushing the kit to Claude Design "v3", include `_shared.jsx` + every tagged
`screens/NN-*.jsx` so the `data-mx-node` ids live at the canonical source.
