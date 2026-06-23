# mx-node rollout loop — state (cursor / HINT)

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
| 02-dashboard | yes (redesigned) | — | — | **special**: kit-02 is pre-redesign; contract from the redesign, not kit-02 |
| 03-library-overview | yes | ✅ | new-folder-fab, search-dock | DONE |
| 04-folder-detail | yes | ✅ | create-deck-fab, new-subfolder-fab, search-dock | DONE |
| 05-library-search | yes | ✅ | search-dock | DONE |
| 06-flashcard-list | yes | ✅ | add-card-fab, search-dock | DONE |
| 07-flashcard-create | yes | ✅ | flashcard-editor/front-field, back-field | DONE |
| 08-flashcard-edit | yes | ✅ | (reuses flashcard-editor/front-field, back-field) | DONE |
| 12–16 study | yes (behavior) | — | — | next (study modes: top bar / rate / answer) |
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
- **Shared-screen ids (07/08):** 07-create and 08-edit are ONE Flutter screen
  (`flashcard_editor_*`). A shared widget can hold only one key, so editor nodes use a
  shared prefix `flashcard-editor/<node>` tagged in BOTH kit 07 + kit 08; the FE keys
  once. gen_contract lists the same key under both spec files; each screen's test
  finds it. `TextArea` spreads `...rest` → tag at the call site.

## Notes for push

When pushing the kit to Claude Design "v3", include `_shared.jsx` + every tagged
`screens/NN-*.jsx` so the `data-mx-node` ids live at the canonical source.
