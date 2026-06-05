---
last_updated: 2026-06-05
status: contract
applies_to: UI mock-to-code implementation
---

# Mock Design Index

This file maps approved mock designs to MemoX routes, wireframes, and visual
contracts. It complements `docs/system-design/mock-design-doc-mapping.md`: that
file maps mock groups to product docs, while this file points implementation
agents to the exact per-screen visual contract when one exists.

## Rules

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
| Library Overview | `/library`  | `docs/system-design/MemoX Design System/ui_kits/mobile/index.html` - `03 · Library overview` (`03a`-`03f`)                  | `docs/wireframes/02-library.md`      | `docs/design/screens/library-overview.visual-contract.md` | Current V1 partial                 | `lib/presentation/features/folders/screens/library_overview_screen.dart`, `lib/presentation/features/folders/widgets/library_overview_body.dart`, `lib/presentation/features/folders/widgets/library_folder_tile.dart` |
| Dashboard        | `/home`     | `docs/system-design/MemoX Design System/ui_kits/mobile/index.html` - `02 · Dashboard`                                       | `docs/wireframes/01-dashboard.md`    | TBD                                                       | Partial / mixed Current and Future | TBD                                                                                                                                                                                                                    |
| Progress         | `/progress` | `docs/system-design/MemoX Design System/ui_kits/mobile/index.html` - `19 · Progress`; `18 · Stats` is legacy reference only | `docs/wireframes/03-progress.md`     | TBD                                                       | Partial / mixed Current and Future | TBD                                                                                                                                                                                                                    |
| Settings         | `/settings` | `docs/system-design/MemoX Design System/ui_kits/mobile/index.html` - `20 · Settings`                                        | `docs/wireframes/04-settings-hub.md` | TBD                                                       | Partial / mixed Current and Future | TBD                                                                                                                                                                                                                    |

## Agent Workflow

1. Find the target screen in this index.
2. Read the listed visual contract when present.
3. Read the listed wireframe and its implementation refs.
4. Read `docs/design/design-token-mapping.md` and `docs/design/component-visual-contract.md`.
5. Implement only elements marked Current, unless the task explicitly promotes a Future item.
6. Run `docs/design/visual-parity-checklist.md` before reporting completion.

## Related

- `docs/system-design/mock-design-doc-mapping.md`
- `docs/system-design/MemoX Design System/README.md`
- `docs/system-design/MemoX Design System/ui_kits/mobile/README.md`
- `docs/ui-ux/ui-ux-contract.md`
- `docs/wireframes/index.md`
