The signature MemoX memo tile — a tinted left bar, folder eyebrow, title, 2-line preview, and tag badges. Use it anywhere notes are listed.

```jsx
<NoteCard
  title="Q3 launch checklist"
  folder="Work"
  time="9:24"
  color="var(--memox-note-amber)"
  pinned
  body="Finalize copy, ship the changelog, schedule the announce thread."
  tags={['launch','todo']}
/>
```

Pick `color` from the `--memox-note-*` palette to color-code spaces. Composes `Badge` for tags.
