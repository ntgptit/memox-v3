---
last_updated: 2026-06-07
status: contract
route: /settings/learning/tags
screen: Tag management
mock_source: "docs/system-design/MemoX Design System/ui_kits/mobile/index.html — 11 · Tag management"
---

# Tag Management Visual Contract

Maps the Tag management mock to the Flutter implementation under
`lib/presentation/features/settings/**`. The route is shell-hidden and lives
under Settings → Learning.

## 1. Screen identity

- **Screen name:** Tag management
- **Route:** `/settings/learning/tags`
- **Feature / module:** `settings`
- **User purpose:** Inspect all tags across decks, search by name, and manage
  tag rename / merge / delete flows.
- **Mock source:** `index.html` `11 · Tag management` (states: loaded · loading ·
  empty · search empty · action sheet · rename · rename-to-merge · merge sheet ·
  delete · busy row · op error).
- **Related business docs:** `docs/business/tags/tag-system.md`,
  `docs/business/navigation/navigation-flow.md`.
- **Related wireframe:** `docs/wireframes/22-settings-tag-management.md`.
- **Existing Flutter implementation files:** `lib/presentation/features/settings/screens/tag_management_screen.dart`,
  `lib/presentation/features/settings/widgets/tag_management_settings_content.dart`,
  `lib/presentation/features/settings/routes/settings_routes.dart`.
- **Scope status:** **Partial** (mock/state-gallery implementation; route wired).

## 2. Notes

- The mock includes study/view actions in the context sheet, but the repo's
  current V1 contract keeps those actions hidden.
- Rename collision / merge / delete states are visualized as screen overlays.
- Search and sorting are presented in the mock UI language, but the route is
  intentionally a non-persistent state gallery in this ref.

