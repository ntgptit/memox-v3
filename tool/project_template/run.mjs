// project_template — scaffolds a complete "Claude-Code-ready" project skeleton.
//
// Goal: when you hand a task to Claude Code on a NEW project, it should only
// have to FILL IN correct content — never re-brainstorm the architecture, the
// doc layout, the guard/verify pipeline, or the agent rules. This generator
// emits that whole skeleton (docs source-of-truth + parity rules + verify
// single-entry + doc_guard + prompt_gen + agents + git hooks), pre-wired and
// full of explicit `<!-- FILL: ... -->` placeholders.
//
// It is config-driven and stack-agnostic: a single `scaffold.config.json`
// captures project name / language / framework / source+test dirs / verify
// command chains. The generated `tool/verify` and `tool/doc_guard` read that
// config at runtime, so the same skeleton works for Flutter, Node, Python, Go…
//
// Usage (zero npm dependencies; Node 18+):
//   node tool/project_template/run.mjs init <target-dir> [options]
//   node tool/project_template/run.mjs list                 # files that would be written
//   node tool/project_template/run.mjs --help
//
// init options:
//   --name "<Project Name>"     human name              (default: target dir basename)
//   --slug "<slug>"             machine slug            (default: derived from name)
//   --repo "<owner/repo>"       git remote slug         (default: "owner/repo")
//   --stack <preset>            flutter|node|python|go|generic   (default: generic)
//   --language "<lang>"         overrides preset language
//   --framework "<fw>"          overrides preset framework
//   --source-dir <dir>          source root             (preset default)
//   --test-dir <dir>            test root               (preset default)
//   --manifest <file>           dependency manifest     (preset default)
//   --force                     overwrite existing files (default: skip + warn)
//   --dry                       print plan, write nothing
//
// Exit codes: 0 = ok, 1 = usage error / write conflict without --force.

import {
  existsSync, readFileSync, writeFileSync, readdirSync, statSync, mkdirSync, chmodSync,
} from 'node:fs';
import { join, resolve, dirname, relative, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const templatesDir = join(here, 'templates');
const today = new Date().toISOString().slice(0, 10);

// ── stack presets ────────────────────────────────────────────────────────────
// Each preset only fills sensible DEFAULTS for the config; everything is
// overridable on the CLI. The generated docs/tools never hardcode the stack —
// they read scaffold.config.json — so "generic" is always a valid choice.
const PRESETS = {
  generic: {
    language: '<language>', framework: '<framework / none>',
    sourceDir: 'src', testDir: 'test', manifest: '<manifest file>',
    verifyDocs: ['node tool/doc_guard/run.mjs check'],
    verifyCode: ['<lint command>', '<type-check command>', '<test command>'],
  },
  flutter: {
    language: 'Dart 3', framework: 'Flutter (Material 3)',
    sourceDir: 'lib', testDir: 'test', manifest: 'pubspec.yaml',
    verifyDocs: ['node tool/doc_guard/run.mjs check'],
    verifyCode: ['dart format --output=none --set-exit-if-changed .', 'flutter analyze', 'flutter test'],
  },
  node: {
    language: 'TypeScript / Node.js', framework: 'none',
    sourceDir: 'src', testDir: 'test', manifest: 'package.json',
    verifyDocs: ['node tool/doc_guard/run.mjs check'],
    verifyCode: ['npm run lint', 'npm run typecheck', 'npm test'],
  },
  python: {
    language: 'Python 3', framework: 'none',
    sourceDir: 'src', testDir: 'tests', manifest: 'pyproject.toml',
    verifyDocs: ['node tool/doc_guard/run.mjs check'],
    verifyCode: ['ruff check .', 'mypy .', 'pytest -q'],
  },
  go: {
    language: 'Go', framework: 'none',
    sourceDir: 'internal', testDir: 'internal', manifest: 'go.mod',
    verifyDocs: ['node tool/doc_guard/run.mjs check'],
    verifyCode: ['gofmt -l .', 'go vet ./...', 'go test ./...'],
  },
};

// ── arg parsing ──────────────────────────────────────────────────────────────
const argv = process.argv.slice(2);
if (argv.includes('--help') || argv.includes('-h') || argv.length === 0) {
  printHelp();
  process.exit(0);
}

const cmd = argv[0];
const flagVal = (name, def) => {
  const i = argv.indexOf(name);
  return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : def;
};
const hasFlag = (name) => argv.includes(name);

function slugify(s) {
  return String(s).toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
}

// ── walk the template tree ───────────────────────────────────────────────────
function walk(dir, out = []) {
  for (const e of readdirSync(dir)) {
    const p = join(dir, e);
    if (statSync(p).isDirectory()) walk(p, out);
    else out.push(p);
  }
  return out;
}

// Template filenames use `__dot__` for leading dots and `.tmpl` suffix to keep
// the template tree from being treated as real config by tooling. Strip both.
function outRelPath(absTemplatePath) {
  let r = relative(templatesDir, absTemplatePath).split(sep).join('/');
  r = r.replace(/\.tmpl$/, '').replaceAll('__dot__', '.');
  return r;
}

function substitute(content, tokens) {
  return content.replace(/\{\{([A-Z0-9_]+)\}\}/g, (m, key) =>
    Object.prototype.hasOwnProperty.call(tokens, key) ? tokens[key] : m,
  );
}

// ── commands ─────────────────────────────────────────────────────────────────
if (cmd === 'list') {
  if (!existsSync(templatesDir)) fail('templates/ directory not found next to run.mjs');
  for (const f of walk(templatesDir).sort()) console.log(outRelPath(f));
  process.exit(0);
}

if (cmd !== 'init') fail(`unknown command "${cmd}". Run with --help.`);

const target = argv[1] && !argv[1].startsWith('--') ? resolve(argv[1]) : null;
if (!target) fail('init requires a target directory: `init <target-dir>`');

const stack = flagVal('--stack', 'generic');
const preset = PRESETS[stack];
if (!preset) fail(`unknown --stack "${stack}". One of: ${Object.keys(PRESETS).join(', ')}`);

const name = flagVal('--name', target.split(sep).pop());
const slug = flagVal('--slug', slugify(name));
const repo = flagVal('--repo', 'owner/repo');
const language = flagVal('--language', preset.language);
const framework = flagVal('--framework', preset.framework);
const sourceDir = flagVal('--source-dir', preset.sourceDir);
const testDir = flagVal('--test-dir', preset.testDir);
const manifest = flagVal('--manifest', preset.manifest);
const force = hasFlag('--force');
const dry = hasFlag('--dry');

const config = {
  project: { name, slug, repo },
  stack: { preset: stack, language, framework, architecture: 'clean' },
  layers: { sourceDir, testDir, manifest },
  verify: { docs: preset.verifyDocs, code: preset.verifyCode },
};

const tokens = {
  PROJECT_NAME: name,
  PROJECT_SLUG: slug,
  REPO: repo,
  STACK_PRESET: stack,
  STACK_LANGUAGE: language,
  STACK_FRAMEWORK: framework,
  SOURCE_DIR: sourceDir,
  TEST_DIR: testDir,
  MANIFEST_FILE: manifest,
  DATE: today,
  SCAFFOLD_CONFIG_JSON: JSON.stringify(config, null, 2),
};

if (!existsSync(templatesDir)) fail('templates/ directory not found next to run.mjs');

console.log(`\nScaffolding "${name}" (stack: ${stack}) → ${target}${dry ? '  [DRY RUN]' : ''}\n`);

const files = walk(templatesDir).sort();
let written = 0, skipped = 0;
for (const tpl of files) {
  const rel = outRelPath(tpl);
  const dest = join(target, rel);
  const raw = readFileSync(tpl, 'utf8');
  const content = substitute(raw, tokens);

  if (existsSync(dest) && !force) {
    console.log(`  skip   ${rel}  (exists; use --force)`);
    skipped++;
    continue;
  }
  if (dry) {
    console.log(`  would  ${rel}`);
    continue;
  }
  mkdirSync(dirname(dest), { recursive: true });
  writeFileSync(dest, content);
  if (rel.startsWith('.githooks/')) chmodSync(dest, 0o755); // git ignores non-executable hooks
  console.log(`  write  ${rel}`);
  written++;
}

if (!dry) {
  console.log(`\nDone. ${written} written, ${skipped} skipped.\n`);
  console.log('Next steps:');
  console.log(`  1. cd ${relative(process.cwd(), target) || '.'}`);
  console.log('  2. Open scaffold.config.json — confirm name/stack/verify commands.');
  console.log('  3. Open CLAUDE.md — fill every <!-- FILL: ... --> marker (start at the top).');
  console.log('  4. git init && git config core.hooksPath .githooks   (enable marker-gated commits)');
  console.log('  5. node tool/doc_guard/run.mjs generate               (build docs/_generated/*)');
  console.log('  6. Hand the first task to Claude Code — it fills, it does not invent.\n');
} else {
  console.log('\n[dry run] nothing written.\n');
}

// ── helpers ──────────────────────────────────────────────────────────────────
function fail(msg) {
  console.error(`project_template: ${msg}`);
  process.exit(1);
}

function printHelp() {
  console.log(`project_template — scaffold a Claude-Code-ready project skeleton.

Usage:
  node tool/project_template/run.mjs init <target-dir> [options]
  node tool/project_template/run.mjs list
  node tool/project_template/run.mjs --help

Options for init:
  --name "<Project Name>"   human name (default: target basename)
  --slug "<slug>"           machine slug (default: from name)
  --repo "<owner/repo>"     git slug (default: owner/repo)
  --stack <preset>          ${Object.keys(PRESETS).join(' | ')}   (default: generic)
  --language "<lang>"       override preset language
  --framework "<fw>"        override preset framework
  --source-dir <dir>        source root (preset default)
  --test-dir <dir>          test root (preset default)
  --manifest <file>         dependency manifest (preset default)
  --force                   overwrite existing files
  --dry                     print plan, write nothing

What it writes: CLAUDE.md + AGENTS.md + scaffold.config.json + docs/ (source of
truth + parity rules + contracts + WBS + decision table + checklists) +
tool/{verify,doc_guard,prompt_gen} + .claude/agents/ + .githooks/.

Every doc is a skeleton full of <!-- FILL: ... --> markers so Claude Code only
fills correct content instead of re-brainstorming the structure.`);
}
