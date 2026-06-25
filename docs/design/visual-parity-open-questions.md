# Prompt — hỏi AI agent khác về visual-parity (MemoX)

> Mục đích: bản prompt tự-chứa để đưa cho một AI agent khác (cố vấn kỹ thuật, hoặc
> một phiên Claude/GPT mới) nhằm xin tư vấn về bài toán "FE khớp mock design".
> Copy nguyên khối dưới đây. Nếu agent kia CÓ quyền truy cập repo, thêm mục "Repo
> paths" ở cuối vào prompt.

---

## PROMPT (copy từ đây)

# Vai trò
Bạn là cố vấn kỹ thuật cấp cao về **design-parity engineering** (visual regression,
golden testing, design-token tooling) cho một app Flutter. Tư vấn cụ thể, có
trade-off, KHÔNG nói chung chung.

# Bối cảnh
App: MemoX — flashcard, local-first, Flutter / Material 3 / Riverpod / Drift.
Nguồn thiết kế ("source of truth") là một **UI kit** (React/HTML chạy runtime,
zero-build):
- shots: ~280 PNG mock (mỗi screen × state × light/dark) — chân lý visual.
- specs: spec DOM auto-gen (cây element, bounding box, token đã resolve, a11y label).
- data-mx-node: id định danh ổn định gắn trên node "required element" của kit.

Đã dựng pipeline "kit-as-compiled-contract" map kit → Flutter:
- **Token codegen**: assert token màu/spacing/radius/type trong Dart == CSS kit.
- **Symbol resolve**: mọi `mx:<Component>` trong spec resolve tới `class Mx*` thật.
- **Binding contract**: mỗi node có `ValueKey('mx-node:<id>')`; test assert node render
  ĐÚNG Mx-component-TYPE (vd search-dock → MxSearchDock).
- **Identity/coverage gate**: kit tag đủ node ↔ FE key đủ (deterministic, immune
  renderer / vị trí / nền).
- **Golden test** per state (light+dark) + **SSIM report** (so golden vs mock shot).

# Vấn đề (đã kiểm chứng thực nghiệm)
Mục tiêu: FE phải KHỚP VISUAL với mock. Nhưng:

1. **Binding contract chỉ chứng minh component TYPE**, không phải visual. "Đúng Mx
   widget ở mỗi node" ≠ "giống mock".

2. **Whole-frame SSIM KHÔNG dùng làm verdict được.** Làm 2 fix thật + nhìn thấy
   (button outlined→tonal; app-bar title 22px→24px) → SSIM KHÔNG nhúc nhích. Vì:
   (a) thô — chi tiết quan trọng (icon, fill, cỡ chữ) chỉ là phần nhỏ pixel;
   (b) **lẫn data** — golden render fixture-test tối thiểu (1 voice "Yuna · ko-KR"),
   mock render data thiết kế phong phú (Yuna · Female · Neural + Minho + Sora) → khác
   content → KHÔNG bao giờ match dù FE hoàn hảo.

3. **Verdict đáng tin duy nhất hiện tại = AI đọc golden-vs-shot từng screen** (phân
   loại mỗi khác biệt: gap-fidelity-thật / khác-data-seed / read-model-thiếu). Chính
   xác nhưng tốn ~85K token/screen × ~20 screen → đắt, bán thủ công.

4. Khi sửa lộ ra **shared-component drift toàn hệ thống** (app-bar title sai cỡ trên
   MỌI screen; 1 fix shared = sửa N screen). Nghi còn nhiều shared component drift.

# Câu hỏi cần tư vấn

**Nhóm 1 — Verify visual tự động, đáng tin, rẻ hơn AI-per-screen:**
- Kỹ thuật nào đo "FE khớp mock" mà KHÔNG dính 2 lỗi của SSIM? Cân nhắc: per-element
  region-diff theo bounding-box lấy từ spec (thay vì whole-frame)? perceptual-hash
  per-element? layout-tree diff (so cây spec vs cây render Flutter)? feature matching?
- Nếu buộc dùng AI-per-screen: cách giảm chi phí (chỉ chạy khi golden content-hash đổi?
  cache verdict? batch nhiều screen/1 lần?).

**Nhóm 2 — Data fixture vs data mock:**
- Nên re-seed golden fixtures cho KHỚP data mẫu của mock (để diff có nghĩa) — hay tách
  bạch: golden = regression-lock nội bộ (data bất kỳ miễn ổn định) + matching-vs-mock
  là kênh riêng? Trade-off mỗi hướng?

**Nhóm 3 — Audit hệ thống vs per-screen:**
- Nên audit TOÀN BỘ shared `Mx*` component vs spec một lượt, hay bắt lẻ per-screen?
- Có nên gen một "component spec contract" (mỗi Mx* widget ↔ spec đo được của primitive
  kit tương ứng: cỡ / typography / token) để GATE tự động drift shared-component
  không? Thiết kế contract đó thế nào cho deterministic?

**Nhóm 4 — Quy trình + định nghĩa "done":**
- Định nghĩa "1 screen đã matching" thế nào khi không có % tin cậy? (checklist?
  AI-verdict + human spot-check? gate gì?)
- Tiêu chí ưu tiên ~20 screen còn lại?

# Output mong muốn
Mỗi nhóm: đề xuất CỤ THỂ + trade-off + 1 phương án "nên làm trước". Nêu tên
pattern / tool / kỹ thuật trong ngành (nếu phù hợp) + cách áp vào pipeline trên.

## (Tùy chọn) Repo paths — chỉ thêm nếu agent có quyền đọc repo
- Pipeline: thư mục `tool/parity/` (đặc biệt report SSIM `tool/parity/report.mjs`,
  binding gen `tool/parity/gen_bindings.mjs`).
- Golden harness: `test/flutter_test_config.dart`.
- Helper binding-contract test: `test/support/parity_contract.dart`.
- Specs + shots: dưới `docs/system-design/MemoX Design System/ui_kits/mobile/`.
- Log hiện trạng + backlog: `docs/project-management/overnight-fe-sync-log.md`.

---

## Phụ lục — quyết định cần HUMAN (PO/designer), AI chỉ giúp framing options

Không hỏi AI để "quyết" mấy mục này; chỉ nhờ AI liệt kê option + hệ quả:

- **23-audio-speech / voice gender + quality** ("Female · Neural"): read-model
  `TtsVoice` chỉ có `localeTag`; `flutter_tts` có thể không cấp gender/quality →
  Future? bỏ khỏi design? tìm nguồn data khác?
- **23-audio-speech / row "System default"**: FE có, mock không → giữ hay bỏ?
- Các screen khác nhiều khả năng có kiểu xung đột data-vs-design tương tự.
