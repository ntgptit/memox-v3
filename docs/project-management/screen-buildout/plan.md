# Screen build-out plan — 12 remaining screens (FE+BE together, until mock-mapped)

Build the 12 designed-but-unbuilt screens **end-to-end** (FE and BE in the same pass,
no FE/BE split) until each one **maps to its mock**. The mock (kit shots + specs) is the
source of truth. One screen per loop iteration; see `state.md` for the live cursor.

> Read first every iteration: `docs/design/mock-to-ui-playbook.md` (runbook),
> `docs/design/design-language.md` (taste), `docs/design/visual-parity-checklist.md`
> (final gate), the 3 universal contracts (`docs/contracts/{error-contract,types-catalog,code-style}.md`).

## Definition of "mapped to mock" (per-screen done bar)

A screen is DONE only when ALL hold:

1. **Every mock state** from `shots/INDEX.md` for that screen is implemented OR explicitly
   marked Future/Rejected/needs-schema in `tool/parity/intent-ledger.json` (no state
   silently dropped — see the mapping table the playbook requires).
2. **Route** added to `route_names.dart`/`route_paths.dart` + `docs/business/navigation/navigation-flow.md`.
3. **BE wired**: the screen reads a real read-model through UseCase → Repository → DAO
   (no provider-only state). New schema ⇒ migration + `schema-contract.md` +
   `migration-contract.md` + test, all in the same commit.
4. **Identity parity**: required singleton kit nodes carry `data-mx-node`; FE widgets
   carry `key: ValueKey('mx-node:<id>')`; a `*_parity_test.dart` asserts them
   (`test/support/parity_contract.dart`). `parity-map.json` updated; `gen_contract --check`
   + `mxnode_coverage --check --min 100` green.
5. **Visual parity**: the screen is in `parity-map.json` with a golden per current state;
   `report.mjs --check` green; per-state diff% in normal range (~5–15%) and
   `ui-parity-checker` agent verdict = OK (it judges borderline %). A golden per state
   (light+dark, 390×780).
6. **Tests** per the bug-class gate map: widget test per state, golden per state, unit
   tests for new BE/read-model, semantics where relevant.
7. **Docs**: business doc + wireframe + decision-table rows + `overview.md` status flip +
   l10n keys; **WBS** (`docs/project-management/wbs.md`) updated + §10 traceability line.
8. **Verify** `node tool/verify/run.mjs` (full chain) PASS; kit changes auto-sync to
   Claude Design v3 on push (pre-push hook).

## Per-screen recipe (one loop iteration)

1. Pick next screen from `state.md`. Open **ALL** its `shots/` PNGs (every state, light+dark)
   + its `specs/*.md` + business doc + wireframe + `usecase-contracts/*` + `repository-contracts/*`.
2. **Mapping table** (mock element → existing code/component → plan → scope) for every
   visible element AND every state. Nothing unmapped before coding.
3. **Drift check**: does the existing BE/doc match reality? If a contract exists but BE is
   partial, note the gap. If docs lag code, STOP + report.
4. **BE**: reuse existing usecases/repos (see status table); build the gaps
   (entity → repo contract → usecase → DAO/drift). Schema change ⇒ migration + docs + test.
5. **Route** + `RouteNames`/`RoutePaths` + navigation-flow doc.
6. **FE**: build with `Mx*` components + tokens only; all states. No raw widgets where an
   `Mx*` exists; no hardcoded color/px/route/string.
7. **Identity**: tag kit `data-mx-node` (common-layer prop first) → re-export specs →
   `gen_contract` → FE `ValueKey` → parity-contract test. Add the screen to `parity-map.json`.
8. **Tests + goldens** per state (write goldens intentionally, prove pass without `--update`).
9. **Docs + WBS** + decision table + overview status + l10n.
10. **Verify** (`tool/verify/run.mjs`), `report.mjs --ssim` for the screen, fan out
    `ui-parity-checker` (+ `code-reviewer`, `docs-drift-detector`). Fix blockers.
11. Commit → PR → merge. Update `state.md`. (Push auto-syncs kit to v3.)

## Build order + BE status (rationale: BE-ready & small first; sub-screens before the hub; new-BE flows last)

| # | Screen | Mock states | BE status | Notes / new BE needed |
| --- | --- | --- | --- | --- |
| 1 | 18-stats | 1 | ✅ progress models/usecases | smallest — warm up the workflow; subset of 19 |
| 2 | 19-progress | 9 | ✅ progress usecases (box dist, due, read-model, statistics) | FE-heavy, BE ready; `engagement` contract |
| 3 | 09-flashcard-history | 5 | ✅ v7_add_card_history + history usecases/contract | activity feed; reset keeps cumulative |
| 4 | 11-tag-management | 11 | ✅ tag usecases (watch/rename/merge/delete) | most states; rename/merge flows |
| 5 | 10-deck-import | 9 | ✅ import usecases (parse/prepare/commit) | CSV preview/commit; `csv` dep already in |
| 6 | 22-learning-settings | 5 | ✅ learning_settings usecases + repo | wire to existing settings repo |
| 7 | 24-appearance | 3 | ◑ preferences datasource exists | theme-mode persistence (light/dark/system) |
| 8 | 25-language | 3 | ◑ preferences datasource exists | locale persistence + ARB |
| 9 | 23-audio-speech | 7 | ✗ tts doc+contract only | **new BE**: TTS settings/engine (medium) |
| 10 | 20-settings | 5 | ◑ hub aggregates | build after 21–25 routes exist (links resolve) |
| 11 | 21-account-sync | 9 | ✗ account-sync doc+contracts only | **new BE**: Drive auth + sync (largest) |
| 12 | 01-onboarding | 9 | ✗ first-run flag | **new BE**: onboarding-seen flag + first-run gate |

Legend: ✅ BE ready (FE+wire) · ◑ partial · ✗ new BE.

## Gates that must stay green throughout

- `node tool/verify/run.mjs` (analyze + tests + guard + doc_guard + specs-fresh).
- `tool/parity`: `report.mjs --check`, `mxnode_coverage --check --min 100`,
  `gen_contract --check`, `design_watch --check`, `token_lint --check`.
- `ui-parity-checker` agent verdict per screen (visual judgment beyond diff%).
- WBS + §10 traceability updated per screen.
