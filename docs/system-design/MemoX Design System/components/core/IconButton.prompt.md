Icon-only square button for toolbars, list rows, and headers — always pass `label` for accessibility.

```jsx
<IconButton icon="search" label="Search" />
<IconButton icon="bold" active label="Bold" />
<IconButton icon="plus" variant="accent" label="New" />
<IconButton icon="more-horizontal" variant="surface" label="More" />
```

Variants: `ghost`, `surface`, `accent`. `active` applies the accent-soft selected state (used for formatting toggles).
