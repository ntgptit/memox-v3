Pill-shaped primary action button for MemoX — use for any tap-to-act control; reach for `variant="ghost"` for low-emphasis and `soft` for tinted secondary actions.

```jsx
<Button variant="primary" icon="plus">New note</Button>
<Button variant="secondary" size="sm">Cancel</Button>
<Button variant="soft" iconRight="arrow-right">Continue</Button>
<Button variant="danger" icon="trash-2">Delete</Button>
<Button variant="ghost" disabled>Saved</Button>
```

Variants: `primary` (accent fill + glow), `secondary` (surface + border), `ghost` (transparent), `soft` (accent-soft tint), `danger`. Sizes: `sm` / `md` / `lg`. Props: `icon`, `iconRight` (Lucide names), `full` (100% width), `disabled`. Icons require `lucide.createIcons()` to run after mount.
