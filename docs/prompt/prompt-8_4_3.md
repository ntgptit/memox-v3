# Claude Code Task Prompt — WBS 8.4.3: Auto-play on reveal

**Generated:** 2026-06-19
**Flow:** Settings | **Layer:** Integration | **Status:** Specified

**Deliverable:**
> Study-session reveal triggers TTS per settings

## ⚠️ Dependency warnings

⚠️  Dependency `8.4.1` (TTS service BE) is **Specified** — build it first.
⚠️  Dependency `4.3.2` (Session review shell FE) is **Specified** — build it first.

Resolve dependencies before this task or document why they can be skipped.

---

## Step 1 — Read first (mandatory; stop and report DRIFT before any code)

### Universal (every task)
- `docs/_generated/repo-map.md`
- `docs/_generated/where-is.md`
- `docs/business/index.md`
- `docs/business/glossary.md`
- `docs/contracts/error-contract.md`
- `docs/contracts/types-catalog.md`
- `docs/contracts/code-style.md`

### Task-specific
- `docs/contracts/usecase-contracts/study.md`
- `docs/contracts/repository-contracts/study-repository.md`
- `docs/business/study/study-flow.md`
- `docs/business/srs/srs-review.md`
- `docs/state/state-management-contract.md`
- `docs/decision-tables/memox-core-decision-table.md`
- `docs/testing/test-strategy.md`
- `docs/database/schema-contract.md`
- `docs/database/drift-guide.md`
- `docs/design/mock-to-ui-playbook.md`
- `docs/design/design-language.md`
- `docs/ui-ux/ui-ux-contract.md`
- `docs/ui-ux/action-hierarchy-contract.md`
- `docs/ui-ux/l10n-copy-contract.md`
- `docs/system-design/MemoX Design System/README.md`
- `docs/system-design/MemoX Design System/CLAUDE.md`
- `docs/wireframes/12-study-entry-gate.md`
- `docs/wireframes/13-study-session-review.md`
- `docs/wireframes/14-study-session-match.md`
- `docs/wireframes/15-study-session-guess.md`
- `docs/wireframes/16-study-session-recall.md`
- `docs/wireframes/17-study-session-fill.md`
- `docs/wireframes/18-study-result.md`
### Mock shots (FE/Integration tasks — before any code)
1. Locate PNG set for each wireframe via `shots/INDEX.md` → find all states (light + dark)
2. Create mapping table: mock element → existing component → implementation plan → scope (Current/Future/Rejected)
3. Check `docs/design/screens/{screen}.visual-contract.md` if it exists
4. For exact measurements (without vision): `docs/system-design/MemoX Design System/ui_kits/mobile/specs/INDEX.md` → `specs/NN-{screen}.md`
5. **Do not code until every visible mock element is mapped** — silent gaps are parity failures

### Drift check protocol
If any doc does not match current code, **stop immediately** and report:
```
DRIFT DETECTED:
- File code: lib/...
- File doc: docs/...
- Mismatch: {description}
- Suggested fix: {update doc | update code | needs user decision}
```
Do NOT continue the task until user confirms resolution.

---

## Step 2 — Scope

**WBS ID:** `8.4.3`
**Evidence / Source:** `lib/presentation/features/study/widgets/study_session_recall_mode_view.dart` (`_maybeAutoPlay`, `_autoPlayIfEnabled`); fill mode has speak-front only (no auto-play per spec)

**Tech stack:** State management uses **Riverpod Annotation v3** (`@riverpod`, `@freezed`, code-generated; after any change, run `dart run build_runner build --delete-conflicting-outputs`).

**Hard rules (do not violate):**
- Do NOT bypass UseCase → Repository → DAO flow
- Do NOT import data layer from domain; domain has no outward imports
- Do NOT hardcode route strings, colors, text styles, user-facing strings, durations
- Do NOT use `ref.watch` inside callbacks
- Do NOT add new shared widget if existing one works
- Do NOT use raw Material components, colors, spacing, or radii — use MemoX Design System tokens/components (FE: `Mx*`, `--memox-*` vars; BE: follow style guide)
- Do NOT commit without running `node tool/verify/run.mjs` (produces pass-marker)
- Do NOT run `flutter analyze` / `flutter test` / `build_runner` directly — use `verify` tool

---

## Step 3 — Implement

**Integration order:**
1. Confirm BE contracts exist and unit tests pass
2. Wire presentation → **Riverpod Annotation provider** → use case → repository
3. End-to-end navigation test
4. Widget/integration tests covering the cross-layer flow
5. After any `@riverpod` / `@freezed` change: `dart run build_runner build --delete-conflicting-outputs`

---

## Step 4 — Inner loop (run after each significant change)

```bash
node tool/verify/run.mjs --quick --test <test-paths>
```

- Fast feedback; does **not** write a pass-marker (cannot commit from --quick alone)
- Fix all analyzer warnings before continuing
- Replace `<test-paths>` with the specific test files being worked on

## Step 5 — Design parity (FE / Integration tasks)

1. Render golden for each state and compare with mock shot:
   ```bash
   python tool/golden_diff/diff.py <golden.png> <shot.png> [--out heatmap.png]
   ```
2. Generate goldens **intentionally** (only after visual review):
   ```bash
   node tool/verify/run.mjs --update-goldens --test <golden-test-paths>
   ```
3. Prove the gate is real — re-run **without** `--update` (must pass):
   ```bash
   node tool/verify/run.mjs --test <golden-test-paths>
   ```
4. Visual parity checklist (from CLAUDE.md §Visual Parity Gate):
   - [ ] Spec read — ALL `shots/` PNGs + measured DOM spec `specs/NN-*.md`
   - [ ] Golden per state — light + dark 390×780; regenerated + re-proved
   - [ ] Tokens, not kit px — `Mx*` components + spacing/radius/typography tokens
   - [ ] Invariant in shared widget — layout detail fixed at `Mx*` level
   - [ ] Visual gaps listed — each unmatched element: Current / Future / Rejected / Missing-data / Token-missing / Mock-doc-conflict
5. UI Density Gate (CLAUDE.md §UI Density Gate):
   - [ ] Compact mobile review at 360dp — no overflow
   - [ ] Exactly one visually dominant primary action per screen
   - [ ] Full-width / large buttons: each one justified or guard-commented
   - [ ] No card-level large/fullWidth violation
   - [ ] `MxActionButton` / `MxCardActions` preferred over raw buttons
6. Design System compliance (MemoX Design System/CLAUDE.md):
   - [ ] All shadows: neutral only, no colored/glowing shadows (use `--memox-shadow-sm/md/lg`)
   - [ ] Spacing/radius/colors: token-driven via `--memox-*` only, no hardcoded px/hex
   - [ ] Shared primitives used: `window.MX` (Icon, S, PillBtn, Chip, ListRow, etc.) + contract classes (.card, .card-row, .list-row)
   - [ ] Side-by-side cards: use `.card-row` wrapper (equal-height stretch), not hand-rolled flex
   - [ ] If UI-kit screen: pass `node tools/check-ui-kit.js` (0 errors required)

---

## Step 6 — Full verify + parity check + commit

### 6.1 Full verification
```bash
node tool/verify/run.mjs --full
```
This runs all checks: gen-l10n (if ARB changed) → build_runner → guard → doc_guard → dart fix → dart format → flutter analyze → flutter test → diff --check → writes pass-marker.

After it runs `dart fix` / `dart format`, inspect the diff and revert changes outside this task's scope.

### 6.2 Pre-commit parity check (8 steps — CLAUDE.md §Pre-commit parity check)
- [ ] 1. User-visible behavior changed → updated business doc + wireframe
- [ ] 2. Schema / persistence changed → updated `docs/database/schema-contract.md` + `migration-contract.md` + `storage-boundaries.md`
- [ ] 3. Route / navigation changed → updated `docs/business/navigation/navigation-flow.md` + `RouteNames`/`RoutePaths`
- [ ] 4. SRS / study algo changed → updated `docs/business/srs/srs-review.md` + `study-flow.md` + decision table
- [ ] 5. Rule / validation changed → updated corresponding doc
- [ ] 6. New testable behavior branch → added row in decision table + test
- [ ] 7. Specified → Implemented transition → updated status in `docs/business/system/overview.md`
- [ ] 8. Renamed any term/route/field → fixed ALL refs (`node tool/doc_guard/run.mjs terms <old>`)

### 6.3 WBS §10 Traceability Log
Append **one line** to `docs/project-management/wbs.md` §10 (newest first):
```
| `<8-char-hash>` | 2026-06-19 | 8.4.3 | {one-line summary of what was implemented} |
```
(The short hash is known after commit; amend the WBS log in the next commit if needed.)

### 6.4 Doc regeneration (if route / schema / use case / screen changed)
```bash
node tool/doc_guard/run.mjs generate
```
Then re-run verify to catch any new doc_guard findings on the generated files.

### 6.5 Commit + push
```bash
git add <files>
git commit -m "<type>: <subject>

Co-Authored-By: Claude <noreply@anthropic.com>"
git push -u origin <branch>
```

---

## Expected report format

Follow `docs/checklist/implementation-checklist.md` §Final report template. Include at minimum:

- **Summary** — 1-3 sentences
- **WBS:** 8.4.3
- **Changed code files** — paths
- **Changed doc files** — paths (or "no docs needed because: …")
- **Doc-code parity check** — 8 ticks
- **Drift detected** — any legacy mismatches found during task
- **Business / UX impact** — what user sees differently
- **Route impact** — routes added/changed (none / list)
- **Persistence impact** — schema/storage changes (none / list)
- **UI impact** — screens/widgets changed (none / list)
- **Decision table / test impact** — rows touched, tests added
- **Verification result** — pass/fail from `node tool/verify/run.mjs`
- **Guard status** — pass / skipped (tool not present) / skipped (reason)
- **WBS update** — log entry appended / not needed (reason)
- **Skipped checks or risks** — explicit, with reason
