// doc_guard — docs/process linter + repo-map generator for MemoX.
//
// Guards the zone `code-verification-guard` does not cover: claims made by docs
// about the codebase. Saves agent tokens by replacing the recurring manual
// audits (path/symbol/test-ref existence, WBS hygiene, ARB hygiene) with one
// command, and by generating `docs/_generated/repo-map.md` so cold agent
// sessions read one small file instead of re-exploring the repo.
//
// Usage (from repo root or this dir; zero npm dependencies):
//   node tool/doc_guard/run.mjs check        # all doc/process checks (CI gate)
//   node tool/doc_guard/run.mjs generate     # regenerate docs/_generated/{repo-map,where-is}.md
//   node tool/doc_guard/run.mjs terms <old>  # find leftover refs to a renamed term
//
// Exit codes: 0 = clean (warnings allowed), 1 = errors found, 2 = tool failure.
//
// Suppression: a doc line whose +/-2-line window contains a negation/target
// marker ("does not exist", "target structure", "previous iteration", "TBD",
// "Future", "removed", ...) is exempt from existence checks — docs are allowed
// to talk about things that intentionally do not exist yet.

import { existsSync, readFileSync, writeFileSync, readdirSync, statSync, mkdirSync } from 'node:fs';
import { join, resolve, dirname, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const rel = (p) => p.slice(repoRoot.length + 1).replaceAll(sep, '/');

function walk(dir, out = []) {
  for (const e of readdirSync(dir)) {
    const p = join(dir, e);
    const st = statSync(p);
    if (st.isDirectory()) {
      if (['node_modules', '.git', '.dart_tool', 'build', 'generated'].includes(e)) continue;
      walk(p, out);
    } else out.push(p);
  }
  return out;
}

const docFiles = () => [
  ...walk(join(repoRoot, 'docs')).filter((p) => p.endsWith('.md')),
  join(repoRoot, 'CLAUDE.md'),
  ...(existsSync(join(repoRoot, 'AGENTS.md')) ? [join(repoRoot, 'AGENTS.md')] : []),
];

const libSource = () => {
  const files = walk(join(repoRoot, 'lib'))
    .filter((p) => p.endsWith('.dart') && !rel(p).startsWith('lib/l10n/generated'));
  return { files, all: files.map((p) => readFileSync(p, 'utf8')).join('\n') };
};
const testSource = () =>
  walk(join(repoRoot, 'test')).filter((p) => p.endsWith('.dart')).map((p) => readFileSync(p, 'utf8')).join('\n');

// ── suppression ──────────────────────────────────────────────────────────────
const NEGATION = [
  'does not exist', 'do not exist', 'not exist', 'no longer exist', 'there is no',
  'none of th', 'removed', 'former', 'phantom', 'previous iteration', 'target',
  'future', 'tbd', 'deferred', 'specified', 'planned', 'when built', 'when implemented',
  'do not edit', 'rejected', 'not applicable', 'legacy', 'pending', 'blocked',
  'must not be', 'never emitted', 'drift note', 'drift correction', 'earlier revision',
  'example', 'e.g.',
];
// A reference is suppressed when a negation/target marker appears within +/-2
// lines OR anywhere between the line and its nearest preceding heading (so a
// "Target structure (none exist yet):" intro covers the whole list under it).
function suppressed(lines, idx) {
  for (let i = Math.max(0, idx - 2); i <= Math.min(lines.length - 1, idx + 2); i++) {
    const l = lines[i].toLowerCase();
    if (NEGATION.some((m) => l.includes(m))) return true;
  }
  for (let i = idx - 3; i >= Math.max(0, idx - 40); i--) {
    const l = lines[i].toLowerCase();
    if (NEGATION.some((m) => l.includes(m))) return true;
  }
  return false;
}

// Docs whose header declares the whole feature unbuilt get their not-found
// findings downgraded to warnings (the doc is ALLOWED to describe its target).
function fileIsTargetSpec(lines) {
  return lines
    .slice(0, 30)
    .some((l) => /status.*(specified|future|target|proposal|not.*implement)/i.test(l));
}

// ── findings ─────────────────────────────────────────────────────────────────
const errors = [];
const warnings = [];
const err = (file, line, msg) => errors.push(`${rel(file)}:${line}  ${msg}`);
const warn = (file, line, msg) => warnings.push(`${rel(file)}:${line}  ${msg}`);

// ── check 1: backtick repo paths exist ───────────────────────────────────────
function checkPaths() {
  const prefixes = ['docs/', 'lib/', 'test/', 'tool/'];
  for (const file of docFiles()) {
    const lines = readFileSync(file, 'utf8').split('\n');
    const report = fileIsTargetSpec(lines) ? warn : err;
    lines.forEach((line, i) => {
      for (const m of line.matchAll(/`([^`]+)`/g)) {
        let token = m[1].trim();
        if (!prefixes.some((p) => token.startsWith(p))) continue;
        if (token.includes('{') || token.includes('<')) continue; // template/example
        token = token.split('::')[0]; // `path::test name` → path (names checked by checkTestRefs)
        token = token.replace(/:[\d,§A-Za-z.-]*$/, ''); // strip :line / :§sec suffix
        const star = token.indexOf('*');
        if (star >= 0) {
          // Glob pattern: only require the directory part of the prefix to exist.
          const prefix = token.slice(0, star);
          token = prefix.includes('/') ? prefix.slice(0, prefix.lastIndexOf('/')) : prefix;
        }
        token = token.replace(/\/+$/, '');
        if (!token || token === 'docs' || token === 'lib') continue;
        if (existsSync(join(repoRoot, token))) continue;
        if (suppressed(lines, i)) continue;
        report(file, i + 1, `path not found: ${m[1]}`);
      }
    });
  }
}

// ── check 2: Dart symbols mentioned by docs exist in source ─────────────────
const SYMBOL_SUFFIX =
  /^[A-Z][A-Za-z0-9]*(UseCase|Screen|Repository|RepositoryImpl|Dao|Notifier|ViewModel|Service|Controller|Dialog|Sheet|Strategy|Factory)$/;
function checkSymbols(lib, tests) {
  // UI-kit JSX components are legitimate doc references — include the kit source.
  const kitHtml = join(repoRoot, 'docs', 'system-design', 'MemoX Design System', 'ui_kits', 'mobile', 'index.html');
  const haystack = lib + tests + (existsSync(kitHtml) ? readFileSync(kitHtml, 'utf8') : '');
  for (const file of docFiles()) {
    if (rel(file) === 'docs/contracts/code-style.md') continue; // naming examples by design
    const lines = readFileSync(file, 'utf8').split('\n');
    const report = fileIsTargetSpec(lines) ? warn : err;
    lines.forEach((line, i) => {
      for (const m of line.matchAll(/`([A-Za-z0-9_.]+)`/g)) {
        const sym = m[1].split('.')[0];
        if (!SYMBOL_SUFFIX.test(sym)) continue;
        if (haystack.includes(sym)) continue;
        if (suppressed(lines, i)) continue;
        report(file, i + 1, `Dart symbol not found in lib/ or test/: ${sym}`);
      }
    });
  }
}

// ── check 3: `test/...::name` refs resolve to a real test ───────────────────
function checkTestRefs() {
  for (const file of docFiles()) {
    const lines = readFileSync(file, 'utf8').split('\n');
    lines.forEach((line, i) => {
      for (const m of line.matchAll(/`(test\/[^`:]+\.dart)::([^`]+)`/g)) {
        const [, path, name] = m;
        const abs = join(repoRoot, path);
        if (!existsSync(abs)) {
          if (!suppressed(lines, i)) err(file, i + 1, `test file not found: ${path}`);
          continue;
        }
        const probe = name.split('+')[0].trim(); // "S12+S15" style → probe first id
        if (!readFileSync(abs, 'utf8').includes(probe)) {
          if (!suppressed(lines, i)) err(file, i + 1, `test name "${probe}" not found in ${path}`);
        }
      }
    });
  }
}

// ── check 4: WBS hygiene ─────────────────────────────────────────────────────
const WBS_STATUS = ['Implemented', 'Partial', 'Specified', 'Target', 'Future', 'Blocked', 'Rejected', 'Ongoing'];
function checkWbs() {
  const wbsPath = join(repoRoot, 'docs', 'project-management', 'wbs.md');
  const text = readFileSync(wbsPath, 'utf8');
  const lines = text.split('\n');
  const sec4 = text.indexOf('## 4.');
  const sec5 = text.indexOf('## 5.');
  const sec10 = text.indexOf('## 10.');
  const lineNoOf = (charIdx) => text.slice(0, charIdx).split('\n').length;

  const hashes = new Set();
  lines.forEach((line, i) => {
    const charIdx = lines.slice(0, i).join('\n').length;
    const inPlan = charIdx > sec4 && charIdx < sec5;
    const inLog = charIdx > sec10;

    if (inPlan && /^\| \d+(\.\d+){1,2} \|/.test(line)) {
      const cells = line.replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
      if (cells.length !== 10) err(wbsPath, i + 1, `WBS function row has ${cells.length} columns, expected 10`);
      else {
        const status = cells[5].split(/[ —(]/)[0];
        if (!WBS_STATUS.includes(status)) err(wbsPath, i + 1, `unknown WBS status "${cells[5]}"`);
        const commit = cells[8];
        const h = commit.match(/`([0-9a-f]{7,10})`/);
        if (h) hashes.add(h[1]);
        else if (commit !== 'TBD') warn(wbsPath, i + 1, `Commit ID is neither TBD nor a backtick hash: "${commit}"`);
        if (status === 'Implemented' && commit === 'TBD' && !/no single anchor|spans many/i.test(cells[9]))
          warn(wbsPath, i + 1, `Implemented row without commit anchor (use a verified hash where practical)`);
        if (['Specified', 'Future', 'Blocked'].includes(status) && h)
          warn(wbsPath, i + 1, `${status} row carries a commit hash — should be TBD until implemented`);
      }
    }
    if (inLog) {
      const h = line.match(/^\| `([0-9a-f]{7,10})` \|/);
      if (h) hashes.add(h[1]);
    }
  });

  for (const h of hashes) {
    try {
      execFileSync('git', ['rev-parse', '--quiet', '--verify', `${h}^{commit}`], { cwd: repoRoot, stdio: 'pipe' });
    } catch {
      err(wbsPath, lineNoOf(text.indexOf(h)), `commit hash not found in git history: ${h}`);
    }
  }
}

// ── check 5: ARB hygiene ─────────────────────────────────────────────────────
function arbKeys(path) {
  // Count TOP-LEVEL keys only (exactly 2-space indent in ARB files); deeper
  // indents are metadata inside "@key" blocks (description/placeholders/...)
  // where repeated names are normal JSON structure, not duplicates.
  const counts = new Map();
  for (const line of readFileSync(path, 'utf8').split('\n')) {
    const m = line.match(/^ {2}"([^"@][^"]*)"\s*:/);
    if (m) counts.set(m[1], (counts.get(m[1]) ?? 0) + 1);
  }
  return counts;
}
function checkArb(lib) {
  const enPath = join(repoRoot, 'lib', 'l10n', 'app_en.arb');
  const viPath = join(repoRoot, 'lib', 'l10n', 'app_vi.arb');
  if (!existsSync(enPath) || !existsSync(viPath)) { err(enPath, 1, 'ARB file missing'); return; }
  const en = arbKeys(enPath);
  const vi = arbKeys(viPath);
  for (const [k, n] of en) if (n > 1) warn(enPath, 1, `duplicate key in app_en.arb (last wins): ${k} ×${n}`);
  for (const [k, n] of vi) if (n > 1) warn(viPath, 1, `duplicate key in app_vi.arb (last wins): ${k} ×${n}`);
  for (const k of en.keys()) if (!vi.has(k)) warn(viPath, 1, `key missing in app_vi.arb: ${k}`);
  for (const k of vi.keys()) if (!en.has(k)) warn(enPath, 1, `key missing in app_en.arb: ${k}`);
  let unused = 0;
  for (const k of en.keys()) {
    if (!new RegExp(`\\.${k}\\b`).test(lib)) { unused++; if (unused <= 15) warn(enPath, 1, `key not referenced in lib/ (excluding generated): ${k}`); }
  }
  if (unused > 15) warn(enPath, 1, `...and ${unused - 15} more unreferenced keys`);
}

// ── check 6: schema-contract version matches code ────────────────────────────
function checkSchema() {
  const db = readFileSync(join(repoRoot, 'lib', 'data', 'datasources', 'local', 'app_database.dart'), 'utf8');
  const codeV = db.match(/currentSchemaVersion\s*=\s*(\d+)/)?.[1];
  const contractPath = join(repoRoot, 'docs', 'database', 'schema-contract.md');
  const contract = readFileSync(contractPath, 'utf8');
  const docV = contract.match(/schema_version:\s*(\d+)/)?.[1];
  if (codeV && docV && codeV !== docV)
    err(contractPath, 1, `schema_version drift: doc says v${docV}, code says v${codeV}`);
  const tables = driftTables();
  for (const t of tables.keys()) {
    if (!contract.includes(`\`${t}\``) && !contract.includes(`| \`${t}\``) && !contract.includes(t))
      warn(contractPath, 1, `table "${t}" exists in .drift but is not mentioned in schema-contract.md`);
  }
}

// ── repo facts (shared by generate + checks) ─────────────────────────────────
function driftTables() {
  const tables = new Map();
  const dir = join(repoRoot, 'lib', 'data', 'datasources', 'local', 'drift');
  if (!existsSync(dir)) return tables;
  for (const f of readdirSync(dir).filter((f) => f.endsWith('.drift'))) {
    const text = readFileSync(join(dir, f), 'utf8');
    for (const m of text.matchAll(/CREATE TABLE (\w+)/g)) {
      const body = text.slice(m.index, text.indexOf(';', m.index));
      const cols = [...body.matchAll(/^\s{2}(\w+)\s/gm)].map((c) => c[1]);
      tables.set(m[1], cols);
    }
  }
  return tables;
}

function routeInventory(lib) {
  const pathsFile = readFileSync(join(repoRoot, 'lib', 'app', 'router', 'route_paths.dart'), 'utf8');
  const paths = [...pathsFile.matchAll(/static const String (\w+)\s*=\s*'([^']+)'/g)]
    .filter(([, , v]) => v.startsWith('/'))
    .map(([, name, value]) => ({ name, value }));
  const placeholders = new Set([...lib.matchAll(/RoutePlaceholder\(\s*routeName:\s*RouteNames\.(\w+)/g)].map((m) => m[1]));
  return { paths, placeholders };
}

function countGlob(dir, suffix = '.dart') {
  const abs = join(repoRoot, dir);
  if (!existsSync(abs)) return [];
  return walk(abs).filter((p) => p.endsWith(suffix) && !/\.(g|freezed)\.dart$/.test(p)).map(rel);
}

// ── generate: docs/_generated/where-is.md ────────────────────────────────────
// Deterministic feature -> location index. The registry below holds STABLE doc
// paths and source-name PATTERNS; actual file lists are resolved live against
// the repo on every `generate`, so the index cannot drift (and doc_guard
// path-checks the generated output like any other doc). One row answers
// "where is X handled?" without any searching.
const WHERE_IS = [
  { f: 'Folder create', docs: ['docs/business/folder/folder-management.md', 'docs/contracts/usecase-contracts/folder.md', 'docs/wireframes/24-shared-dialogs.md'], src: ['create_root_folder', 'create_subfolder', 'mx_folder_form_dialog'], shots: ['03','04'], wbs: '2.1.x' },
  { f: 'Folder rename', docs: ['docs/business/folder/folder-management.md', 'docs/contracts/usecase-contracts/folder.md'], src: ['rename_folder', 'library_folder_actions_sheet', 'mx_name_dialog'], shots: ['03','04'], wbs: '2.2.x' },
  { f: 'Folder delete', docs: ['docs/business/folder/folder-management.md', 'docs/contracts/usecase-contracts/folder.md'], src: ['delete_folder', 'mx_folder_delete_dialog'], shots: ['03','04'], wbs: '2.3.x, 2.21.1' },
  { f: 'Folder move', docs: ['docs/business/folder/folder-management.md', 'docs/contracts/usecase-contracts/folder.md'], src: ['move_folder', 'folder_move'], shots: ['04'], wbs: '2.4.x' },
  { f: 'Folder reorder', docs: ['docs/business/folder/folder-management.md'], src: ['reorder_folders'], shots: ['04'], wbs: '2.5.x' },
  { f: 'Folder content-mode lock', docs: ['docs/business/folder/folder-management.md', 'docs/business/glossary.md'], src: ['content_mode'], shots: ['04'], wbs: '2.6.1' },
  { f: 'Library overview', docs: ['docs/business/folder/folder-management.md', 'docs/wireframes/02-library.md', 'docs/design/screens/library-overview.visual-contract.md'], src: ['library_overview', 'library_folder_tile', 'library_sections', 'library_skeleton', 'watch_library_overview'], shots: ['03'], wbs: '3.1.x' },
  { f: 'Folder detail screen', docs: ['docs/business/folder/folder-management.md', 'docs/wireframes/05-folder-detail.md'], src: ['folder_detail', 'folder_deck_tile', 'folder_subfolder_tile', 'watch_folder_detail'], shots: ['04'], wbs: '3.2.x' },
  { f: 'Deck create', docs: ['docs/business/deck/deck-management.md', 'docs/contracts/usecase-contracts/deck.md'], src: ['create_deck'], shots: ['04'], wbs: '2.7.x' },
  { f: 'Deck rename', docs: ['docs/business/deck/deck-management.md', 'docs/contracts/usecase-contracts/deck.md'], src: ['rename_deck'], shots: ['06'], wbs: '2.8.x' },
  { f: 'Deck delete', docs: ['docs/business/deck/deck-management.md'], src: ['delete_deck', 'deck_actions_sheet'], shots: ['06'], wbs: '2.9.x' },
  { f: 'Deck reorder', docs: ['docs/business/deck/deck-management.md'], src: ['reorder_decks'], shots: ['04'], wbs: '2.10.x' },
  { f: 'Deck move', docs: ['docs/business/deck/deck-management.md'], src: ['move_deck'], shots: ['04'], wbs: '2.19.x' },
  { f: 'Deck import (CSV/structured)', docs: ['docs/business/flashcard/flashcard-management.md', 'docs/wireframes/10-deck-import.md'], src: ['deck_import', 'flashcard_import', 'flashcard_repository_impl_imports'], shots: ['10'], wbs: '6.x' },
  { f: 'Import duplicate policy', docs: ['docs/business/flashcard/flashcard-management.md'], src: ['prepare_deck_import', 'flashcard_import_preview'], shots: ['10'], wbs: '6.6.x' },
  { f: 'Manual duplicate soft-warning', docs: ['docs/business/flashcard/flashcard-management.md'], src: ['check_manual_duplicate', 'flashcard_duplicate_check', 'duplicate_behavior'], shots: ['07'], wbs: '2.20.x' },
  { f: 'Deck export (CSV)', docs: ['docs/business/export/export.md'], src: ['export_deck', 'flashcard_export'], shots: [], wbs: '8.7.x' },
  { f: 'Flashcard create/edit', docs: ['docs/business/flashcard/flashcard-management.md', 'docs/wireframes/07-flashcard-create.md', 'docs/wireframes/08-flashcard-edit.md'], src: ['flashcard_editor', 'create_flashcard', 'update_flashcard', 'get_flashcard_detail'], shots: ['07','08'], wbs: '2.11.x, 2.12.x' },
  { f: 'Flashcard delete', docs: ['docs/business/flashcard/flashcard-management.md'], src: ['delete_flashcard', 'flashcard_row_actions'], shots: ['06'], wbs: '2.13.x' },
  { f: 'Flashcard reorder', docs: ['docs/business/flashcard/flashcard-management.md'], src: ['reorder_flashcards'], shots: ['06'], wbs: '2.14.x' },
  { f: 'Flashcard list screen', docs: ['docs/business/flashcard/flashcard-management.md', 'docs/wireframes/06-flashcard-list.md'], src: ['flashcard_list', 'flashcard_detail_card_row', 'flashcard_empty_state', 'watch_flashcard_list'], shots: ['06'], wbs: '3.4.x' },
  { f: 'Flashcard tags (input/validation)', docs: ['docs/business/tags/tag-system.md', 'docs/contracts/usecase-contracts/tag.md'], src: ['tag_validator', 'flashcard_tags', 'editor_tags'], shots: ['07'], wbs: '2.15.x' },
  { f: 'Global search', docs: ['docs/business/search/global-search.md', 'docs/wireframes/11-library-search.md'], src: ['search'], shots: ['05'], wbs: '3.5.x' },
  { f: 'Study entry gate', docs: ['docs/business/study/study-flow.md', 'docs/wireframes/12-study-entry-gate.md', 'docs/contracts/usecase-contracts/study.md'], src: ['study_entry'], shots: [], wbs: '4.1.x' },
  { f: 'Study session create/resume/restart', docs: ['docs/business/study/study-flow.md', 'docs/business/resume/resume-session.md'], src: ['study_repo_impl_study_session', 'study_usecases', 'study_repo.dart', 'restart_study', 'start_study'], shots: [], wbs: '4.2.x' },
  { f: 'Study review shell (current card/reveal)', docs: ['docs/business/study/study-flow.md', 'docs/wireframes/16-study-session-recall.md'], src: ['study_session_screen', 'study_session_review', 'study_session_item'], shots: ['15'], wbs: '4.3.x' },
  { f: 'Self-grade answer recording', docs: ['docs/business/srs/srs-review.md', 'docs/business/study/study-flow.md'], src: ['record_answer', 'record_study_session_answer'], shots: ['15'], wbs: '4.4.x' },
  { f: 'Study modes / strategy', docs: ['docs/business/study/study-flow.md', 'docs/wireframes/13-study-session-review.md'], src: ['study_mode_strategy', 'recall_study_mode', 'study_mode.dart'], shots: ['12','13','14','15','16'], wbs: '4.5.x' },
  { f: 'Finalization + SRS transitions', docs: ['docs/business/srs/srs-review.md', 'docs/contracts/usecase-contracts/srs.md'], src: ['study_repo_impl.dart', 'srs_transition'], shots: [], wbs: '4.6.x' },
  { f: 'SRS data model (box/due/progress)', docs: ['docs/business/srs/srs-review.md', 'docs/database/schema-contract.md'], src: ['attempt_result', 'box_number', 'flashcard_progress'], shots: [], wbs: '4.6.x' },
  { f: 'Study result screen', docs: ['docs/business/study/study-flow.md', 'docs/wireframes/18-study-result.md'], src: ['study_result'], shots: ['17'], wbs: '4.7.x' },
  { f: 'Bury / suspend', docs: ['docs/business/study-actions/bury-suspend.md'], src: ['bury', 'suspend'], shots: ['06'], wbs: '4.11.x, 2.17.x' },
  { f: 'Dashboard', docs: ['docs/business/engagement/dashboard-engagement.md', 'docs/wireframes/01-dashboard.md', 'docs/design/screens/dashboard.visual-contract.md'], src: ['dashboard'], shots: ['02'], wbs: '5.x' },
  { f: 'Progress read model / screen', docs: ['docs/wireframes/03-progress.md', 'docs/contracts/repository-contracts/progress-repository.md'], src: ['progress_dao', 'progress_queries', 'progress_repo', 'progress_read_model', 'usecases/progress', 'progress_providers'], shots: ['19'], wbs: '7.x' },
  { f: 'Tag management (settings)', docs: ['docs/business/tags/tag-system.md', 'docs/wireframes/22-settings-tag-management.md'], src: ['tag_repo', 'usecases/tag/', 'tags_with_count', 'tag_management'], shots: ['11'], wbs: '8.3.x' },
  { f: 'Bulk operations', docs: ['docs/business/bulk/bulk-operations.md', 'docs/contracts/usecase-contracts/bulk.md'], src: ['bulk'], shots: ['06'], wbs: '8.9.x' },
  { f: 'Settings hub', docs: ['docs/wireframes/04-settings-hub.md'], src: ['settings_screen', 'settings/routes'], shots: ['20'], wbs: '8.1.x' },
  { f: 'Learning settings', docs: ['docs/wireframes/20-settings-learning.md', 'docs/business/engagement/dashboard-engagement.md'], src: ['learning_settings'], shots: ['22'], wbs: '8.2.x' },
  { f: 'Audio / TTS', docs: ['docs/business/tts/tts-settings.md', 'docs/wireframes/21-settings-audio-speech.md'], src: ['audio_speech', 'tts_'], shots: ['23'], wbs: '8.4.x' },
  { f: 'Account & Drive sync', docs: ['docs/business/account-sync/account-sync.md', 'docs/wireframes/19-settings-account.md'], src: ['account_sync', 'drive_sync', 'cloud_account'], shots: ['21'], wbs: '8.5.x, 8.6.x' },
  { f: 'Router / navigation', docs: ['docs/business/navigation/navigation-flow.md'], src: ['app/router'], shots: [], wbs: '1.1.3' },
  { f: 'Schema / migrations', docs: ['docs/database/schema-contract.md', 'docs/database/migration-contract.md', 'docs/database/drift-guide.md'], src: ['migrations/', 'app_database', '.drift'], shots: [], wbs: '1.1.5' },
];

function whereIs() {
  const inv = walk(join(repoRoot, 'lib'))
    .concat(walk(join(repoRoot, 'test')))
    .map(rel)
    .filter((p) => !/\.(g|freezed)\.dart$/.test(p) && !p.startsWith('lib/l10n/generated'));

  const cap = (arr, n) =>
    arr.length === 0
      ? '—'
      : arr.slice(0, n).map((p) => `\`${p}\``).join('<br>') + (arr.length > n ? `<br>*+${arr.length - n} more*` : '');

  const rows = WHERE_IS.map((e) => {
    const match = (p) => e.src.some((pat) => p.toLowerCase().includes(pat.toLowerCase()));
    const srcHits = inv.filter((p) => p.startsWith('lib/') && match(p));
    const testHits = inv.filter((p) => p.startsWith('test/') && match(p));
    for (const d of e.docs) {
      if (!existsSync(join(repoRoot, d))) console.warn(`where-is: doc missing for "${e.f}": ${d}`);
    }
    const docsCell = e.docs.map((d) => `\`${d}\``).join('<br>');
    const shotsCell = e.shots.length ? e.shots.map((s) => `\`shots/${s}-*\``).join('<br>') : '—';
    return `| ${e.f} | ${docsCell} | ${cap(srcHits, 5)} | ${cap(testHits, 4)} | ${shotsCell} | ${e.wbs} |`;
  });

  const out = [
    '# Where-Is Index (auto-generated — DO NOT EDIT)',
    '',
    'Generated by `node tool/doc_guard/run.mjs generate`. One row answers "where is X handled?" —',
    'docs to read, source files (resolved LIVE against the repo at generation time), tests, mock',
    'shots prefix (under `docs/system-design/MemoX Design System/ui_kits/mobile/shots/` — see its',
    '`INDEX.md`; DOM specs in sibling `specs/`), and WBS rows. `—` means not built yet — check the',
    'WBS row status before assuming anything exists. If this file looks stale, regenerate it.',
    '',
    '| Feature | Docs | Source | Tests | Mock | WBS |',
    '| --- | --- | --- | --- | --- | --- |',
    ...rows,
    '',
  ];
  const outDir = join(repoRoot, 'docs', '_generated');
  mkdirSync(outDir, { recursive: true });
  writeFileSync(join(outDir, 'where-is.md'), out.join('\n'));
  console.log(`generated docs/_generated/where-is.md (${WHERE_IS.length} features)`);
}

// ── generate: docs/_generated/repo-map.md ────────────────────────────────────
function generate() {
  const { all: lib } = libSource();
  const tables = driftTables();
  const dbV = lib.match(/currentSchemaVersion\s*=\s*(\d+)/)?.[1] ?? '?';
  const { paths, placeholders } = routeInventory(lib);
  const head = execFileSync('git', ['log', '--oneline', '-10'], { cwd: repoRoot }).toString().trim();
  const shortHead = execFileSync('git', ['rev-parse', '--short=8', 'HEAD'], { cwd: repoRoot }).toString().trim();

  const usecaseDirs = ['folder', 'deck', 'flashcard', 'search'].map((d) => {
    const files = countGlob(`lib/domain/usecases/${d}`);
    return `${d}(${files.length})`;
  });
  const studyUc = readFileSync(join(repoRoot, 'lib/domain/study/usecases/study_usecases.dart'), 'utf8');
  const studyClasses = [...studyUc.matchAll(/^class (\w+UseCase)/gm)].map((m) => m[1]);
  const screens = countGlob('lib/presentation/features').filter((p) => p.includes('/screens/'));
  const repos = countGlob('lib/domain/repositories');
  const testFiles = countGlob('test').filter((p) => p.endsWith('_test.dart'));

  const routeLines = paths.map(({ name, value }) => {
    const ph = placeholders.has(name) ? ' ⛔ RoutePlaceholder' : ' ✅';
    return `| \`${value}\` | \`RoutePaths.${name}\` |${ph} |`;
  });

  const out = [
    '# Repo Map (auto-generated — DO NOT EDIT)',
    '',
    `Generated by \`node tool/doc_guard/run.mjs generate\` at commit \`${shortHead}\`.`,
    'Cold-start summary for agent sessions: read this BEFORE exploring the repo by hand.',
    'If it looks stale (commit far behind HEAD), regenerate it first.',
    '',
    `## Database — Drift schema v${dbV}`,
    '',
    ...[...tables.entries()].map(([t, cols]) => `- \`${t}\`: ${cols.join(', ')}`),
    '',
    '## Routes',
    '',
    '| Path | Constant | Status |',
    '| --- | --- | --- |',
    ...routeLines,
    '',
    `Placeholders are wired in \`lib/app/router/app_router.dart\` / feature route files.`,
    '',
    '## Domain',
    '',
    `- Use cases: ${usecaseDirs.join(', ')} + study(${studyClasses.length}: ${studyClasses.join(', ')})`,
    `- Repository ports: ${repos.map((p) => `\`${p.split('/').pop()}\``).join(', ')} + \`lib/domain/study/ports/study_repo.dart\``,
    '',
    '## Presentation',
    '',
    ...screens.map((s) => `- \`${s}\``),
    '',
    `## Tests — ${testFiles.length} files`,
    '',
    '## Recent commits',
    '',
    '```text',
    head,
    '```',
    '',
    '## Pointers',
    '',
    '- Delivery plan / status / next tasks: `docs/project-management/wbs.md`',
    '- Mock references: `docs/system-design/MemoX Design System/ui_kits/mobile/shots/INDEX.md` (PNG) + `.../specs/INDEX.md` (DOM specs)',
    '- Doc/process gate: `node tool/doc_guard/run.mjs check`',
    '',
  ];
  const outDir = join(repoRoot, 'docs', '_generated');
  mkdirSync(outDir, { recursive: true });
  writeFileSync(join(outDir, 'repo-map.md'), out.join('\n'));
  console.log(`generated docs/_generated/repo-map.md (schema v${dbV}, ${paths.length} routes, ${screens.length} screens, ${testFiles.length} test files)`);
}

// ── terms: rename leftover scan ──────────────────────────────────────────────
function terms(old) {
  let hits = 0;
  for (const file of docFiles()) {
    readFileSync(file, 'utf8').split('\n').forEach((line, i) => {
      if (line.toLowerCase().includes(old.toLowerCase())) {
        console.log(`${rel(file)}:${i + 1}  ${line.trim().slice(0, 120)}`);
        hits++;
      }
    });
  }
  console.log(hits ? `\n${hits} reference(s) to "${old}" — update ALL in the same commit (CLAUDE.md parity rule).` : `no references to "${old}" in docs.`);
}

// ── baseline ─────────────────────────────────────────────────────────────────
// Known pre-existing findings live in baseline.json (keyed by file+message, no
// line numbers so unrelated edits don't churn it). `check` fails only on NEW
// findings; burn the baseline down over time. `check --update-baseline`
// re-snapshots the current findings.
const baselinePath = join(repoRoot, 'tool', 'doc_guard', 'baseline.json');
const findingKey = (f) => f.replace(/:(\d+)  /, '  '); // drop line number

function runChecks() {
  const { all: lib } = libSource();
  const tests = testSource();
  checkPaths();
  checkSymbols(lib, tests);
  checkTestRefs();
  checkWbs();
  checkArb(lib);
  checkSchema();
}

// ── main ─────────────────────────────────────────────────────────────────────
const cmd = process.argv[2];
if (cmd === 'generate') {
  generate();
  whereIs();
} else if (cmd === 'terms') {
  const old = process.argv[3];
  if (!old) { console.error('usage: run.mjs terms <old-term>'); process.exit(2); }
  terms(old);
} else if (cmd === 'check' || !cmd) {
  runChecks();
  if (process.argv.includes('--update-baseline')) {
    const snapshot = [...new Set(errors.map(findingKey))].sort();
    writeFileSync(baselinePath, JSON.stringify(snapshot, null, 2) + '\n');
    console.log(`baseline updated: ${snapshot.length} known finding(s) recorded.`);
    process.exit(0);
  }
  const baseline = new Set(existsSync(baselinePath) ? JSON.parse(readFileSync(baselinePath, 'utf8')) : []);
  const fresh = errors.filter((e) => !baseline.has(findingKey(e)));
  const known = errors.length - fresh.length;
  if (fresh.length) {
    console.log(`\nNEW ERRORS (${fresh.length}) — docs claim things the repo contradicts:`);
    for (const e of fresh) console.log('  ✖ ' + e);
  }
  if (warnings.length) {
    console.log(`\nwarnings (${warnings.length}):`);
    for (const w of warnings.slice(0, 40)) console.log('  ⚠ ' + w);
    if (warnings.length > 40) console.log(`  ... and ${warnings.length - 40} more`);
  }
  console.log(`\ndoc_guard: ${fresh.length} new error(s), ${known} baselined (burn down via --update-baseline after fixing), ${warnings.length} warning(s).`);
  process.exit(fresh.length ? 1 : 0);
} else {
  console.error('usage: run.mjs [check [--update-baseline]|generate|terms <old>]');
  process.exit(2);
}
