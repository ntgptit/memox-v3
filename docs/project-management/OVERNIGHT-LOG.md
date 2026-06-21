# Overnight Loop Log

Append-only, newest-last. One line per task: `[time] commit-hash · WBS ID · summary · status`.

- [loop-1] ce978d1 · 4.0.1 · Study persistence enabler (B1): schema v6 study_sessions/items/attempts + StudyRepository skeleton (expireOldSessions only) + DAO + DI + SessionId typedef; schema/migration/WBS docs synced, stale study "DONE" markers corrected · **DONE**
- [loop-2] 640ef46 · 4.1.1 · Study entry eligibility BE: EntryType/StudyType/StudyScope + StudyEntryEligibility/StudyScopeEmptyReason; StudyEntryRepository classifies deck/folder-recursive/today scope counts vs empty-scope matrix (suspended/buried excluded); ResolveStudyEntryEligibilityUseCase + DI; 16+1 tests; study-flow/study.md/decision-table/WBS synced · **DONE**
- [loop-3] 201fe72 · 4.2.1 · Session creation BE: StudySession entity + SessionStatus enum + StudySessionMapper; StudyRepository.createSession + StudySessionDao.createSessionWithItems (transactional session+ordered items, in_progress, rolls back as unit); CreateStudySessionUseCase (validates empty list) + DI; 6+2 tests; StudyType token→new_cards per catalog; study.md/study-repository/decision-table/WBS synced · **DONE**
- [loop-4] 15a4d74 · 4.2.4 · Session batch limit BE: CreateStudySessionUseCase.maxSessionItems const (20) + first-N cap (caller's order); cap lives in use case not repo; reconciled 4.2.1 "cap by caller" notes; 2 use-case tests; decision S1/S2/S3 + overview status synced · **DONE**
- [loop-5] 793e542 · 4.10.1 · Cancel/discard session BE: StudyRepository.cancelSession + StudySessionDao.markCancelled (guarded UPDATE status→cancelled for draft/in_progress only; row not deleted, attempts/items preserved); 0-rows + sessionById fallback → NotFoundFailure vs UnsupportedActionFailure (terminal); CancelStudySessionUseCase + DI; 4+1 tests; study.md/WBS synced · **DONE**
- [loop-6] 275f6d7 · 4.3.1 · Session item loading BE: StudySessionReview/StudySessionReviewItem entities (header+ordered flashcard-joined items, firstUnansweredIndex/isComplete getters); StudyRepository.loadStudySessionReview composes sessionById+itemsForSession+flashcardsByIds (cardById map preserves order, avoids dynamic-typed builder join); empty items→ValidationFailure; toReviewItem mapper; LoadStudySessionReviewUseCase + DI; 3 tests; study.md/WBS synced · **DONE**
- [loop-7] d238c9d · 4.5.1 · Study mode strategy V1 BE: AttemptResult+StudyMode enums (catalog Target→Current); sealed StudyModeStrategy + 3 families (BinaryGrade review/recall/guess perfect/forgot, TypedAnswer fill strict trim case-sensitive, Board match no-grading) + 5 leaves; StudyModeStrategyFactory exhaustive switch; 7 tests; decision S46/S47/S48/S49/S58 refs · **DONE**
- [loop-8] 237160c · 4.4.1 · Submit self-grade BE: SrsBox.nextBox box transition (perfect+1cap8/recovered-stay/forgot-1); StudyRepository.recordStudySessionAnswer (transactional attempt insert + answered_at + updated_at, progress untouched=finalization-owned; terminal/already-answered→UnsupportedAction; new-card→box1); mapper result/study_mode tokens; RecordStudySessionAnswerUseCase + DI; 7+5 tests; study.md/srs-review/decision S6/S35/S36/S76 synced · **DONE**
- [loop-9] 7ee272b · 4.2.2 · No-silent-resume gate BE: StudyRepository.findResumable + StudySessionDao.findResumableSession (NULL-safe scope match, draft/in_progress, 30d window strict>, most-recent; study_type NOT in conflict key per contract); StudyEntryStartResult sealed (resumeRequired/canStart/blocked) + ResolveStudyEntryStartUseCase gate composing eligibility 4.1.1; DI; 7+3 tests; study.md/decision S28 synced · **DONE**
- [loop-10] a36f632 · 5.1.1 · Dashboard Continue-Studying summary BE: DashboardResumeSessionSummary model (scope/answered/total/lastActive + progress); dashboardResumeSession .drift query (most-recent resumable any-scope, 30d window, COUNT items + COUNT(answered_at)); DashboardRepository.loadResumeSessionSummary (null=no session, not error); LoadDashboardResumeSummaryUseCase + DI; 5 tests; engagement contract note · **DONE**

---

## TỔNG KẾT phiên xuyên đêm (2026-06-21, loop-1…loop-10) — PAUSED at loop-11

**10 commits feature đã push lên `main` (mỗi cái lật ≥1 WBS ID Specified→Implemented; verify XANH + dual-review + doc-parity):**

| # | WBS | Commit | Tóm tắt |
|---|-----|--------|---------|
| 1 | 4.0.1 | ce978d1 | Study persistence schema v6 (study_sessions/items/attempts) + StudyRepository skeleton + DAO + DI |
| 2 | 4.1.1 | 640ef46 | Study entry eligibility BE (EntryType/StudyType/StudyScope + empty-scope matrix classification) |
| 3 | 4.2.1 | 201fe72 | Session creation BE (transactional session+ordered items, StudySession entity + mapper) |
| 4 | 4.2.4 | 15a4d74 | Session batch limit (maxSessionItems cap in use case) |
| 5 | 4.10.1 | 793e542 | Cancel/discard session BE (guarded status→cancelled, terminal→UnsupportedAction) |
| 6 | 4.3.1 | 275f6d7 | Session item loading BE (StudySessionReview header+ordered flashcard-joined items) |
| 7 | 4.5.1 | d238c9d | Study mode strategy V1 BE (AttemptResult/StudyMode enums + sealed families + factory) |
| 8 | 4.4.1 | 237160c | Submit self-grade BE (SrsBox box transition + recordStudySessionAnswer transactional) |
| 9 | 4.2.2 | 7ee272b | No-silent-resume gate BE (findResumable + StudyEntryStartResult + gate use case) |
| 10 | 5.1.1 | a36f632 | Dashboard Continue-Studying summary BE (resumable read model + progress) |

**BE study chain hiện chạy được tới mức data-layer:** resume-gate → eligibility → create → load → answer → cancel. SRS box transition đã ghi per-attempt; flashcard_progress chờ finalization.

**TASK CÒN LẠI eligible nhưng PAUSED (lý do — KHÔNG phải blocked thật):**
- **4.6.1 Finish session BE (finalization)** — keystone lớn nhất + nhạy cảm SRS (transaction + interval table + due_at=localMidnight + progress upsert + lapse + rollback; biên 4.6.1/4.6.2/4.6.4 đan nhau). Spec rõ (srs-review §transition+interval tables) nhưng task nặng & dễ sai semantic → để dành 1 run context-tươi để tránh "để dở"/sai semantic đã commit. KHÔNG cần quyết định sản phẩm.
- **4.5.2 Review mode BE** — delta BE so với 4.5.1 mỏng/không rõ ("both-sides + attempt semantics" hầu hết đã có ở BinaryGrade); cần làm chung với FE 4.5.3 hoặc làm rõ scope.
- **4.10.2 Resume expiry anchor** — hành vi anchor-on-updated_at ĐÃ thoả mãn bởi 4.0.1/4.2.2/4.3.1/4.4.1/5.1.1 (findResumable + dashboard filter updated_at; answer bump updated_at; read-only load không bump). Chỉ còn test khoá hành vi — không phải feature code-mới.

## DANH SÁCH QUYẾT ĐỊNH CẦN USER (sáng dậy trả lời)
1. **today + newCards** (đã nêu nhiều lần): `study-flow.md` nói `today` luôn `srs_review`, nhưng `docs/wireframes/01-dashboard.md` + dashboard visual-contract tham chiếu CTA `goStudyEntry(today, newCards)`. Code hiện xử lý phòng thủ (today+new → đếm active cards) + có test khoá. **Hỏi:** today+new có phải entry hợp lệ không, hay reject? (Khuyến nghị: hợp lệ — "học bài mới hôm nay" — giữ hành vi hiện tại; nếu KHÔNG, đổi sang reject + sửa wireframe.)
2. **4.6.1 next:** xác nhận làm finalization gộp box-transition(4.6.2)+due_at-midnight(4.6.4) trong 1 slice, hay tách 4.6.1 (chỉ transaction+mark-complete) trước rồi 4.6.2/4.6.4 sau. (Khuyến nghị: gộp — chúng đan nhau, tách ra tạo trạng thái nửa vời.)
3. **4.5.2 scope:** xác nhận review-mode BE = tách `ReviewStudyModeStrategy` ra file riêng + trait "both-sides/no-reveal", hay gộp luôn với FE 4.5.3.
- [loop-12] c4a0e5c · 4.7.1 · Result summary BE: `StudySessionResult`/`StudySessionResultItem` models (total/answered/forgot/passed getters); `StudyRepository.loadStudySessionResult` = header + ordered flashcard-joined items + terminal `AttemptResult` per item via the V1 last-attempt classifier SHARED with finalization (`_terminalResult`), so result screen and persisted SRS outcome can't diverge; unanswered item→null; missing→NotFound; item-less→ValidationFailure. `StudySessionMapper.toResultItem`; `LoadStudySessionResultUseCase`+DI. 6 tests (4 repo incl. recovered multi-attempt + null/notfound/empty branches, 2 usecase). Docs: study.md Implemented note, decision rows RES6/RES7/RES8 (+index RES1–RES8), WBS 4.7.1 Specified→Implemented + §10 + backlog P0.8. 3-reviewer fan-out: SRS classifier-reuse confirmed correct; addressed srs-reviewer (added BE decision rows+test refs) & added defensive comment; deferred N+1 attemptsForItem (pre-existing finalize pattern, bounded ≤20 items) · **DONE** · hash-fill e330f20 (1 slice): finalizeStudySession transactional (per item: _terminalResult last-attempt classifier → SrsBox.nextBox box_after → due=localMidnight(studyDay+BoxIntervals.daysFor) Dart-local → review+1/lapse+1-on-forgot; new-card box1; suspend/bury preserved; mark completed; rollback unit). BoxIntervals ladder (1-5/12/30/60). Validate-all-answered→FinalizationFailure stays-open; terminal→UnsupportedAction; missing→NotFound. FinalizeStudySessionUseCase+DI. 7 transition + 5 finalize tests. srs/srs-review/study.md phantom source refs corrected, decision S9/S10/S11-S15/S17/S18. 3-reviewer fan-out (SRS math confirmed correct) · **DONE**
