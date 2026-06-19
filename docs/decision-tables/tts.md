---
last_updated: 2026-06-19
source: split from memox-core-decision-table.md
applies_to: TTS / Audio playback behavior branches
---

# MemoX Decision Table — TTS

## Convention
- `ID` is stable. Tests reference it by ID (e.g. `// decision: T1`).
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` column: `TBD` until the implementing agent writes the test.
  Tests must be derived from the Expected column, NOT from code.

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| T1 | Save settings | Slider change | Persist immediately, no save button | C0+C1 | TBD |
| T2 | Set rate | Value outside `[0.3, 0.7]` | Clamp via `normalizeRate` | C1 | TBD |
| T3 | Set pitch | Value outside `[0.7, 1.5]` | Clamp via `normalizePitch` | C1 | TBD |
| T4 | Set volume | Value outside `[0.0, 1.0]` | Clamp via `normalizeVolume` | C1 | TBD |
| T5 | Change language | New language picked | Persist + clear `frontVoiceName` | C0+C1 | TBD |
| T6 | Speak side | side=`front` | Speak via `TtsService` | C0+C1 | TBD |
| T7 | Speak side | side=`back` or `note` | No-op (policy blocks) | C1 | TBD |
| T8 | Speak text | Blank text | No-op | C1 | TBD |
| T9 | Load voices | Unknown stored voice | Fall back to platform default | C1 | TBD |
| T10 | Persist load | Corrupt row | Return defaults via normalization | C1 | TBD |
| T11 | Speak action | Deck `target_language = unsupported` | Speak button disabled; auto-play suppressed silently | C0+C1 | TBD |
| T12 | Speak action | Deck `target_language = korean` | Use ko-KR voice from settings | C0+C1 | TBD |
| T13 | Deck create form | New deck | `target_language` field required, defaults to `korean` | C0+C1 | TBD |
| T14 | Fill feedback TTS | Fill wrong feedback with `autoPlay=true` | No automatic speech; manual speak button remains available and speaks front on tap | C0+C1 | TBD |
| T15 | Fill hint-taint grading | Exact match after Hint, Try again after Hint, or Mark correct override | Persist `AttemptResult.recovered`; exact match without Hint remains `AttemptResult.perfect`; new card resets taint | C0+C1 | TBD |
