# MemoX — Bộ công cụ hỗ trợ AI Agents (`tool/`)

Tài liệu tổng hợp **mục đích, cách hoạt động, cách chạy** của toàn bộ công cụ đã phát triển cho
dự án. Đối tượng đọc: người vận hành dự án và AI agents (Claude Code, Codex).

---

## 1. Vấn đề mà bộ công cụ giải quyết

Khi phát triển bằng AI agents, token bị đốt nhiều nhất KHÔNG phải lúc viết code, mà ở 4 việc lặp
đi lặp lại:

| Việc lặp lại | Chi phí khi làm tay | Tool thay thế |
| --- | --- | --- |
| Khám phá repo mỗi phiên mới (cấu trúc, schema, route nào placeholder...) | 20–40 tool calls / phiên | `repo-map.md` + `where-is.md` (generated) |
| Đọc mock design từ file HTML 10.500 dòng | Không đọc nổi → agent tự chế → lệch design | `shots/` (PNG) + `specs/` (DOM spec) |
| Kiểm tra docs có nói dối về code không (path ma, class ma, test ref ma) | Cả một phiên audit / lần | `doc_guard check` |
| Chạy 7 lệnh verify rời, nhớ đúng thứ tự | Nhiều lượt chạy + đọc 7 output | `verify` (1 lệnh, 1 bảng kết quả) |
| Soạn prompt cho từng WBS task theo đúng 6-bước dev loop | 10–15 phút / task, dễ quên bước | `prompt_gen` (sinh tự động từ WBS ID) |

Nguyên tắc thiết kế xuyên suốt: **index tất định (generated) + được lint, thay vì để agent tự tìm
hoặc dùng vector/RAG** — vì corpus có cấu trúc và convention ổn định thì sinh-và-kiểm-chứng luôn
thắng truy hồi xác suất về cả độ tươi lẫn độ chính xác.

## 2. Bản đồ hệ sinh thái

```text
                    ┌─────────────────────────────────────────────┐
                    │  UI KIT (index.html — 23 màn × 135 states)  │
                    └──────────────┬──────────────────────────────┘
                                   │ tool/ui_kit_shots
                    ┌──────────────┴──────────────┐
                    ▼                             ▼
            shots/*.png (270)              specs/*.md (23)
            cho agent CÓ vision            cho agent KHÔNG vision
                    │                             │
                    └─────────────┬───────────────┘
                                  ▼
                    UI task implement màn hình
                                  │
                                  ▼
            tool/golden_diff  ◄── so golden Flutter vs mock shot
                                  │
                                  ▼
            tool/verify  ◄── 1 lệnh chạy cả chuỗi verification
                  │
                  ├── code-verification-guard (lint CODE — tool riêng có sẵn)
                  └── tool/doc_guard (lint DOCS/PROCESS — check)
                              │
                              └── generate → docs/_generated/repo-map.md
                                           → docs/_generated/where-is.md
```

## 3. Chi tiết từng công cụ

### 3.1 `tool/ui_kit_shots/` — Xuất mock design thành ảnh + spec

| | |
| --- | --- |
| **Mục đích** | Biến UI kit (1 file HTML/JSX ~10.5k dòng, agent không tiêu thụ nổi) thành 2 artifact tiêu thụ được: ảnh PNG cho agent có vision, DOM spec text cho agent không có vision. |
| **Cách hoạt động** | Mở `index.html` bằng Chrome headless (puppeteer-core). Kit render mỗi màn 1 state sau một *stepper* và lazy-render theo viewport → script scroll tới từng row, bấm stepper qua **từng state**, mỗi state chụp riêng frame light + dark (`export_shots`), đồng thời walk DOM đã render để đo bounding box + computed style và resolve màu ngược về tên token `--memox-*` (`export_specs`). Spec được ghép từ template file riêng: `spec-file.template.md` cho khung file và `spec-node.template.md` cho từng node block. State sau state đầu xuất dạng **delta** (added/removed so với base) cho gọn. |
| **Cách chạy** | `cd tool/ui_kit_shots` → `npm install` (lần đầu) → `npm run export:all` (hoặc `export` = chỉ ảnh, `export:specs` = chỉ spec). Cần Chrome + mạng (kit load React/Babel từ CDN). |
| **Khi nào chạy lại** | Sau BẤT KỲ thay đổi nào của `index.html`. |
| **Output** | `docs/system-design/MemoX Design System/ui_kits/mobile/shots/` — 270 PNG + `INDEX.md` (manifest screen→state→file). Cùng cấp: `specs/` — 23 file MD + `INDEX.md`. |

Ví dụ một block trong spec (chính xác đến từng px, màu theo tên token):

```text
- node: pill-btn
  text: Start study · 23 due
  box:
    abs: [37,248 332x40]
    rel: [37,248 332x40]
  style: bg:seed-indigo font:14/600 color:on-primary r:12
```

### 3.2 `tool/doc_guard/` — Lint docs/process + sinh wiki

| | |
| --- | --- |
| **Mục đích** | Canh vùng mà `code-verification-guard` không phủ: **các tuyên bố docs đưa ra về repo**. Docs từng tích lũy hàng trăm ref ma (file/class/test không tồn tại) khiến agent build chồng lên API không có thật — tool này chặn drift đó tại commit. |
| **Cách hoạt động** | `check`: quét mọi `*.md` trong `docs/` + `CLAUDE.md` + `AGENTS.md` — (1) path trong backtick phải tồn tại; (2) tên class Dart được nhắc phải có trong `lib/`/`test/`; (3) ref `test/...dart::tên test` phải resolve được; (4) WBS: đủ 10 cột, status đúng vocabulary, commit hash có thật trong git; (5) ARB: key trùng, lệch en↔vi, key không dùng; (6) version schema doc khớp code. Docs được phép nói về thứ chưa tồn tại nếu có **marker** ("Target", "does not exist", "Specified"...) gần đó hoặc status header — tool tự suppress. Finding tồn đọng nằm trong `baseline.json`; gate **chỉ fail với finding MỚI**. |
| **Cách chạy** | `node tool/doc_guard/run.mjs check` — gate chính (exit 1 nếu có lỗi mới). `node tool/doc_guard/run.mjs check --update-baseline` — chụp lại baseline SAU KHI đã fix bớt finding cũ. `node tool/doc_guard/run.mjs terms <từ-cũ>` — tìm ref sót sau khi rename thuật ngữ. |
| **Output `generate`** | Xem 3.3. |
| **Bảo trì** | Burn-down `baseline.json` (57 findings gốc) dần theo từng khu vực khi chạm tới — tracked tại WBS 9.12. |

### 3.3 `doc_guard generate` — Wiki sinh tự động cho agent

| | |
| --- | --- |
| **Mục đích** | Xóa chi phí "cold-start": phiên agent mới đọc 2 file nhỏ thay vì tự khám phá repo bằng hàng chục tool calls. Đặc biệt quan trọng khi **nhiều agent chạy song song** — wiki regen theo commit nên baseline luôn tươi. |
| **Cách hoạt động** | Parse trực tiếp từ code (không viết tay nên không thể drift): schema version + bảng/cột từ `.drift`; route + cờ placeholder từ router; đếm use case/screen/test từ cây file. Riêng `where-is.md`: registry 42 feature giữ doc-path ổn định + **pattern tên file**, danh sách file thật được resolve sống mỗi lần chạy. Output nằm trong `docs/` nên **được chính `doc_guard check` lint ngược** — wiki không thể nói dối. |
| **Cách chạy** | `node tool/doc_guard/run.mjs generate` |
| **Khi nào chạy lại** | Trong commit có thay đổi route / schema / use case / screen, hoặc khi thấy file generated ghi commit cũ hơn HEAD nhiều. |
| **Output** | `docs/_generated/repo-map.md` — "cái gì đang tồn tại" (schema, routes, use cases, screens, tests, commit gần nhất). `docs/_generated/where-is.md` — "feature X nằm đâu": mỗi dòng = docs cần đọc + source files + tests + mock shots + WBS rows. |

### 3.4 `tool/golden_diff/diff.py` — So ảnh app vs mock (Python: Pillow + scikit-image)

| | |
| --- | --- |
| **Mục đích** | Vòng phản hồi visual-parity **không cần vision**: agent (kể cả model nhỏ) đọc kết quả text để biết màn hình lệch mock ở đâu và tự sửa lặp. Đây là gate thực thi cho rule "screen chỉ complete khi pass visual parity". |
| **Cách hoạt động** | Hai metric (phần lõi đều do lib đã kiểm thử lo): **(1) % pixel** (Pillow) — so pixel-by-pixel, tolerance 16/kênh hấp thụ anti-alias, tự resize nếu khác kích thước, in mismatch % + bbox vùng lệch; `--spec` → **log per-node** (mỗi node lệch: status `MISSING?`/`COLOR?`/`SHIFT?` · bbox · %pixel · SSIM-node · màu đo golden→shot ΔRGB · giá trị design intended từ spec). `MISSING?` (block đặc trong mock, trống trong render) chỉ bắt được **block đặc**; text/icon thưa cần inventory structural. **(2) SSIM** (`--ssim`, scikit-image) — tương đồng cấu trúc perceptual ∈[-1,1] (1.0=giống hệt), bền với nhiễu renderer hơn % pixel. Tùy chọn heat-map (`--out`, `--ssim-out`). Exit 1 khi `% > --threshold` hoặc `SSIM < --min-ssim`. |
| **Cách chạy** | `python tool/golden_diff/diff.py <ảnh-app.png> <ảnh-mock.png> [--out heatmap.png] [--threshold 5.0] [--tolerance 16] [--spec <specfile> --top N] [--ssim --min-ssim 0.6]`. Dep: `pip install -r tool/golden_diff/requirements.txt` (pixel-mode chỉ cần Pillow; SSIM cần numpy + scikit-image, import lazy). Test glue tự viết: `python tool/golden_diff/test_diff.py`. |
| **Khi nào dùng** | Trong UI task: render golden test Flutter → diff với `shots/NN-...--light.png` tương ứng. Gate per-screen sẽ được gắn từ UI task đầu tiên (WBS 9.14). |

### 3.5 `tool/verify/run.mjs` — Một lệnh verify duy nhất

| | |
| --- | --- |
| **Mục đích** | Thay 7 lệnh verify rời + các pairing rule phải nhớ bằng MỘT lệnh, MỘT bảng tổng kết — và **ép buộc** điều đó: chạy lệnh rời không sinh pass-marker nên không commit được. |
| **Cách hoạt động** | Tự phát hiện scope từ `git status`: chỉ docs đổi → docs chain (~10 giây); có `.dart`/pubspec đổi → code chain đầy đủ đúng thứ tự chuẩn: `gen-l10n` (chỉ khi ARB đổi) → `build_runner` → guard → `doc_guard` → `dart fix --apply` → `dart format .` → `flutter analyze` → `flutter test` (targeted) → `git diff --check`. **PASS (docs/code) ghi `tool/verify/.last-pass.json`** chứa hash trạng thái nội dung tree; pre-commit hook gọi `--check-marker` — commit bị từ chối khi không có marker khớp, hoặc khi stage code mà marker chỉ là docs-chain. Sửa bất kỳ file nào sau PASS → hash lệch → phải chạy lại. |
| **Cách chạy** | **Inner loop khi đang dev**: `node tool/verify/run.mjs --quick [--test <paths>]` (analyze + test nhắm đích, nhanh, KHÔNG marker — không dùng để commit). **Cuối task**: `--test <paths>` (code) hoặc `--docs` (docs-only) hoặc auto-detect / `--code` / `--full`. Regen toàn bộ golden (vd sau khi đổi `test/flutter_test_config.dart`): `--full --update-goldens` (nhánh `--full` đã forward `--update-goldens` xuống `flutter test`). |
| **Lưu ý** | Sau khi nó chạy `dart fix`/`dart format`, vẫn phải xem diff và chỉ giữ thay đổi thuộc task hiện tại. KHÔNG chạy `flutter analyze`/`flutter test`/`build_runner`... trực tiếp — đó là hard-rule violation (`CLAUDE.md` §Hard rules). |

### 3.6 `tool/prompt_gen/run.mjs` — Sinh Claude Code prompt từ WBS ID

| | |
| --- | --- |
| **Mục đích** | Biến một WBS row thành **prompt hoàn chỉnh theo 6-bước dev loop** (Read → Drift check → Implement → Inner loop → Design parity → Full verify+commit) mà không cần agent tự nhớ reading list, hard rules, hay parity checklist mỗi lần. Giảm variance giữa các phiên agent. |
| **Cách hoạt động** | Parse `docs/project-management/wbs.md` §4 lấy row theo WBS ID → phát hiện entity (Folder/Deck/Study/…) từ Flow+Function+Deliverable → tra bảng entity→docs để build reading list → phát hiện Layer (BE/FE/Integration) để chọn đúng implementation order và có hay không Design Parity block (Step 5) → in prompt markdown hoàn chỉnh ra stdout. Có thể sinh prompt cho 1 row, nhiều row cùng lúc (batch), hoặc xem overview 1 phase. Zero npm dependency. |
| **Cách chạy** | `node tool/prompt_gen/run.mjs <WBS_ID>` — prompt 1 task. `node tool/prompt_gen/run.mjs <ID1> <ID2> …` — prompt batch (≤7 row). `node tool/prompt_gen/run.mjs --phase <N>` — tổng quan phase + danh sách row ready. `node tool/prompt_gen/run.mjs --ready [--gen [N]]` — task next **status-driven** trên toàn WBS (mọi row `Specified` có đủ dep `Implemented`); `--gen` sinh luôn prompt cho row đầu (hoặc N row đầu). `node tool/prompt_gen/run.mjs --list [--status <S>]` — liệt kê WBS rows. `node tool/prompt_gen/run.mjs --next` — xem §5 Next tasks (prose **curated thủ công**; có thể drift — dùng `--ready` để lấy task chính xác). |
| **Khi nào dùng** | Trước mỗi task implement: chạy tool → copy prompt → paste vào Claude Code session mới. Muốn "task tiếp theo chính xác bây giờ": `--ready` (hoặc `--ready --gen`). Khi bắt đầu một phase mới: `--phase N` để thấy gì ready trong phase đó. |
| **Dependency check** | Tự động kiểm tra `Depends on` column — in ⚠️ warning nếu dep chưa `Implemented`. So khớp status theo **token đầu** nên cell dạng `Implemented (2026-06-20; …)` vẫn được tính là done (không còn báo nhầm "build it first"). |
| **Output** | Markdown prompt ra stdout — pipe sang file nếu muốn lưu: `node tool/prompt_gen/run.mjs 1.2.1 > /tmp/task-1.2.1.md`. |

### 3.7 `tool/parity/` — Báo cáo & lint visual-parity (tất định, KHÔNG AI)

| | |
| --- | --- |
| **Mục đích** | Biến vòng "parity audit" làm tay (liệt kê kit states → tìm golden → `diff.py` từng state → bắt state thiếu golden; soát bare-hex trong spec) thành **lệnh tất định chạy mỗi commit/CI, không gọi model**. Tách phần ĐO + GATE (tất định, ở đây) khỏi phần PHÁN ĐOÁN visual (agent `ui-parity-checker` đọc ảnh thật). |
| **Cách hoạt động** | `report.mjs` đọc `parity-map.json` (hợp đồng máy-đọc: mỗi state khai `golden` + `scope`); scope `current` → kiểm golden tồn tại (light+dark) + gọi `golden_diff/diff.py` golden↔shot, **thiếu golden = FAIL** (gate STATE COVERAGE). scope `deferred`/`behavior`/`needs-schema`/`needs-token`/`shared` → chỉ liệt kê (divergence sở hữu nơi khác, xem `docs/project-management/parity-loop/parity-deferred.md`). `token_lint.mjs` soát bare `#rrggbb` trong specs (= màu chưa token hóa = gap) + thống kê token màu kit dùng. |
| **Cách chạy** | `node tool/parity/report.mjs` (bảng; `--ssim`, `--check [--max <pct>] [--min-ssim V]`, `--screen`, `--json`) · `node tool/parity/token_lint.mjs [--check\|--json]` · `node tool/parity/node_audit.mjs` (per-node MISSING?/COLOR?/SHIFT? toàn app) · **closed loop**: `node tool/parity/structural_inventory.mjs --dump <json> --spec <md>` (node thiếu thật theo hình học, phân loại redesign/bug qua `intent-ledger.json`; dump sinh bởi `test/support/structural_dump.dart`). Schema + vòng khép kín: `tool/parity/README.md`. |
| **Lưu ý** | diff% chứa **nhiễu font Ahem** (golden render chữ bằng Ahem) → tín hiệu tương đối, KHÔNG phải verdict; vì vậy `--check` mặc định chỉ gate state-coverage (tất định). Thêm/đổi screen/state → cập nhật `parity-map.json` trong CÙNG commit. Chưa wire vào `verify` (commit gate) để tránh chặn commit khi map tạm lệch — gọi trong CI hoặc chạy tay. |

## 4. Artifacts sinh ra — tra cứu nhanh

| File | Trả lời câu hỏi | Sinh bởi |
| --- | --- | --- |
| `docs/_generated/repo-map.md` | "Repo hiện có gì?" (schema, routes, use cases, screens, tests) | `doc_guard generate` |
| `docs/_generated/where-is.md` | "Feature X nằm đâu?" (docs/source/tests/mock/WBS — 42 features) | `doc_guard generate` |
| `docs/system-design/MemoX Design System/ui_kits/mobile/shots/INDEX.md` | "Màn NN state S trông thế nào?" → file PNG | `ui_kit_shots export` |
| `docs/system-design/MemoX Design System/ui_kits/mobile/specs/INDEX.md` | "Kích thước/token chính xác của màn NN?" | `ui_kit_shots export:specs` |
| `tool/doc_guard/baseline.json` | Danh sách finding docs tồn đọng đang được miễn gate | `doc_guard check --update-baseline` |

## 5. Quy trình điển hình của một task

```text
1. Mở phiên   → đọc docs/_generated/repo-map.md + dòng liên quan trong where-is.md
2. UI task?   → mở shots/NN-*.png (có vision) và/hoặc specs/NN-*.md (không vision)
              → mapping table mọi state theo CLAUDE.md §UI Mock Design Parity
3. Implement  → theo contracts; docs đi cùng commit (parity rule)
4. Verify     → node tool/verify/run.mjs --test <tests>   (một lệnh duy nhất)
5. UI task?   → python tool/golden_diff/diff.py <golden> <shot>
6. Đổi route/schema/usecase/screen? → node tool/doc_guard/run.mjs generate (regen wiki)
7. Rename thuật ngữ? → node tool/doc_guard/run.mjs terms <từ-cũ>
8. Commit     → kèm WBS §10 traceability log theo CLAUDE.md
```

## 6. Cài đặt & yêu cầu môi trường

| Thành phần | Yêu cầu | Ghi chú |
| --- | --- | --- |
| `doc_guard`, `verify` | Node ≥ 18, **zero npm dependency** | Chạy được ngay, không cần install |
| `ui_kit_shots` | Node + `npm install` trong thư mục + Google Chrome + mạng | puppeteer-core dùng Chrome hệ thống, không tải browser |
| `golden_diff` | Python 3 + `pip install -r tool/golden_diff/requirements.txt` (Pillow; numpy + scikit-image cho `--ssim`) | Pixel-mode chỉ cần Pillow; SSIM import lazy. Có unit test: `python tool/golden_diff/test_diff.py` |
| `code-verification-guard` | Tool riêng có sẵn trong repo (Python) | Không thuộc `tool/`; được `verify` gọi tự động |
| pre-commit hook | `git config core.hooksPath .githooks` (một lần / clone) | Tự chạy `doc_guard check` + whitespace check mỗi commit |

## 7. Trigger matrix — tool nào chạy khi nào, bởi ai, điều kiện gì

| Tool / lệnh | Tác nhân trigger | Thời điểm | Điều kiện trigger | Bắt buộc? | Được wire ở đâu |
| --- | --- | --- | --- | --- | --- |
| `verify --quick` | AI agent | TRONG lúc dev (inner loop), thay cho việc chạy `flutter analyze`/`test` trực tiếp | Muốn feedback nhanh giữa chừng | **Bắt buộc dùng thay lệnh rời** (hard rule); không sinh marker | `CLAUDE.md` §Hard rules + §Verification |
| `verify` (full) | AI agent (mọi loại) | Cuối mỗi task, TRƯỚC khi commit/báo cáo | Có bất kỳ thay đổi nào (tự phát hiện scope docs/code) | **Bắt buộc + cưỡng chế** — PASS ghi pass-marker; không có marker thì hook chặn commit | `CLAUDE.md` §Verification, `AGENTS.md` phase "After", `docs/checklist/implementation-checklist.md` §Verification, `.githooks/pre-commit` |
| `doc_guard check` | (a) `verify` gọi tự động; (b) **git pre-commit hook** chạy tự động; (c) agent chạy tay khi sửa nhiều docs | Mỗi lần verify + mỗi lần `git commit` | Luôn chạy được (~3s); hook block commit khi có finding MỚI | **Bắt buộc** (tự động qua 2 đường trên) | `tool/verify/run.mjs`, `.githooks/pre-commit` |
| `doc_guard generate` | AI agent | Trong commit có thay đổi route / schema / use case / screen; hoặc khi thấy `repo-map.md` ghi commit tụt xa HEAD | Một trong các thay đổi trên xảy ra | Bắt buộc theo điều kiện | `CLAUDE.md` §Verification, `AGENTS.md` §Fast lookups |
| `doc_guard check --update-baseline` | AI agent / người | CHỈ sau khi đã fix bớt finding trong baseline (burn-down WBS 9.12) | Vừa fix xong finding cũ; KHÔNG dùng để "cho qua" finding mới | Tùy chọn có kiểm soát | `tool/doc_guard/baseline.json` |
| `doc_guard terms <old>` | AI agent | Ngay sau khi rename thuật ngữ/route/field | Có rename xảy ra | **Bắt buộc khi rename** (CLAUDE.md parity bước 8, AGENTS.md self-audit #6) | `CLAUDE.md`, `AGENTS.md` |
| `ui_kit_shots export:all` | AI agent / người chỉnh design | Sau BẤT KỲ thay đổi nào của `ui_kits/mobile/index.html` | Kit đổi (state mới, màn mới, style đổi) | **Bắt buộc khi kit đổi** — không regen = shots/specs nói dối | Kit `README.md` §How agents consume |
| `golden_diff` | AI agent làm UI task | Sau khi render golden/screenshot của màn hình vừa implement | Có golden PNG của màn hình + shot mock tương ứng | Bắt buộc cho UI task (gate per-screen kích hoạt từ WBS 4.1.3) | `CLAUDE.md` §Verification, WBS 9.14 |
| `parity/report` + `parity/token_lint` | AI agent / CI | Sau UI task; định kỳ/CI để soát regression visual-parity toàn app | Có `parity-map.json` (state→golden→scope) | Tùy chọn (CI gate state-coverage qua `--check`) — KHÔNG gọi AI | `tool/parity/README.md` |
| **pre-commit hook** | git (tự động) | Mỗi `git commit` | Clone đã chạy MỘT LẦN: `git config core.hooksPath .githooks` | Gọi `verify --check-marker`: chặn commit khi không có pass-marker khớp trạng thái tree, hoặc stage code mà marker là docs-chain. Bypass khẩn cấp: `--no-verify` (phải nêu lý do trong report) | `.githooks/pre-commit` → `tool/verify/run.mjs --check-marker` |
| `prompt_gen` | AI agent / người | Trước mỗi task implement | Muốn sinh prompt đầy đủ 6-bước từ WBS ID | Tùy chọn nhưng khuyến nghị — tiết kiệm ~10 phút soạn prompt + giảm sót bước | `tool/prompt_gen/run.mjs` |

Quy tắc nhớ nhanh cho agent: **verify trước mọi commit; generate khi đổi cấu trúc; terms khi
rename; export khi kit đổi; golden_diff khi làm UI; parity/report để soát parity toàn app (cập nhật
`parity-map.json` khi đổi screen/state); prompt_gen khi bắt đầu task mới; hook lo phần còn lại tự động.**

## 8. Tái sử dụng cho dự án khác (portability)

Các tool được viết zero-framework (Node thuần / Python thuần) nên copy được, nhưng mỗi tool có
phần **generic** (giữ nguyên) và phần **MemoX-specific** (phải sửa). Bảng dưới liệt kê chính xác
chỗ cần đụng:

| Tool | Mức độ generic | Phải sửa gì khi copy sang dự án khác |
| --- | --- | --- |
| `golden_diff/diff.py` | ✅ **100% generic** | Không sửa gì — so 2 PNG bất kỳ. Copy là chạy. |
| `verify/run.mjs` | 🔶 Khung generic, steps theo stack | (1) Danh sách step trong 2 chain (hiện là Flutter: build_runner/analyze/flutter test → thay bằng lệnh của stack mới, vd `npm run lint`/`pytest`); (2) hàm phát hiện scope: prefix `lib/`, `test/`, `pubspec.yaml` → đổi theo cây dự án; (3) điều kiện `arbTouched` (Flutter l10n) → bỏ hoặc thay. |
| `doc_guard/run.mjs` — check 1–3 (path/symbol/test-ref) | 🔶 Gần generic | (1) `prefixes` trong `checkPaths` (`docs/`, `lib/`, `test/`, `tool/` → đổi theo cây mới); (2) `SYMBOL_SUFFIX` regex (suffix class theo convention dự án, vd `Controller\|Service\|Handler` cho Spring); (3) danh sách `NEGATION` markers giữ nguyên được, thêm từ khóa status của dự án mới. |
| `doc_guard` — checkWbs | 🔴 MemoX-specific | Gắn với format WBS của repo này (10 cột, §4/§10, `WBS_STATUS` vocabulary). Dự án khác: sửa section anchors + số cột + vocabulary, hoặc xóa hàm nếu không dùng WBS kiểu này. |
| `doc_guard` — checkArb / checkSchema | 🔴 Stack-specific (Flutter ARB / Drift) | Thay bằng checker tương đương của stack mới (vd: i18n JSON keys; schema từ JPA entities / Prisma schema so với doc). Cấu trúc hàm giữ nguyên: parse nguồn-sự-thật-trong-code → so với doc. |
| `doc_guard generate` — repo-map | 🔴 Parser theo stack | 3 hàm parse: `driftTables` (đọc `.drift`), `routeInventory` (đọc GoRouter constants + `RoutePlaceholder`), đếm glob theo cây Flutter. Viết lại parser cho stack mới (vd: parse `@RestController` cho route map Spring). Khung output + ý tưởng giữ nguyên. |
| `doc_guard generate` — where-is | 🔶 Engine generic, registry theo dự án | Engine resolve-pattern giữ nguyên. Viết lại mảng `WHERE_IS` (~40 entries): feature + doc paths + source-name patterns của dự án mới. Đây là phần tốn công nhất (~1-2 giờ) nhưng chỉ làm một lần. |
| `ui_kit_shots/*` | 🔴 Gắn với DOM của kit này | Selectors (`.row`, `.stepper`, `.phone`, `.frame-wrap`, `.st-label`) + cơ chế stepper/lazy-render là của kit MemoX. Kit HTML khác: sửa selectors + vòng lặp state cho khớp cấu trúc gallery mới. Ý tưởng (headless render → chụp per-state + walk DOM → spec) tái dùng nguyên vẹn. |
| `.githooks/pre-commit` | ✅ Generic | Chỉ cần `tool/doc_guard` tồn tại; nhớ chạy lại `git config core.hooksPath .githooks` ở clone mới. |
| `prompt_gen/run.mjs` | 🔴 MemoX-specific | Bảng `ENTITY_DOCS` (~15 entries) và `ENTITY_PATTERNS` gắn với domain MemoX. Dự án khác: viết lại 2 bảng này + hàm `implOrder` (nếu stack khác). Khung 6-bước loop + CLI (`--list`, `--phase`, `--ready`, `--next`) giữ nguyên. |

**Quy trình copy đề xuất (cho một dự án mới):**

1. Copy nguyên thư mục `tool/` + `.githooks/` + `.gitattributes`.
2. Xóa/sửa các checker stack-specific trong `doc_guard/run.mjs` (checkWbs/checkArb/checkSchema)
   và parser trong `generate` theo bảng trên.
3. Sửa step list + scope detection trong `verify/run.mjs` theo stack.
4. Chạy `doc_guard check` lần đầu → tune `NEGATION`/`prefixes` đến khi false-positive sạch →
   `--update-baseline` để chốt finding tồn đọng.
5. Viết registry `WHERE_IS` cho ~feature chính của dự án; chạy `generate`.
6. Kích hoạt hook: `git config core.hooksPath .githooks`.
7. Wire vào tài liệu agent của dự án (tương đương `CLAUDE.md`/`AGENTS.md`): verify entry +
   repo-map/where-is vào required reading + trigger matrix.

Thứ tự giá trị khi copy: **verify + doc_guard check (1 ngày) → repo-map/where-is (nửa ngày) →
golden_diff (miễn phí) → shots/specs (chỉ khi có HTML design kit).**

## 9. Lịch sử & truy vết

Mỗi công cụ được đăng ký trong WBS (`docs/project-management/wbs.md` §Group 9, rows 9.11–9.16)
với commit anchor đã verify; lịch sử per-commit nằm ở §10 Commit Traceability Log. Khi thêm/sửa
tool, cập nhật README này + WBS row tương ứng trong cùng commit.
