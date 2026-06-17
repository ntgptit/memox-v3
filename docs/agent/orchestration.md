---
last_updated: 2026-06-17
status: contract
---

# Agent Orchestration — fan-out vs sequential

How work is delegated to sub-agents so it stays **accurate** and **token-cheap**.
Companion to `docs/agent/agent-task-template.md` (how to brief one agent) and the
custom agents in `.claude/agents/`.

Principles below are adapted from the addyosmani/agent-skills orchestration
catalog (https://github.com/addyosmani/agent-skills), tailored to MemoX's
Clean-Architecture + doc-parity + `tool/verify` gate.

## Governing rule

**The user (or a slash command) is the orchestrator. Personas do NOT invoke other
personas.** A sub-agent that wants another perspective surfaces it as a
*recommendation in its report* — it does not delegate. Orchestration lives in the
main session / slash command, never inside a persona.

Why: an LLM "orchestrator persona" loses nuance summarizing for hand-off, skips the
human checkpoints that catch wrong-direction work early, and doubles token cost via
paraphrasing turns.

## Core economics (read first)

The expensive thing is **context, not agent count**. Every spawned sub-agent is a
cold start: it re-reads `CLAUDE.md`, re-greps, re-derives what the main session
already knows. Goal: **each agent gets just enough context and returns a conclusion,
not raw files**.

Three levers, in priority order:

1. **Deterministic tooling over LLM reasoning.** Anything a script can prove
   (`tool/verify/run.mjs`, `tool/doc_guard/run.mjs`, `golden_diff/diff.py`,
   `docs/_generated/where-is.md`, `docs/_generated/repo-map.md`) must NOT be done by
   an agent. Scripts don't hallucinate and cost no tokens.
2. **Narrow context per agent.** A sub-agent loads only the docs for its task type,
   not all of `CLAUDE.md`. The `.claude/agents/*.md` definitions pin this.
3. **Conclusions, not dumps.** Every sub-agent returns severity-ordered findings +
   file:line, never pasted file contents.

## Patterns (compare every choice against pattern 1)

### 1. Direct invocation — the cheapest baseline
One persona, one perspective, one artifact, one round trip. Use when the work is one
perspective you can state in a sentence. Always compare orchestrated patterns against
this cost.

### 2. Single-persona slash command
A saved prompt wrapping one persona + its skills (e.g. `/review`, `/code-review`).
Same cost as direct invocation. Anti-signal: if the command body is mostly "decide
which persona to call," delete it.

### 3. Parallel fan-out with merge
Multiple personas on the same input concurrently; the main session merges. Maps to
`/ship`. **Issue all Agent calls in ONE assistant turn** or you lose the parallelism.

Validation checklist before using fan-out (all must be yes):
- [ ] Sub-tasks genuinely independent — no shared mutable state, no ordering.
- [ ] Each persona produces a *different kind* of finding, not the same one re-angled.
- [ ] The merge step fits in the main session's remaining context.
- [ ] Wait time is long enough that parallelism is noticeable.

If any is no → fall back to pattern 1.

### 4. Sequential pipeline as user-driven commands
The user runs commands in order, carrying context/commits between them
(`/spec → /plan → /build → /test → /review → /ship`). No orchestrator agent — the
user is the orchestrator, so the orchestration layer costs zero tokens. Use when
steps depend on each other and human judgment between them adds value. Do NOT
automate this into one LLM orchestrator (see Governing rule).

### 5. Research isolation (context preservation)
Reading lots of material that shouldn't pollute the main context → spawn a research
sub-agent that returns only a digest. **Use the built-in `Explore` (runs on Haiku,
no write/edit tools)** rather than a custom research persona. Define a custom one
only when `Explore` needs a domain-specific prompt it can't infer.

## Token budget by model

- **Main session (orchestrator):** Opus — holds the plan, splits work, synthesizes.
  Delegates broad sweeps to `Explore` (Haiku) instead of grepping 50 files itself.
- **Read-mostly reviewers** (`srs-reviewer`, `ui-parity-checker`,
  `docs-drift-detector`, generic `code-reviewer`/`test-engineer`): Sonnet — judgment
  over a narrow set, cheaper per token.
- **Reserve Opus** for reasoning that needs it (cross-phase SRS design, architecture).

## Two-layer agent setup (plugin + local)

MemoX runs a hybrid:

- **Plugin layer (auto, broad):** `addyosmani/agent-skills` installed as a Claude Code
  plugin provides generic personas (`code-reviewer`, `security-auditor`,
  `test-engineer`, `web-performance-auditor`), lifecycle commands, and skills
  (`context-engineering`, …). Auto-discovered, activate by `description`.
- **Local layer (manual, specific):** `.claude/agents/` holds MemoX specialists
  (`srs-reviewer`, `ui-parity-checker`, `docs-drift-detector`) plus MemoX-tailored
  *overrides* of generic personas (`code-reviewer`, `test-engineer`). **Local/project
  agents take precedence over plugin agents of the same name** — so `/review` and
  `/ship` automatically pick up the MemoX-aware versions (Clean-Architecture
  boundaries, doc-parity, `tool/verify` gate).

## MemoX canonical flows

- **Post-implementation review (fan-out, pattern 3):** after a feature lands, spawn in
  parallel whichever apply: `code-reviewer` (always), `srs-reviewer` (study/SRS
  touched), `ui-parity-checker` (a screen touched), `docs-drift-detector` (any docs
  trigger fired). Main session merges + fixes. The `tool/verify` gate still runs.
- **Locate-then-act (pattern 5 → inline):** unknown location → `Explore` returns
  file:line conclusions → main session implements inline with that narrow context.
- **Plan-then-build (sequential):** ambiguous/large task → one `Plan` agent produces
  the step plan → main session executes.

## Anti-patterns (cost tokens AND accuracy)

- Spawning an agent to "check docs are synced" — that's `doc_guard`.
- Spawning an agent to "run the tests" — that's `tool/verify`.
- A persona delegating to another persona (violates the Governing rule).
- Fan-out on dependent steps — each agent re-pays cold start with overlapping context.
- Sub-agent returning whole files — the conclusion is the product.
- Bypassing `docs/_generated/where-is.md` / `repo-map.md` and grepping cold.

## Always-true invariants

- Sub-agents are **read-mostly**: they review and report; the main session owns edits
  (single writer = no merge hazard on a shared tree). Use `isolation: worktree` if a
  sub-agent must write.
- Final verification always goes through the single entry `node tool/verify/run.mjs`;
  agent findings never replace the gate (and never write the commit marker).
