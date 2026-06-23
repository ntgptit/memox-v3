# `tool/parity/` — Báo cáo & lint visual-parity (tất định, KHÔNG AI)

Biến hai việc lặp đi lặp lại của vòng visual-parity thành **lệnh tất định chạy mọi lần / trong CI,
không gọi model**:

| Việc (trước đây làm tay/AI mỗi vòng) | Tool thay thế |
| --- | --- |
| Liệt kê kit states → tìm golden → chạy `diff.py` từng state → phát hiện state thiếu golden | `report.mjs` |
| Soát spec có màu bare-hex (chưa token hóa) + thống kê token màu kit dùng | `token_lint.mjs` |
| Chạy per-node log (`diff.py --spec`) cho TOÀN APP → tổng hợp MISSING?/COLOR?/SHIFT? | `node_audit.mjs` |
| Phát hiện node **thiếu thật** theo hình học (cây widget vs spec), không lệ thuộc màu/theme | `structural_inventory.mjs` + `test/support/structural_dump.dart` |
| Phân loại **FIX (mặc định) vs ngoại lệ có-docs** (behavior/future/rejected/needs-schema) | `intent-ledger.json` |
| Phát hiện **design đổi** (shots/specs) → bắt FE + docs + golden phải sửa theo | `design_watch.mjs` + `design-baseline.json` |
| **Đếm bug toàn app** (structural, mọi screen có dump) | `structural_audit.mjs` |

Triết lý: **mã hóa quyết định MỘT LẦN thành dữ liệu** (`parity-map.json`) → tool đọc và chấm tất
định mãi mãi. AI chỉ cần khi: build screen mới, một gate fail cần phán đoán, hoặc duyệt baseline
golden / gắn scope cho node mới. CI không gọi AI lần nào.

> Ranh giới: phần **đo + gate** là tất định (ở đây). Phần **phán đoán visual "đúng chưa"** khi % bị
> nhiễu font vẫn là việc của agent `ui-parity-checker` (đọc ảnh thật). Hai lớp bổ trợ, không thay nhau.

---

## `report.mjs` — báo cáo parity per screen/state

Đọc `parity-map.json`; với mỗi state:
- **scope `current`**: kiểm golden tồn tại (light+dark) + chạy `tool/golden_diff/diff.py` golden↔shot.
  **Thiếu golden = FAIL** (đây là gate STATE COVERAGE — tất định, giá trị cao nhất).
- **scope khác** (`deferred` / `behavior` / `needs-schema` / `needs-token` / `shared`): chỉ liệt kê,
  KHÔNG diff (divergence đã được sở hữu ở nơi khác — xem `docs/project-management/parity-loop/parity-deferred.md`).
- screen trong `noFe`: liệt kê là `NO-FE-YET` (ngoài scope).

```bash
node tool/parity/report.mjs                 # in bảng markdown
node tool/parity/report.mjs --json          # JSON cho máy
node tool/parity/report.mjs --check         # exit 1 nếu state `current` nào THIẾU golden
node tool/parity/report.mjs --check --max 60  # đồng thời fail nếu diff% pixel > 60 (mặc định TẮT)
node tool/parity/report.mjs --ssim          # thêm cột SSIM (perceptual; 1.0 = giống hệt)
node tool/parity/report.mjs --check --min-ssim 0.6  # fail nếu SSIM < 0.6 (implies --ssim)
node tool/parity/report.mjs --screen 03-library-overview   # giới hạn 1 screen
```

**Hai metric, hai việc** (đều do thư viện đã kiểm thử lo phần lõi):
- **% pixel** (Pillow) = "bao nhiêu pixel khác" — nhạy với mọi dịch chuyển; dễ báo động giả khi
  scrim/overlay/anti-alias đổi nhiều pixel delta-thấp.
- **SSIM** (`--ssim`, scikit-image) = tương đồng cấu trúc perceptual ∈ [-1,1], 1.0 = giống hệt; bền
  với nhiễu renderer. Ví dụ thật: `03 overflow-sheet` light pixel **63%** (báo động giả do scrim) nhưng
  SSIM **0.74** → cấu trúc vẫn khớp. Dùng SSIM cho phán đoán "về cơ bản có cùng layout không".

ℹ️ **Golden render bằng font thật** (Plus Jakarta Sans, nạp ở `test/flutter_test_config.dart` — xem
"Nâng cấp đã làm"). Trước đây golden dùng font khối Ahem nên % so shot bị nhiễu nặng (dark ~2× light);
giờ % so shot có nghĩa hơn nhiều (vd `03 loaded` light 14.13% → 6.64%). Vẫn còn sai khác renderer
(anti-alias, variable-font weight) nên coi % là **tín hiệu mạnh nhưng chưa tuyệt đối**; phán đoán cuối
khi % lưng chừng vẫn để `ui-parity-checker`. Có thể bật `--check --max <pct>` làm gate regression pixel
(chọn ngưỡng sau khi xem báo cáo real-font).

Exit: `0` ok · `1` gate fail (`--check`) · `2` lỗi config/IO.

## `token_lint.mjs` — lint token màu trong specs

Theo reading-guide của spec: tên `--memox-*` ↔ token Flutter; còn **bare `#rrggbb` = "không token nào
khớp → gap, không được hardcode"**. Linter này phát hiện gap đó + thống kê mọi token màu kit dùng.

```bash
node tool/parity/token_lint.mjs           # GAPS (bare-hex) + inventory token
node tool/parity/token_lint.mjs --check   # exit 1 nếu có bare-hex gap
node tool/parity/token_lint.mjs --json
```

- **GAPS** = bare `#rrggbb` trong spec (màu chưa được design-system đặt tên) → `file:line`.
- **INVENTORY** = mọi token `bg:`/`color:` kit dùng + số lần → đối chiếu với
  `docs/design/design-token-mapping.md` + lớp Dart token.
- KHÔNG lint giá trị scalar (`font:22/800`, `r:14`) — đó là value, không phải token; thiếu *slot*
  type/size được theo dõi ở `parity-deferred.md` dưới `needs-token`.

Hiện `--check` báo 8 bare-hex ở `24-appearance.md` (màn color/appearance hiển thị swatch theme). Đây
là **gap thật** (khi screen đó được build phải token hóa), KHÔNG phải false-positive — nhưng vì screen
24 chưa có FE, hãy chạy token_lint ở chế độ **report** trong CI, chỉ bật `--check` (hoặc allowlist 24)
khi muốn chặn cứng.

## `node_audit.mjs` — per-node log cho TOÀN APP

Chạy `diff.py --spec` cho **mọi state `current`** trong `parity-map.json` (cả light+dark) rồi tổng hợp
số node `MISSING?`/`COLOR?`/`SHIFT?` per screen/state, liệt kê tên node MISSING.

```bash
node tool/parity/node_audit.mjs                 # bảng tổng hợp cả 2 theme
node tool/parity/node_audit.mjs --missing       # chỉ liệt kê node MISSING?
node tool/parity/node_audit.mjs --theme dark    # 1 theme
node tool/parity/node_audit.mjs --screen 02-dashboard --json
```

⚠️ **Đọc đúng các con số:**
- **`MISSING?` đáng tin** (high-precision, chỉ block đặc) — đây là tín hiệu "thiếu hẳn" giá trị nhất.
- **`COLOR?` bị thổi phồng cross-theme**: golden dark của app **tối hệ thống** hơn shot kit → rất nhiều
  node vượt ngưỡng ΔRGB 40 dù không phải bug token. Coi `COLOR?` là **xếp hạng tương đối** (so light vs
  dark, so screen vs screen), KHÔNG phải số bug tuyệt đối. Light theme đáng tin hơn dark.
- **`SHIFT?`** phần lớn là residual text-raster/offset.
- Verdict thị giác cuối vẫn là `ui-parity-checker`.

## Vòng khép kín (closed loop): detect → inventory → classify → resolve

> **Nguồn chân lý = shots + specs (gen từ mock).** Mọi lệch so với chúng là **BUG → FIX** (sửa FE cho
> khớp mock). KHÔNG có cửa "redesign" để bỏ qua. Ngoại lệ DUY NHẤT là thứ **có docs quy định** FE cố ý
> khác mock (behavior-owned / Future / Rejected / needs-schema) — và chỉ những thứ đó nằm trong
> `intent-ledger.json`.

```text
1. DETECT    node_audit.mjs (pixel)        → MISSING?/COLOR?/SHIFT? (có nhiễu, dark-theme)
2. INVENTORY structural_inventory.mjs      → node THIẾU THẬT theo hình học (bác/ xác nhận pixel)
3. CLASSIFY  intent-ledger.json            → node thiếu: FIX (mặc định) vs exception (có docs)
4. RESOLVE   FIX → sửa FE cho khớp mock · exception có docs → +1 dòng ledger (trích doc)
             → lần chạy sau tự phân loại (vòng khép lại)
```

Vì sao chia tầng: **pixel** nhanh nhưng nhiễu (dark-theme, AA); **structural** chính xác cho "thiếu
hay không" nhưng cần dump cây widget; **FIX-vs-exception** mặc định là **FIX**, ledger chỉ giữ ngoại lệ
có-docs (quyết 1 lần, trích nguồn). Ví dụ thật (dashboard dark): pixel báo `progress-fill` MISSING →
structural cho thấy **vẫn render** (bác false-positive của pixel). Phần COLOR còn lại (accent bị trầm so
shot) → theo nguyên tắc **shots = chân lý** thì đây là **FIX candidate** (sửa FE cho khớp accent của
mock), KHÔNG phải "redesign" — trừ khi có docs nói behavior/Future.

## `structural_inventory.mjs` — inventory node theo hình học (no pixel, no AI)

So **cây widget render** (dump từ `test/support/structural_dump.dart`, frame 390×780) với bbox node
trong `specs/NN-*.md`: node spec nào **không có widget nào phủ** = thiếu thật — đúng cả dark, cả
text/icon (giải hạn chế pixel). Mỗi node thiếu được ledger phân loại `FIX` (mặc định) / `exception`.

```bash
# 1) sinh dump (Flutter test gọi dumpStructure → test/_parity_dump/<name>.json, là artifact commit)
node tool/verify/run.mjs --test test/presentation/features/dashboard/dashboard_structural_test.dart
# 2) so dump vs spec
node tool/parity/structural_inventory.mjs \
  --dump test/_parity_dump/dashboard_loaded__dark.json \
  --spec "docs/system-design/MemoX Design System/ui_kits/mobile/specs/02-dashboard.md"
```

Loại trừ đúng: node **dưới fold** (`y+h > --viewport`, mặc định 780) và node **app-shell**
(`--exclude bottom-nav,nav-ind`) bị bỏ qua vì screen pump cô lập không có chúng — báo riêng, không
tính missing.

**Rollout đã làm cho 8 screen FE** (02/03/04/05/06/07/08/17): dump được sinh bằng cách hook 1 dòng
`dumpStructure(tester, '<golden-basename>')` vào golden test sẵn có của từng screen (tái dùng pump +
data). Chạy gộp cả app:

## `structural_audit.mjs` — đếm bug toàn app (structural)

Với mỗi state `current` trong `parity-map.json` có dump, chạy `structural_inventory` và cộng số node
`FIX` (bug) vs `exception` (ledger).

```bash
node tool/parity/structural_audit.mjs           # bảng + tổng
node tool/parity/structural_audit.mjs --bugs     # liệt kê từng node FIX
node tool/parity/structural_audit.mjs --check    # exit 1 nếu có bug (CI gate)
```

**Kết quả 2026-06-23: TOTAL BUGS = 0** trên 44 lượt state×theme (4778 node checkable) — mọi node mock
khai báo đều có widget render. Tức **không có bug "thiếu node"** nào. Lưu ý: structural chỉ đo "có
render hay không"; lệch **màu/spacing/size** (styling) KHÔNG nằm trong số này — đó là việc của
pixel/SSIM + `ui-parity-checker`.

## `intent-ledger.json` — ngoại lệ có-docs (KHÔNG phải cửa "redesign")

**Mặc định: lệch so mock = FIX.** Ledger chỉ liệt kê thứ FE **cố ý** khác mock vì **có docs quy định**.
Mỗi entry: `{screen, node ("*"=mọi node), kind (missing/color/"*"), verdict:"exception", exceptionKind
(behavior|future|rejected|needs-schema), reason, source}`. `source` BẮT BUỘC trích doc/owner ruling.
Khi `structural_inventory` thấy node thiếu: khớp ledger → `exception (source)`; không khớp → **`FIX`**
(sửa FE cho khớp mock). Giữ ledger **tối thiểu** — phân vân thì để trống và sửa FE. Phán đoán "có phải
ngoại lệ không" cho ca mới vẫn do `ui-parity-checker`/owner dựa trên docs; ledger chỉ giữ kết quả đã
trích nguồn.

## `design_watch.mjs` — design đổi thì code/docs phải đổi theo (gate)

Vì **shots/specs = chân lý**, khi design đổi thì FE + golden + docs **phải đổi theo**. Tool hash
`spec + shots` của từng screen, so với baseline đã commit (`design-baseline.json`); lệch = "design đã
đổi kể từ lần acknowledge cuối → cập nhật downstream rồi re-baseline".

```bash
node tool/parity/design_watch.mjs           # báo screen nào design đã đổi vs baseline
node tool/parity/design_watch.mjs --check    # exit 1 nếu có drift (CI gate)
node tool/parity/design_watch.mjs --update   # re-baseline (SAU khi đã sửa downstream)
```

Khi báo drift, tool in **checklist downstream bắt buộc** (theo trigger-map của `CLAUDE.md`): FE widget →
golden (`--update-goldens`) → structural dump → `visual-contract.md` → wireframe → decision table →
`parity-map.json` → **re-baseline**. Re-baseline (`--update`) chính là **dấu xác nhận** đã làm 1–7 cho
screen đổi. CI chạy `--check` ⇒ PR đổi design mà chưa cập nhật code/docs (chưa re-baseline) sẽ **đỏ**.
(Khác với `check_specs_fresh` — cái đó canh specs khớp `index.html`; `design_watch` canh design ⇄
code/docs.)

---

## `parity-map.json` — hợp đồng máy-đọc (nguồn sự thật)

Mỗi screen/state khai 1 lần ở đây để `report.mjs` chấm tất định.

```jsonc
{
  "shotsDir": "docs/system-design/MemoX Design System/ui_kits/mobile/shots",
  "screens": [
    { "id": "03-library-overview", "title": "...", "states": [
      { "kit": "loaded", "golden": "test/.../library_overview_loaded", "scope": "current" },
      { "kit": "overflow-sheet", "golden": "test/.../library_overview_overflow-sheet", "scope": "current" }
    ]}
  ],
  "noFe": ["01-onboarding", "..."]
}
```

- `golden` = path repo-root **không có** hậu tố `__<theme>.png` (tool tự thêm `__light.png`/`__dark.png`).
- `shot` được suy ra: `<shotsDir>/<screen.id>--<state.kit>--<theme>.png`. Vì vậy **tên kit-state có thể
  khác tên golden** (vd kit `empty-unlocked` ↔ golden `folder_detail_empty`) — map tách rời 2 thứ.
- `scope`: `current` (diff; thiếu golden = FAIL) · `deferred`/`behavior`/`needs-schema`/`needs-token`
  (lý do ở `reason`, không diff) · `shared` (state phủ bởi golden component dùng chung, vd
  `mx_confirm-destructive`).
- **Khi thêm/đổi 1 screen/state → cập nhật file này trong CÙNG commit** (giống doc-parity).

---

## Vị trí trong pipeline design → Flutter

```text
design → export_specs (specs + shots)  ─┐
tokens (Mx*) + shared Mx widgets        ─┤  (build screen: AI/người 1 lần)
golden-per-state                        ─┘
        │
        ▼
parity/report.mjs + token_lint  ──►  gate tất định mỗi commit/CI (0 AI)
        │ (khi % nhiễu / cần phán đoán visual)
        ▼
agent ui-parity-checker (đọc ảnh thật) ──►  verdict + gap list
```

Phần "đo + chặn regression" chạy hằng ngày không cần AI; AI chỉ vào lúc build mới hoặc khi một gate
tất định fail.

## Yêu cầu môi trường
- Node ≥ 18 (ESM). Python 3 + Pillow (cho `diff.py`, do `report.mjs` gọi). Không phụ thuộc package
  ngoài.

## Nâng cấp đã làm (2026-06-23)
1. ✅ **Real-font golden harness**: `test/flutter_test_config.dart` nạp Plus Jakarta Sans cho mọi
   golden → `diff.py` hết nhiễu Ahem → % so shot có nghĩa. Có thể bật `report.mjs --check --max <pct>`
   làm gate regression pixel thật (chọn ngưỡng sau khi xem báo cáo real-font).
2. ✅ **CI**: `.github/workflows/parity.yml` chạy `report.mjs --check` (state-coverage) + `token_lint
   --check` (bare-hex) trên PR/push — Node + Python + Pillow, KHÔNG Flutter, KHÔNG AI. Vẫn chưa gắn vào
   `tool/verify/run.mjs` (commit gate) để tránh chặn commit khi map tạm lệch.
3. ✅ **Allowlist cho token_lint**: `parity-map.json` → `tokenLintAllow` (vd `24-appearance`) → bỏ qua
   spec là swatch theme; `token_lint --check` giờ dùng được làm gate.
4. ✅ **Per-node log AI-fix-được**: `diff.py --spec <specfile> [--top N]` parse `specs/NN-*.md` thành
   từng node (tên + bbox + `style:` font/color/bg/r/border) rồi với mỗi node lệch in 1 dòng:
   **bbox · %pixel · SSIM-node · màu đo được golden→shot (ΔRGB) · giá trị design "intended" từ spec**.
   Nhờ vậy phân biệt được loại lỗi: **ΔRGB cao → sai màu/token**; **ΔRGB thấp nhưng %pixel cao →
   text/vị trí/size** (đối chiếu `font`/`rel` của spec với widget). Đây là phần "log cần gì, lệch bao
   nhiêu" để agent sửa, không phải chỉ ảnh heat-map cho người.
   - **Phân loại `status`**: `MISSING?` (mock có **block đặc** ở đây nhưng render trống — figure-vs-ground)
     · `COLOR?` (có nội dung nhưng sai màu/token) · `SHIFT?` (đúng màu, lệch vị trí/size) · `diff`.
     MISSING xếp lên đầu. **Giới hạn trung thực**: phát hiện-thiếu bằng pixel chỉ **đáng tin với block
     đặc** (fill/badge/tile); **text/icon thưa trên theme tối** có mean ≈ nền nên KHÔNG thể tách "thiếu"
     khỏi "có mà mờ" → cố ý KHÔNG gắn MISSING cho chúng (để MISSING giữ độ chính xác cao). Muốn
     **inventory node đầy đủ** (mọi loại thiếu) thì phải so **cây widget render vs danh sách node spec**
     theo cấu trúc, không phải pixel.
5. ✅ **SSIM perceptual metric**: `diff.py --ssim [--min-ssim V] [--ssim-out heat.png]` qua
   `skimage.metrics.structural_similarity` (KHÔNG tự viết công thức — dùng lib đã kiểm thử). `report.mjs
   --ssim` thêm cột SSIM; `--check --min-ssim V` làm gate. Dep ở `tool/golden_diff/requirements.txt`
   (Pillow + numpy + scikit-image); pixel-mode vẫn chỉ cần Pillow (import skimage lazy).
6. ✅ **Unit test cho diff.py**: `tool/golden_diff/test_diff.py` (stdlib `unittest`, dep-free phần
   pixel; SSIM tự skip nếu thiếu skimage) pin phần glue tự viết — resize 780↔770, tolerance mask,
   region crop, spec-parse, và SSIM gate. Chạy: `python tool/golden_diff/test_diff.py` (CI chạy tự động).

## Còn để ngỏ
- Pump screen **trong app-shell** (thay vì cô lập) để bottom-nav không phải loại bằng `--exclude`,
  và **scroll** để kiểm cả node dưới fold (hiện below-fold + shell bị skip).
- Mở rộng structural sang **mọi state** (giờ mới hook loaded/primary mỗi screen) — thêm dòng
  `dumpStructure` cho các state còn lại trong golden loop.
- Lớp **styling** (màu/spacing/size) chưa có gate tất định ngoài pixel/SSIM — vẫn dựa
  `ui-parity-checker` cho phán đoán cuối.
- Gắn `report.mjs --check` / `structural_audit --check` vào `tool/verify/run.mjs` khi ổn định.
