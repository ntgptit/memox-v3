# Claude Code Task Prompt — WBS 9.16: Where-is feature index

**Generated:** 2026-06-19
**Flow:** Quality | **Layer:** Docs | **Status:** Specified

**Deliverable:**
> `docs/_generated/where-is.md`: deterministic feature → docs/source/tests/mock-shots/WBS cross-reference (42 features; file lists resolved LIVE per generate; output linted by doc_guard); AGENTS.md fast-lookup table routes Codex to the same infra

## ⚠️ Dependency warnings

⚠️  Dependency `9.13` (Repo-map cold-start snapshot) is **Specified** — build it first.

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

**WBS ID:** `9.16`
**Evidence / Source:** `docs/_generated/where-is.md`, `tool/doc_guard/run.mjs` (`WHERE_IS` registry), `AGENTS.md` §Where to look for what

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

Follow the layer-appropriate order from CLAUDE.md §Mandatory workflow.

---

## Step 4 — Inner loop (run after each significant change)

```bash
node tool/verify/run.mjs --quick --test <test-paths>
```

- Fast feedback; does **not** write a pass-marker (cannot commit from --quick alone)
- Fix all analyzer warnings before continuing
- Replace `<test-paths>` with the specific test files being worked on

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
| `<8-char-hash>` | 2026-06-19 | 9.16 | {one-line summary of what was implemented} |
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
- **WBS:** 9.16
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
