---
last_updated: 2026-06-05
status: checklist
applies_to: UI mock-to-code implementation
---

# Visual Parity Checklist

Use this checklist before marking a UI implementation task complete. It does
not replace `docs/checklist/implementation-checklist.md`; it adds visual parity
checks for mock-driven screen work.

## Structure

- Every visible mock element is mapped in the screen visual contract or task notes.
- Every unmapped element has a reason: Future, Rejected, Missing data, Visual-only, Unknown, or Conflict.
- Current, Future, Rejected, and Unknown elements are not mixed in production UI.
- No unsupported behavior was added to make a mock look active.
- No mock-only route, schema field, provider state, or action was invented.

## Layout

- Header/app bar matches the approved scope and visual hierarchy.
- Search/filter/sort controls match approved behavior, not only mock appearance.
- Section order matches the visual contract.
- Screen padding, list spacing, and section gaps use design tokens or shared shell defaults.
- Cards use the correct surface, density, icon placement, metadata hierarchy, and trailing action.
- Bottom navigation matches the shared component and route behavior.
- FAB style, label, position, and prominence match the approved scope.
- Narrow mobile layout has no overflow or clipped text.

## States

- Loading state uses skeletons where the contract requires them.
- Loaded state renders the required content and hides unsupported controls.
- True empty state is distinct from search no-results.
- Search no-results state has a clear recovery action when applicable.
- Error state uses localized copy and a retry path.
- Disabled visual-only controls are clearly non-interactive and do not expose fake behavior.
- Overlay/sheet/dialog states use approved shared patterns and documented actions only.

## Component Details

- Icons match the mock intent or have a documented replacement.
- Badges/chips only appear when backed by current data.
- Due/new/progress/mastery indicators are not faked.
- Row/card actions have visible affordances and accessible labels.
- Destructive actions use confirmation dialogs where required.
- Long-press-only actions have a tap alternative when accessibility requires it.

## Design System

- No raw hex colors in feature widgets.
- No random spacing, radius, duration, opacity, or typography values in feature widgets.
- Existing shared components are used first.
- `MxText` or theme typography is used for role-based text.
- ARB/l10n is used for all user-facing copy.
- Light and dark themes remain readable.

## Validation

- Run the related widget tests for loaded, loading, empty, error, search/no-results, and key actions.
- Run `flutter analyze` and targeted tests for UI code changes.
- Run `python code-verification-guard/guard/run.py check --project . --ruleset memox` when the guard is present.
- For docs-only visual-contract changes, run markdown path/reference checks and `git diff --check`.

## Reporting

Final reports for UI mock work must include:

- Mock elements mapped.
- Visual gaps fixed.
- Remaining visual gaps and reasons.
- Behavior intentionally unchanged.
- Verification commands run or explicitly skipped with reason.

## Related

- `docs/checklist/implementation-checklist.md`
- `docs/design/mock-design-index.md`
- `docs/design/design-token-mapping.md`
- `docs/design/component-visual-contract.md`
