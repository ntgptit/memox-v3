# `tool/parity/` — Báo cáo & lint visual-parity (tất định, KHÔNG AI)

Biến hai việc lặp đi lặp lại của vòng visual-parity thành **lệnh tất định chạy mọi lần / trong CI,
không gọi model**:

| Việc (trước đây làm tay/AI mỗi vòng) | Tool thay thế |
| --- | --- |
| Liệt kê kit states → tìm golden → chạy `diff.py` từng state → phát hiện state thiếu golden | `report.mjs` |
| Soát spec có màu bare-hex (chưa token hóa) + thống kê token màu kit dùng | `token_lint.mjs` |

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
node tool/parity/report.mjs --check --max 60  # đồng thời fail nếu diff% > 60 (mặc định TẮT)
node tool/parity/report.mjs --screen 03-library-overview   # giới hạn 1 screen
```

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
4. ✅ **Per-element diff**: `diff.py --spec <specfile> [--top N]` → crop từng node bbox trong
   `specs/NN-*.md`, in "node X lệch Y%" sắp xếp giảm dần (localize divergence thay vì cả frame). Nhãn
   node là heuristic (lấy `node:`/`text:` gần nhất) — bbox + % là phần chính xác để cross-ref.

## Còn để ngỏ
- Per-element label tagging chính xác hơn (theo cây DOM thật, không heuristic dòng-gần-nhất).
- Gắn `report.mjs --check` vào `tool/verify/run.mjs` khi map đã ổn định lâu dài.
