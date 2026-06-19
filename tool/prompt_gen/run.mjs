// prompt_gen — generates Claude Code task prompts from WBS IDs.
//
// Usage (from repo root or this dir; zero npm dependencies):
//   node tool/prompt_gen/run.mjs <WBS_ID> [<WBS_ID2> ...]   # generate prompt(s)
//   node tool/prompt_gen/run.mjs --phase <N>                 # phase overview + ready rows
//   node tool/prompt_gen/run.mjs --list [--status <S>]       # list all WBS rows
//   node tool/prompt_gen/run.mjs --next                      # show §5 Next tasks from WBS
//
// Output: stdout — pipe to a file or copy-paste into Claude Code.
// Exit codes: 0 = ok, 1 = unknown WBS ID or usage error.

import { readFileSync, existsSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const wbsPath = join(repoRoot, 'docs', 'project-management', 'wbs.md');
const today = new Date().toISOString().slice(0, 10);

// ── WBS parsing ───────────────────────────────────────────────────────────────

function parseWbsRows(text) {
  const rows = new Map();
  // §4 section only — between "## 4." and "## 5."
  const sec4 = text.indexOf('\n## 4.');
  const sec5 = text.indexOf('\n## 5.');
  const section = text.slice(sec4, sec5 > 0 ? sec5 : text.length);

  for (const line of section.split('\n')) {
    if (!/^\| \d+(\.\d+){1,2} \|/.test(line)) continue;
    const cells = line.replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
    if (cells.length !== 10) continue;
    rows.set(cells[0], {
      id: cells[0],
      flow: cells[1],
      function: cells[2],
      layer: cells[3],
      deliverable: cells[4],
      status: cells[5],
      dependsOn: cells[6],
      evidence: cells[7],
      commitId: cells[8],
      nextAction: cells[9],
    });
  }
  return rows;
}

function parsePhaseTable(text) {
  const sec = text.indexOf('### 4.1 Rebuild Delivery Phases');
  const end = text.indexOf('\n### ', sec + 10);
  const section = text.slice(sec, end > 0 ? end : text.length);
  const phases = new Map();

  for (const line of section.split('\n')) {
    // Match "| **N — ..." or "| **Ongoing ..."
    if (!/^\| \*\*([\dOngoing])/.test(line)) continue;
    const cells = line.replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
    if (cells.length < 4) continue;
    const m = cells[0].match(/\*\*(\d+|Ongoing)/);
    if (m) phases.set(m[1], { header: cells[0], goal: cells[1], scope: cells[2], exit: cells[3] });
  }
  return phases;
}

function parseNextSection(text) {
  const sec5 = text.indexOf('\n## 5.');
  const sec6 = text.indexOf('\n## 6.');
  if (sec5 < 0) return '';
  return text.slice(sec5, sec6 > 0 ? sec6 : text.length).trim();
}

// ── entity / reading-list logic ───────────────────────────────────────────────

const ENTITY_PATTERNS = [
  [/\bfolder/i, 'folder'],
  [/\bdeck/i, 'deck'],
  [/\bflashcard|\bimport|\bexport/i, 'flashcard'],
  [/\bsrs|\bleitner|\bspaced.repet/i, 'srs'],
  [/\bstudy.session|\bsession|study.mode|\breview.mode|\bmatch|\bguess|\brecall|\bfill.mode/i, 'study'],
  [/\bbury|\bsuspend/i, 'study-actions'],
  [/\bresume.session|\bresumable/i, 'resume'],
  [/\btag/i, 'tag'],
  [/\bbulk/i, 'bulk'],
  [/\bsearch/i, 'search'],
  [/\bcard.history|\bhistory/i, 'history'],
  [/\bdashboard|\bstreak|\bengagement/i, 'engagement'],
  [/\bprogress/i, 'progress'],
  [/\btts|\baudio|\bspeech/i, 'tts'],
  [/\baccount|\bsync|\bgoogle|\bdrive/i, 'account-sync'],
  [/\blearning.setting/i, 'learning-settings'],
  [/\bwidget.kit|\bshared.widget|\bdesign.system|\btheme.token|\bmx[a-z]/i, 'widget-kit'],
];

function detectEntity(row) {
  const haystack = `${row.flow} ${row.function} ${row.deliverable}`;
  for (const [pat, entity] of ENTITY_PATTERNS) {
    if (pat.test(haystack)) return entity;
  }
  return null;
}

// Maps entity → { usecase, repo, business, wireframeHint }
const ENTITY_DOCS = {
  folder: {
    usecase: 'docs/contracts/usecase-contracts/folder.md',
    repo: 'docs/contracts/repository-contracts/folder-repository.md',
    business: ['docs/business/folder/folder-management.md'],
    wireframes: ['docs/wireframes/02-library.md', 'docs/wireframes/05-library-folder-detail.md'],
  },
  deck: {
    usecase: 'docs/contracts/usecase-contracts/deck.md',
    repo: 'docs/contracts/repository-contracts/deck-repository.md',
    business: ['docs/business/deck/deck-management.md'],
    wireframes: ['docs/wireframes/06-library-deck-detail.md', 'docs/wireframes/07-library-deck-cards.md'],
  },
  flashcard: {
    usecase: 'docs/contracts/usecase-contracts/flashcard.md',
    repo: 'docs/contracts/repository-contracts/flashcard-repository.md',
    business: ['docs/business/flashcard/flashcard-management.md', 'docs/business/export/export.md'],
    wireframes: ['docs/wireframes/07-library-deck-cards.md', 'docs/wireframes/08-library-deck-card-detail.md', 'docs/wireframes/10-deck-import.md'],
  },
  study: {
    usecase: 'docs/contracts/usecase-contracts/study.md',
    repo: 'docs/contracts/repository-contracts/study-repository.md',
    business: ['docs/business/study/study-flow.md', 'docs/business/srs/srs-review.md'],
    wireframes: ['docs/wireframes/12-study-setup.md', 'docs/wireframes/13-study-session-review.md',
      'docs/wireframes/14-study-session-match.md', 'docs/wireframes/15-study-session-guess.md',
      'docs/wireframes/16-study-session-recall.md', 'docs/wireframes/17-study-session-fill.md',
      'docs/wireframes/18-study-session-result.md'],
  },
  srs: {
    usecase: 'docs/contracts/usecase-contracts/srs.md',
    repo: 'docs/contracts/repository-contracts/study-repository.md',
    business: ['docs/business/srs/srs-review.md', 'docs/business/study/study-flow.md'],
    wireframes: ['docs/wireframes/13-study-session-review.md'],
  },
  'study-actions': {
    usecase: 'docs/contracts/usecase-contracts/study.md',
    repo: 'docs/contracts/repository-contracts/study-repository.md',
    business: ['docs/business/study-actions/bury-suspend.md'],
    wireframes: [],
  },
  resume: {
    usecase: 'docs/contracts/usecase-contracts/study.md',
    repo: 'docs/contracts/repository-contracts/study-repository.md',
    business: ['docs/business/resume/resume-session.md'],
    wireframes: ['docs/wireframes/01-dashboard.md'],
  },
  tag: {
    usecase: 'docs/contracts/usecase-contracts/tag.md',
    repo: 'docs/contracts/repository-contracts/tag-repository.md',
    business: ['docs/business/tags/tag-system.md'],
    wireframes: [],
  },
  bulk: {
    usecase: 'docs/contracts/usecase-contracts/bulk.md',
    repo: 'docs/contracts/repository-contracts/flashcard-repository.md',
    business: ['docs/business/bulk/bulk-operations.md'],
    wireframes: [],
  },
  search: {
    usecase: 'docs/contracts/usecase-contracts/search.md',
    repo: null,
    business: ['docs/business/search/global-search.md'],
    wireframes: ['docs/wireframes/11-library-search.md'],
  },
  history: {
    usecase: 'docs/contracts/usecase-contracts/history.md',
    repo: 'docs/contracts/repository-contracts/progress-repository.md',
    business: ['docs/business/history/card-history.md'],
    wireframes: ['docs/wireframes/09-flashcard-history.md'],
  },
  engagement: {
    usecase: 'docs/contracts/usecase-contracts/engagement.md',
    repo: null,
    business: ['docs/business/engagement/dashboard-engagement.md'],
    wireframes: ['docs/wireframes/01-dashboard.md'],
  },
  progress: {
    usecase: 'docs/contracts/usecase-contracts/srs.md',
    repo: 'docs/contracts/repository-contracts/progress-repository.md',
    business: ['docs/business/srs/srs-review.md'],
    wireframes: ['docs/wireframes/03-progress.md'],
  },
  tts: {
    usecase: 'docs/contracts/usecase-contracts/tts.md',
    repo: null,
    business: ['docs/business/tts/tts-settings.md'],
    wireframes: ['docs/wireframes/21-settings-audio-speech.md'],
  },
  'account-sync': {
    usecase: 'docs/contracts/usecase-contracts/account-sync.md',
    repo: 'docs/contracts/repository-contracts/sync-repository.md',
    business: ['docs/business/account-sync/account-sync.md'],
    wireframes: ['docs/wireframes/19-settings-account.md'],
  },
  'learning-settings': {
    usecase: 'docs/contracts/usecase-contracts/learning-settings.md',
    repo: 'docs/contracts/repository-contracts/learning-settings-repository.md',
    business: ['docs/business/study/study-flow.md'],
    wireframes: ['docs/wireframes/20-settings-learning.md'],
  },
  'widget-kit': {
    usecase: null,
    repo: null,
    business: [],
    wireframes: ['docs/wireframes/index.md'],
  },
};

const UNIVERSAL_DOCS = [
  'docs/_generated/repo-map.md',
  'docs/_generated/where-is.md',
  'docs/business/index.md',
  'docs/business/glossary.md',
  'docs/contracts/error-contract.md',
  'docs/contracts/types-catalog.md',
  'docs/contracts/code-style.md',
];

function buildReadingList(row, entity) {
  const layer = row.layer.toLowerCase();
  const isBE = layer.includes('be');
  const isFE = layer.includes('fe');
  const isIntegration = layer.includes('integration');
  const isTest = layer.includes('test');
  const isDocs = layer.includes('docs');
  const entityInfo = entity ? ENTITY_DOCS[entity] : null;

  const specific = [];

  // BE / Integration
  if (isBE || isIntegration) {
    if (entityInfo?.usecase) specific.push(entityInfo.usecase);
    if (entityInfo?.repo) specific.push(entityInfo.repo);
    if (entityInfo?.business) specific.push(...entityInfo.business);
    specific.push('docs/state/state-management-contract.md');
    specific.push('docs/decision-tables/memox-core-decision-table.md');
    specific.push('docs/testing/test-strategy.md');

    // Schema-touching entities
    const schemaEntities = ['folder', 'deck', 'flashcard', 'study', 'srs', 'tag', 'progress', 'history', 'engagement'];
    if (entity && schemaEntities.includes(entity)) {
      specific.push('docs/database/schema-contract.md');
      specific.push('docs/database/drift-guide.md');
    }
  }

  // FE / Integration
  if (isFE || isIntegration) {
    specific.push('docs/design/mock-to-ui-playbook.md');
    specific.push('docs/design/design-language.md');
    specific.push('docs/ui-ux/ui-ux-contract.md');
    specific.push('docs/ui-ux/action-hierarchy-contract.md');
    specific.push('docs/ui-ux/l10n-copy-contract.md');
    specific.push('docs/system-design/MemoX Design System/README.md');
    if (entityInfo?.wireframes?.length) specific.push(...entityInfo.wireframes);
    if (entityInfo?.business?.length && !(isBE || isIntegration)) specific.push(...entityInfo.business);
    specific.push('docs/decision-tables/memox-core-decision-table.md');
    specific.push('docs/testing/test-strategy.md');
  }

  // Docs-only
  if (isDocs) {
    if (entityInfo?.business?.length) specific.push(...entityInfo.business);
  }

  // Test-only
  if (isTest) {
    specific.push('docs/testing/test-strategy.md');
    specific.push('docs/decision-tables/memox-core-decision-table.md');
  }

  // Deduplicate while preserving order
  const seen = new Set();
  return specific.filter((p) => (!seen.has(p) && seen.add(p)) || false);
}

// ── prompt template ───────────────────────────────────────────────────────────

function depWarnings(row, allRows) {
  if (!row.dependsOn || row.dependsOn === 'none' || row.dependsOn === '-') return [];
  const deps = row.dependsOn.split(/[,;\/]/).map((d) => d.trim()).filter(Boolean);
  const warnings = [];
  for (const dep of deps) {
    const depRow = allRows.get(dep);
    if (!depRow) {
      warnings.push(`⚠️  Dependency \`${dep}\` not found in WBS — verify ID.`);
    } else if (depRow.status !== 'Implemented') {
      warnings.push(`⚠️  Dependency \`${dep}\` (${depRow.function}) is **${depRow.status}** — build it first.`);
    }
  }
  return warnings;
}

function implOrder(layer) {
  const l = layer.toLowerCase();
  if (l.includes('be')) {
    return `**Clean Architecture order:**
1. Domain entity / value objects (if new)
2. Repository port (interface in domain layer)
3. Use case(s)
4. Drift DAO / query (if persistence needed)
5. Repository implementation (data layer)
6. Riverpod provider wiring (\`@riverpod\`)
7. Unit tests (use case + SRS transitions if relevant)

After any \`@riverpod\` / \`@freezed\` / \`JsonSerializable\` change:
\`\`\`bash
dart run build_runner build --delete-conflicting-outputs
\`\`\``;
  }
  if (l.includes('fe')) {
    return `**Presentation order:**
1. Read ALL \`shots/\` PNGs for this screen (light + dark, EVERY state)
2. Build mapping table: mock element → component/token → scope (Current/Future/Rejected)
3. Wire screen to existing provider (do NOT bypass UseCase → Repository flow)
4. Add ARB keys for new copy (\`lib/l10n/app_en.arb\` + \`lib/l10n/app_vi.arb\`)
5. Widget tests: loaded, empty, loading, error, navigation
6. Golden per state: light + dark at 390×780 (\`matchesGoldenFile\`)

After ARB changes: \`node tool/verify/run.mjs --quick\` triggers \`gen-l10n\` automatically.`;
  }
  if (l.includes('integration')) {
    return `**Integration order:**
1. Confirm BE contracts exist and unit tests pass
2. Wire presentation → use case → repository
3. End-to-end navigation test
4. Widget/integration tests covering the cross-layer flow`;
  }
  return `Follow the layer-appropriate order from CLAUDE.md §Mandatory workflow.`;
}

function generatePrompt(row, allRows) {
  const entity = detectEntity(row);
  const entityInfo = entity ? ENTITY_DOCS[entity] : null;
  const specific = buildReadingList(row, entity);
  const deps = depWarnings(row, allRows);
  const layer = row.layer.toLowerCase();
  const isFE = layer.includes('fe') || layer.includes('integration');
  const isBE = layer.includes('be') || layer.includes('integration');
  const shotsNote = isFE && entityInfo?.wireframes?.length
    ? `\n### Mock shots (FE/Integration tasks)\nFor each wireframe above, locate the PNG set:\n- \`docs/system-design/MemoX Design System/ui_kits/mobile/shots/INDEX.md\` → find screen rows\n- Open **all state PNGs** (light + dark) before writing a single widget\n- For exact measurements without vision: \`docs/system-design/MemoX Design System/ui_kits/mobile/specs/INDEX.md\``
    : '';

  const depBlock = deps.length
    ? `\n## ⚠️ Dependency warnings\n\n${deps.join('\n')}\n\nResolve dependencies before this task or document why they can be skipped.\n`
    : '';

  const designParityBlock = isFE ? `\n## Step 5 — Design parity (FE / Integration tasks)

1. Render golden for each state and compare with mock shot:
   \`\`\`bash
   python tool/golden_diff/diff.py <golden.png> <shot.png> [--out heatmap.png]
   \`\`\`
2. Generate goldens **intentionally** (only after visual review):
   \`\`\`bash
   node tool/verify/run.mjs --update-goldens --test <golden-test-paths>
   \`\`\`
3. Prove the gate is real — re-run **without** \`--update\` (must pass):
   \`\`\`bash
   node tool/verify/run.mjs --test <golden-test-paths>
   \`\`\`
4. Visual parity checklist (from CLAUDE.md §Visual Parity Gate):
   - [ ] Spec read — ALL \`shots/\` PNGs + measured DOM spec \`specs/NN-*.md\`
   - [ ] Golden per state — light + dark 390×780; regenerated + re-proved
   - [ ] Tokens, not kit px — \`Mx*\` components + spacing/radius/typography tokens
   - [ ] Invariant in shared widget — layout detail fixed at \`Mx*\` level
   - [ ] Visual gaps listed — each unmatched element: Current / Future / Rejected / Missing-data / Token-missing / Mock-doc-conflict
5. UI Density Gate (CLAUDE.md §UI Density Gate):
   - [ ] Compact mobile review at 360dp — no overflow
   - [ ] Exactly one visually dominant primary action per screen
   - [ ] Full-width / large buttons: each one justified or guard-commented
   - [ ] No card-level large/fullWidth violation
   - [ ] \`MxActionButton\` / \`MxCardActions\` preferred over raw buttons
` : '';

  return `# Claude Code Task Prompt — WBS ${row.id}: ${row.function}

**Generated:** ${today}
**Flow:** ${row.flow} | **Layer:** ${row.layer} | **Status:** ${row.status}

**Deliverable:**
> ${row.deliverable}
${depBlock}
---

## Step 1 — Read first (mandatory; stop and report DRIFT before any code)

### Universal (every task)
${UNIVERSAL_DOCS.map((d) => `- \`${d}\``).join('\n')}
${specific.length ? `\n### Task-specific\n${specific.map((d) => `- \`${d}\``).join('\n')}` : ''}${shotsNote}

### Drift check protocol
If any doc does not match current code, **stop immediately** and report:
\`\`\`
DRIFT DETECTED:
- File code: lib/...
- File doc: docs/...
- Mismatch: {description}
- Suggested fix: {update doc | update code | needs user decision}
\`\`\`
Do NOT continue the task until user confirms resolution.

---

## Step 2 — Scope

**WBS ID:** \`${row.id}\`
**Evidence / Source:** ${row.evidence || '(see business docs)'}

**Hard rules (do not violate):**
- Do NOT bypass UseCase → Repository → DAO flow
- Do NOT import data layer from domain; domain has no outward imports
- Do NOT hardcode route strings, colors, text styles, user-facing strings
- Do NOT use \`ref.watch\` inside callbacks
- Do NOT add new shared widget if existing one works
- Do NOT commit without running \`node tool/verify/run.mjs\` (produces pass-marker)
- Do NOT run \`flutter analyze\` / \`flutter test\` / \`build_runner\` directly — use \`verify\`

---

## Step 3 — Implement

${implOrder(row.layer)}

---

## Step 4 — Inner loop (run after each significant change)

\`\`\`bash
node tool/verify/run.mjs --quick --test <test-paths>
\`\`\`

- Fast feedback; does **not** write a pass-marker (cannot commit from --quick alone)
- Fix all analyzer warnings before continuing
- Replace \`<test-paths>\` with the specific test files being worked on
${designParityBlock}
---

## Step 6 — Full verify + parity check + commit

### 6.1 Full verification
\`\`\`bash
node tool/verify/run.mjs --test <test-paths>
\`\`\`
This runs: gen-l10n (if ARB changed) → build_runner → guard → doc_guard → dart fix → dart format → flutter analyze → flutter test → diff --check → writes pass-marker.

After it runs \`dart fix\` / \`dart format\`, inspect the diff and revert changes outside this task's scope.

### 6.2 Pre-commit parity check (8 steps — CLAUDE.md §Pre-commit parity check)
- [ ] 1. User-visible behavior changed → updated business doc + wireframe
- [ ] 2. Schema / persistence changed → updated \`docs/database/schema-contract.md\` + \`migration-contract.md\` + \`storage-boundaries.md\`
- [ ] 3. Route / navigation changed → updated \`docs/business/navigation/navigation-flow.md\` + \`RouteNames\`/\`RoutePaths\`
- [ ] 4. SRS / study algo changed → updated \`docs/business/srs/srs-review.md\` + \`study-flow.md\` + decision table
- [ ] 5. Rule / validation changed → updated corresponding doc
- [ ] 6. New testable behavior branch → added row in decision table + test
- [ ] 7. Specified → Implemented transition → updated status in \`docs/business/system/overview.md\`
- [ ] 8. Renamed any term/route/field → fixed ALL refs (\`node tool/doc_guard/run.mjs terms <old>\`)

### 6.3 WBS §10 Traceability Log
Append **one line** to \`docs/project-management/wbs.md\` §10 (newest first):
\`\`\`
| \`<8-char-hash>\` | ${today} | ${row.id} | {one-line summary of what was implemented} |
\`\`\`
(The short hash is known after commit; amend the WBS log in the next commit if needed.)

### 6.4 Doc regeneration (if route / schema / use case / screen changed)
\`\`\`bash
node tool/doc_guard/run.mjs generate
\`\`\`
Then re-run verify to catch any new doc_guard findings on the generated files.

### 6.5 Commit + push
\`\`\`bash
git add <files>
git commit -m "<type>: <subject>

Co-Authored-By: Claude <noreply@anthropic.com>"
git push -u origin <branch>
\`\`\`

---

## Expected report format

Follow \`docs/checklist/implementation-checklist.md\` §Final report template. Include at minimum:

- **Summary** — 1-3 sentences
- **WBS:** ${row.id}
- **Changed code files** — paths
- **Changed doc files** — paths (or "no docs needed because: …")
- **Doc-code parity check** — 8 ticks
- **Drift detected** — any legacy mismatches found during task
- **Business / UX impact** — what user sees differently
- **Route impact** — routes added/changed (none / list)
- **Persistence impact** — schema/storage changes (none / list)
- **UI impact** — screens/widgets changed (none / list)
- **Decision table / test impact** — rows touched, tests added
- **Verification result** — pass/fail from \`node tool/verify/run.mjs\`
- **Guard status** — pass / skipped (tool not present) / skipped (reason)
- **WBS update** — log entry appended / not needed (reason)
- **Skipped checks or risks** — explicit, with reason
`;
}

// ── phase overview ────────────────────────────────────────────────────────────

function generatePhaseOverview(phaseKey, phases, allRows) {
  const phase = phases.get(phaseKey);
  if (!phase) {
    console.error(`Unknown phase: ${phaseKey}. Available: ${[...phases.keys()].join(', ')}`);
    process.exit(1);
  }

  // Heuristic: which rows belong to this phase?
  // Use the scope description to extract WBS ID prefixes / explicit IDs.
  const scopeText = phase.scope;
  const mentionedIds = new Set();

  // Extract explicit IDs like 1.1.1 or ranges like 1.2.1–1.2.5
  for (const m of scopeText.matchAll(/(\d+\.\d+(?:\.\d+)?)/g)) mentionedIds.add(m[1]);

  // For range notation (e.g. "2.1.1–2.21.1"), collect all rows in that group
  const groupPrefixes = new Set();
  for (const m of scopeText.matchAll(/(\d+)\.\d+\.?\d*[–-]\d+\.\d+/g)) groupPrefixes.add(m[1]);
  for (const m of scopeText.matchAll(/(\d+)\.x/g)) groupPrefixes.add(m[1]);

  const phaseRows = [...allRows.values()].filter((r) => {
    if (mentionedIds.has(r.id)) return true;
    const groupPrefix = r.id.split('.')[0];
    return groupPrefixes.has(groupPrefix);
  });

  // Filter to only actionable (non-Implemented, non-Rejected, non-Future) rows
  const todo = phaseRows.filter((r) => !['Implemented', 'Rejected', 'Future'].includes(r.status));
  const done = phaseRows.filter((r) => r.status === 'Implemented');

  const tableRows = todo.map(
    (r) => `| \`${r.id}\` | ${r.function} | ${r.layer} | ${r.dependsOn} | **${r.status}** |`
  ).join('\n');

  const doneRows = done.map(
    (r) => `| \`${r.id}\` | ${r.function} | ${r.layer} | ✅ ${r.status} |`
  ).join('\n');

  // Dependency-ready rows: all deps Implemented
  const ready = todo.filter((r) => {
    if (!r.dependsOn || r.dependsOn === 'none' || r.dependsOn === '-') return true;
    const deps = r.dependsOn.split(/[,;\/]/).map((d) => d.trim()).filter(Boolean);
    return deps.every((dep) => allRows.get(dep)?.status === 'Implemented');
  });

  return `# Phase ${phaseKey} Overview — ${phase.goal}

**Generated:** ${today}
**Scope:** ${scopeText}

## Exit criteria
${phase.exit}

## Rows to implement (${todo.length} remaining, ${done.length} done)

| WBS ID | Function | Layer | Depends on | Status |
| --- | --- | --- | --- | --- |
${tableRows || '_(none — phase complete)_'}

${doneRows ? `### Already implemented\n\n| WBS ID | Function | Layer | Status |\n| --- | --- | --- | --- |\n${doneRows}\n` : ''}
## Ready to start now (all deps Implemented)

${ready.length
  ? ready.map((r) => `- \`${r.id}\` — **${r.function}** (${r.layer})`).join('\n')
  : '_(none ready — resolve dependencies first)_'}

## Generate a prompt for a specific row

\`\`\`bash
node tool/prompt_gen/run.mjs <WBS_ID>
\`\`\`

Example for first ready row:
\`\`\`bash
${ready[0] ? `node tool/prompt_gen/run.mjs ${ready[0].id}` : 'node tool/prompt_gen/run.mjs <WBS_ID>'}
\`\`\`
`;
}

// ── list ──────────────────────────────────────────────────────────────────────

function generateList(allRows, filterStatus) {
  let rows = [...allRows.values()];
  if (filterStatus) rows = rows.filter((r) => r.status.toLowerCase() === filterStatus.toLowerCase());

  const lines = rows.map(
    (r) => `| \`${r.id}\` | ${r.flow} | ${r.function} | ${r.layer} | ${r.status} |`
  );

  return `# WBS Row List${filterStatus ? ` (status: ${filterStatus})` : ''}\n\nGenerated: ${today}\n\n| WBS ID | Flow | Function | Layer | Status |\n| --- | --- | --- | --- | --- |\n${lines.join('\n')}\n`;
}

// ── main ──────────────────────────────────────────────────────────────────────

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args[0] === '--help') {
    console.log(`Usage:
  node tool/prompt_gen/run.mjs <WBS_ID> [<WBS_ID2> ...]   # generate prompt(s)
  node tool/prompt_gen/run.mjs --phase <N>                 # phase overview + ready rows
  node tool/prompt_gen/run.mjs --list [--status <S>]       # list all WBS rows
  node tool/prompt_gen/run.mjs --next                      # show §5 Next tasks from WBS

Examples:
  node tool/prompt_gen/run.mjs 1.2.1
  node tool/prompt_gen/run.mjs 1.1.1 1.1.3 1.1.4          # multi-row prompt
  node tool/prompt_gen/run.mjs --phase 0
  node tool/prompt_gen/run.mjs --list --status Specified`);
    process.exit(0);
  }

  if (!existsSync(wbsPath)) {
    console.error(`WBS not found: ${wbsPath}`);
    process.exit(2);
  }

  const wbsText = readFileSync(wbsPath, 'utf8');
  const allRows = parseWbsRows(wbsText);
  const phases = parsePhaseTable(wbsText);

  // --phase N
  if (args[0] === '--phase') {
    const phaseKey = args[1];
    if (!phaseKey) { console.error('Usage: --phase <N>'); process.exit(1); }
    console.log(generatePhaseOverview(phaseKey, phases, allRows));
    return;
  }

  // --list [--status S]
  if (args[0] === '--list') {
    const si = args.indexOf('--status');
    const filterStatus = si >= 0 ? args[si + 1] : null;
    console.log(generateList(allRows, filterStatus));
    return;
  }

  // --next
  if (args[0] === '--next') {
    console.log(parseNextSection(wbsText));
    return;
  }

  // WBS ID(s)
  const ids = args.filter((a) => !a.startsWith('--'));
  if (ids.length === 0) {
    console.error('No WBS IDs provided. Run with --help for usage.');
    process.exit(1);
  }

  const rows = [];
  for (const id of ids) {
    const row = allRows.get(id);
    if (!row) {
      console.error(`WBS ID not found: ${id}`);
      const suggestions = [...allRows.keys()].filter((k) => k.startsWith(id.split('.')[0] + '.'));
      if (suggestions.length) console.error(`  Did you mean one of: ${suggestions.slice(0, 6).join(', ')}?`);
      process.exit(1);
    }
    rows.push(row);
  }

  if (rows.length === 1) {
    console.log(generatePrompt(rows[0], allRows));
  } else {
    // Multi-row: generate a combined prompt
    const combinedIds = rows.map((r) => r.id).join(', ');
    const combinedFunctions = rows.map((r) => r.function).join(' + ');
    const allDeps = [...new Set(rows.flatMap((r) => depWarnings(r, allRows)))];
    const allSpecific = [...new Set(rows.flatMap((r) => buildReadingList(r, detectEntity(r))))];
    const allEvidence = rows.map((r) => r.evidence).filter(Boolean).join('; ');
    const hasAnyFE = rows.some((r) => r.layer.toLowerCase().includes('fe') || r.layer.toLowerCase().includes('integration'));

    console.log(`# Claude Code Task Prompt — WBS ${combinedIds}

**Generated:** ${today}
**Tasks:** ${combinedFunctions}

> This prompt covers ${rows.length} tightly coupled WBS rows. Build them in dependency order.

## Rows in this prompt

| WBS ID | Function | Layer | Depends on | Status |
| --- | --- | --- | --- | --- |
${rows.map((r) => `| \`${r.id}\` | ${r.function} | ${r.layer} | ${r.dependsOn} | ${r.status} |`).join('\n')}

${allDeps.length ? `## ⚠️ Dependency warnings\n\n${allDeps.join('\n')}\n` : ''}
---

## Step 1 — Read first

### Universal
${UNIVERSAL_DOCS.map((d) => `- \`${d}\``).join('\n')}

### Task-specific
${allSpecific.map((d) => `- \`${d}\``).join('\n')}

${hasAnyFE ? '### Mock shots (FE tasks)\nSee `docs/system-design/MemoX Design System/ui_kits/mobile/shots/INDEX.md` for each screen.' : ''}

---

## Step 2 — Drift check

Stop and report DRIFT before any code. See individual row prompts for entity-specific protocol.

---

## Step 3 — Implement (in dependency order)

${rows.map((r, i) => `### ${i + 1}. WBS ${r.id} — ${r.function}\n\n**Deliverable:** ${r.deliverable}\n\n${implOrder(r.layer)}`).join('\n\n')}

---

## Step 4 — Inner loop
\`\`\`bash
node tool/verify/run.mjs --quick --test <test-paths>
\`\`\`

---

## Step 6 — Full verify + parity + commit

\`\`\`bash
node tool/verify/run.mjs --test <test-paths>
\`\`\`

Pre-commit parity check (8 ticks — CLAUDE.md §Pre-commit parity check):
- [ ] 1–8. (see individual prompts or CLAUDE.md)

WBS §10 Traceability Log — append one line per WBS ID committed:
\`\`\`
| \`<hash>\` | ${today} | ${combinedIds} | {summary} |
\`\`\`

\`\`\`bash
git add <files> && git commit -m "<message>" && git push -u origin <branch>
\`\`\`

---

## Expected report

Follow \`docs/checklist/implementation-checklist.md\`. List each WBS ID separately in the impact sections.
`);
  }
}

main();
