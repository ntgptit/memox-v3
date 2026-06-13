---
last_updated: 2026-06-05
status: contract
applies_to: UI mock-to-code implementation
---

# Mock Design Index

This file maps approved mock designs to MemoX routes, wireframes, and visual
contracts. It complements `docs/system-design/mock-design-doc-mapping.md`: that
file maps mock groups to product docs, while this file points implementation
agents to the exact per-screen visual contract when one exists. To actually
*build* a screen from these mocks step by step, follow
`docs/design/mock-to-ui-playbook.md`.

## Rules

- **Canonical mock source = screenshots.** Every approved kit screen state ships as a light + dark
  PNG pair under `docs/system-design/MemoX Design System/ui_kits/mobile/shots/` (manifest:
  `shots/INDEX.md`). Read the PNGs for the target screen — ALL states, both themes — as the visual
  contract input. Do NOT derive the design by reading the kit's `index.html` JSX; consult its
  source only for exact copy/control order via the line index in the kit `README.md`.
- **No/weak image input? Use the DOM specs.** Agents that cannot read images reliably use
  `docs/system-design/MemoX Design System/ui_kits/mobile/specs/` (manifest: `specs/INDEX.md`):
  one file per screen with the measured element tree (text, bounding boxes, token-resolved
  styles) for the base state + added/removed deltas per remaining state. Agents WITH vision
  should still use the specs for exact numbers (spacing, sizes, token names) alongside the PNGs.
- Do not implement a screen from an unapproved mock.
- Do not use an old mock when this index points to a newer approved source.
- Do not start UI code from `docs/system-design/MemoX Design System/ui_kits/mobile/index.html`
  alone.
- Read the matching wireframe and visual contract before changing a screen.
- If a screen has no approved mock source or visual contract, map visible mock elements before
  coding and ask if scope is unclear.
- If a mock conflicts with business, route, schema, state, or wireframe docs, stop and resolve the
  conflict before coding.

## Screen Index

| Screen           | Route       | Mock source                                                                                                                 | Wireframe                            | Visual contract                                           | Current status                     | Main implementation files                                                                                                                                                                                              |
|------------------|-------------|-----------------------------------------------------------------------------------------------------------------------------|--------------------------------------|-----------------------------------------------------------|------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Library Overview | `/library`  | `ui_kits/mobile/shots/03-library-overview--*` (11 states × light/dark; see `shots/INDEX.md`)                                | `docs/wireframes/02-library.md`      | `docs/design/screens/library-overview.visual-contract.md` | Current V1 partial                 | `lib/presentation/features/folders/screens/library_overview_screen.dart`, `lib/presentation/features/folders/widgets/library_overview_body.dart`, `lib/presentation/features/folders/widgets/library_folder_tile.dart` |
| Dashboard        | `/home`     | `ui_kits/mobile/shots/02-dashboard--*` (9 states × light/dark)                                                              | `docs/wireframes/01-dashboard.md`    | `docs/design/screens/dashboard.visual-contract.md`         | Partial / mixed Current and Future | TBD                                                                                                                                                                                                                    |
| Progress         | `/progress` | `ui_kits/mobile/shots/19-progress--*` (7 states × light/dark); `shots/18-stats--*` is legacy reference only                 | `docs/wireframes/03-progress.md`     | TBD                                                       | Current V1 (help icon + card-state links Future) | `lib/presentation/features/progress/screens/progress_screen.dart`, `lib/presentation/features/progress/widgets/progress_activity_sections.dart`, `lib/presentation/features/progress/widgets/progress_summary_sections.dart` |
| Settings         | `/settings` | `ui_kits/mobile/shots/20-settings--*` (5 states × light/dark)                                                               | `docs/wireframes/04-settings-hub.md` | TBD                                                       | Partial / mixed Current and Future | TBD                                                                                                                                                                                                                    |

Screens not yet listed here: resolve the mock source via
`docs/system-design/MemoX Design System/ui_kits/mobile/shots/INDEX.md` (all 23 screens, 135
states, light + dark are covered there).

## Agent Workflow

1. Find the target screen in this index (or in `shots/INDEX.md` for screens not listed here).
2. **Open the `shots/` PNGs for the screen — every state, light + dark** (vision agents), and/or
   read the screen's `specs/NN-*.md` DOM spec (text agents; vision agents use it for exact
   numbers). Each kit state must map to a row in your implementation plan or be explicitly marked
   Future/Rejected/out-of-scope; a kit state silently missing from the plan is a parity failure
   (per `CLAUDE.md` §UI Mock Design Parity).
3. Read the listed visual contract when present.
4. Read the listed wireframe and its implementation refs.
5. Read `docs/design/design-language.md` (taste contract for decisions the mock does not
   answer), `docs/design/design-token-mapping.md`, and
   `docs/design/component-visual-contract.md`.
6. Implement only elements marked Current, unless the task explicitly promotes a Future item.
7. Run `docs/design/visual-parity-checklist.md` before reporting completion, comparing against
   the `shots/` PNGs.

## Related

- `docs/design/design-language.md`
- `docs/system-design/mock-design-doc-mapping.md`
- `docs/system-design/MemoX Design System/README.md`
- `docs/system-design/MemoX Design System/ui_kits/mobile/README.md`
- `docs/ui-ux/ui-ux-contract.md`
- `docs/wireframes/index.md`
