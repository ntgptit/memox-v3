# Screen 02 — Dashboard — parity plan

Source: `docs/system-design/MemoX Design System/ui_kits/mobile/specs/02-dashboard.md`
+ `.../shots/02-dashboard--*--{light,dark}.png` + `docs/design/screens/dashboard.visual-contract.md`.
FE: `lib/presentation/features/dashboard/screens/dashboard_screen.dart`
+ `lib/presentation/features/dashboard/widgets/dashboard_body.dart`.
Audit: 2026-06-23.

## KEY FINDING — kit 02 is PRE-REDESIGN (scope/redesign-owned divergence)

The kit `02` mock is the **old engagement dashboard**: greeting header, a 4-stat card
(Due / Decks / **Accuracy** / **Streak**), **Continue Studying** + Resume/Discard, a due card, and
**Recent Decks**. The FE is the **redesigned "quiet refer" surface** (`[[design-redesign-ia-2026-06-21]]`,
screen doc, `dashboard.visual-contract.md`): just `MxDueSummary` (due snapshot / caught-up) + two
`MxShortcutRow`s (Progress, Library). **No streak/accuracy/goal** (moved to Progress), no
Continue-Studying, no Recent-Decks, no app-bar search. → the kit-02 engagement layout pixel-match is
**scope/redesign-owned**, NOT a pixel gap. Do NOT rebuild the engagement dashboard to match the kit.

## diff.py baseline (golden ↔ kit shot, tolerance 16, threshold 100)

| State | light | dark |
| --- | --- | --- |
| loaded (FE due-snapshot vs kit engagement) | 11.93% | 21.35% |
| loading | 2.16% | 12.02% |
| caught-up | 11.40% | 18.02% |
| error | 14.96% | 18.43% |

(% is golden-vs-kit but the layouts are intentionally different — redesign; not a parity target.)

## STATE COVERAGE

FE dashboard states (the redesigned surface): **loading** (MxLoadingState), **error** (summary null →
MxErrorState), **content** with **due** (loaded) / **caught-up** variants. Goldens: loaded, loading,
caught-up, error (light+dark) — **FE state coverage complete**.

Kit 02 states with NO FE equivalent (all pre-redesign engagement): multi-resume, no-session, offline,
onboarding, + the engagement `loaded` content (streak/accuracy/continue-studying/recent-decks). These
are **scope/redesign-owned** — the redesign dropped/moved them. NOT addable goldens.

## GAP checklist
1. Kit-02 engagement layout (streak/accuracy/continue-studying/recent-decks/resume/onboarding/offline/
   multi-resume) → **DEFER scope/redesign-owned**: the FE dashboard is the approved redesigned quiet
   surface; engagement lives on Progress (`[[design-redesign-ia-2026-06-21]]`). Source of truth for the
   FE dashboard = `dashboard.visual-contract.md`, not the pre-redesign kit 02.
2. Within the FE design: `MxDueSummary` + `MxShortcutRow` token/typography parity — light diff moderate
   (Ahem); no concrete token divergence surfaced. Per-node INVENTORY low-priority (deferred).

## Status: AUDITED; done (modulo redesign-deferred)
FE state coverage complete; the kit-02 engagement layout is a documented redesign divergence
(scope-owned), tracked in parity-deferred.
