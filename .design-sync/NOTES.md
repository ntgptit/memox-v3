# design-sync notes — MemoX

## Shape: off-script (format-3 bundle)
The design system at `docs/system-design/MemoX Design System/` is a hand-maintained
bundle already in claude.ai/design upload layout (format-3 + `_ds_manifest.json`),
NOT produced by the /design-sync converter. There is no React package / Storybook to
build — this repo is Flutter. So the converter (`package-build.mjs`) does not apply;
syncs upload the existing artifacts directly.

## Target project
- Project: **MemoX Design System v3** (`c83bf9df-9f34-4480-8351-3acbaa1e3246`)
- Created 2026-06-24, first push was this run.
- NOTE: two other projects named "MemoX Design System" exist in the account
  (`ddee88dc-…`, `48ad9c4b-…`). The bundle namespace is `DesignSystem_48ad9c`, which
  matches `48ad9c4b-…` — that is likely the original export source. Owner chose to push
  to a fresh, separately-named project instead of updating either existing one.

## Upload set (77 files)
Uploaded: `_ds_bundle.js`, `_ds_manifest.json`, `styles.css` + import closure
(`colors_and_type.css`, `memox-components.css`), `README.md`, `components/**`,
`guidelines/**`, `ui_kits/mobile/index*.html`, `ui_kits/mobile/screens/**`,
`tools/check-ui-kit.js`, plus a `_ds_needs_recompile` marker.

Excluded (repo-only, not consumed by the Claude Design app):
- `ui_kits/mobile/shots/**` (~280 golden reference PNGs — repo parity tooling)
- `ui_kits/mobile/specs/**` (DOM specs — repo parity tooling)
- `scraps/`, `screenshots/`, `uploads/`, `run.cmd`, `SKILL.md`, `CLAUDE.md`,
  `.thumbnail`, `_adherence.oxlintrc.json`

## No sync anchor
No `_ds_sync.json` is produced (the format-3 recipe isn't the converter's). This is the
honest choice for an off-script layout: the next sync re-verifies/re-uploads everything.
If incremental re-syncs become desirable, convert to the converter's anchored layout
(`_vendor/`, `_preview/`, per-component dirs, `_ds_sync.json`).
