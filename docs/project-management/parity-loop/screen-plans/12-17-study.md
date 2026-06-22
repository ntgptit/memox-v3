# Screens 12–17 — Study modes + result — parity plan

Source: `docs/system-design/MemoX Design System/ui_kits/mobile/specs/1{2,3,4,5,6,7}-*.md`
+ `.../shots/1{2..7}-*--{light,dark}.png`.
FE: `lib/presentation/features/study/screens/*` (study_session [review], match_session, guess_session,
recall_session, fill_session, study_result, study_entry). The 5 modes share one spine
(`[[study-mode-chain-complete]]`): mock wins visual, docs win behavior.
Audit: 2026-06-23.

## diff.py parity sample (golden ↔ kit shot, light, tolerance 16, threshold 100)

| Mode | golden ↔ shot | light % |
| --- | --- | --- |
| 12 review | study_session_review-card ↔ 12 default | 9.51% |
| 13 match | match_session_board-mid ↔ 13 matching | 16.78% |
| 14 guess | guess_session_question ↔ 14 default | 19.84% (highest) |
| 15 recall hidden | recall_session_hidden ↔ 15 hidden | 7.38% |
| 15 recall revealed | recall_session_revealed ↔ 15 revealed | 8.46% |
| 16 fill input | fill_session_typing ↔ 16 input | 8.88% |
| 16 fill wrong | fill_session_wrong ↔ 16 wrong | 12.26% |
| 17 result loaded | study_result_loaded ↔ 17 loaded | 17.19% |
| 17 result defensive | study_result_defensive ↔ 17 defensive | 13.14% |

All within Ahem range; guess + result-loaded highest (text-dense). No screaming structural outlier.

## STATE COVERAGE (kit states per specs/INDEX.md)

| Screen | kit states | FE goldens | Missing |
| --- | --- | --- | --- |
| 12 review | 1 (default) | study_session_review-card | — ✓ |
| 13 match | 3 (matching, long-meanings, read-full-meaning) | board-fresh, board-mid | long-meanings / read-full-meaning are **content variants** (long text) — verify if a distinct render exists or = same board with long text |
| 14 guess | 1 (default) | question, answered | — ✓ (FE has question + answered phases; covers + exceeds) |
| 15 recall | 2 (hidden, revealed) | hidden, revealed | — ✓ |
| 16 fill | 2 (input, wrong) | typing, wrong, correct, hint_revealed | — ✓ (covers + exceeds) |
| 17 result | 6 (loaded, loading, defensive, goal-off, save-failed, tough-empty) | loaded, defensive, save-failed | **MISSING: loading, goal-off, tough-empty** |

Extra FE coverage (no kit state, app states): study_entry (resume + 5 empty variants), fill correct/
hint, guess answered, match board-fresh — all legit app states, keep.

## GAP checklist (ordered)

1. **17 Result missing goldens** (state-coverage FAIL): add **loading**, **goal-off**, **tough-empty**
   (light+dark = 6 goldens) — verify `study_result_screen` renders these branches first. **WP candidate.**
2. **13 Match content variants** (long-meanings, read-full-meaning): verify whether the FE match board
   renders a distinct layout for long meanings (wrap/ellipsis/expand) or it's the same board with longer
   text; add golden(s) if a distinct render exists, else note as covered by board goldens.
3. **14 Guess** (19.84%) + **17 result loaded** (17.19%) — highest %; per-mode INVENTORY pass to check
   for real divergences (vs Ahem text density). Likely text-noise; confirm via image compare.
4. Per-mode node INVENTORY (deferred to per-mode WPs): each mode is a full-screen study UI; audit
   app-bar/progress, card surface, answer controls, rating bar, etc. against its spec when taken as a WP.

## Notes
- Study/SRS screens → fan-out MUST add `srs-reviewer` (behavior: box/interval/finalization) in addition
  to ui-parity-checker + code-reviewer + docs-drift-detector — but parity WPs here are visual-only;
  srs-reviewer guards against accidental behavior change.
- Behavior (study flow, SRS transitions, rating) is docs-owned (`docs/business/study/**`,
  `docs/business/srs/**`) — do NOT alter to match mock; visual-only.
