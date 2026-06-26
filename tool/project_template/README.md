# project_template — Claude-Code-ready project scaffolder

Generates a complete **skeleton** for a brand-new project so that when you hand a task to
Claude Code, it only has to **fill in correct content** — never re-brainstorm the
architecture, the docs layout, the verification pipeline, or the agent rules.

It is the generalized, stack-agnostic distillation of this repo's own working setup:
`docs/` as source of truth + the Doc-code parity engine + a single-entry marker-gated
`verify` + `doc_guard` + `prompt_gen` + custom review agents + git hooks.

## Usage

```bash
# Preview the file list
node tool/project_template/run.mjs list

# Scaffold a new project
node tool/project_template/run.mjs init ../my-new-app \
  --name "My New App" --repo "me/my-new-app" --stack node

# Dry run (print plan, write nothing)
node tool/project_template/run.mjs init ../my-new-app --stack flutter --dry
```

Stacks: `generic` (default), `flutter`, `node`, `python`, `go`. Every preset is just
defaults — override any with `--language / --framework / --source-dir / --test-dir /
--manifest`. The generated tools never hardcode the stack; they read `scaffold.config.json`.

## What it writes

```
CLAUDE.md                 # master rules: doc-parity engine, hard rules, trigger map, workflow
AGENTS.md                 # agent entry point + reporting contract
scaffold.config.json      # project name / stack / source+test dirs / verify command chains
docs/                     # source of truth (skeletons full of <!-- FILL: ... --> markers)
  README.md, MANIFEST.md
  business/               # index, glossary, system/overview (status), _feature-template, navigation
  contracts/              # error, types, code-style, usecase + repository contracts (+ templates)
  database/               # schema, migration, storage-boundaries
  decision-tables/        # core-decision-table (every testable branch = a row)
  state/ ui-ux/ testing/ quality/
  project-management/     # wbs.md (task source of truth + §10 commit traceability log)
  checklist/ agent/
tool/
  _lib/env.mjs            # shared: repo-root discovery + config defaults + git-safe wrappers
  verify/run.mjs          # THE single verification entry, marker-gated
  doc_guard/run.mjs       # path-ref guard + repo-map generator + term search
  prompt_gen/run.mjs      # WBS row → ready-to-paste task prompt
  README.md
.claude/agents/           # code-reviewer, docs-drift-detector, test-engineer
.githooks/                # pre-commit (marker gate), pre-push (doc_guard)
```

## The idea: skeleton, not blank page

Every generated doc is a **structured skeleton** with `<!-- FILL: ... -->` markers and a
fixed section layout. Claude Code reads the layout, knows exactly where each kind of
content goes, and fills it — instead of re-inventing the structure each session. The
parity rules, verify gate, and review fan-out then keep code and docs from drifting apart
as the project grows.

## After generating

```bash
cd ../my-new-app
# 1. Fill scaffold.config.json (verify commands for your stack)
# 2. Fill CLAUDE.md <!-- FILL --> markers (start at the top)
git init && git config core.hooksPath .githooks   # enable marker-gated commits
node tool/doc_guard/run.mjs generate               # build docs/_generated/repo-map.md
# 3. Hand the first task to Claude Code (or: node tool/prompt_gen/run.mjs <WBS_ID>)
```

## Extending the template

Templates live under `tool/project_template/templates/`, mirroring the output tree.
Conventions:
- Strip-on-write suffix `.tmpl`; leading dots written as `__dot__` (e.g.
  `__dot__githooks/` → `.githooks/`).
- Tokens `{{LIKE_THIS}}` are substituted at generation time. Available:
  `PROJECT_NAME`, `PROJECT_SLUG`, `REPO`, `STACK_PRESET`, `STACK_LANGUAGE`,
  `STACK_FRAMEWORK`, `SOURCE_DIR`, `TEST_DIR`, `MANIFEST_FILE`, `DATE`,
  `SCAFFOLD_CONFIG_JSON`.
- Add a file to `templates/` and it is generated automatically — no code change needed.
