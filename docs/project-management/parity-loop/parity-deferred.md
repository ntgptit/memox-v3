# Parity Loop — Deferred items

One line per deferred item: `date · screen/node · reason · suggestion`.
Valid reasons: no-FE-yet · needs-token · needs-schema · behavior-conflict · spec-stale ·
verify-fail · review-blocker.

- 2026-06-23 · 03 Library / app-bar search icon · behavior-conflict · kit loaded state has only the sort icon; FE adds a search-toggle that mounts the in-screen folder-search dock (approved redesign, `[[design-redesign-ia-2026-06-21]]`). Keep the affordance; visual gap is behavior-owned.
- 2026-06-23 · 03 Library / LibraryRootAnchor row · behavior-conflict · kit loaded state goes app-bar → card with no anchor row; FE adds the breadcrumb-root anchor (approved redesign). Keep; visual gap is nav-owned.
