---
last_updated: 2026-06-21
applies_to: prioritized backlog of outstanding (not-yet-Implemented) work
source_of_truth: docs/project-management/wbs.md
---

# MemoX — Outstanding Work Backlog (prioritized)

> This is a **prioritized view** of everything still outstanding as of 2026-06-21. The full
> breakdown, dependencies, source paths, decision rows, and the Commit Traceability Log remain
> canonical in `docs/project-management/wbs.md` (snapshot backed up as
> `docs/project-management/wbs.backup-2026-06-21.md`). Each item below cites its WBS ID — open
> `wbs.md` for the row detail. Statuses mirror `wbs.md` at the time of writing.
>
> **Snapshot:** ~127 outstanding rows (115 Specified · 6 Future · 5 Blocked · 1 Rejected).
> **Already shipped this redesign cycle** (for context, not outstanding): IA 5-tab nav + `/search`
> screen, breadcrumb, engagement shared widgets, guard cleanup (0 errors local), Dashboard `/home`.
>
> **Priority key:** **P0** = critical, blocks the product's core value or unblocks many tasks ·
> **P1** = high, the next coherent feature increments · **P2** = medium, completeness/settings ·
> **P3** = low / Future / tech-debt / pre-release.

---

## P0 — Critical: the Study / SRS loop (the app cannot study yet)

The app today can build content, search, and show a due count — but **there is no way to actually
review cards**. Standing up the study loop is the single highest-value gap and unblocks Progress,
Card history, Dashboard streak/goal, and the dashboard due CTA.

| Priority | WBS | Item | Note |
|---|---|---|---|
| ~~P0.1~~ | ~~**4.0.1**~~ | ~~Study persistence schema + repo skeleton (ENABLER B1)~~ | ✅ **DONE 2026-06-21** (schema v6: `study_sessions`/`study_session_items`/`study_attempts` + `StudyRepository` skeleton). B1 resolved — §4 persistence unblocked. |
| P0.2 | ~~4.1.1~~ / 4.1.2 | ~~Study entry eligibility BE~~ ✅ **DONE 2026-06-21** (count-based classification, empty-scope matrix) + entry FE (4.1.2 pending) | Resolve scope, empty-state matrix. |
| P0.3 | ~~4.2.1~~ / ~~4.2.2~~ / 4.2.3 / ~~4.2.4~~ | ~~Session creation BE~~ ✅ **DONE** + ~~no-silent-resume gate~~ ✅ **DONE 2026-06-21** (findResumable + StudyEntryStartResult gate) + resume/start-over FE (4.2.3) + ~~batch limit~~ ✅ **DONE** | |
| P0.4 | ~~4.3.1~~ / 4.3.2 | ~~Session item loading BE~~ ✅ **DONE 2026-06-21** (`StudySessionReview` load) + review shell FE (4.3.2) | |
| P0.5 | ~~4.4.1~~ / 4.4.2 / 4.4.3 | ~~Submit self-grade BE~~ ✅ **DONE 2026-06-21** (recordStudySessionAnswer + SrsBox transition) + Forgot/Got-it FE + re-grade before finalize | |
| P0.6 | ~~4.5.1~~ / 4.5.2 / 4.5.3 | ~~Study mode strategy BE~~ ✅ **DONE 2026-06-21** (sealed families + factory) + Review mode BE + Review mode FE | Review is the core mode; other modes are P1. |
| P0.7 | ~~4.6.1~~ / ~~4.6.2~~ / 4.6.3 / ~~4.6.4~~ | ✅ **DONE 2026-06-21** Finish session + SRS progress update + due-time local-midnight (finalization keystone, 1 slice) · 4.6.3 finalization-recovery FE still open | The Leitner box transition. |
| P0.8 | ~~4.7.1~~ / 4.7.2 | ~~Result summary BE~~ ✅ **DONE 2026-06-21** (`loadStudySessionResult` + `StudySessionResult` model: terminal result per item + total/answered/forgot/passed counts) + result screen FE (4.7.2) | |
| P0.9 | 4.8.1 / 4.9.1 | Session persistence recovery + protected active-session exit FE | |
| P0.10 | 4.1.3 / 4.1.4 | Deck study CTA FE + Folder study CTA FE | Wires Library/detail screens into the new loop. |

---

## P1 — High: Progress, engagement, study modes, full card editor

### Progress + engagement (the redesign Dashboard's natural pair — `/progress` is still a placeholder)
| Priority | WBS | Item | Note |
|---|---|---|---|
| P1.1 | **7.0.1** | Card-history schema (ENABLER B4) | Blocked — **needs schema approval.** |
| P1.2 | 7.4.1 / 7.4.2 / 7.1.1 / 7.2.1 / 7.3.1 | Progress read models + due/box/stats queries | 7.1.1 partly covered by the Dashboard due query. |
| P1.3 | 7.5.1 / 7.5.2 | **Progress screen FE + states** (redesign **E4**) | Assemble the ready `MxGoalRing` + `MxInsight`; needs E2 below for goal/streak data. |
| P1.4 | 5.4.1 / 5.4.2 | Engagement persistence + streak/goal (redesign **E2**) | `study_days` + daily-goal — **schema/migration, needs approval.** Feeds Progress goal/streak. |
| P1.5 | 7.6.2 / 7.6.3 / 7.6.1 | Card history use cases + screen FE + review-history query | |
| P1.6 | ~~5.1.1~~ / 5.1.2 · 5.6.1 / 5.6.2 · 5.7.1 · 5.5.1 | Dashboard: ~~resume summary BE~~ ✅ **DONE 2026-06-21** + resume card FE (5.1.2), recent-decks, start-new-learning, refresh | Builds on the shipped `/home`. |
| P1.7 | 7.7.1 | Dashboard/Progress consistency | |

### Study modes beyond Review + study actions
| Priority | WBS | Item |
|---|---|---|
| P1.8 | 4.5.4–4.5.9 | Match / Guess / Fill modes (BE + FE) |
| P1.9 | 4.5.10–4.5.13, 4.5.11 | Daily new limit + Recall mode FE + mode-chain persistence + per-phase chain runtime |
| P1.10 | ~~4.10.1~~ / 4.10.2 · ~~4.11.1~~ / ~~4.11.2~~ / 4.11.3 | ~~Cancel/discard session~~ ✅ **DONE 2026-06-21** + resume-expiry anchor + ~~bury/suspend queue exclusion BE~~ ✅ **DONE 2026-06-21** (`resolveEligibleCardIds`) + ~~in-session bury/suspend BE~~ ✅ **DONE 2026-06-21** (`bury/suspendStudySessionCard`) + in-session FE (4.11.3) |

### Full flashcard editor (current editor is front/back-only)
| Priority | WBS | Item |
|---|---|---|
| P1.11 | 2.11.2 / 2.12.2 / 2.13.2 | Flashcard Create / Edit / Delete FE — full (notes, example, pronunciation, tags) |
| P1.12 | 2.15.2 · 2.14.2 | Flashcard tags FE + reorder FE |

---

## P2 — Medium: content completeness, import, settings

### Content management (remaining FE / schema)
2.5.2 folder reorder · 2.7.2 / 2.8.2 / 2.9.2 deck create/rename/delete FE (some advanced at V1) ·
2.10.2 deck reorder · 2.16.2 parent-child guard FE · 2.17.1 (Blocked) / 2.17.2 status filter +
badges · 2.18.2 tag filter FE · 2.19.2 deck move FE · 2.20.2 duplicate soft-warning ·
2.21.1 folder-delete blast-radius confirm · 2.22.1 folder color/icon schema + BE ·
3.2.3 folder-detail new-vs-due split · 3.6.1 error retry state.

### Import (§6) — none built
6.1.1 route/shell · 6.2.1 / 6.2.2 CSV parse + validation · 6.3.1 preview · 6.4.1 / 6.4.2
transactional commit (no silent partial) · 6.5.1 result · 6.6.1 / 6.6.2 duplicate detection +
preview · 6.7.1 file picker · 6.9.1 structured-text import.

### Settings (§8)
8.1.1 / 8.1.2 hub shell + hide-fabricated-state · 8.2.2 learning settings wiring ·
8.3.2 tag management FE wiring · 8.4.1 / 8.4.2 / 8.4.3 TTS service + settings + auto-play ·
8.5.1 account settings · 8.6.1 / 8.6.2 Google linking + Drive backup/restore ·
8.7.1 / 8.7.2 deck export CSV BE/FE · 8.9.1 / 8.9.2 bulk operations + selection mode.

---

## P3 — Low / Future / tech-debt / pre-release

### Redesign tech-debt follow-ups (from the 2026-06-21 cycle)
- **`folder_repository_impl.dart` split** — 694 lines; currently a documented local-guard exclusion
  (the guard tool dir is gitignored). Needs a composition refactor.
- **MxText positional `data`** — kept as an idiomatic exception (local-guard exclusion); revisit if
  the team prefers migrating the ~31 `MxText('…')` call sites to named, or formalizing the exclusion.
- **Search-result deep navigation** — first hop stays in the Search tab; deeper subfolder/deck taps
  inside an opened detail still switch to the Library branch (branch-aware deep nav is a refinement).
- **Search result rows missing-data meta** — folder/deck/flashcard rows show name only; due badge +
  count/path meta need the `SearchResults` projection to grow.
- **Dashboard Today study CTA** — intentionally omitted (quiet refer surface); revisit once the
  study loop (P0) lands if a Today CTA is wanted.

### Future (each needs its own approval)
3.8.1 tags/recent/popular search sections · 6.8.1 Excel import · 8.6.3 silent token refresh +
reconnect banner · 8.6.4 auto-backup · 8.6.5 server-API sync · 8.8.1 appearance/locale settings.

### Quality / process (§9) — ongoing
9.10 CI status checks · 9.11 doc_guard docs/process gate · 9.12 doc_guard baseline burn-down ·
9.13 repo-map snapshot · 9.14 golden-diff visual-parity runner · 9.15 unified verify entry
(ENFORCED) · 9.16 where-is index · 9.17 pre-commit hook + repo hygiene.

### Release (§10) — pre-release gates
10.1 MVP smoke path · 10.2 Android readiness · 10.3 Web readiness · 10.4 Windows readiness ·
10.5 known-deferred list · 10.6 release acceptance checklist.

### Rejected (no action)
5.8.1 Dashboard app-bar search shortcut — superseded by the top-level `/search` tab.

---

## Suggested sequencing

1. **Get approval for the study/engagement/card-history schemas** (4.0.1, 5.4.1/engagement,
   7.0.1) — these gate the highest-value tiers.
2. **Build the P0 study loop** end-to-end (entry → session → review → self-grade → finish → SRS →
   result) so the app can actually do spaced repetition.
3. **P1 Progress + engagement** (assemble `/progress` with the ready `MxGoalRing`/`MxInsight`,
   wire streak/goal) and finish the Dashboard (resume/recent-decks).
4. **P1 study modes + full editor**, then **P2 import/settings**, then **P3** polish/pre-release.
