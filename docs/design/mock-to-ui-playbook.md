---
last_updated: 2026-06-14
status: playbook
applies_to: building/refining a screen from kit mock images (AI agents)
---

# Mock → UI Playbook (operating procedure)

Step-by-step runbook for turning a kit mock (the `shots/` PNGs) into a shipped
MemoX screen **without skipping steps**. It complements — does not replace:

- `docs/design/mock-design-index.md` — *where* the canonical mock lives.
- `docs/design/visual-parity-checklist.md` — *what* to verify before "done".
- `CLAUDE.md` §UI Mock Design Parity — the hard contract.

This file is the *how*, distilled from the Card History (kit screen 09) build.
Each phase lists the action **and the traps that actually bit us** so the next
agent does not repeat them. Work the phases in order; do not jump to coding.

> Golden rule: the **kit is the visual source of truth**; `docs/business/**` is
> the behavior source of truth. When they disagree, **stop and reconcile in the
> same change** — never silently pick one (see Phase 2).

---

## Phase 0 — Resolve the mock reference (all of it)

1. Find the screen in `docs/system-design/MemoX Design System/ui_kits/mobile/shots/INDEX.md`.
2. Read **every state row** for that screen, **both light and dark** PNGs — not
   just the "loaded" one. The kit ships N states per screen; a state that exists
   in `shots/INDEX.md` but is missing from your plan is a **parity failure**.
3. Open the measured DOM spec
   `docs/system-design/MemoX Design System/ui_kits/mobile/specs/<screen>.md` for
   exact bounding boxes, spacing, token names, copy, and per-state add/remove
   deltas. Agents without strong vision rely on this; agents *with* vision still
   use it for exact numbers/tokens.

> **Trap — "loaded" tunnel vision.** Card History ships **5 states** (Loaded,
> Empty, Loading, Error, Partial). The first pass only built Loaded+Empty and
> missed Partial entirely. Always enumerate states from `shots/INDEX.md` first.
>
> **Trap — reading `index.html`.** Do NOT derive the design from the kit's
> `index.html` JSX. Use it only for exact copy / control order via the line
> index in the kit `README.md`.
>
> **Trap — the mock's sample data is not the contract.** The kit drew "Box 3 / 5";
> MemoX SRS is 8 boxes (`docs/business/srs/srs-review.md`). Render `/8`. Treat
> kit numbers/labels as illustrative, the *system contract* as truth.

## Phase 1 — Read the mock like an inventory, build a mapping table

Before any code, write a row per **visible element AND per state**:

| Mock element / state | Source PNG/spec | Code target | In scope? | Notes |
|---|---|---|---|---|

- Mark each element `Current` / `Future` / `Rejected` / `Missing data` /
  `Visual-only` / `Conflict`. No element may be left unmapped.
- The mock is often **richer than it looks**. Card History's timeline was not an
  attempts list — it was a **mixed activity feed** (attempts + created/edited/
  reset/audio events + a "Beginning of history" sentinel + a filter pill +
  per-row duration). Each of those is a separate element that needs a row.

## Phase 2 — Classify every element by data availability (decide before coding)

For each mapped element decide **where its data comes from**, and bucket it:

- **(A) Sourceable now** — exists in the current read model / schema. Build it.
- **(B) Blocked by data model** — needs a schema change or a feature that does
  not exist. Either get approval for the migration, or mark the element a
  documented gap. Do **not** fake it.
- **(C) Blocked by a doc conflict** — the kit shows behavior the business doc
  forbids (or vice-versa). **Stop and reconcile**: update `docs/business/**` +
  the kit understanding in the same change once the user confirms the direction.

> **Card History examples:**
> - Recall rate / Reviews / Lapses / box stepper → **(A)** from `flashcard_progress`.
> - Correct streak, Since added, event count → **(A)** but *derived* (compute in
>   the repo from attempts / `created_at`; never scan attempts for accuracy —
>   use stored counters).
> - Per-row **duration** ("1.4s") → **(B)**: needed `study_attempts.duration_ms`
>   (added v7) + capture in the study viewmodel.
> - **Edited / Audio-added** lifecycle rows → **(B)**: needed a `card_events`
>   table (added v7). Audio has no capture feature yet → kind defined but **not
>   emitted** (documented gap).
> - Mixed activity feed vs. "attempts-only" business doc → **(C)**: the doc was
>   rewritten to the feed once the user chose "full activity feed".

If a bucket-(B)/(C) decision is non-trivial, **ask the user** before building.

## Phase 3 — Schema & backend (if Phase 2 needs it)

- One migration per change: bump `AppDatabase.currentSchemaVersion`, add an
  `onUpgrade` step, write a **legacy-DB migration test** (see
  `docs/database/migration-contract.md`). Update `docs/database/schema-contract.md`
  (frontmatter `schema_version` + table area) in the same change.
- Keep the read path clean: `.drift` query → DAO → repository (`Result<T>`, not
  thrown) → use case → provider. Domain must not import data.

> **Trap — migration tests cross all newer steps.** Re-opening `AppDatabase`
> runs every `onUpgrade` step. A v6 migration test whose legacy DB omitted the
> study tables broke when v7's `addColumn(studyAttempts, …)` ran. A legacy test
> DB must contain every table a *later* migration will ALTER.
> Also: bump the `schemaVersion` assertion in older migration tests.

## Phase 4 — Build the screen on the shared shell (layout traps live here)

The page shell is `MxScaffold` / `MxListScaffold` / `MxFormScaffold` /
`MxStudyScaffold`. They already provide the gutter; you provide content.

> **Trap — double gutter (guard-enforced).** `MxScaffold` already wraps `body`
> in `MxContentShell` (the horizontal gutter + max-width cap). Wrapping feature
> content in `MxContentShell` **again** double-insets the screen vs. every other
> screen. Add only *vertical* spacing in the body. Enforced by
> `memox.screen_shell.no_redundant_content_shell`; the only exception is
> `MxScaffold(useShell: false)` with `// guard:allow-content-shell -- reason: …`.
>
> **Trap — unified scroll + per-state slivers.** When header + sections + a list
> must scroll together AND loading/empty/error must fill the screen, use one
> `CustomScrollView`: header parts as `SliverToBoxAdapter`, the list as
> `SliverList`, and loading/empty/error as `SliverFillRemaining`. A "fixed top +
> `Expanded(list)`" layout squeezes the empty/error state on short screens
> (it overflowed by 144px in the 600px test window).
>
> **Trap — `IntrinsicHeight` + flexible rows overflow.** A timeline row that put
> a chip, `Spacer()`, and a time column in a `Row` overflowed horizontally on
> narrow widths. Give the shrinkable side `Expanded`/`Flexible` + `maxLines: 1` +
> `TextOverflow.ellipsis`; flip arrow direction instead of letting text grow.
>
> **Trap — text-over-a-line dividers.** A label-in-the-middle-of-a-rule divider
> built as `Row[Expanded(rule), Text, Expanded(rule)]` overflows when the label
> is long. Use a `Stack` (full-width rule + a `ColoredBox` label on top).

## Phase 5 — Design-system compliance (every guard rule that bit us)

Run the guard early; it encodes the design system. The rules that caught
Card History, with the fix:

| Guard rule | What it forbids | Do instead |
|---|---|---|
| `memox.screen_shell.no_redundant_content_shell` | extra `MxContentShell` in feature code | let the scaffold own the gutter |
| `memox.screen_shell.no_manual_page_gutter` | `ListView`/`SingleChildScrollView` body `padding: EdgeInsets…` in a screen file | put scrollables/padding in a `widgets/` file or use the shell |
| `memox.design_system.no_raw_divider` | raw `Divider`/`VerticalDivider` | a token-coloured `Container(height: …)` hairline |
| `flutter.no_hardcoded_color` | `Colors.*` / `Color(…)` (incl. `Colors.transparent`) | `ColorScheme` / `context.customColors`; omit the widget instead of a transparent one |
| `memox.coding.string_normalization_via_string_utils` | `.toUpperCase()` / `.toLowerCase()` | `StringUtils.uppercased(…)` |
| `memox.state_management.use_app_async_builder` | `AsyncValue.when(…)` on UI | `MxRetainedAsyncState`, or branch on `.value`/`.hasError` (no `.when`) when you need slivers |
| `memox.ui_async_guard.no_compound_mounted_check` | `if (!confirmed || !context.mounted)` | split: `if (!confirmed) return;` then `if (!context.mounted) return;` |

- **Tokens:** semantic accents live on `context.customColors` (`streak` = amber,
  `mastery` = green), not `colorScheme.tertiary` guesses. Spacing/opacity/radius
  via `SpacingTokens` / `OpacityTokens` / `RadiusTokens` — no magic numbers.
- **Reuse first:** `MxCard`, `MxText`, `MxEmptyState`, `MxErrorState`,
  `MxLoadingState`, `MxActionButton`, `MxBreadcrumb`, `MxBottomSheet`. Build a new
  shared widget only on real repetition.

## Phase 6 — Localization

- New copy → `lib/l10n/app_en.arb` **and** `lib/l10n/app_vi.arb` (append at end;
  both files; `verify` runs `gen-l10n` when ARB changed).
- **Remove keys you superseded** — unused keys raise `doc_guard` warnings. When a
  redesign drops a label, delete the key from both ARB files.
- Never hardcode user-facing strings; never call `toUpperCase()` on copy
  (uppercase in the widget via `StringUtils`, keep ARB title-case).

## Phase 7 — Tests (one per kit state + behavior)

Cover every kit state from Phase 0: loading, loaded (+ ordering), empty, error,
not-found, and any partial/variant. Plus navigation + entry route + invalid id.

**Add a golden test per state** (`matchesGoldenFile`, light + dark, on a
390×780 surface — see `test/presentation/features/progress/progress_screen_golden_test.dart`
and the pilot `test/presentation/features/folders/library_search_field_golden_test.dart`).
`flutter analyze` / unit tests / the guard are blind to spacing, padding, and
alignment; a golden is the only gate that catches "the keycap hugs the border"
class of drift without a human eyeballing the mock. Regenerate intentionally with
`node tool/verify/run.mjs --update-goldens --test <paths>`; never `--update` to
silence an unexplained diff. Prefer pushing layout invariants into the shared
component (e.g. `MxSearchField` owns its trailing inset) + a geometry contract
test, so the whole class is unrepresentable rather than re-checked per screen.
Golden covers the **static-visual** class only; for overflow / large-font /
behaviour / data / a11y bugs, choose the prevention + gate from the bug-class map
in `CLAUDE.md` §UI Mock Design Parity ("Catch the bug CLASS, not the instance").

> **Trap — tall screens need a real surface.** `SliverFillRemaining` empty/error
> states get squeezed in the default 800×600 test window. Set
> `tester.view.physicalSize`/`devicePixelRatio` to a device size and
> `addTearDown(tester.view.reset)`.
>
> **Trap — `import 'package:drift/drift.dart' hide isNull;`** in DB tests — drift
> and `matcher` both export `isNull`.
>
> **Trap — `record…` repository fakes.** Adding a param to a port (e.g.
> `durationMs`) breaks every test `_Fake…Repository` override — update them all.

## Phase 8 — Docs / WBS parity (same change)

- Update the wireframe (`docs/wireframes/<n>-*.md`): Components, States (map all
  kit states), Data-to-load, Forbidden, Code-paths.
- Update the business doc + `docs/contracts/usecase-contracts/<x>.md` if behavior
  changed; resolve any Phase-2 (C) conflict here.
- `docs/decision-tables/memox-core-decision-table.md`: a row per testable branch,
  with a **real** `path::marker` test ref (the marker substring must exist in the
  test). Promote any Future/Blocked rows you implemented.
- `docs/project-management/wbs.md`: flip the matching row to `Implemented` only
  with source + tests; append the §10 Commit Traceability line (newest first)
  after the commit hash is known (commit, then a small docs commit with the hash).
- Regenerate the index: `node tool/doc_guard/run.mjs generate`.

> **Trap — editing the decision table re-surfaces baselined phantom test refs.**
> `doc_guard` is line/section-keyed; editing the H/N rows can un-baseline old
> phantom refs elsewhere in the table. Fix what's yours; for pre-existing debt run
> `node tool/doc_guard/run.mjs check --update-baseline` and confirm the diff only
> re-adds known phantoms.

## Phase 9 — Verify (single entry) & commit

- One entry only: `node tool/verify/run.mjs` (`--quick [--test <paths>]` inner
  loop; `--test <paths>` / `--code` / `--full` at the end → writes the pass
  marker). Standalone `flutter analyze/test`, `dart fix/format`, `build_runner`,
  `doc_guard`, guard do **not** write the marker, so the pre-commit hook rejects
  the commit. Re-run after any edit (the marker is content-bound).
- After `dart fix`/`format`: inspect the diff, keep only task changes.
- The guard tool is the **vendored nested repo** `code-verification-guard/`
  (gitignored by the app repo; remote `code-verification-guard-v2`). New/changed
  **rules are committed/pushed from inside that directory**, not the app repo.

## Phase 10 — Recursive review against the mock

Re-open every `shots/` PNG (both themes, all states) next to the running screen.
A screen is done only when it passes **behavior + visual** parity. Any remaining
visual gap must be listed with a reason: Missing data / Future / Rejected /
Token-or-component missing / Mock-doc conflict (see
`docs/design/visual-parity-checklist.md`).

---

## One-screen quick checklist

- [ ] All states enumerated from `shots/INDEX.md` (light + dark).
- [ ] Every visible element mapped + bucketed A/B/C (Phase 1–2).
- [ ] Schema/BE done with migration + test + schema docs (if Phase 2 needed it).
- [ ] Built on the shared shell; **no second `MxContentShell`**; one scroll;
      states via `SliverFillRemaining`.
- [ ] Tokens + shared widgets only; guard passes (no raw color/divider/`.when`/
      `toUpperCase`/compound-mounted).
- [ ] ARB en+vi updated; superseded keys removed.
- [ ] Tests per state + nav, on a device-sized surface.
- [ ] Wireframe + business + decision table + WBS (+§10) updated same change.
- [ ] `node tool/verify/run.mjs --test <paths>` PASS (marker written).
- [ ] Recursive visual review vs PNGs; remaining gaps listed with reasons.
