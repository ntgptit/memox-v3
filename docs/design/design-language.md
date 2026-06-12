---
last_updated: 2026-06-13
status: contract
applies_to: every UI task (screens, widgets, dialogs, sheets, copy)
---

# MemoX Design Language — Taste Contract

The judgment rules for decisions the mock does not answer. `shots/` PNGs and `specs/` DOM
specs say *what the screen looks like*; this file says *which way to lean when you must
choose beyond the mock*. Distilled from
`docs/system-design/MemoX Design System/README.md` — read that file for token values and
full rationale. When giving a UI task to an external agent (one that does not read
`CLAUDE.md`), paste this file into the prompt.

## Identity in one paragraph

MemoX is a calm, focused learning tool — studious, grown-up, a little Scandinavian. The
product shell stays quiet so the *cards* are the loudest thing on screen. One accent color
(indigo) does most of the work; green is reserved for the specific feeling of *mastery*.
It talks like a thoughtful study coach, never like a gamified app.

## When in doubt, lean this way

Each rule: the default → the anti-pattern to refuse.

1. **Hierarchy comes from surface tiers, not shadows.** Stack `surfaceContainer` levels;
   shadows cap at 6% opacity. → Never add a drop shadow to make an element "pop".
2. **Cards get a ghost border, nothing more.** 1px at 15% of outlineVariant, flat surface.
   → Never elevation + border together; never a colored card background for emphasis.
3. **One accent at a time.** Primary indigo carries selection, focus, and CTAs. Green only
   ever means mastery/success; orange only streaks; red only errors/destructive.
   → Never decorate with semantic colors; never introduce a second accent on one screen.
4. **Dark mode outlines are faded indigo, never gray.** That is the signature of the
   Tokyo Nebula theme. → Never `Colors.grey`-family dividers or borders in dark mode.
5. **The only gradient in the product is the mastery tri-stop** (coral → amber → green) on
   progress visuals. → Never gradient buttons, headers, or backgrounds.
6. **Motion is quick and even; nothing bounces.** Standard easing, 100–350ms; `elasticOut`
   is a named anti-pattern. → Never bounce, overshoot, or scale-down-on-press (presses are
   state-layer tints only).
7. **Type scale has exactly seven sizes** (48/32/24/20/16/14/12), one family
   (Plus Jakarta Sans). → Never a size in between; never a second family; never faux-bold
   beyond the shipped weights.
8. **Copy is calm, second-person, sentence case.** "All caught up", "You're offline.
   Reconnect to keep syncing." → Never hype ("Awesome job!!"), never ALL-CAPS buttons,
   never exclamation marks outside genuine completion, never "we/I".
9. **No emoji, no unicode glyph icons, anywhere.** Material `Icons.*` at 20/24dp carry all
   glyph meaning. → Never an emoji in UI text, labels, or empty states.
10. **Empty states teach the next action quietly.** Icon (64dp) + one sentence + one CTA.
    → Never a bare "No data"; never an illustration or mascot.
11. **Blur and glass exist in exactly one place:** app bar / bottom nav / sticky chrome at
    84% page-surface opacity. → Never frosted-glass cards, sheets, or dialogs.
12. **Radii are semantic, not decorative.** Cards/dialogs/sheets 16, buttons/inputs 12,
    chips pill, FAB 28. → Never mix radii within one component family on a screen.
13. **No imagery.** Icon-and-typography only; layout does the visual work. → Never stock
    photos, illustrations, or decorative patterns.
14. **Build with the `Mx*` kit first** (`lib/presentation/shared/mx_widgets.dart`); tokens
    are law for color/size/radius/duration/strings. → Never raw hex, raw `Card`, raw
    `TextField`, or a one-off widget when an `Mx*` equivalent exists.

## Escalation

If a mock seems to demand breaking one of these rules, do not improvise: report the
conflict (per `CLAUDE.md` §UI Mock Design Parity) and wait for a decision.
