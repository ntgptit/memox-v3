---
last_updated: 2026-06-21
object: Study — Review mode (and Match / Guess / Recall / Fill)
loop_order: 6-10 of 10 (outer→inner)
route: /library/study/session/:sessionId (NOT wired — no study routes exist)
status: DEFER (greenfield study FE wiped + mock↔docs conflict + doc drift)
---

# Loop plan — Objects 6-10: Study (Review / Match / Guess / Recall / Fill)

## Audit — the entire Study FE is absent (greenfield), the docs say otherwise

- **No Study FE exists.** `lib/presentation/features/study/` does **not exist**; there are **no
  study routes** (`route_names.dart` / `route_paths.dart` have none); WBS **4.5.3 (Review FE),
  4.5.5 (Match FE), 4.5.7 (Guess FE), 4.5.9 (Fill FE)** are all `Specified`. The study session UI
  was wiped in the 2026-06-19/06-21 reset and never rebuilt.
- **Study BE is largely built** (loops 1-30): entry eligibility (4.1.1), session create/load/answer
  /cancel (4.2.x/4.3.1/4.4.1), finalize + SRS transition (4.6.1), resume gate (4.2.2), mode
  strategies (4.5.1 review/recall/guess, 4.5.6 guess options, 4.5.8 fill), daily new limit (4.5.10),
  result read model (4.7.1). So the FE has BE to call — but no screen, no route.
- **Mocks exist:** `shots/12-study-review`, `13-match`, `14-guess`, `15-recall`, `16-fill`,
  `17-result`; wireframes `12-study-entry-gate.md` … `18-study-result.md`.

## DEFER reasons (objects 6-10)

1. **Doc drift (DRIFT DETECTED).** `docs/wireframes/13-study-session-review.md` §"Current V1
   implementation note" claims a **shipped** screen at
   `lib/presentation/features/study/screens/study_session_screen.dart` ("swipe-grade review
   surface…") — but that file/dir does **not exist**. Wireframes 13-18 describe a prior iteration's
   shipped state that the reset wiped. The docs must be corrected (status → Specified/greenfield) by
   an owner-directed pass before a rebuild, so a rebuild isn't started from a false "as-built" spec.
2. **Mock ↔ docs conflict on the core Review interaction (do not guess).** The **mock** `12-study-
   review--default` shows a **flip card**: a TERM front + pronunciation + `↻ TAP TO FLIP`, with
   `Flip` / `Next →` buttons (front → flip → back → advance). The **wireframe 13 + business
   `study-flow.md` §61/§160-176** specify the opposite: **both sides shown on one card, graded by
   swipe** (right = perfect, left = forgot), **no reveal/flip step**. These are fundamentally
   different grade interactions. Review mode is the **anchor screen** whose "visual grammar is reused
   by modes 14-17", so this conflict blocks **all five** study screens. Per `CLAUDE.md` (mock-parity:
   "if the mock and documentation conflict, stop and document"), this needs an **owner decision**:
   flip-then-grade (mock) vs both-sides-swipe (docs).
3. **Greenfield scope.** Building the study session UI from scratch — routes, entry gate (12),
   the shared session shell + 5 mode surfaces (12-16), card-actions sheet (edit/bury/suspend),
   exit-confirm, finalize → result (17/18) — is a large multi-slice feature, not a single overnight
   work-package, and it cannot start until (1) and (2) are resolved.

## Gap-checklist (all DEFER — owner-blocked)

- [ ] Objects 6-10 — Study session FE (Review/Match/Guess/Recall/Fill) — **DEFER (mock-doc-conflict +
      drift + greenfield).** Needs: (a) an owner decision on the Review grade interaction (flip vs
      swipe); (b) a docs pass correcting wireframes 13-18 from "shipped" to greenfield; (c) a
      dedicated multi-slice build of the study FE over the existing BE. None is a safe overnight slice.

## Conclusion

Objects 6-10 are **DEFERred** — the study FE is greenfield (wiped), the wireframes wrongly claim it
is shipped (drift), and the mock contradicts the docs on the foundational Review grade interaction.
This is the loop's stopping point: objects 1-5 (Library, Folder detail, Sub-folder, Deck detail,
Flashcard list+editor) are DONE; objects 6-10 (all Study) are blocked on owner decisions + a large
greenfield rebuild. See `docs/project-management/loop-deferred.md` for the decision list.
