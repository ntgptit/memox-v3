# Screen 07/08 — Flashcard editor (create / edit) — parity plan

Source: `docs/system-design/MemoX Design System/ui_kits/mobile/specs/07-flashcard-create.md`
+ `08-flashcard-edit.md` + `.../shots/0{7,8}-*--{light,dark}.png`.
FE: `lib/presentation/features/decks/screens/flashcard_editor_screen.dart`
+ `lib/presentation/features/decks/widgets/flashcard_editor_body.dart` (one shared `FlashcardEditorForm`).
Audit: 2026-06-23.

## diff.py baseline (golden ↔ kit shot, tolerance 16, threshold 100)

| Golden | Kit shot | light | dark |
| --- | --- | --- | --- |
| create-empty | 07 empty | 7.51% | 13.91% |
| details-open | 07 details-open | 12.47% | **27.58%** |
| saving | 07 saving | 7.17% | 13.22% |
| save-failed | 07 save-failed | 10.34% | 17.75% |
| edit-loaded | 08 loaded | 9.12% | 16.13% |
| loading | 08 loading | 2.39% | 18.60% |
| load-error | 08 load-error | 10.98% | 12.64% |

**Pattern: dark ≈ 2× light across the editor** → a systematic dark-mode divergence (most states),
not per-state. Likely `MxTextField` fill / border or the scaffold body bg token in dark mode differs
from the kit's dark field surface. **← primary WP candidate (shared MxTextField dark parity).**

## STATE COVERAGE

07 create (6 kit states): empty ✓(create-empty) · valid ✗(no golden) · details-open ✓ · validation
✗(no golden) · saving ✓ · save-failed ✓.
08 edit (7 kit states): loaded ✓(edit-loaded) · loading ✓ · load-error ✓ · validation ✗(no golden) ·
saving ✓(shared) · save-failed ✓(shared) · delete ✓(shared `mx_confirm-destructive`).

Missing goldens: **07 valid** (filled form, Save enabled), **07/08 validation** (field error states).
Note: the form is one shared `FlashcardEditorForm`; create vs edit differ by leading (X vs back) +
delete action + title + initial text.

## INVENTORY — Create base (empty)

| Node (spec) | mx / token | FE widget | Divergence | Scope |
| --- | --- | --- | --- | --- |
| appbar leading | MxIconButton (X create / back edit) | `MxAppBar leading` | ✓ | Current |
| appbar-title "New card"/"Edit card" | 24/700 | `MxAppBar title` | verify | Current |
| appbar delete (edit only) | MxIconButton trash | `if (_isEdit)` delete action | ✓ | Current |
| appbar Save | accent pill, check icon | `MxPrimaryButton size:xsmall loading` | verify pill size/disabled state | Current |
| breadcrumb | row, crumbs + chevron16 | `MxBreadcrumb` | verify | Current |
| FRONT label + field | label overline + MxTextField | `MxTextField labelText` | verify field fill/border (esp DARK) | Current |
| BACK label + field | MxTextField | `MxTextField` | verify (DARK) | Current |
| Details expander | chevron/expand_more + "Details" + Optional/summary | `MxTappable` row | verify glyph + trailing label | Current |
| (Details open) DECK selector | icon-tile + deck name + chevron | — | **MISSING — Future** (deck retargeting, `flashcard-management.md` §V1) → behavior-owned | Future |
| (Details open) TAGS | `#`chips + Add tag | `_TagEditor` | verify chip style | Current |
| (Details open) NOTE field | single field "Add a hint, mnemonic or example…" | example/pronunciation/hint (3 fields) | **kit 1 Note → FE 3 fields** (business model: example/pronunciation/hint) → data-owned | Current |
| save-failed banner | danger-tonal strip + alert + Retry | `_SaveErrorBanner` | verify | Current |

## GAP checklist (ordered)

1. **Dark-mode divergence** — INVESTIGATED (2026-06-23). Two findings: (a) the dark ≈2× light pattern is
   NOT editor-specific — dark runs higher than light on EVERY screen (general Ahem light-on-dark + dark
   surface deltas), so it's golden-rendering amplification, not an editor bug; (b) a REAL token gap: kit
   field fill is `accent-contrast` (= `colors.surface`, MxCard's surface), but `MxTextField` uses
   `colors.surfaceMuted`. Fix = `fillColor: colors.surface`. DEFERRED app-wide-coordinated: MxTextField
   feeds editor + 3 dialogs + MxSearchField (all search docks) + study fill + shared mx_inputs goldens
   (~20 goldens) — needs a dedicated WP regenerating every field golden in one pass (parity-deferred).
2. **Missing goldens** — ✅ 07 valid DONE (2026-06-23): added `create-valid` golden (light+dark) — filled
   create form, Save enabled (7.87%/13.62%). 07/08 **validation** = behavior-owned: the FE has NO inline
   field-error UI — it DISABLES Save when front/back empty (`canSubmit` gate), so the "validation" visual
   ≈ create-empty (no distinct render). Keep disable-Save behavior; no separate golden. (validation is
   validation/behavior per precedence rule 2.)

## Screen 07/08 status: DONE (modulo deferred)

All states covered: 07 empty/valid/details-open/saving/save-failed + 08 loaded/loading/load-error/
saving/save-failed + delete (shared mx_confirm-destructive). validation = behavior-owned (disable-Save,
no inline errors). Remaining deferred:
- MxTextField field-fill (accent-contrast vs surfaceMuted) — app-wide-coordinated (parity-deferred).
- Details DECK selector — Future (deck retargeting). Note→3 fields — business model.
- dark≈2× = general Ahem-on-dark amplification (not a bug).
3. **Save pill**: verify size/enabled+disabled (soft vs solid) match kit; the details-open golden seeds
   an empty form (Save disabled/soft) while the kit shows a filled form (Save solid) — consider a
   filled fixture for the details-open golden so it matches the kit scenario.

## Behavior / data-owned (do NOT "fix" to kit — documented)
- **DECK selector** inside Details — kit shows it; FE omits it. Deck retargeting is Future
  (`flashcard-management.md` §V1; FE comment). behavior-owned → defer.
- **Note → 3 fields** — kit shows one "Note"; FE renders example/pronunciation/hint (business model).
  data-owned → keep 3 fields, visual gap noted.
- Editor copy (labels/hints) from ARB; kit copy illustrative.
