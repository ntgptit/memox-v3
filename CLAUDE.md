# CLAUDE.md - MemoX

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Local-first Flutter flashcard app.

`docs/` là **source of truth** cho behavior, schema, routes, UI contract. Khi `docs/` và code mâu thuẫn, KHÔNG tự chọn. Report mismatch hoặc update cả hai trong cùng commit.

## 🔴 Doc-code parity rule (đọc trước tiên, luôn áp dụng)

**Mỗi commit thay đổi code phải giữ docs đồng bộ với code.** Nếu thay đổi code ảnh hưởng đến bất kỳ aspect nào được spec trong `docs/`, bắt buộc update docs **trong CÙNG commit**, không phải "sửa sau".

Lý do: docs đã từng bị drift trong các iteration trước. Drift làm Claude Code các phiên sau làm sai vì đọc spec đã lỗi thời. Quy tắc này tồn tại để chặn drift ngay từ source.

### Pre-commit parity check (bắt buộc, không skip)

Trước khi finish task, tự trả lời theo thứ tự:

1. **Có thay đổi behavior người dùng thấy không?** (UX flow, dialog copy, button order, empty states, validation message, error handling, navigation transition)
   → Nếu CÓ: update file business/wireframe tương ứng.

2. **Có thay đổi schema/persistence không?** (column add/remove/rename, index, migration, SharedPreferences key, file path, encoding)
   → Nếu CÓ: update `docs/database/schema-contract.md` + `docs/database/migration-contract.md` + `docs/database/storage-boundaries.md`.

3. **Có thay đổi route/navigation không?** (new path, new param, push vs go, redirect rule, deep link)
   → Nếu CÓ: update `docs/business/navigation/navigation-flow.md` + `RouteNames`/`RoutePaths` constants.

4. **Có thay đổi SRS algorithm, intervals, box count, result enum, study flow, study mode behavior?**
   → Nếu CÓ: update `docs/business/srs/srs-review.md` + `docs/business/study/study-flow.md` + decision table.

5. **Có thay đổi rule, edge case, validation hoặc agent rule không?**
   → Nếu CÓ: update doc tương ứng. NEVER quietly relax/tighten a documented rule.

6. **Có thêm/sửa branch behavior có thể test được không?**
   → Nếu CÓ: thêm/sửa row trong `docs/decision-tables/memox-core-decision-table.md` và viết test tương ứng.

7. **Có chuyển một aspect từ "Specified" sang implemented (hoặc ngược lại) không?**
   → Update bảng status trong `docs/business/system/overview.md`.

8. **Behavior đã thay đổi nhưng docs cũ vẫn còn ref đến cách cũ?**
    → Phải sửa **TẤT CẢ** ref. Dùng `node tool/doc_guard/run.mjs terms <old_term>` để tìm. Không để lại text inconsistent.

Nếu không chắc một mục có cần update không, **mặc định LÀ cần update**. Cost của update thừa < cost của drift.

## WBS Maintenance Rule

`docs/project-management/wbs.md` là source of truth cho task breakdown và task allocation của project.

- Bất kỳ task nào tạo, xóa, rename, split, merge, re-scope, promote, defer, hoặc complete một feature/task phải kiểm tra WBS có bị ảnh hưởng không.
- Nếu task đổi task allocation, implementation status, feature scope, ownership boundary, dependency order, hoặc next-step planning, cùng commit đó phải update `docs/project-management/wbs.md`.
- Nếu WBS không bị ảnh hưởng, final report phải ghi rõ: `WBS update: not needed — <reason>`.
- Không để WBS drift sau docs/source.
- Update WBS là bổ sung; không thay thế business docs, wireframes, decision tables, tests, hoặc schema docs.

### Commit traceability rule (bắt buộc)

Mọi commit tạo, đẩy tiến (advance), hoặc complete một WBS work package PHẢI append một dòng vào **Commit Traceability Log (§10 của `docs/project-management/wbs.md`)** trong CÙNG commit đó.

- Mỗi dòng gồm: short commit id (8 ký tự), ngày (absolute), WBS ID(s) bị chạm (comma-separated nếu nhiều), tóm tắt 1 dòng.
- Append-only, newest first. Không sửa/xóa dòng cũ.
- Commit tooling/format thuần không chạm WBS row nào thì được bỏ qua log.
- Dòng "Baseline reviewed" ở đầu WBS theo dõi commit review mới nhất; §10 theo dõi lịch sử per-task. Đừng nhồi cột commit vào các bảng feature — dùng log để giữ liên kết 2 chiều (WBS ID ↔ commit id).
- Vì short hash chỉ biết sau khi commit, có thể commit trước rồi `amend` để điền dòng log, hoặc commit log cùng change rồi sửa hash ở commit kế. Final report phải xác nhận log đã được cập nhật hoặc lý do bỏ qua.

### Code change → required docs (trigger map)

Bảng này map giữa loại thay đổi code và các file docs BẮT BUỘC kiểm tra (không phải "có thể"):

| Code change | Bắt buộc kiểm tra & update nếu liên quan |
| --- | --- |
| `lib/data/datasources/local/drift/**` (`.drift` tables/queries) | `docs/database/schema-contract.md`, `docs/database/migration-contract.md`, `docs/database/drift-guide.md`, `docs/decision-tables/memox-core-decision-table.md` |
| `lib/domain/entities/**` | Business doc của entity đó + `docs/business/glossary.md` (nếu thêm thuật ngữ) |
| `lib/domain/usecases/**` (new use case hoặc behavior thay đổi) | Business doc liên quan + decision table |
| `lib/data/repositories/study_repo_impl_study_session.dart` (`_intervalForBox`) | `docs/business/srs/srs-review.md` (interval table) + `test/data/repositories/study_srs_transition_test.dart` |
| `lib/data/repositories/study_repo_impl_study_session.dart` (`_finalizeResultForAttempts`, `_boxAfterFinalization`) | `docs/business/srs/srs-review.md` (transition table) + `test/data/repositories/study_srs_transition_test.dart` |
| `lib/app/router/route_names.dart` / `route_paths.dart` | `docs/business/navigation/navigation-flow.md` |
| `lib/presentation/features/**/screens/*.dart` | Wireframe tương ứng trong `docs/wireframes/*.md` + screenshot mock trong `docs/system-design/MemoX Design System/ui_kits/mobile/shots/` (tra `shots/INDEX.md`) + visual contract trong `docs/design/screens/*.visual-contract.md` nếu có |
| `lib/presentation/features/**/widgets/dialog_*.dart` hoặc `*_dialog.dart` | `docs/wireframes/24-shared-dialogs.md` (nếu là shared dialog) |
| `lib/presentation/features/**/widgets/*_sheet.dart` hoặc bottom sheet | `docs/wireframes/25-shared-bottom-sheets.md` (nếu là shared sheet) |
| `lib/presentation/features/study/**` (5 mode files) | `docs/wireframes/13-17-study-session-*.md` + `docs/business/study/study-flow.md` |
| `lib/data/repositories/flashcard_import_*.dart` | `docs/business/flashcard/flashcard-management.md` (import section) + `docs/wireframes/10-deck-import.md` |
| `lib/data/repositories/flashcard_export_*.dart` | `docs/business/export/export.md` |
| `lib/data/sync/**` hoặc `drive_sync_*.dart` | `docs/business/account-sync/account-sync.md` + `docs/wireframes/19-settings-account.md` |
| `lib/presentation/features/settings/**` | `docs/wireframes/04-settings-hub.md` + sub-screen wireframes 19-22 |
| `lib/l10n/app_*.arb` (new key) | Đảm bảo key được ref trong wireframe/business doc tương ứng |
| `pubspec.yaml` (new dependency) | Stop and ask. Approval needed. |
| Theme tokens (`lib/core/theme/**`) | `docs/ui-ux/ui-ux-contract.md` + `docs/system-design/MemoX Design System/README.md` + `docs/system-design/MemoX Design System/colors_and_type.css` |

Nếu code change rơi vào nhiều rows, kiểm tra tất cả.

### Drift detection (khi nhận task)

Trước khi code, đọc related docs (theo "Required reading" bên dưới). Nếu phát hiện docs ĐÃ lag so với code hiện tại (ví dụ: code có column mới chưa được doc, hoặc behavior code khác behavior doc):

1. **Dừng lại.** Không continue task.
2. Report drift cho user với format:

   ```
   DRIFT DETECTED:
   - File code: lib/...
   - File doc: docs/...
   - Mismatch: {mô tả cụ thể}
   - Suggested fix: {update doc / update code / cần user quyết định}
   ```

3. Chờ user xác nhận hướng xử lý trước khi continue.

Đây là cách duy nhất để drift không tích lũy.

## Required reading by task

**Universal additions (apply to every task):**

- `docs/contracts/error-contract.md` (Failure taxonomy)
- `docs/contracts/types-catalog.md` (enums, value objects)
- `docs/contracts/code-style.md` (naming, structure)

**Task-specific:**

| Task type | Đọc trước |
| --- | --- |
| Bất kỳ task nào | `docs/_generated/repo-map.md` (cold-start snapshot) + row liên quan trong `docs/_generated/where-is.md` (feature → docs/source/tests/mock/WBS — đọc TRƯỚC khi tự grep; nếu stale thì `node tool/doc_guard/run.mjs generate`), `docs/business/index.md`, `docs/business/glossary.md`, **3 universal contracts above** |
| Thêm/sửa use case | `docs/contracts/usecase-contracts/{entity}.md` + business spec + decision rows |
| Thêm/sửa repository | `docs/contracts/repository-contracts/{entity}-repository.md` + use case contract |
| Thêm/sửa screen | `docs/design/mock-to-ui-playbook.md` (operating procedure) + Wireframe của screen đó + related `docs/business/**` + `docs/design/design-language.md` (taste contract — judgment rules ngoài mock; paste vào prompt khi giao UI task cho agent ngoài) + `docs/ui-ux/ui-ux-contract.md` + `docs/system-design/MemoX Design System/README.md` + Implementation refs trong wireframe (→ tự link đến contracts) |
| Thêm/sửa route | `docs/business/navigation/navigation-flow.md` |
| Schema change | `docs/database/schema-contract.md`, `docs/database/migration-contract.md` |
| State/provider | `docs/state/state-management-contract.md` (đặc biệt §Per-notifier contracts) |
| Study/SRS | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md`, `docs/contracts/usecase-contracts/study.md`, `docs/contracts/usecase-contracts/srs.md` |
| Bury/Suspend | `docs/business/study-actions/bury-suspend.md`, `docs/contracts/usecase-contracts/study.md` §Bury/Suspend |
| Resume session | `docs/business/resume/resume-session.md`, `docs/contracts/usecase-contracts/study.md` §FindResumableSessionUseCase |
| Folder/Deck/Flashcard | `docs/business/{folder,deck,flashcard}/*.md` + wireframe + `docs/contracts/usecase-contracts/{folder,deck,flashcard}.md` |
| Tag-related | `docs/business/tags/tag-system.md`, `docs/contracts/usecase-contracts/tag.md` |
| Bulk operations | `docs/business/bulk/bulk-operations.md`, `docs/contracts/usecase-contracts/bulk.md` |
| Search | `docs/business/search/global-search.md`, `docs/wireframes/11-library-search.md`, `docs/contracts/usecase-contracts/search.md` |
| Card history | `docs/business/history/card-history.md`, `docs/wireframes/09-flashcard-history.md`, `docs/contracts/usecase-contracts/history.md` |
| Dashboard / engagement | `docs/business/engagement/dashboard-engagement.md`, `docs/wireframes/01-dashboard.md`, `docs/contracts/usecase-contracts/engagement.md` |
| Export | `docs/business/export/export.md` |
| TTS | `docs/business/tts/tts-settings.md`, `docs/contracts/usecase-contracts/tts.md` |
| Account / Drive sync | `docs/business/account-sync/account-sync.md`, `docs/wireframes/19-settings-account.md`, `docs/contracts/usecase-contracts/account-sync.md`, `docs/contracts/repository-contracts/sync-repository.md` |
| Dialog work | `docs/wireframes/24-shared-dialogs.md` |
| Bottom-sheet work | `docs/wireframes/25-shared-bottom-sheets.md` |
| Writing tests | `docs/testing/test-strategy.md` |
| Perf-sensitive feature | `docs/quality/performance-contract.md` |
| Adding log site | `docs/quality/observability-contract.md` |
| Adding user-facing string | `docs/ui-ux/l10n-copy-contract.md` |
| Giving task to agent | `docs/agent/agent-task-template.md` |
| Delegating to sub-agents | `docs/agent/orchestration.md` (fan-out vs sequential, token budget, anti-patterns) + custom agents in `.claude/agents/` |
| Review code | `docs/checklist/recursive-agent-review.md` |
| Complete task | `docs/checklist/implementation-checklist.md` |

## Path convention for cross-references (canonical)

Whenever a markdown file references another markdown file inside backticks, the path MUST be **repo-root absolute, no leading slash**:

```
✓  `docs/business/folder/folder-management.md`
✓  `docs/wireframes/13-study-session-review.md`
✓  `docs/contracts/usecase-contracts/study.md`
✓  `CLAUDE.md`
✓  `AGENTS.md`

✗  /docs/business/folder/folder-management.md          (leading slash)
✗  ../business/folder/folder-management.md             (relative)
✗  folder-management.md                                (bare filename)
✗  business/folder/folder-management.md                (missing docs/ prefix)
```

Rationale: one path style across the codebase, trivially verifiable by `[ -f path ]` from repo root, no resolution-by-context confusion. Agents finding a non-conforming ref MUST fix it in the same commit (report under "Drift detected").

This convention applies to **backtick references** in markdown body text and tables. Markdown link syntax (`[label](url)`), if used, also follows the same path rule.

## Hard rules (vi phạm = task fail)

- KHÔNG commit code change without parity-checking docs theo "Pre-commit parity check".
- KHÔNG implement từ giả định khi docs đã có contract.
- KHÔNG sửa generated files (`*.g.dart`, `*.freezed.dart`, Drift generated, `lib/l10n/generated/**`).
- KHÔNG hardcode route strings, colors, text styles, durations, user-facing strings.
- KHÔNG bypass MemoX design tokens/theme. UI phải dùng token/shared component hiện có trong MemoX Design System; nếu token thiếu, report gap hoặc update token theo task được duyệt.
- KHÔNG tạo shared widget mới khi widget hiện có giải quyết được. Chỉ tạo shared widget mới khi có nhu cầu lặp lại thật, có naming/contract rõ, và task yêu cầu hoặc user approve.
- KHÔNG dùng raw `Card`, raw `Button`, raw action layout nếu MemoX đã có component tương ứng như `MxCard`, `MxActionButton`, `MxCardActions`, `MxContentShell`. Nếu phải dùng raw Material widget, giải thích lý do trong report.
- KHÔNG sửa schema/persistence nếu không có migration, schema docs, migration docs, và test tương ứng trong cùng commit.
- KHÔNG đánh dấu item trong docs từ `Future`/`Target`/`Specified` sang `Current`/`Implemented` nếu code chưa implement thật và chưa có verification/test tương ứng.
- KHÔNG giữ persistent data chỉ trong provider memory.
- KHÔNG bypass UseCase → Repository → DAO flow.
- KHÔNG import ngược chiều dependency: domain MUST NOT import data or presentation; presentation MUST NOT import data directly. Allowed imports: presentation → domain; data → domain (data implements domain interfaces). Dependencies point inward: domain has no outward imports.
- KHÔNG dùng `ref.watch` trong callback.
- KHÔNG thêm route mới mà không update route constants AND `docs/business/navigation/navigation-flow.md` trong cùng commit.
- KHÔNG để docs reference đến term/route/field cũ sau khi rename.
- KHÔNG đánh dấu task "done" nếu chưa pass Pre-commit parity check.
- KHÔNG báo cáo complete nếu `code-verification-guard` tồn tại trong repo mà chưa chạy pass. Nếu tool không tồn tại, ghi rõ: `guard: skipped (tool not present)`.
- **KHÔNG chạy lệnh verification rời** (`flutter analyze`, `flutter test`, `dart fix`, `dart format`, `build_runner`, `flutter gen-l10n`, guard, doc_guard) trực tiếp — KỂ CẢ trong lúc đang dev. Mọi bước verification đi qua MỘT entry: `node tool/verify/run.mjs` (inner loop: `--quick [--test <paths>]`; cuối task: full chain). Verify PASS ghi pass-marker gắn với trạng thái nội dung tree; **pre-commit hook từ chối commit không có marker hợp lệ** — chạy lẻ tẻ không sinh marker nên không commit được. Sửa file sau khi PASS → marker hết hiệu lực → chạy lại verify.

## Mandatory workflow

1. Đọc related docs theo bảng "Required reading".
2. Inspect "Source files to inspect" trong related doc.
3. **Drift check**: docs có match với code hiện tại không? Nếu không, dừng lại và report (xem "Drift detection" ở trên).
4. Confirm acceptance criteria khi spec không rõ.
5. Implement theo Clean Architecture: entity → repository contract → use case → notifier/viewmodel → widget.
6. **Pre-commit parity check**: chạy 8-step checklist ở trên trước khi finish.
7. Update related docs nếu behavior thay đổi (mandatory, cùng commit).
8. Update decision table nếu thêm/sửa behavior branch.
9. Check MemoX Design System compliance nếu có thay đổi UI: token usage, shared component usage, no raw component bypass.
10. Chạy verification theo `docs/checklist/implementation-checklist.md`.
11. **Auto-review fan-out** (xem `## Auto-delegation (subagent fan-out)` bên dưới): sau khi verify PASS, trước khi báo cáo, tự fan-out sang `code-reviewer` + `docs-drift-detector`.
12. Báo cáo theo format trong checklist, **bao gồm section "Docs updated"** liệt kê file docs đã sửa và lý do, section `Guard status`, section `Subagent review` (tóm tắt finding của code-reviewer + docs-drift-detector, hoặc lý do skip), và lý do nếu bỏ qua command nào.

## Auto-delegation (subagent fan-out)

> Quy tắc này do product owner thiết lập (2026-06-20) và là **standing authorization**: với
> repo MemoX, agent chính ĐƯỢC PHÉP và ĐƯỢC YÊU CẦU tự spawn các review-subagent dưới đây sau task
> code mà không cần user nhắc lại từng lần. Đây là tự-động-hóa "mềm" (model-driven), không phải hook
> harness — phiên sau phải đọc và tuân thủ mục này.

Sau khi hoàn tất một task **thay đổi code** và `node tool/verify/run.mjs` đã PASS, **trước khi
viết báo cáo cuối**, tự fan-out **song song** (một lượt, nhiều `Agent` call):

- `code-reviewer` — review diff theo 5 trục + MemoX gates (Clean-Architecture, doc-parity,
  design-system, tool/verify).
- `docs-drift-detector` — quét doc-code drift còn sót (path/symbol/test-ref ma, WBS gap, ARB).

**Diff là đơn vị review (không commit trước).** Mọi review-subagent fan-out (gồm cả
`srs-reviewer`, `ui-parity-checker` khi áp dụng) phải anchor trên **working-tree diff**, KHÔNG
phải whole-file và KHÔNG commit trước để "có cái mà diff". Trong prompt fan-out, chỉ thị reviewer:
chạy `git add -N .` (intent-to-add để file mới cũng hiện trong diff) rồi `git diff` — đó là toàn
bộ thay đổi chưa commit (sửa + mới); với file mới, diff degenerate thành full content nên không
cần phân biệt nhánh "mới vs sửa". Chỉ mở whole-file khi cần bối cảnh ngoài 3 dòng context của
hunk. Lý do không commit trước: giữ đúng thứ tự `verify → review → sửa blocker → commit` (commit
trước = đẩy code chưa review vào history, review ra Critical thì phải amend), và tránh pre-commit
hook `--check-marker` chặn commit giữa chừng.

Xử lý kết quả:

- Tổng hợp finding của cả hai vào section `Subagent review` của báo cáo.
- Nếu có finding **blocker/nghiêm trọng** (vi phạm hard rule, drift thật, test thiếu cho branch
  mới): sửa rồi mới kết thúc; nếu cần re-verify thì chạy lại `tool/verify`.
- Finding nhỏ/không chắc: liệt kê trong báo cáo để user quyết định, không tự ý mở rộng scope.

**Bỏ qua fan-out** (ghi rõ lý do trong báo cáo) khi: task docs-only thuần; đổi trivial
(rename/format/comment); user yêu cầu nhanh hoặc "không review"; hoặc verify chưa PASS (sửa cho
xanh trước đã). Với task động đến SRS/study-flow, thêm `srs-reviewer`; với task UI screen, thêm
`ui-parity-checker`.

## UI Mock Design Parity

When implementing or modifying UI screens, the mock design is a contract, not a loose inspiration.

**Operating procedure (đọc trước khi code UI từ mock):** `docs/design/mock-to-ui-playbook.md` — the
step-by-step runbook (resolve all states → map → bucket by data availability → schema/BE → shared
shell → guard → l10n → tests → docs/WBS → verify) with the concrete layout/guard/test traps that
must not be repeated. Pair it with `docs/design/visual-parity-checklist.md` (final gate) and
`docs/design/mock-design-index.md` (where the mock lives).

**Mock reference resolution (bắt buộc):** the canonical visual mock for every screen is the PNG
set under `docs/system-design/MemoX Design System/ui_kits/mobile/shots/` (one light + one dark
PNG per state; look up files via `shots/INDEX.md`). Do NOT "read the design" from the kit's
`index.html` source — open the PNGs (agents can read images). For exact measurements (bounding
boxes, spacing, token names) and for agents WITHOUT image input, use the measured DOM specs
under `.../ui_kits/mobile/specs/` (one file per screen, base tree + per-state deltas; manifest
`specs/INDEX.md`). Consult `index.html` only for exact copy text / control order, jumping via
the line index in the kit's `README.md`.

Before coding any UI screen:

1. Identify the exact target mock/design reference: **ALL `shots/` PNGs for that screen — every
   state the kit ships, not just the loaded state** — plus the screen's
   `docs/design/screens/*.visual-contract.md` when it exists.
2. Identify the exact target screen/route/component.
3. Create a short mapping table before implementation:

   - Mock element
   - Existing code/component
   - Implementation plan
   - Scope status: Current / Future / Rejected / Unknown
4. Map every state variant from `shots/INDEX.md` for the screen to a row in the screen's state
   handling (or explicitly mark it Future/Rejected/out-of-scope). A state that exists in the kit
   but is silently missing from the implementation plan is a parity failure.
5. Do not start coding until every visible mock element is mapped or explicitly marked out of scope.

Implementation rules:

- Match layout, spacing, hierarchy, density, typography, colors, icons, states, and component behavior as closely as the current design system allows.
- Use existing design tokens and shared components first.
- Do not hardcode raw colors, spacing, radius, or typography inside feature widgets unless the design system explicitly allows it.
- Do not invent unsupported behavior just to visually match the mock.
- Do not silently skip visible mock elements.
- Do not replace a visible mock element with a different UI pattern unless there is a documented reason.
- Do not expose Future/Rejected features from docs just because they appear in an old mock.
- If the mock and documentation conflict, stop and document the conflict instead of guessing.

Required UI parity checklist:
Before finishing a UI task, verify (compare against the `shots/` PNGs for the screen, both
light and dark, across ALL states in scope):

- Header/app bar matches the mock.
- Search/filter/sort controls match approved scope.
- Cards/rows match mock structure, spacing, icon placement, badges, and trailing actions.
- Empty/loading/error/search-no-results states remain valid.
- Bottom navigation matches mock density and selected state.
- FAB/button style, position, label, and prominence match the mock.
- Light and dark mode remain readable and visually consistent.
- No unsupported actions were introduced.
- No existing behavior/regression was broken.

Visual drift policy:

- A screen is not complete when it only "works".
- A screen is complete only when it passes both behavior and visual parity checks.
- Any remaining visual gap must be listed explicitly with one of these reasons:

  - Missing data in current read model
  - Feature marked Future
  - Feature marked Rejected
  - Design token/component not available yet
  - Mock/documentation conflict

Testing requirements:
For UI changes, add or update widget tests for:

- Main loaded state
- Important row/card actions
- Empty state
- Loading state
- Error state
- Search/no-results state when applicable
- Navigation behavior when applicable
- **A golden test per state** (`matchesGoldenFile`, light + dark, 390×780) — this is
  the "static visual" row of the gate map below.

**Catch the bug CLASS, not the instance (general — applies beyond UI):**

Small bugs slip past `flutter analyze`, unit tests, and the guard because each is
blind to a different thing (spacing, overflow, behaviour, data, a11y). Don't fix the
single instance — identify the bug's CLASS, push prevention to the lowest layer, and
add the cheapest automatic gate that covers the whole class:

| Bug class | Prevent (lowest layer) | Detect (automatic gate) |
|---|---|---|
| Spacing / alignment / colour (static visual) | invariant in the `Mx*` widget + tokens | golden test per state (light + dark, 390×780) |
| Overflow / large `textScaleFactor` / narrow width | `Flexible`/ellipsis in the shared widget | widget test at narrow width + scaled text |
| Behaviour / navigation / state | use case + provider contract | widget/interaction test per decision row |
| Wrong data / count / sort | repository contract | unit test on the read model |
| a11y (labels, target size) | semantics in the shared widget | semantics test |
| Design-system bypass (raw widget/colour) | — | a `memox.*` guard rule |

Push the fix to the lowest layer so every consumer is fixed at once (example, visual
row: `MxSearchField` owns its trailing inset + a geometry contract test → no consumer
can misalign the keycap). Regenerate goldens intentionally with
`node tool/verify/run.mjs --update-goldens --test <paths>`, then prove they pass
WITHOUT `--update`; never `--update` to silence an unexplained diff. Golden pattern:
`test/presentation/features/folders/library_search_field_golden_test.dart`.

Expected final response after implementing a UI task:

- Files changed
- Mock elements mapped
- Visual gaps fixed
- Remaining visual gaps and reasons
- Behavior intentionally unchanged
- `flutter analyze` result
- `flutter test` result

## Stack reference

- Flutter, Dart 3
- Material 3
- Riverpod annotation v3
- Drift SQLite (DAO pattern)
- GoRouter
- fpdart Either (Target; requires approved dependency/API migration before implementation if not adopted)
- freezed
- ARB localization
- MemoX Design System
- code-verification-guard

## Verification commands

**Single entry (BẮT BUỘC — xem Hard rules; lệnh rời không sinh marker nên không commit được):**

```text
node tool/verify/run.mjs --quick [--test <paths>]   # INNER LOOP khi đang dev: analyze (+ test nhắm đích), nhanh, KHÔNG marker
node tool/verify/run.mjs --test <test paths>        # cuối task code: full chain + targeted tests → ghi pass-marker
node tool/verify/run.mjs --docs                     # cuối task docs-only (~10s) → ghi pass-marker
node tool/verify/run.mjs                            # auto-detect scope | --code | --full
```

The entry runs the canonical chain in order with the analyze/dart-fix pairing rules applied,
prints one pass/fail/skipped summary, and exits non-zero on any failure. A docs/code PASS writes
`tool/verify/.last-pass.json` bound to the tree's content state; the pre-commit hook
(`--check-marker`) rejects commits without a matching marker, and requires a **code-chain**
marker when staged changes include code. Rules that survive the automation:

- Sau khi nó chạy `dart fix`/`dart format`: inspect diff, chỉ giữ thay đổi thuộc task hiện tại;
  fixable diagnostic không apply phải có lý do trong report.
- `code-verification-guard` không có trong clone → verify tự skip; report ghi
  `guard: skipped (tool not present)`.
- Drift docs (path/symbol/test-ref ma, WBS format, ARB) bị chặn bởi `doc_guard` bên trong verify
  và bởi pre-commit hook (`.githooks/` — kích hoạt: `git config core.hooksPath .githooks`).
- Rename thuật ngữ: `node tool/doc_guard/run.mjs terms <old>`. Đổi route/schema/usecase/screen:
  `node tool/doc_guard/run.mjs generate` (regen wiki) trong cùng commit.
- Visual parity cho UI task: `python tool/golden_diff/diff.py <golden> <mock-shot>`.
- Soát visual-parity toàn app (tất định, KHÔNG AI): `node tool/parity/report.mjs` (bảng diff% +
  state-coverage per screen/state, `--check` gate state thiếu golden) và `node tool/parity/token_lint.mjs`
  (bare-hex gap + token inventory). Hợp đồng máy-đọc ở `tool/parity/parity-map.json` — khi thêm/đổi
  screen/state phải cập nhật map trong CÙNG commit. Phần phán đoán "đúng chưa" khi % nhiễu vẫn để agent
  `ui-parity-checker`. Chi tiết: `tool/parity/README.md`.

Chi tiết từng tool, lệnh rời để debug một bước, trigger matrix, portability: `tool/README.md`.

## When in doubt

- Ưu tiên minimal structurally correct change hơn broad refactor.
- Ưu tiên update doc thừa hơn skip parity check.
- Nếu task yêu cầu vi phạm bất kỳ hard rule nào, dừng lại và confirm với user trước.
- Nếu phát hiện docs drift nhưng task không yêu cầu sửa, vẫn report drift để user biết.
