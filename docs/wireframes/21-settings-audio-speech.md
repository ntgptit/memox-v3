---
last_updated: 2026-06-07
route: /settings/audio-speech
source_specs:
  - docs/system-design/MemoX Design System/ui_kits/mobile/index.html
---

# 21 - Settings: Audio & Speech

## Purpose

Audio & speech is the Settings sub-page shown for screen 23 in the mobile UI kit mock. The screen
is a design-system preview of per-language TTS controls: general toggles, Korean/English language
tabs, voice selection, sliders, preview, engine guidance, and a supported-languages note.

## Mock / implementation coverage

| Mock ID | State | Required UI | Actions | Notes |
|---|---|---|---|---|
| 23-loaded | Korean | General section, Korean tab active, Korean voice list, preview card, supported-languages note, auto-save footer | None | Default gallery state |
| 23-english | English | Same structure with English tab active and English voice list | None | Proves tabs are independent |
| 23-loading | Loading | Voice list skeletons instead of voices | None | Preview section hidden |
| 23-empty | No voices | Empty-state card with install guidance and system-speech CTA | Open system speech | Preview section hidden |
| 23-engineErr | Engine error | Error banner above the screen, disabled general/voice/preview surfaces | Open system settings | Tabs stay visible |
| 23-playing | Playing | Preview card shows mastery-colored playing state and bars | Stop preview | Preview label changes |
| 23-saving | Saving | Saved chip in the app bar | None | Uses the same layout as loaded |

## Layout

```
┌───────────────────────────────────────┐
│ ←  Audio & speech               Saved  │
├───────────────────────────────────────┤
│ [Engine unavailable banner]           │
│                                       │
│ GENERAL                               │
│ ┌ Auto-play on reveal   [switch] ───┐ │
│ ├ Play after grading            Soon │ │
│ └────────────────────────────────────┘ │
│                                       │
│ LANGUAGE                              │
│ ┌ [한 Korean]  [EN English] ────────┐ │
│ └────────────────────────────────────┘ │
│                                       │
│ VOICE · Korean / English             │
│ ┌ System default  Default   Preview  │ │
│ │ Suji / Emma                      ▶  │ │
│ │ ...loading / empty / error states  │ │
│ └────────────────────────────────────┘ │
│                                       │
│ PREVIEW                               │
│ ┌ sample text                        ┐ │
│ │ sample hint (Korean only)          │ │
│ │ [Preview voice / Playing bars]     │ │
│ └────────────────────────────────────┘ │
│                                       │
│ ABOUT SUPPORTED LANGUAGES             │
│ ┌ MemoX currently speaks Korean...   │ │
│ └────────────────────────────────────┘ │
│ Changes save automatically.           │
└───────────────────────────────────────┘
```

## Actions

| Action | Trigger | Result |
|---|---|---|
| Toggle Auto-play on reveal | Tap switch | Preview-only toggle in the mock screen |
| Tap Korean / English tab | Tap tab | Switches the visible gallery state |
| Tap voice row preview | Tap speaker button | Shows the preview affordance in the mock only |
| Tap system-speech / system-settings CTA | Tap button | Opens the OS settings path in the mock contract |
| Tap preview voice button | Tap | Changes to playing state in the mock contract |

## States

| State | Trigger | Behavior |
|---|---|---|
| Korean | Default mock state | Shows Korean voices, Korean sample, Korean tab active |
| English | Gallery state | Shows English voices and English tab active |
| Loading | Voice list fetch | Shows skeleton rows only |
| No voices | Platform reports no voices | Shows install guidance and CTA |
| Engine error | TTS engine unavailable | Shows banner and dims the rest of the controls |
| Playing | Preview in progress | Shows mastery-colored preview bar and voice bars |
| Saving | Auto-save in progress | Shows saved chip in the app bar |

## Accessibility

- Keep the language tabs and preview CTA at touch-target sizes that match MemoX button density.
- Use semantic labels for the speaker and system-settings actions.
- The loading state should remain readable on narrow phones with no horizontal overflow.

## Navigation

- Settings hub → Audio & speech.
- Back → Settings hub.

## Notes

- The screen is a mock/gallery surface, not a schema or migration change.
- Voice names and sample phrases are localized in ARB to keep the mock copy consistent with the app.
