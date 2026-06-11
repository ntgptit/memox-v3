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
| **Cách hoạt động** | Mở `index.html` bằng Chrome headless (puppeteer-core). Kit render mỗi màn 1 state sau một *stepper* và lazy-render theo viewport → script scroll tới từng row, bấm stepper qua **từng state**, mỗi state chụp riêng frame light + dark (`export_shots`), đồng thời walk DOM đã render để đo bounding box + computed style và resolve màu ngược về tên token `--memox-*` (`export_specs`). State sau state đầu xuất dạng **delta** (added/removed so với base) cho gọn. |
| **Cách chạy** | `cd tool/ui_kit_shots` → `npm install` (lần đầu) → `npm run export:all` (hoặc `export` = chỉ ảnh, `export:specs` = chỉ spec). Cần Chrome + mạng (kit load React/Babel từ CDN). |
| **Khi nào chạy lại** | Sau BẤT KỲ thay đổi nào của `index.html`. |
| **Output** | `docs/system-design/MemoX Design System/ui_kits/mobile/shots/` — 270 PNG + `INDEX.md` (manifest screen→state→file). Cùng cấp: `specs/` — 23 file MD + `INDEX.md`. |

Ví dụ một dòng trong spec (chính xác đến từng px, màu theo tên token):

```text
- pill-btn "Start study · 23 due" [37,248 332x40] bg:seed-indigo font:14/600 color:on-primary r:12
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

### 3.4 `tool/golden_diff/diff.py` — So ảnh app vs mock (Python + Pillow)

| | |
| --- | --- |
| **Mục đích** | Vòng phản hồi visual-parity **không cần vision**: agent (kể cả model nhỏ) đọc kết quả text để biết màn hình lệch mock ở đâu và tự sửa lặp. Đây là gate thực thi cho rule "screen chỉ complete khi pass visual parity". |
| **Cách hoạt động** | So 2 PNG pixel-by-pixel (mặc định tolerance 16/kênh để hấp thụ khác biệt anti-aliasing giữa renderer), tự resize nếu khác kích thước, in **mismatch % + bounding box vùng lệch** (đối chiếu được với bbox element trong `specs/`), tùy chọn xuất heat-map đỏ cho người xem. Exit 1 khi vượt threshold. |
| **Cách chạy** | `python tool/golden_diff/diff.py <ảnh-app.png> <ảnh-mock.png> [--out heatmap.png] [--threshold 5.0] [--tolerance 16]`. Cần `pip install Pillow` (máy hiện tại đã có). |
| **Khi nào dùng** | Trong UI task: render golden test Flutter → diff với `shots/NN-...--light.png` tương ứng. Gate per-screen sẽ được gắn từ UI task đầu tiên (WBS 9.14). |

### 3.5 `tool/verify/run.mjs` — Một lệnh verify duy nhất

| | |
| --- | --- |
| **Mục đích** | Thay 7 lệnh verify rời + các pairing rule phải nhớ bằng MỘT lệnh, MỘT bảng tổng kết. Agent không còn lý do chạy lẻ tẻ hay bỏ sót gate. |
| **Cách hoạt động** | Tự phát hiện scope từ `git status`: chỉ docs đổi → docs chain (~10 giây: `doc_guard` → guard → `git diff --check`); có `.dart`/pubspec đổi → code chain đầy đủ theo đúng thứ tự chuẩn: `gen-l10n` (chỉ khi ARB đổi) → `build_runner` → guard → `doc_guard` → `dart fix --apply` → `dart format .` → `flutter analyze` → `flutter test` (targeted) → `git diff --check`. In bảng pass/fail/skipped kèm lý do + thời gian; exit ≠ 0 nếu bất kỳ bước nào fail. |
| **Cách chạy** | `node tool/verify/run.mjs` (auto-detect) · `--test <đường-dẫn-test...>` (code chain + test nhắm đích) · `--docs` / `--code` / `--full` (ép scope; `--full` chạy toàn bộ test — chậm). |
| **Lưu ý** | Sau khi nó chạy `dart fix`/`dart format`, vẫn phải xem diff và chỉ giữ thay đổi thuộc task hiện tại (rule trong `CLAUDE.md`). |

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
| `golden_diff` | Python 3 + Pillow (`pip install Pillow`) | |
| `code-verification-guard` | Tool riêng có sẵn trong repo (Python) | Không thuộc `tool/`; được `verify` gọi tự động |

## 7. Lịch sử & truy vết

Mỗi công cụ được đăng ký trong WBS (`docs/project-management/wbs.md` §Group 9, rows 9.11–9.16)
với commit anchor đã verify; lịch sử per-commit nằm ở §10 Commit Traceability Log. Khi thêm/sửa
tool, cập nhật README này + WBS row tương ứng trong cùng commit.
