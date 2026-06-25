# Overnight FE-sync loop — log

Autonomous loop (branch `feat/overnight-fe-sync`, not pushed). One screen per
iteration: bring the Flutter FE into sync with the latest kit specs, gate-driven.
Each entry the owner should review before merging.

## Synced

| # | Screen | Commit | What | Note |
| --- | --- | --- | --- | --- |
| 1 | 03-library-overview | 8756363 | binding-contract test | FE already realized kit components (lock-in). |
| 2 | 04-folder-detail | 6ddb440 | binding-contract test | both content modes; FE already correct. |
| 3 | 06-flashcard-list | 4bd8717 | binding-contract test | ⚠ see decision below (search-dock alias). |
| 4 | 20-settings | 3a2c8e3 | binding-contract test | account-card → MxCard; FE already correct. |
| 5 | 21-account-sync | adeec33 | binding-contract test | signin-card → MxCard, signin-button → MxPrimaryButton; FE already correct. |
| 6 | 09-flashcard-history | 3ed00ea | binding-contract test | header → MxCard; FE already correct. |
| 7 | 23-audio-speech | 5f4a844 | binding-contract test | preview-card → MxCard, preview-button → MxSecondaryButton; FE already correct. |
| 8 | 17-study-result | a87fa79 | binding-contract test | done-button → MxPrimaryButton, close-btn → MxIconButton; FE already correct. |
| 9 | 11-tag-management | 51b30f0 | binding-contract test | search-dock → MxScopedSearchDock (scoped variant, aliased — same as 06). |
| 10 | 05-library-search | 006110c | binding-contract test | search-dock → MxSearchDock (global dock, no alias); FE already correct. |
| 11 | 10-deck-import | bdf46d3 | binding-contract test | empty-card/file-chip/result-card → MxCard, choose-file → MxPrimaryButton (per-state); FE already correct. |
| 12 | search-dock (D1) | 669b33c | centralize scoped-dock realization | resolved decision 1 — see below. |
| 13 | 18-stats (D2) | (this commit) | build MxSectionHeader + binding test | resolved decision 2 — see below. |

## Decisions — RESOLVED (2026-06-26)

- **D1 · scoped search-dock (06 + 11) — RESOLVED (commit 669b33c).** Investigation
  confirmed the kit correctly has ONE `SearchDock` primitive (05/06/11 all use it) —
  scoped-ness is an FE concern, not a visual one — so adding a kit "scoped class"
  would wrongly push an FE detail into the visual kit. Instead the accepted variant
  is centralized in the binding helper's `_bindingRealizations` map (`MxSearchDock →
  {MxSearchDock, MxScopedSearchDock}`); the per-test aliases on 06/11 were removed.
  The assertion stays strong (a raw widget still fails); 05 keeps the global dock.
  One reviewed place instead of scattered aliases.

- **D2 · MxSectionHeader gap — RESOLVED (this commit).** Only one keyed node needed
  it (`18-stats/mastery-section`). Built `MxSectionHeader`
  (`lib/presentation/shared/widgets/mx_section_header.dart`): a row with the title in
  `MxTextRole.titleMedium` (the kit's 16px section role) + an optional trailing slot
  (kit `flex:row justify:between`). 18-stats renders the mastery header through it
  (zero visual change — same MxText inside), gained its binding test, and
  `MxSectionHeader` was dropped from `symbol-aliases.json` componentGaps (now
  resolves to a real class for all 7 referencing specs). Other screens' (unkeyed)
  section headers can migrate to it incrementally.

## Skipped — no binding test (intentional, not a defect)

These screens have a parity test (presence is covered) but their kit nodes carry
**no concrete component** in the binding contract (all `component: null` — content
containers / rows / sections only), so a binding-contract test would assert nothing.
Per the loop's rule, no empty test was added:

- **flashcard-editor** (create + edit) — form fields only, no kit component nodes.
- **25-language** — selectable list rows only, no kit component nodes.
- **24-appearance** — theme-list only (content container, null component).
- **dashboard** — its parity test keys nodes without a screen-id-prefixed binding
  entry; covered by its own parity test (PR #-engagement). Revisit if its binding
  contract gains concrete components.

18-stats is now DONE (D2 above) — `MxSectionHeader` was built, so its
`mastery-section` node has a binding test.

## Final summary (loop ended)

Branch `feat/overnight-fe-sync`, 11 commits, NOT pushed — review + merge to main.

**Outcome:** every built screen with a concrete kit-component binding now has an
enforced **binding-contract test** (`expectGeneratedBindingContract`) that fails if
the FE keeps a node's `ValueKey` but swaps in the wrong widget (a design-system
bypass the presence contract can't catch). 11 screens locked in:
03-library, 04-folder-detail, 06-flashcard-list, 20-settings, 21-account-sync,
09-flashcard-history, 23-audio-speech, 17-study-result, 11-tag-management,
05-library-search, 10-deck-import. All FEs already realized the kit components —
this run found **zero raw bypasses** and surfaced **two intentional scoped-dock
variants** (06, 11) for confirmation. Remaining screens are all-null (nothing to
assert) or owner-decision (MxSectionHeader gap). The binding contract is wired into
`tool/verify/run.mjs`, so these stay enforced on every future change.

## Visual parity — the honest layer (2026-06-26)

The binding-contract rollout above proves component **TYPE** (right `Mx*` widget at
each node). It does **NOT** prove the screens **look** like the mock. Separate work:

**Step 1 — golden harness fixed (commit 10daa06).** Goldens rendered every `Icon`
as the missing-glyph box (MaterialIcons wasn't loaded). Fixed: the harness now loads
the full MaterialIcons font; all 220 goldens regenerated with real icons. The
goldens are now *honest* — a fair basis for golden-vs-shot review.

**Key finding — whole-frame SSIM is NOT the matching verdict.** Re-reading SSIM
after the icon fix (and again after real visual fixes) barely moved the numbers.
Two reasons: (a) SSIM is whole-frame/coarse — small but important details (icons,
button fills, title size) are a tiny pixel fraction; (b) it conflates **test-seed
data** (the golden's minimal fixture) with **the mock's designed sample content** —
they differ by CONTENT, so a perfect FE still won't SSIM-match. SSIM is a coarse
smoke signal only. The real verdict is an **expert visual review**
(`ui-parity-checker`) that ignores data differences and judges layout/styling/
treatment fidelity.

**Step 3 — per-screen ui-parity-checker (in progress).** First screen reviewed:
**23-audio-speech**. Real gaps found + FIXED so far:
- **MxAppBar title 22px/600 → 24px/700** (was `headlineMedium`, spec says `font:24/700`
  on every screen → `headlineLarge`). SYSTEMIC — improves the app-bar on **every**
  screen (shared-layer fix).
- **23 "Play sample" button outlined → tonal** (spec preview-button = `accentSoft`
  fill, no border).
- Correctly classified as NON-gaps (not FE bugs): voice subtitle `ko-KR` vs designed
  `Female · Neural` (read-model has no gender/quality), the `System default` row,
  speed/pitch fixture values — all test-seed/read-model differences.

**Remaining (real, not yet done):** 23-audio-speech still has gaps (hero card not
vertically centered on no-voices/engine-error; hero icon-tile 40→56px; hero title
role; busy-overlay spinner 20→24px; overline tracking/caps; missing loading golden).
And ~18 other screens have not had a ui-parity-checker pass yet. This is the real
"match the mock" backlog — to be worked per-screen with honest goldens, fixing
category-1 gaps and locking each with golden-per-state tests.
