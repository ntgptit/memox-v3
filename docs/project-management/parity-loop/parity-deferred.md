# Parity Loop — Deferred items

One line per deferred item: `date · screen/node · reason · suggestion`.
Valid reasons: no-FE-yet · needs-token · needs-schema · behavior-conflict · spec-stale ·
verify-fail · review-blocker.

- 2026-06-23 · 03 Library / app-bar search icon · behavior-conflict · kit loaded state has only the sort icon; FE adds a search-toggle that mounts the in-screen folder-search dock (approved redesign, `[[design-redesign-ia-2026-06-21]]`). Keep the affordance; visual gap is behavior-owned.
- 2026-06-23 · 03 Library / LibraryRootAnchor row · behavior-conflict · kit loaded state goes app-bar → card with no anchor row; FE adds the breadcrumb-root anchor (approved redesign). Keep; visual gap is nav-owned.
- 2026-06-23 · shared MxEmptyState/MxErrorState/MxNoResultsState inner panel (56px tile, solid-accent empty tile, 22/800 title -0.4) · needs-token · no 56 size token + no 22/800/-0.4 title slot; 13 consumers (dashboard/decks/folders/search/study) need cross-mock audit before restructuring the shared widget. Suggestion: dedicated shared-widget WP — add size+title tokens, verify each consumer mock, mass golden regen.
