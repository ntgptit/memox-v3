# Visual-Parity Build Plan — MemoX

> Trạng thái: PLAN (chưa build). Tổng hợp 4 vòng tư vấn (Codex ↔ ChatGPT ↔ Claude
> Code) đã hội tụ + các sửa ground-truth từ repo thật. Mục tiêu: hệ **nhiều gate
> deterministic per-element** để bắt visual-drift thật (app-bar title 22→24, button
> outlined→tonal) rẻ + tin cậy; AI chỉ xử lý phần mơ hồ.

## 0. Vì sao

- Binding contract hiện chỉ chứng minh **component TYPE** (đúng `Mx*` widget ở mỗi
  node), KHÔNG phải visual matching.
- **Whole-frame SSIM không phải verdict**: thô (chi tiết = ít pixel), lẫn **data
  seed-test với data thiết kế của mock**, và đụng **cross-engine render floor** (mock
  render browser/Blink, golden render Flutter/Skia → sai khác sàn dù FE hoàn hảo).
- Đã chứng minh thực nghiệm: 2 fix thật (title 22→24, button outlined→tonal) → SSIM
  không nhúc nhích.

## 1. Nguyên tắc (hard rules — không thương lượng)

1. **Số-đo là precise-backbone.** `RenderParagraph`/`getRect`/`getSize` assert ngược
   **spec-number** — engine-independent + honest. KHÔNG lấy debug-contract/SSIM làm
   xương sống.
2. **Pixel-diff (golden vs shot) chỉ là gross-smoke.** Cross-engine floor cấm dùng nó
   kết luận precise (1–2px, font 22/24, màu chính xác).
3. **Các lớp BỔ SUNG, không thay thế.** Số-đo bắt geometry/precise; micro-golden +
   ROI bắt **visual-không-geometric** (fill sai/rect đúng, icon glyph, shadow, radius
   nhìn lệch, asset, anti-alias/weight).
4. **Hai lane golden tách bạch**: regression (fixture ổn định, FE-vs-FE) ‖ parity
   (design-seed hoặc mask, vs-mock).
5. **Audit shared `Mx*` TRƯỚC** (drift shared = N screen); per-screen sau.
6. **Không average variant.** Tách variant hoặc báo `needs-variant`.
7. **Debug-contract (nếu làm) phải single-resolver** dùng chung bởi `build()` +
   `debug()`; nếu không → false-green. → defer tới khi cần.
8. **Không tìm "1 metric thay AI".** AI = bộ phân loại mơ hồ trên changed-ROI, cache
   theo content-hash.
9. **Right-size theo độ chín**: design/FE đang mid-dev → làm phần rẻ-lợi-cao trước,
   defer rig nặng.

## 2. Trust hierarchy

| Lớp | Honest | Precise | Engine-independent | Vai trò |
| --- | --- | --- | --- | --- |
| Số-đo: RenderParagraph/getRect vs spec-number | ✅ đo | ✅ | ✅ | **XƯƠNG SỐNG precise** |
| Micro-golden (FE-vs-FE) + spec-number assert | ✅ đo | 🟡 | ❌ vs-shot | regression + visual |
| ROI diff vs shot (mask data) | ✅ | ❌ noise | ❌ | gross-smoke |
| Whole-frame SSIM (`tool/parity/report.mjs`) | — | ❌ | ❌ | ranking/smoke |
| Debug-contract single-resolver | 🟡 khai | ✅ | ✅ | metadata — **DEFER** |
| AI / ui-parity-checker | ✅ | ✅ | ✅ | ambiguity classifier, cached |

## 3. Rủi ro thực thi phải giải trong Phase 0 (4 gotcha)

1. **Spec-number không đồng đều.** Có `font:24/700`, `r:20`, đôi khi `pad:8/16`;
   nhiều node KHÔNG có padding/gap explicit → phải **derive child-rect − parent-rect**.
2. **CSS border-box ≠ Flutter `getRect` paint-bounds.** Lệch theo border-width /
   content-box. "height==64" phải định nghĩa rõ **đo box nào**.
3. **Probe-key breadth.** `data-mx-node` hiện ở **container**; đo font cần key trên
   **Text con**. Phải thêm `mx-probe:<component>/<part>` cho sub-part đo được (8
   component). Spec đã có sub-node (vd `section-head-title`) → ánh xạ được.
4. **Noise-floor circular.** Muốn đo cross-engine floor cần known-good (FE khớp hoàn
   hảo) — thứ ta đang đi tìm. → Floor là **ước lượng kinh nghiệm**, rủi ro: cao quá
   thì nuốt gap nhỏ thật. Ghi rõ là *judgment*, không phải số sạch.

## 4. Build order (phase + acceptance gate)

### Phase 0 — Calibration + noise floor (BLOCKING cho ROI)

```
tool/parity/calibrate_coords.mjs
tool/parity/calibration-baseline.json
```

Đo + chốt: spec viewport · shot PNG size · golden surface size · devicePixelRatio ·
scaleX/scaleY · safe crop padding · **box-model mapping rule** (gotcha #2) ·
**cross-engine noise floor per component-class** (gotcha #4, đánh dấu là estimate).

Acceptance: baseline committed; rule box-model viết rõ; **không ROI verdict nếu thiếu
baseline**.

### Phase 1 — Spec-number gate cho shared components ⟵ **VALIDATING SLICE bắt đầu**

```
tool/parity/gen_component_contract.mjs
tool/parity/contracts/component-contracts.json
test/presentation/shared/widgets/navigation/mx_app_bar_spec_gate_test.dart
test/presentation/shared/widgets/buttons/mx_button_spec_gate_test.dart
```

- Sinh contract: group spec node theo `mx:<Component>` + style → extract
  height/padding/gap/radius/border/icon-size/fontSize/fontWeight/lineHeight. Variant
  nhiều style → tách (`MxActionButton.tonal`, `MxCard.metric`…) hoặc `needs-variant`.
- Thêm **probe-key** vào sub-part shared widget (gotcha #3).
- Test assert `getRect(...).height`, `RenderParagraph.text.style.fontSize`,
  `RenderParagraph.textSize`, padding/radius vs `component-contracts.json`.

**Pilot MxAppBar TRƯỚC** (bắt 22→24), rồi `MxPrimaryButton` / `MxSecondaryButton` /
`MxActionButton` / `MxCard` (theo tần suất `tool/parity/symbol-map.json`).

Acceptance (M0 STOP/GO): test **ĐỎ** khi revert app-bar về `headlineMedium` (22) →
**XANH** sau fix (24/700). Không averaging. Đây là **bằng chứng plan chạy**.

### Phase 1.5 — Upgrade existing micro-goldens thành spec-aware

Existing (giữ làm FE-vs-FE regression — KHÔNG pixel-match Skia↔Blink):
`tool/parity` không đụng; các test golden shared đã có ở
`test/presentation/shared/widgets/**` (buttons/surfaces/navigation/inputs/states…).

Việc mới: **thêm spec-number assertion cạnh `matchesGoldenFile`** (không viết lại
golden). Golden = regression; spec-number = conformance.

Acceptance: mỗi shared-component golden test có thêm khối assert spec-number.

### Phase 2 — Layout snapshot (screen-level)

```
test/support/parity_layout_snapshot.dart
test/parity/layout_snapshots/<screen>.<state>.<theme>.json
```

Dump per `ValueKey('mx-node:<id>')`: type · rect · parentRect · relative-pos ·
text-metrics (nếu text node). Check **relative-to-parent + IoU≥0.95**, không absolute
nguội.

Catches: drift layout hệ thống, position/size, missing/extra surface — chưa cần pixel.

Acceptance: snapshot cho Tier-1 screens; diff theo relative/IoU.

### Phase 3 — `screen-status.json` dispatch ledger

```
tool/parity/screen-status.json
```

Per screen: `tier · calibration · componentSpecGate · layoutSnapshot · roiSmoke ·
aiVerdict · done`. **Agent chỉ nhận task theo status** — chặn "nhìn ảnh sửa lung tung"
(failure-mode đã gặp ở loop trước).

### Phase 4 — ROI smoke diff (changed-only)

```
tool/parity/element_report.mjs
```

Crop mock-by-spec-bbox + golden-by-flutter-rect, **mask data-bearing node**, so bằng
pixel% + ΔE/CIEDE2000, tolerance **≥ noise floor (Phase 0)**.

Verdict: `gross-pass / gross-fail / borderline-needs-ai / data-masked /
not-comparable-cross-engine`. **KHÔNG precise verdict.**

Chỉ chạy khi: calibration pass ∧ component-gate pass ∧ layout pass ∧ data seed/mask
rõ ∧ (spec|golden|layout|contract) đổi.

### Phase 5 — DEFER: debug-contract / visual resolver

```
lib/presentation/shared/visual_contracts/   (chỉ khi cần)
```

Chỉ làm khi: số-đo không biểu đạt được **token intent** ("dùng token nào", không chỉ
"giá trị bao nhiêu") ∧ có drift lặp do hardcode style. Rule: `build()` +
`debugVisualContract(context)` **dùng chung một resolver** (gotcha #từ vòng 4).

## 5. Two-lane golden + data policy (cross-cutting)

- **Lane A — regression**: fixture app ổn định, FE-vs-FE, update có chủ đích
  (`--update-goldens`).
- **Lane B — parity**: fixture **khớp data mock** hoặc **mask** node data-heavy.
  Metadata trong spec/fixture: `compare: visual-and-text | mask-text`.
- **Không fake field chưa có trong read-model.** Mock cần data chưa có → `needs-schema`
  + mask + ghi `tool/parity/intent-ledger.json`.

## 6. Definition of done — per screen

1. Design fresh: specs/shots fresh; `design_watch --check` pass; parity-map đủ state
   light/dark in-scope.
2. Identity: `mxnode_coverage` + `gen_contract --check` + `fe_node_usage` pass; không
   structural component unkeyed chưa giải thích.
3. Binding/type: mỗi required node có `ValueKey` đúng + render đúng `Mx*` type.
4. **Layout number gate** (Phase 1/2): mọi keyed node rect + text-metric pass
   tolerance; không major position/size drift.
5. **Visual ROI/micro-golden**: gross-pass; phần dư phân loại (renderer/anti-alias ·
   data-seed · accepted-behavior · real-gap-phải-fix).
6. Whole-frame: golden light+dark tồn tại; SSIM/pixel chỉ smoke/ranking.
7. Review: AI/human chỉ chạy khi baseline mới hoặc ROI-hash đổi; verdict cache + ghi
   ledger.

**Verdict levels:** `MATCHED` · `MATCHED_WITH_DOCUMENTED_GAPS` (behavior/future/
needs-schema/rejected có source) · `UNKNOWN` (tín hiệu xung đột → AI/human) ·
`DIVERGED` (missing node / sai Mx type / number-gate fail / ROI fail trên node
required unmasked).

## 7. Ưu tiên (sau khi shared components xong)

- **Tier 1 — flow học chính**: Dashboard, Library-overview, Folder/Deck-detail,
  Flashcard list/detail/editor, Study entry/session/result, Progress.
- **Tier 2 — shared-density cao** (nhiều MxAppBar/MxCard/MxButton/MxSearchDock).
- **Tier 3 — dễ seed / static settings** (làm sau nếu không chặn flow).
- **Tier 4 — dark-mode/token-risk** (sau khi light pass; dark lộ color-token drift).

## 8. Milestones (right-sized rollout)

- **M0 — Validating slice**: Phase 0 + Phase 1 chỉ **MxAppBar** → bắt deterministic
  bug 22→24. **CHECKPOINT STOP/GO**: nếu vướng (box-model/spec-number/calibration khó
  hơn tưởng) → học rẻ, điều chỉnh trước khi đổ công.
- **M1**: Phase 1 cho 5 shared components + Phase 1.5.
- **M2**: Phase 2 + Phase 3 trên Tier-1 screens.
- **M3**: Phase 4 ROI smoke + AI cache.
- **Defer**: Phase 5, rollout đủ ~20 screen — tới khi design ổn.

## 9. Anti-scope (KHÔNG làm)

- Không nâng ngưỡng SSIM để mong nó thành chân lý.
- Không pixel-match Skia với Blink.
- Không build debug-contract/resolver ở giai đoạn này.
- Không rollout 20 screen trước khi shared components có number-gate.
- Không fake data để khớp mock.

## 10. Effort + tích hợp verify

- Toàn bộ chạy qua entry hiện có (`node tool/verify/run.mjs`); gate mới gắn vào
  docs+code chain như các gate parity khác.
- Quy mô đầy đủ = nhiều tuần; **M0 chỉ là 1 lát mỏng** — re-evaluate sau M0.
- WBS: tooling/parity-infra, không advance feature package → ghi "WBS not needed" khi
  commit.
