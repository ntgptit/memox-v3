# MemoX v3 Work Breakdown Structure (WBS)

Generated: 2026-06-09
Last reviewed: 2026-06-10
Repository: `ntgptit/memox-v3`
Baseline reviewed: local `main` = remote `origin/main` at `e7b9af69` (`docs(wbs): add deck import transaction traceability`). This revision rebuilds the WBS as a whole-project, function-level delivery plan: every major flow is decomposed into BE (local-backend) and FE (presentation) function rows with explicit dependencies, evidence paths, and verified commit anchors.

## 0. Purpose

This WBS is the delivery plan for the whole MemoX project. It decomposes every user-facing flow into function-level work packages so that each row is independently deliverable, testable, and reviewable by an AI agent in a single narrow prompt.

MemoX is a local-first flashcard learning app. Core learning must work offline; Google account and Drive backup are optional. The local database is the source of truth, and UI/business behavior must follow the business docs, wireframes, decision tables, and source contracts.

Terminology used by the `Layer` column:

- **BE** — MemoX local backend inside Flutter: domain model, use case, repository port, repository implementation, Drift table/DAO/query, transaction, provider wiring, backend/unit tests.
- **FE** — Flutter presentation: screen, widget, Riverpod presentation state, navigation, loading/empty/error states, ARB/l10n copy, widget tests.
- **Integration** — behavior that spans BE and FE (navigation wiring, cross-flow consistency, end-to-end transactions visible to the user).
- **Docs** — business docs, wireframes, decision tables, contracts.
- **Test** — quality gates that are not owned by a single feature row.

## 1. Status Legend

| Status | Meaning |
| --- | --- |
| Implemented | Confirmed by current source, tests, and/or docs evidence. |
| Partial | Some source pieces exist, but the function is not complete (e.g. UI shell without data wiring). |
| Specified | Product/spec docs exist; implementation work is still needed. |
| Target | Intended future behavior; not safe to implement without promotion/checklist. |
| Future | Future proposal; do not implement without explicit approval. |
| Blocked | Requires prerequisite schema/contract/product decision. |
| Rejected | Explicitly out of scope; do not implement. |
| Ongoing | Continuous quality gate; never "done", enforced on every task. |

## 2. Delivery Guidance

MemoX priority is a **usable flashcard/SRS app**. The WBS must drive real user flow, not architecture-only progress.

- Do not build all BE at once; do not create one huge "build all backend" task.
- Do not build isolated FE shells without a real data contract behind them.
- Every flow is decomposed into BE function and FE function tasks; FE rows normally depend on their BE row.
- Preferred sequence inside each function: **BE function → BE tests → FE wiring → FE/widget tests → integration behavior → docs/decision-table parity → polish only if needed**.
- New tasks should move the app toward: create content → study content → resume study → finish session → see progress.
- One prompt may cover up to 7 tightly coupled WBS rows/subtasks when they share a subsystem and dependency chain. List every row/subtask explicitly, stop before unrelated subsystems, and do not mix BE/FE unless the prompt says to.

## 3. Source Evidence Reviewed

- Business/product docs: `docs/business/**` (system overview, navigation, folder, deck, flashcard, study, srs, study-actions, tags, bulk, search, tts, account-sync).
- Architecture/data docs: `docs/architecture/clean-architecture-contract.md`, `docs/database/schema-contract.md`, `docs/checklist/implementation-checklist.md`.
- UI kit: `docs/system-design/MemoX Design System/ui_kits/mobile/README.md` (23-screen gallery), `docs/system-design/MemoX Design System/ui_kits/mobile/AUDIT.md`.
- Source: `lib/app/router/**`, `lib/app/di/**`, `lib/domain/**`, `lib/data/**`, `lib/presentation/features/**`, `lib/presentation/shared/**`.
- Tests: `test/**` (49 test files at baseline).
- Commit history: `git log` on `main` (81 commits at baseline); commit anchors below were verified via `git log --diff-filter=A` per file.

## 4. Function-Level Delivery Plan

Row format: `WBS ID | Flow | Function | Layer | Deliverable | Status | Depends on | Evidence/Source | Commit ID | Next action`.

Commit ID rules: implemented rows carry the verified commit that landed the function (file-creation or feature commit verified from history); planned/future rows carry `TBD`. The commit of the current WBS update is never written into rows (it is unknown until commit); §10 tracks per-commit history.

### Group 1 — Project foundation

| WBS ID | Flow | Function | Layer | Deliverable | Status | Depends on | Evidence/Source | Commit ID | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1.1.1 | Foundation | Architecture baseline | BE | Clean Architecture skeleton (`app`/`core`/`domain`/`data`/`presentation`) with DI providers | Implemented | none | `lib/app/di/**`, `lib/domain/**`, `lib/data/**` | `0b48f360` | No action |
| 1.1.2 | Foundation | Design system baseline | FE | Theme tokens + `Mx*` shared widget kit | Implemented | none | `lib/core/theme/**`, `lib/presentation/shared/**` | `ed0e5402` | Extend tokens/widgets only per approved feature need |
| 1.1.3 | Foundation | Routing baseline | FE | GoRouter shell, `RouteNames`/`RoutePaths` constants, placeholder discipline | Implemented | none | `lib/app/router/app_router.dart` | `0b48f360` | No action |
| 1.1.4 | Foundation | l10n baseline | FE | ARB en/vi + generated localizations pipeline | Implemented | none | `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb` | `6c17a461` | No action |
| 1.1.5 | Foundation | Drift/database baseline | BE | `.drift` schema layout, `AppDatabase` v4, migration infrastructure v2–v4 | Implemented | none | `lib/data/datasources/local/app_database.dart`, `lib/data/datasources/local/migrations/**`, `test/data/migrations/**` | `68c67656` | No action; any schema change follows §9 rules |
| 1.1.6 | Foundation | Guard/verification baseline | Test | Analyzer + `dart fix`/`format` + targeted tests workflow; guard ruleset when present | Partial | none | `docs/checklist/implementation-checklist.md` | TBD | Add CI status checks (see 9.10) |
| 1.1.7 | Foundation | Docs baseline | Docs | Business docs, wireframes, contracts, decision tables as source of truth | Implemented | none | `docs/business/index.md`, `docs/decision-tables/memox-core-decision-table.md` | TBD | Maintain parity per commit (history spans many commits; no single anchor) |

### Group 2 — Content management

| WBS ID | Flow | Function | Layer | Deliverable | Status | Depends on | Evidence/Source | Commit ID | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2.1.1 | Content management | Folder Create BE V1 | BE | Validated root/subfolder create use cases + repo + DAO + tests | Implemented | 1.1.5 | `lib/domain/usecases/folder/create_root_folder_usecase.dart`, `lib/domain/usecases/folder/create_subfolder_usecase.dart`, `test/data/repositories/folder_repository_impl_test.dart` | `a736ed16` | No action |
| 2.1.2 | Content management | Folder Create FE V1 | FE | Create-folder dialog, form state, submit, error/loading | Implemented | 2.1.1 | `lib/presentation/shared/dialogs/`, `test/presentation/shared/dialogs/mx_folder_form_dialog_test.dart` | `486dc8ba` | No action |
| 2.2.1 | Content management | Folder Rename BE V1 | BE | Validated rename use case + repo + tests | Implemented | 2.1.1 | `lib/domain/usecases/folder/rename_folder_usecase.dart`, `test/data/repositories/folder_repository_impl_test.dart` | `68c67656` | No action |
| 2.2.2 | Content management | Folder Rename FE V1 | FE | Rename dialog via folder actions sheet | Implemented | 2.2.1 | `lib/presentation/features/folders/widgets/library_folder_actions_sheet.dart`, `test/presentation/features/folders/library_folder_actions_sheet_test.dart` | `486dc8ba` | No action |
| 2.3.1 | Content management | Folder Delete BE V1 | BE | Transactional cascade delete per persistence rules + tests | Implemented | 2.1.1 | `lib/domain/usecases/folder/delete_folder_usecase.dart`, `lib/data/repositories/folder_repo_impl_mutation_helpers.dart` | `3759ad5e` | No action |
| 2.3.2 | Content management | Folder Delete FE V1 | FE | Confirmation dialog + success/error state | Implemented | 2.3.1 | `lib/presentation/shared/dialogs/mx_folder_delete_dialog.dart`, `test/presentation/shared/dialogs/mx_folder_delete_dialog_test.dart` | `3759ad5e` | No action |
| 2.4.1 | Content management | Folder Move BE V1 | BE | Cycle-safe move + move-target query + tests | Implemented | 2.1.1 | `lib/domain/usecases/folder/move_folder_usecase.dart`, `lib/domain/usecases/folder/get_folder_move_targets_usecase.dart` | `68c67656` | No action |
| 2.4.2 | Content management | Folder Move FE V1 | FE | Move picker sheet + states | Implemented | 2.4.1 | `lib/presentation/features/folders/widgets/folder_move_picker_sheet.dart`, `test/presentation/features/folders/folder_move_picker_sheet_test.dart` | `68c67656` | No action |
| 2.5.1 | Content management | Folder Reorder BE V1 | BE | `sort_order` reorder use case + DAO + tests | Implemented | 2.1.1 | `lib/domain/usecases/folder/reorder_folders_usecase.dart`, `lib/data/repositories/folder_repo_impl_mutation_helpers.dart`, `lib/data/repositories/folder_repository_impl.dart`, `test/data/repositories/folder_repository_impl_test.dart`, `test/domain/usecases/folder/reorder_folders_usecase_test.dart` | `48e55584` | No action |
| 2.5.2 | Content management | Folder Reorder FE V1 | FE | Manual reorder UI when sort mode allows | Specified | 2.5.1 | TBD | TBD | Wire reorder gesture to BE; widget tests |
| 2.6.1 | Content management | Folder content-mode guard BE | BE | Parent holds subfolders or decks, never both; enforced outside UI | Implemented | 2.1.1 | `lib/domain/types/content_mode.dart`, `lib/data/repositories/folder_repo_impl_mutation_helpers.dart`, `test/data/repositories/folder_repository_impl_test.dart` | `48e55584` | No action |
| 2.7.1 | Content management | Deck Create BE V1 | BE | Validated deck create (folder-owned, mode lock) + tests | Implemented | 2.6.1 | `lib/domain/usecases/deck/create_deck_usecase.dart`, `test/data/repositories/folder_repository_impl_test.dart` | `f925140f` | No action |
| 2.7.2 | Content management | Deck Create FE V1 | FE | Create-deck flow from folder detail | Implemented | 2.7.1 | `lib/presentation/features/folders/screens/folder_detail_screen.dart`, `test/presentation/features/folders/folder_detail_test.dart` | `f925140f` | No action |
| 2.8.1 | Content management | Deck Rename BE V1 | BE | Validated deck rename use case + repo method + tests | Implemented | 2.7.1 | `lib/domain/usecases/deck/rename_deck_usecase.dart`, `lib/data/repositories/folder_repo_impl_mutation_helpers.dart`, `lib/data/repositories/folder_repository_impl.dart`, `test/data/repositories/folder_repository_impl_test.dart`, `test/domain/usecases/deck/rename_deck_usecase_test.dart` | `48e55584` | No action |
| 2.8.2 | Content management | Deck Rename FE V1 | FE | Rename entry in deck actions sheet + dialog + states | Specified | 2.8.1 | `lib/presentation/features/flashcards/widgets/deck_actions_sheet.dart` (sheet exists; rename action TBD) | TBD | Wire rename action to BE; widget tests |
| 2.9.1 | Content management | Deck Delete BE V1 | BE | Transactional deck delete with flashcard/progress cleanup + tests | Implemented | 2.7.1 | `lib/domain/usecases/deck/delete_deck_usecase.dart` | `486232bd` | No action |
| 2.9.2 | Content management | Deck Delete FE V1 | FE | Confirmation + success/error state from deck actions | Implemented | 2.9.1 | `lib/presentation/features/flashcards/widgets/deck_actions_sheet.dart` | `486232bd` | No action |
| 2.10.1 | Content management | Deck Reorder BE V1 | BE | `sort_order` reorder use case + tests | Implemented | 2.7.1 | `lib/domain/usecases/deck/reorder_decks_usecase.dart`, `lib/data/repositories/folder_repo_impl_mutation_helpers.dart`, `lib/data/repositories/folder_repository_impl.dart`, `test/data/repositories/folder_repository_impl_test.dart`, `test/domain/usecases/deck/reorder_decks_usecase_test.dart` | `48e55584` | No action |
| 2.10.2 | Content management | Deck Reorder FE V1 | FE | Manual reorder UI | Specified | 2.10.1 | TBD | TBD | Wire to BE; widget tests |
| 2.11.1 | Content management | Flashcard Create BE V1 | BE | Front/back required-after-trim validation, optional fields, default SRS progress + tests | Implemented | 1.1.5 | `lib/domain/usecases/flashcard/create_flashcard_usecase.dart`, `test/domain/usecases/flashcard/create_flashcard_usecase_test.dart` | `c0f1df5d` | No action |
| 2.11.2 | Content management | Flashcard Create FE V1 | FE | Editor screen (create mode), draft hook, save-and-add-another, states | Implemented | 2.11.1 | `lib/presentation/features/flashcards/screens/flashcard_editor_screen.dart`, `test/presentation/features/flashcards/flashcard_editor_screen_test.dart` | `c0f1df5d` | No action |
| 2.12.1 | Content management | Flashcard Update BE V1 | BE | Validated update use case + tests | Implemented | 2.11.1 | `lib/domain/usecases/flashcard/update_flashcard_usecase.dart`, `test/domain/usecases/flashcard/update_flashcard_usecase_test.dart` | `6593874b` | No action |
| 2.12.2 | Content management | Flashcard Edit FE V1 | FE | Editor screen (edit mode) + states | Implemented | 2.12.1 | `test/presentation/features/flashcards/flashcard_editor_edit_screen_test.dart` | `6593874b` | No action |
| 2.13.1 | Content management | Flashcard Delete BE V1 | BE | Delete use case with cascade per persistence rules | Implemented | 2.11.1 | `lib/domain/usecases/flashcard/delete_flashcard_usecase.dart` | `486232bd` | No action |
| 2.13.2 | Content management | Flashcard Delete FE V1 | FE | Row actions sheet delete + confirmation + states | Implemented | 2.13.1 | `lib/presentation/features/flashcards/widgets/flashcard_row_actions_sheet.dart`, `test/presentation/features/flashcards/flashcard_list_test.dart` | `486232bd` | No action |
| 2.14.1 | Content management | Flashcard Reorder BE V1 | BE | `sort_order` reorder use case + repo method | Implemented | 2.11.1 | `lib/domain/usecases/flashcard/reorder_flashcards_usecase.dart`, `lib/data/repositories/flashcard_repository_impl.dart`, `test/data/repositories/flashcard_repository_impl_test.dart` | `48e55584` | No action |
| 2.14.2 | Content management | Flashcard Reorder FE V1 | FE | Reorder UI in flashcard list | Specified | 2.14.1 | TBD | TBD | Wire reorder gesture to BE; widget tests |
| 2.15.1 | Content management | Flashcard Tags BE V1 | BE | Tag validation (trim/lowercase/dedupe), `flashcard_tags` table + migration | Implemented | 1.1.5 | `lib/domain/tag/tag_validator.dart`, `lib/data/datasources/local/migrations/v3_add_flashcard_tags.dart` | `e20b5ba7` | No action |
| 2.15.2 | Content management | Flashcard Tags FE V1 | FE | Tag input section in editor | Implemented | 2.15.1 | `lib/presentation/features/flashcards/widgets/flashcard_editor_tags_section.dart` | `e20b5ba7` | No action |
| 2.16.1 | Content management | Parent-child validation BE | BE | Deck must belong to folder; flashcard must belong to deck (non-null FK + repo checks) | Implemented | 1.1.5 | `lib/data/datasources/local/drift/**` (non-null `folder_id`/`deck_id`) | `68c67656` | No action |
| 2.16.2 | Content management | Parent-child guard FE | Integration | Invalid actions prevented in UI with controlled error, not crash | Partial | 2.16.1 | feature screens use `Result`/failure mapping | `484b6a42` | Audit controlled-error coverage for invalid parent actions |
| 2.17.1 | Content management | Flashcard status filter BE V1 | BE | List query filters for active/suspended/buried/due + tests | Implemented | 2.15.1 | `lib/domain/types/flashcard_status_filter.dart`, `lib/domain/usecases/flashcard/watch_flashcard_list_usecase.dart`, `lib/data/datasources/local/drift/flashcard_queries.drift`, `lib/data/repositories/flashcard_repository_impl.dart`, `test/data/repositories/flashcard_repository_impl_test.dart` | `a35f32f1` | No action |
| 2.17.2 | Content management | Flashcard status filter/badges FE V1 | FE | Filter chips + suspended/buried badges in flashcard list | Specified | 2.17.1 | `docs/business/study-actions/bury-suspend.md` | TBD | Wire chips/badges to BE; widget tests |
| 2.18.1 | Content management | Flashcard tag filter BE V1 | BE | Multi-select AND tag filter inside deck + tests | Implemented | 2.15.1 | `lib/domain/usecases/flashcard/watch_flashcard_list_usecase.dart`, `lib/data/datasources/local/drift/flashcard_queries.drift`, `lib/data/repositories/flashcard_repository_impl.dart`, `test/data/repositories/flashcard_repository_impl_test.dart`, `test/domain/usecases/flashcard/watch_flashcard_list_usecase_test.dart` | `a35f32f1` | No action |
| 2.18.2 | Content management | Flashcard tag filter FE V1 | FE | Tag filter chips + clear-filters empty state | Specified | 2.18.1 | `docs/business/tags/tag-system.md` | TBD | Wire to BE; widget tests |
| 2.19.1 | Content management | Deck Move BE V1 | BE | Move deck to another folder (mode validation, sort append, source unlock) + tests | Implemented | 2.7.1 | `lib/domain/usecases/deck/move_deck_usecase.dart`, `lib/data/repositories/folder_repo_impl_mutation_helpers.dart`, `lib/data/repositories/folder_repository_impl.dart`, `test/data/repositories/folder_repository_impl_move_deck_test.dart`, `test/domain/usecases/deck/move_deck_usecase_test.dart` | `7c34ea3c` | No action |
| 2.19.2 | Content management | Deck Move FE V1 | FE | Move action in deck actions sheet + folder picker | Specified | 2.19.1 | `lib/presentation/features/folders/widgets/folder_move_picker_sheet.dart` (reuse picker pattern) | TBD | Wire to BE; widget tests |
| 2.20.1 | Content management | Manual duplicate soft-warning BE V1 | BE | Case-insensitive front+back duplicate check on create/edit save | Implemented | 2.11.1 | `lib/domain/usecases/flashcard/check_manual_duplicate_flashcard_usecase.dart`, `lib/domain/models/flashcard_duplicate_check_result.dart`, `test/domain/usecases/flashcard/check_manual_duplicate_flashcard_usecase_test.dart`, `test/data/repositories/flashcard_repository_impl_duplicate_behavior_test.dart` | `7c34ea3c` | No action |
| 2.20.2 | Content management | Manual duplicate soft-warning FE V1 | FE | Non-blocking "save anyway?" confirm in editor | Specified | 2.20.1 | `docs/business/flashcard/flashcard-management.md` §Rules | TBD | Wire to BE; widget tests |
| 2.21.1 | Content management | Folder delete blast-radius confirm FE V1 | FE | Delete dialog shows subtree counts; stronger confirm above threshold | Specified | 2.3.2 | `docs/business/folder/folder-management.md` §Rules | TBD | Extend delete dialog + tests |

### Group 3 — Library flow

| WBS ID | Flow | Function | Layer | Deliverable | Status | Depends on | Evidence/Source | Commit ID | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 3.1.1 | Library | Library overview load BE | BE | `watchLibraryOverview` stream query, stable ordering + tests | Implemented | 1.1.5 | `lib/domain/usecases/folder/watch_library_overview_usecase.dart`, `test/data/repositories/folder_read_queries_test.dart` | `a736ed16` | No action |
| 3.1.2 | Library | Library overview FE | FE | Overview screen, sections, loading/empty/error, new-user empty state | Implemented | 3.1.1 | `lib/presentation/features/folders/screens/library_overview_screen.dart`, `test/presentation/features/folders/library_overview_test.dart` | `a736ed16` | No action |
| 3.2.1 | Library | Folder detail load BE | BE | `watchFolderDetail` stream (children, decks, counts) + tests | Implemented | 3.1.1 | `lib/domain/usecases/folder/watch_folder_detail_usecase.dart`, `test/data/repositories/folder_read_queries_test.dart` | `7600ea75` | No action |
| 3.2.2 | Library | Folder detail FE | FE | Folder detail screen, tiles, summary, states, navigation | Implemented | 3.2.1 | `lib/presentation/features/folders/screens/folder_detail_screen.dart`, `test/presentation/features/folders/folder_detail_test.dart` | `7600ea75` | No action |
| 3.2.3 | Library | Folder detail new vs due study split | BE+FE | New cards (`due_at NULL`) counted as NEW not due (data fix + migration v11); `new_count` read model on deck/subfolder rows; folder summary shows `{n} new`/`{m} due` + **Study new** (→ `study_type=new`) and **Review due** (→ `srs_review`) CTAs; deck-row new badge | Implemented | 3.2.2, 4.5.10 | `lib/data/repositories/flashcard_repository_impl_imports.dart`, `lib/data/datasources/local/migrations/v11_clear_new_card_due_at.dart`, `lib/data/datasources/local/drift/folder_queries.drift`, `lib/presentation/features/folders/widgets/folder_detail_summary.dart`, `lib/presentation/features/folders/widgets/folder_deck_tile.dart`, `test/presentation/features/folders/folder_detail_test.dart`, `test/data/migrations/clear_new_card_due_at_migration_test.dart`, `docs/business/srs/srs-review.md`, `docs/wireframes/05-folder-detail.md` | `666db551` | No action |
| 3.3.1 | Library | Deck → flashcard list navigation | Integration | Deck tile opens `/library/deck/:deckId/flashcards` | Implemented | 3.2.2, 3.4.2 | `lib/presentation/features/flashcards/routes/flashcard_routes.dart` | `486232bd` | No action |
| 3.4.1 | Library | Flashcard list load BE | BE | `watchFlashcardList` stream + tests | Implemented | 2.11.1 | `lib/domain/usecases/flashcard/watch_flashcard_list_usecase.dart`, `test/data/repositories/flashcard_repository_impl_test.dart` | `486232bd` | No action |
| 3.4.2 | Library | Flashcard list FE | FE | List screen (8 states incl. empty/loading/error/search) | Implemented | 3.4.1 | `lib/presentation/features/flashcards/screens/flashcard_list_screen.dart`, `test/presentation/features/flashcards/flashcard_list_test.dart` | `486232bd` | No action |
| 3.5.1 | Library | Global search BE | BE | Search use case + repo, LIKE escaping, ranking, min-query/debounce contract + tests | Implemented | 1.1.5 | `lib/domain/usecases/search/global_search_usecase.dart`, `test/data/repositories/search_repository_impl_test.dart` | `486232bd` | No action |
| 3.5.2 | Library | Global search FE | FE | `/library/search` screen with 5 states, grouped sections | Implemented | 3.5.1 | `lib/presentation/features/search/screens/global_search_screen.dart`, `test/presentation/features/search/global_search_test.dart` | `486232bd` | No action |
| 3.5.3 | Library | Search result navigation | Integration | Folder → detail; deck → flashcard list; flashcard → owning deck | Implemented | 3.5.2 | `lib/presentation/features/search/widgets/search_results_view.dart` | `486232bd` | No action |
| 3.6.1 | Library | Error retry state | FE | Centralized failure mapping + refetch feedback on library screens | Implemented | 3.1.2 | `lib/app/feedback/**`, `test/app/feedback/mx_app_feedback_observer_test.dart` | `484b6a42` | No action |
| 3.7.1 | Library | Folder/deck due+card counts BE | BE | Counts stream from DB; due excludes buried/suspended | Implemented | 3.2.1 | `lib/data/datasources/local/drift/folder_queries.drift`, `lib/data/repositories/folder_repository_impl.dart`, `test/data/repositories/folder_deck_due_counts_test.dart`, `test/data/repositories/folder_repository_impl_test.dart` | `d50cceb2` | No action |
| 3.8.1 | Library | Tags/recent/popular search sections | FE | Tag search section, recent searches, popular tags landing | Future | 8.5.1 | `docs/business/search/global-search.md` | TBD | Do not implement before tag subsystem promotion |

### Group 4 — Study/SRS flow

| WBS ID | Flow | Function | Layer | Deliverable | Status | Depends on | Evidence/Source | Commit ID | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 4.1.1 | Study/SRS | Study entry eligibility BE | BE | Scope queries (deck/folder/today), empty/all-suspended outcomes + tests | Implemented | 1.1.5 | `lib/data/repositories/study_repo_impl_study_session.dart`, `test/domain/study/start_study_session_usecase_test.dart` | `ead94e76` | No action |
| 4.1.2 | Study/SRS | Study entry FE | FE | Entry gate screen with empty/error/resume-required states | Implemented | 4.1.1 | `lib/presentation/features/study/screens/study_entry_screen.dart`, `test/presentation/features/study/study_entry_screen_test.dart` | `0a7a4c60` | No action |
| 4.1.3 | Study/SRS | Deck study CTA FE V1 | FE | Study-entry section on Flashcard List: Study deck + Today CTAs routing through the gate | Specified | 4.1.1 | `docs/wireframes/06-flashcard-list.md` (component row 4 target) | TBD | **Top priority** — the only study entry today is the Dashboard Today CTA; the study button must live next to the content |
| 4.1.4 | Study/SRS | Folder study CTA FE V1 | FE | Study folder + Today CTAs on Folder Detail routing through the gate | Specified | 4.1.1 | `docs/wireframes/05-folder-detail.md` | TBD | Wire CTAs to gate routes; widget tests |
| 4.2.1 | Study/SRS | Session creation BE | BE | Transactional `study_sessions` + `study_session_items` insert + tests | Implemented | 4.1.1 | `lib/data/repositories/study_repo_impl_study_session.dart`, `test/data/repositories/study_repository_test.dart` | `ead94e76` | No action |
| 4.2.2 | Study/SRS | No-silent-resume gate BE | BE | Existing resumable session returns controlled `resumeRequired` | Implemented | 4.2.1 | `lib/domain/study/study_entry_start_result.dart` | `8582fcb2` | No action |
| 4.2.3 | Study/SRS | Resume/start-over choice FE | FE | Explicit Resume / Start over / Back actions; transactional restart | Implemented | 4.2.2 | `lib/presentation/features/study/widgets/study_entry_resume_required_state.dart`, `test/domain/study/restart_study_session_usecase_test.dart` | `5339d8e5` | No action |
| 4.2.4 | Study/SRS | Session batch limit BE V1 | BE | Cap session at `maxSessionItems` (default 20) before persisting session items; backend-only slice | Implemented | 4.2.1 | `docs/business/study/study-flow.md` §Rules, `lib/data/repositories/study_repo_impl.dart`, `test/data/repositories/study_repository_test.dart` | `53fae583` | FE next-batch CTA deferred |
| 4.3.1 | Study/SRS | Session item loading BE | BE | Load persisted session + ordered items by sessionId | Implemented | 4.2.1 | `lib/domain/study/ports/study_repo.dart` (`loadStudySessionReview`) | `3ab00a9a` | No action |
| 4.3.2 | Study/SRS | Session review shell FE | FE | Current card, reveal toggle, Previous/Next navigation | Implemented | 4.3.1 | `lib/presentation/features/study/screens/study_session_screen.dart`, `test/presentation/features/study/study_session_screen_test.dart` | `2971d800` | No action |
| 4.4.1 | Study/SRS | Submit self-grade BE | BE | `recordStudySessionAnswer` attempt persistence + tests | Implemented | 4.3.1 | `lib/data/repositories/study_repo_record_answer.dart`, `test/domain/usecases/study/record_study_session_answer_usecase_test.dart` | `f3740591` | No action |
| 4.4.2 | Study/SRS | Self-grade FE (Forgot / Got it) | FE | Grading controls + answered-state advancement | Implemented | 4.4.1 | `test/presentation/features/study/study_session_review_viewmodel_test.dart` | `f3740591` | No action |
| 4.4.3 | Study/SRS | Answer re-grade before finalize | BE | Allow correcting an answered item's grade until finalization (append attempt) | Specified | 4.4.1 | `docs/business/study/study-flow.md` §Retry behavior | TBD | Ship together with the first retry mode; do not change the current one-attempt rule alone |
| 4.5.1 | Study/SRS | Study mode strategy V1 BE | BE | `StudyModeStrategyFactory`: implemented mode dispatch matrix; sealed interaction families (`BinaryGrade`/`TypedAnswer`/`Board`) replace the throwing fat interface | Implemented | 4.3.1 | `lib/domain/study/modes/study_mode_strategy.dart`, `lib/domain/study/modes/study_mode_strategy_factory.dart`, `test/domain/study/modes/study_mode_strategy_factory_test.dart` | `30075fbf` | No action |
| 4.5.2 | Study/SRS | Review mode BE V1 | BE | Both-sides item strategy + attempt semantics + tests | Implemented | 4.5.1 | `lib/domain/study/modes/review_study_mode_strategy.dart`, `docs/business/study/study-flow.md`, `test/domain/study/modes/study_mode_strategy_factory_test.dart` | `c77b5989` | No action |
| 4.5.3 | Study/SRS | Review mode FE V1 | FE | Review mode UI per wireframe 13 | Specified | 4.5.2 | `docs/wireframes/13-study-session-review.md` | TBD | Wire UI to strategy; widget tests |
| 4.5.4 | Study/SRS | Match mode BE V1 | BE | 5-pair board strategy, append-only evaluation persistence, transactional finalization derivation + tests | Implemented | 4.5.1 | `docs/business/study/study-flow.md` | `8fe3ce3a` | No action |
| 4.5.5 | Study/SRS | Match mode FE V1 | FE | Match board UI | Specified | 4.5.4 | `docs/wireframes/14-study-session-match.md` | TBD | Wire UI; widget tests |
| 4.5.6 | Study/SRS | Guess mode BE V1 | BE | 5-option selection strategy + tests | Implemented | 4.5.1 | `lib/domain/study/modes/guess_study_mode_strategy.dart`, `lib/domain/study/guess/guess_option_builder.dart`, `test/domain/study/modes/study_mode_strategy_factory_test.dart` | `eb91cbc2` | No action |
| 4.5.7 | Study/SRS | Guess mode FE V1 | FE | Guess UI with auto-advance countdown | Implemented | 4.5.6 | `lib/presentation/features/study/screens/study_session_screen.dart`, `lib/presentation/features/study/widgets/study_session_guess_mode_view.dart`, `lib/presentation/features/study/viewmodels/study_session_guess_viewmodel.dart`, `test/presentation/features/study/study_session_screen_test.dart`, `docs/wireframes/15-study-session-guess.md` | `30e649ca` | No action |
| 4.5.8 | Study/SRS | Fill mode BE V1 | BE | Strict character match, mark-correct override, hint taint + tests | Implemented | 4.5.1 | `lib/domain/study/modes/fill_study_mode_strategy.dart`, `lib/domain/study/fill/fill_answer_evaluator.dart`, `test/domain/study/modes/study_mode_strategy_factory_test.dart` | `129d049f` | No action |
| 4.5.9 | Study/SRS | Fill mode FE V1 | FE | Typed-input fill UI | Implemented | 4.5.8 | `docs/wireframes/17-study-session-fill.md`, `lib/presentation/features/study/screens/study_session_screen.dart`, `lib/presentation/features/study/widgets/study_session_fill_mode_view.dart`, `lib/presentation/features/study/viewmodels/study_session_fill_viewmodel.dart` | `9173a54f` | No action |
| 4.5.10 | Study/SRS | Daily new limit BE V1 | BE | Cap new-card eligibility at `dailyNewLimit` (default 20) per local day; due review cards remain eligible; daily usage is derived from persisted new-card session items | Implemented | 4.5.1 | `docs/business/srs/srs-review.md` §Rules, `docs/business/study/study-flow.md` §Rules, `lib/data/repositories/study_repo_impl_study_session.dart`, `test/data/repositories/study_repository_daily_new_limit_test.dart`, `test/data/repositories/study_repository_test.dart` | `48795861` | New-card eligibility cap only; cancelled sessions still consume quota; settings persistence deferred |
| 4.5.11 | Study/SRS | Recall mode FE V1 | FE | Timed reveal/self-grade recall shell with 20s countdown, timeout reveal, and edit-pause resume | Implemented | 4.5.2, 4.4.1 | `lib/presentation/features/study/screens/study_session_screen.dart`, `lib/presentation/features/study/widgets/study_session_recall_mode_view.dart`, `lib/presentation/features/study/viewmodels/study_session_recall_viewmodel.dart`, `test/presentation/features/study/study_session_screen_test.dart`, `docs/wireframes/16-study-session-recall.md` | `c46900e1` | Recall V1 only; no typed input / recovered path |
| 4.5.12 | Study/SRS | Mode-chain persistence backbone BE | BE | `StudyFlow` type + `StudyFlowPlan` (ordered phases) + `StudyFlowResolver`; schema v10 (`study_sessions.study_flow`, `current_mode`) + migration/test; persist flow + firstMode at create (new deck/folder → `new_full_cycle`). Backbone only — FE consumption + per-phase advance pending 4.5.13 | Implemented | 4.5.1 | `lib/domain/types/study_flow.dart`, `lib/domain/study/study_flow_resolver.dart`, `lib/data/datasources/local/migrations/v10_add_study_flow_and_current_mode.dart`, `lib/data/mappers/study_mapper.dart`, `test/domain/types/study_flow_test.dart`, `test/data/migrations/study_flow_current_mode_migration_test.dart`, `docs/contracts/types-catalog.md`, `docs/business/study/study-flow.md` | `6aa7a8f3` | FE/orchestration + cross-phase finalization tracked under 4.5.13 |
| 4.5.13 | Study/SRS | Per-phase chain runtime (advance + cross-phase finalization + FE) | BE+FE | Consume `current_mode`; `AdvanceStudyPhaseUseCase`; unify finalization to aggregate all-mode attempts + derived match result per item; session screen drives/advances phases (intermediate advance, last finalizes) | Specified | 4.5.12 | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md` | TBD | Cross-phase SRS finalization is NEW spec — define before coding; ship advance + finalization-unification + FE together |
| 4.6.1 | Study/SRS | Finish session BE | BE | Finalization transaction: attempts → SRS outcome → session complete, rollback on failure | Implemented | 4.4.1 | `lib/data/repositories/study_repo_impl.dart`, `test/data/repositories/study_repository_test.dart` | `d5ae03f0` | No action |
| 4.6.2 | Study/SRS | SRS progress update BE | BE | Leitner outcome transitions + due-date computation in finalization | Implemented | 4.6.1 | `lib/data/repositories/study_repo_impl_study_session.dart`, `test/data/repositories/study_srs_transition_test.dart` (verified equal to `docs/business/srs/srs-review.md` transition + interval tables, decision rows S11–S15) | `d5ae03f0` | No action |
| 4.6.3 | Study/SRS | Finalization failure recovery | Integration | Finish failure keeps session open with controlled error; retry affordance | Partial | 4.6.1 | `test/data/repositories/study_repository_test.dart` (rollback) | `d5ae03f0` | Add retry affordance on result/finish failure path |
| 4.6.4 | Study/SRS | Due-time local-midnight normalization | BE | `due_at = localMidnight(studyDay + interval)` so due-today counts are stable across the day | Implemented | 4.6.2 | `docs/business/srs/srs-review.md` §Interval table, `lib/data/repositories/study_repo_impl.dart`, `test/data/repositories/study_srs_transition_test.dart` | `53fae583` | Finalization + transition tests updated together |
| 4.7.1 | Study/SRS | Result summary BE | BE | `loadStudySessionResult` completed-session summary | Implemented | 4.6.1 | `lib/domain/models/study_session_result.dart` | `4477dd86` | No action |
| 4.7.2 | Study/SRS | Result screen FE | FE | `/library/study/session/:sessionId/result` with fallback states | Implemented | 4.7.1 | `lib/presentation/features/study/screens/study_result_screen.dart` | `4477dd86` | No action |
| 4.8.1 | Study/SRS | Session persistence recovery | Integration | In-progress sessions reload by sessionId preserving answered items | Implemented | 4.3.1 | `test/presentation/features/study/study_session_screen_test.dart` (recovery coverage) | `93dec233` | No action |
| 4.9.1 | Study/SRS | Protected active-session exit FE | FE | Exit confirmation; confirmed exit keeps session resumable | Implemented | 4.3.2 | `lib/presentation/features/study/screens/study_session_screen.dart` | `40e3c8b0` | No action |
| 4.10.1 | Study/SRS | Cancel/discard session BE | BE | `cancelStudySession` used by transactional start-over | Implemented | 4.2.1 | `lib/domain/study/ports/study_repo.dart` | `b2ea71ce` | No action |
| 4.10.2 | Study/SRS | Resume expiry anchor `updated_at` | BE | 30-day resumable filter anchors on `updated_at` (activity), not `started_at` | Implemented | 4.2.1 | `docs/business/resume/resume-session.md` §Auto-expiry, `lib/data/datasources/local/daos/study_session_dao.dart`, `lib/data/repositories/study_repo_record_answer.dart`, `test/data/repositories/study_repository_test.dart` | `53fae583` | Read-only resume/open remains non-mutating |
| 4.11.1 | Study/SRS | Bury/suspend queue exclusion BE | BE | Due/new queries exclude suspended and currently-buried cards | Implemented | 4.1.1 | `lib/data/datasources/local/drift/study_scope_queries.drift`, `test/data/repositories/study_eligibility_bury_suspend_test.dart`, `test/data/repositories/study_session_card_action_test.dart` | `ead94e76` | No action |
| 4.11.2 | Study/SRS | In-session bury/suspend action BE | BE | Bury/suspend current card: set fields, no attempt, preserve SRS + tests | Implemented | 4.4.1 | `lib/domain/study/ports/study_repo.dart`, `lib/domain/study/usecases/study_usecases.dart`, `lib/data/repositories/study_repo_impl.dart`, `lib/data/repositories/study_repo_impl_study_actions.dart`, `lib/data/datasources/local/daos/study_session_dao.dart`, `test/data/repositories/study_session_card_action_test.dart`, `test/data/repositories/study_eligibility_bury_suspend_test.dart` | `d50cceb2` | No action |
| 4.11.3 | Study/SRS | In-session bury/suspend action FE | FE | Action UI, queue removal, undo affordance | Specified | 4.11.2 | `docs/business/study-actions/bury-suspend.md` | TBD | Wire UI to BE; widget tests |
| 4.12.1 | Study/SRS | Study by tag | BE | `StudyEntryType.tag` scope queries + routes + tests | Blocked | 8.5.1 | `docs/business/tags/tag-system.md` | TBD | Requires tag subsystem promotion |

### Group 5 — Dashboard flow

| WBS ID | Flow | Function | Layer | Deliverable | Status | Depends on | Evidence/Source | Commit ID | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 5.1.1 | Dashboard | Continue Studying summary BE | BE | `loadDashboardResumeSessionSummary` (scope, progress, last active) | Implemented | 4.2.1 | `lib/domain/models/dashboard_resume_session_summary.dart` | `7645e9e8` | No action |
| 5.1.2 | Dashboard | Continue Studying card FE | FE | Resume card with Continue CTA; hidden when none | Implemented | 5.1.1 | `lib/presentation/features/dashboard/screens/dashboard_screen.dart`, `test/presentation/features/dashboard/dashboard_screen_test.dart` | `7645e9e8` | No action |
| 5.2.1 | Dashboard | Due-today summary BE | BE | `dueToday` from library overview read model (excludes buried/suspended) | Implemented | 3.1.1 | `lib/presentation/features/dashboard/screens/dashboard_screen.dart` (consumes `libraryOverviewQueryProvider`) | `b2d0740f` | No action |
| 5.2.2 | Dashboard | Today study CTA FE | FE | Today's-review card: due count title + due-deck count + estimated minutes; `dueToday > 0` routes to today study, zero state disables CTA | Implemented | 5.2.1, 5.6.1 | `lib/presentation/features/dashboard/screens/dashboard_screen.dart` (`_DashboardTodayCard`, `dashboardDueSummaryQueryProvider`), `test/presentation/features/dashboard/dashboard_screen_test.dart` | `a5d99089` | No action |
| 5.3.1 | Dashboard | New-user empty dashboard FE | FE | Controlled empty/caught-up states | Implemented | 5.2.2 | `test/presentation/features/dashboard/dashboard_screen_test.dart` | `b2d0740f` | No action |
| 5.4.1 | Dashboard | Progress summary on dashboard | BE | Dashboard progress summary read model + provider wiring (due today, goal, streak) | Implemented | 7.4.1 | `lib/domain/models/dashboard_progress_summary.dart`, `lib/domain/usecases/progress/load_dashboard_progress_summary_usecase.dart`, `lib/data/repositories/progress_repository_impl.dart`, `lib/app/di/progress_providers.dart`, `test/domain/usecases/progress/load_dashboard_progress_summary_usecase_test.dart`, `test/data/repositories/progress_repository_impl_test.dart`, `docs/business/engagement/dashboard-engagement.md` | `1359edb4` | No action |
| 5.4.2 | Dashboard | Streak chip + daily-goal ring FE | FE | Streak chip (hidden when `< 1`) + daily-goal ring (hidden when goal disabled) consuming `dashboardProgressSummaryQueryProvider` | Implemented | 5.4.1 | `lib/presentation/features/dashboard/screens/dashboard_screen.dart` (`_DashboardStatsRow`), `lib/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart`, `test/presentation/features/dashboard/dashboard_screen_test.dart` | TBD | No action |
| 5.5.1 | Dashboard | Dashboard data refresh | Integration | Refresh on retry and on return from study flow | Partial | 5.1.2 | `lib/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart` (invalidate on retry) | `b2d0740f` | Verify/refresh on study-flow return; add test |
| 5.6.1 | Dashboard | Recent decks + new-card highlights BE | BE | `loadDashboardDeckHighlights` (recent decks by `updated_at` with card/due/last-studied + library-wide never-studied count) | Implemented | 7.4.1 | `lib/data/datasources/local/drift/progress_queries.drift` (`dashboardRecentDecks`, `dashboardNewCardCount`), `lib/data/datasources/local/daos/progress_dao.dart`, `lib/data/repositories/progress_repository_impl.dart`, `lib/domain/models/dashboard_deck_highlights.dart`, `lib/domain/usecases/progress/load_dashboard_deck_highlights_usecase.dart`, `lib/app/di/progress_providers.dart`, `test/data/repositories/progress_repository_impl_test.dart` | TBD | No action |
| 5.6.2 | Dashboard | Recent decks section FE | FE | Recent-decks section (top 3, card/due/last-studied, deck-row → flashcard list) + Library shortcut | Implemented | 5.6.1 | `lib/presentation/features/dashboard/screens/dashboard_screen.dart` (`_DashboardRecentDecksSection`), `test/presentation/features/dashboard/dashboard_screen_test.dart` | TBD | No action |
| 5.7.1 | Dashboard | Start new learning CTA FE | FE | New-learning card with never-studied count badge → global new-cards study entry (deck/folder scope picker deferred) | Implemented | 5.6.1 | `lib/presentation/features/dashboard/screens/dashboard_screen.dart` (`_DashboardNewLearningCard`), `test/presentation/features/dashboard/dashboard_screen_test.dart` | TBD | No action |
| 5.8.1 | Dashboard | App-bar search shortcut FE | FE | Dashboard search icon → `/library/search` (`pushLibrarySearch`) | Implemented | 3.5.1 | `lib/presentation/features/dashboard/screens/dashboard_screen.dart` | TBD | No action |

### Group 6 — Import flow

| WBS ID | Flow | Function | Layer | Deliverable | Status | Depends on | Evidence/Source | Commit ID | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 6.1.1 | Import | Import route + screen shell | FE | `/library/deck/:deckId/import` opens `DeckImportScreen` | Implemented | 3.3.1 | `lib/presentation/features/flashcards/screens/deck_import_screen.dart` | `66bf1460` | No action |
| 6.2.1 | Import | CSV parse BE | BE | Pasted-CSV parse use case + tests | Implemented | 2.11.1 | `lib/domain/usecases/flashcard/parse_deck_import_csv_usecase.dart`, `test/domain/usecases/flashcard/deck_import_usecases_test.dart` | `c1e89cf5` | No action |
| 6.2.2 | Import | Row validation BE | BE | Per-row validation issues in preview model | Implemented | 6.2.1 | `lib/domain/models/flashcard_import_preview.dart` | `c1e89cf5` | No action |
| 6.3.1 | Import | Preview FE (valid/invalid rows) | FE | In-screen preview: rows + issues + summary; clean preview enables CTA | Implemented | 6.2.2 | `test/presentation/features/flashcards/deck_import_screen_test.dart` | `c1e89cf5` | No action |
| 6.4.1 | Import | Transactional commit BE | BE | Insert valid rows + default SRS progress in one transaction; rollback tests | Implemented | 6.2.2 | `lib/domain/usecases/flashcard/commit_deck_import_usecase.dart`, `test/presentation/features/flashcards/deck_import_screen_test.dart` | `7b3c1691` | No action |
| 6.4.2 | Import | No silent partial import | Integration | Commit only proceeds on clean preview; all-or-nothing insert | Implemented | 6.4.1 | `test/presentation/features/flashcards/deck_import_screen_test.dart` | `7b3c1691` | No action |
| 6.5.1 | Import | Result summary FE | FE | V1 snackbar + pop back (standalone result screen deferred) | Implemented | 6.4.1 | `lib/presentation/features/flashcards/screens/deck_import_screen.dart` | `7b3c1691` | No action |
| 6.6.1 | Import | Duplicate detection BE V1 | BE | Case-insensitive front/back dup check vs file + existing deck + tests | Implemented | 6.2.2 | `lib/domain/usecases/flashcard/prepare_deck_import_usecase.dart`, `lib/domain/repositories/flashcard_repository.dart`, `lib/data/repositories/flashcard_repository_impl_imports.dart`, `lib/app/di/flashcard_providers.dart`, `test/domain/usecases/flashcard/deck_import_usecases_test.dart`, `test/data/repositories/flashcard_repository_impl_test.dart` | `e84f5115` | No action |
| 6.6.2 | Import | Duplicate preview FE V1 | FE | Duplicate rows surfaced in preview with skip policy | Specified | 6.6.1 | `docs/wireframes/10-deck-import.md` | TBD | Wire to BE; widget tests |
| 6.7.1 | Import | File picker entry FE | FE | File selection (UTF-8 CSV file) replacing paste-only input | Specified | 6.2.1 | `docs/wireframes/10-deck-import.md` | TBD | Needs dependency approval if picker package required |
| 6.8.1 | Import | Excel import BE | BE | First-sheet read, header toggle | Future | 6.6.1 | `docs/business/flashcard/flashcard-management.md` | TBD | Do not implement without dependency approval |
| 6.9.1 | Import | Structured text import BE | BE | Separator auto/tab/comma/colon/slash/semicolon/pipe | Implemented | 6.2.1 | `lib/domain/usecases/flashcard/prepare_deck_import_usecase.dart`, `lib/domain/usecases/flashcard/parse_deck_import_csv_usecase.dart`, `lib/domain/models/flashcard_import_preview.dart`, `test/domain/usecases/flashcard/deck_import_usecases_test.dart` | `44407390` | No action |

### Group 7 — Progress/reporting flow

| WBS ID | Flow | Function | Layer | Deliverable | Status | Depends on | Evidence/Source | Commit ID | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 7.1.1 | Progress | Due summary query BE V1 | BE | Aggregate due-card counts (global/per-deck) excluding buried/suspended + tests | Implemented | 4.11.1 | `lib/data/datasources/local/drift/progress_queries.drift`, `lib/data/datasources/local/daos/progress_dao.dart`, `lib/data/repositories/progress_repository_impl.dart`, `test/data/repositories/progress_repository_impl_test.dart` | `4d1eba04` | No action |
| 7.2.1 | Progress | Box distribution query BE V1 | BE | Card counts per Leitner box from current progress table + tests | Implemented | 7.1.1 | `lib/data/datasources/local/drift/progress_queries.drift`, `lib/data/datasources/local/daos/progress_dao.dart`, `lib/data/repositories/progress_repository_impl.dart`, `test/data/repositories/progress_repository_impl_test.dart` | `4d1eba04` | No action |
| 7.3.1 | Progress | Study statistics BE V1 | BE | Session/attempt-based stats (sessions finished, answers recorded) + tests | Implemented | 4.6.1 | `lib/data/datasources/local/drift/progress_queries.drift`, `lib/data/datasources/local/daos/progress_dao.dart`, `lib/data/repositories/progress_repository_impl.dart`, `test/data/repositories/progress_repository_impl_test.dart` | `4d1eba04` | No action |
| 7.4.1 | Progress | Progress read model BE V1 | BE | Combined progress read model + provider wiring | Implemented | 7.1.1, 7.2.1, 7.3.1 | `lib/domain/models/progress_read_model.dart`, `lib/domain/repositories/progress_repository.dart`, `lib/domain/usecases/progress/load_progress_read_model_usecase.dart`, `lib/app/di/progress_providers.dart`, `test/domain/usecases/progress/load_progress_read_model_usecase_test.dart` | `4d1eba04` | No action |
| 7.4.2 | Progress | Progress overview read model BE | BE | Range activity (per-local-day buckets + previous-range delta), study-day streak, suspended/buried counts composed into `ProgressOverview` + tests | Implemented | 7.4.1 | `lib/domain/models/progress_read_model.dart`, `lib/domain/types/progress_range.dart`, `lib/domain/usecases/progress/load_progress_overview_usecase.dart`, `lib/data/repositories/progress_repository_impl.dart`, `test/data/repositories/progress_repository_overview_test.dart` | `3b4c3232` | No action |
| 7.5.1 | Progress | Progress screen FE V1 | FE | `/progress` renders the kit-mock screen: range tabs, cards-studied chart, accuracy + delta + sparkline, box distribution, streak, card states | Implemented | 7.4.2 | `lib/presentation/features/progress/**`, `test/presentation/features/progress/progress_screen_test.dart`, `test/presentation/features/progress/progress_screen_golden_test.dart` | `3b4c3232` | No action |
| 7.5.2 | Progress | Progress states FE | FE | Loading/empty/error/insufficient/partial states per kit mock, data-driven per section | Implemented | 7.5.1 | `test/presentation/features/progress/progress_screen_test.dart` (states), goldens for 7 states × light/dark | `3b4c3232` | No action |
| 7.6.1 | Progress | Review history query BE | BE | Per-card header (preview + SRS + cumulative counters + last_reset_at + correct streak + deck/breadcrumb) and the unified activity feed merging `study_attempts` (+ `duration_ms`, v7) with `card_events` (created/edited/reset, v7); reset writes a `card_events` row; `last_reset_at` v6 | Implemented | 7.3.1 | `lib/data/datasources/local/drift/history_queries.drift`, `lib/data/datasources/local/daos/card_history_dao.dart`, `lib/data/repositories/card_history_repository_impl.dart`, `lib/domain/repositories/card_history_repository.dart`, `lib/data/datasources/local/migrations/v6_add_flashcard_progress_last_reset_at.dart`, `test/data/repositories/card_history_repository_impl_test.dart`, `test/data/migrations/flashcard_progress_last_reset_at_migration_test.dart` | TBD | No action |
| 7.6.2 | Progress | Card history use cases | Domain | `GetCardHistoryHeaderUseCase`, `GetCardHistoryPageUseCase`, `ResetFlashcardProgressUseCase` + DI | Implemented | 7.6.1 | `lib/domain/usecases/history/**`, `lib/domain/models/card_history.dart`, `lib/app/di/card_history_providers.dart`, `test/data/repositories/card_history_repository_impl_test.dart` | TBD | No action |
| 7.6.3 | Progress | Card history screen FE | FE | `CardHistoryScreen` mock-parity (kit screen 09, all 5 states): breadcrumb + header (box chip) + CURRENT PROGRESS card (box stepper + 6-stat grid) + unified activity feed on a left rail (attempt rows with chip/desc/box→box·mode·duration; lifecycle rows; "All events" filter; "Beginning of history") + Edit pill + Reset/Delete overflow; duration measured in study review viewmodel; route `/library/deck/:deckId/flashcards/:flashcardId/history` | Implemented | 7.6.2 | `lib/presentation/features/history/**`, `lib/presentation/features/flashcards/widgets/flashcard_row_actions_sheet.dart`, `lib/app/router/route_paths.dart`, `lib/app/router/route_names.dart`, `lib/presentation/features/flashcards/routes/flashcard_routes.dart`, `test/presentation/features/history/card_history_screen_test.dart` | TBD | Suspend/unsuspend overflow + timeline-row→result deferred (4.11.x) |
| 7.7.1 | Progress | Dashboard/progress consistency | Integration | Same due/progress numbers on dashboard and progress screen | Implemented | 7.5.1, 5.2.1 | `test/domain/usecases/progress/load_dashboard_progress_summary_usecase_test.dart`, `test/data/repositories/progress_repository_impl_test.dart` | `1359edb4` | No action |

### Group 8 — Settings/app operations

| WBS ID | Flow | Function | Layer | Deliverable | Status | Depends on | Evidence/Source | Commit ID | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8.1.1 | Settings | Settings hub FE shell | FE | `/settings` hub rendering mock sections (account row uses mock data) | Partial | 1.1.3 | `lib/presentation/features/settings/screens/settings_screen.dart` (static mock preview, `_mockAppVersion`) | `6593874b` | Replace mock account/version data when real contracts exist |
| 8.1.2 | Settings | Hide fabricated state before release | FE | Hide/disable mock account row + mock version on Settings hub. (Dashboard dead `0 days` placeholder resolved by WBS 5.4.2 — replaced with computed streak chip hidden at 0.) | Specified | 8.1.1 | `docs/wireframes/04-settings-hub.md` + `docs/wireframes/01-dashboard.md` | TBD | Settings-hub mock state still pending; Dashboard part done |
| 8.2.1 | Settings | Learning settings BE persistence | BE | Persisted study-default settings contract + storage + tests. Contract MUST include `dailyNewLimit` (default 20) and `goalDisabledSince` from day one | Implemented | 1.1.5 | `lib/data/datasources/local/preferences/learning_settings_store.dart`, `lib/data/repositories/learning_settings_repository_impl.dart`, `lib/domain/usecases/learning_settings_usecases.dart`, `test/domain/usecases/learning_settings_usecases_test.dart` | `e5cb99ea` | No action |
| 8.2.2 | Settings | Learning settings FE wiring | FE | Wire `/settings/learning` shell to real persisted state | Partial | 8.2.1 | `lib/presentation/features/settings/screens/learning_settings_screen.dart` (static mock preview) | `6593874b` | Wire screen to real provider after 8.2.1 |
| 8.3.1 | Settings | Tag management BE V1 | BE | Distinct tag list/count/search + transactional rename/merge/delete over `flashcard_tags` + tests | Implemented | 2.15.1 | `lib/domain/repositories/tag_repository.dart`, `lib/domain/usecases/tag/watch_tags_with_count_usecase.dart`, `lib/domain/usecases/tag/rename_tag_usecase.dart`, `lib/domain/usecases/tag/merge_tags_usecase.dart`, `lib/domain/usecases/tag/delete_tag_usecase.dart`, `lib/data/repositories/tag_repository_impl.dart`, `test/data/repositories/tag_repository_impl_test.dart`, `test/domain/usecases/tag/tag_usecases_test.dart` | `7c34ea3c` | No action |
| 8.3.2 | Settings | Tag management FE wiring | FE | Wire `/settings/learning/tags` shell to real data + operations | Partial | 8.3.1 | `lib/presentation/features/settings/screens/tag_management_screen.dart` (static mock preview), `test/presentation/features/settings/tag_management_screen_test.dart` | `6593874b` | Wire screen to real provider after 8.3.1 |
| 8.4.1 | Settings | TTS service BE | BE | `TtsService` abstraction + platform implementation + settings storage + tests | Implemented | 1.1.5 | `lib/domain/services/tts_service.dart`, `lib/domain/services/tts_playback_policy.dart`, `lib/domain/models/tts_settings.dart`, `lib/domain/models/tts_voice.dart`, `lib/domain/repositories/tts_settings_repository.dart`, `lib/domain/usecases/tts_usecases.dart`, `lib/data/services/flutter_tts_service.dart`, `lib/data/datasources/local/drift/tts_settings.drift`, `lib/data/datasources/local/migrations/v9_add_tts_settings.dart`, `lib/data/datasources/local/daos/tts_settings_dao.dart`, `lib/data/repositories/tts_settings_repository_impl.dart`, `lib/app/di/tts_providers.dart`, `lib/presentation/features/settings/providers/tts_settings_notifier.dart`, `test/domain/services/tts_settings_normalization_test.dart`, `test/domain/usecases/speak_flashcard_test.dart`, `test/data/migrations/tts_settings_migration_test.dart` | `12652e7` | No action — implemented |
| 8.4.2 | Settings | Audio/speech settings FE wiring | FE | Wire `/settings/audio-speech` shell to real TTS settings | Partial | 8.4.1 | `lib/presentation/features/settings/screens/audio_speech_settings_screen.dart` (static mock preview); `lib/presentation/features/settings/providers/tts_settings_notifier.dart` (provider ready) | `6593874b` | Wire screen to `ttsSettingsNotifierProvider` after 8.4.1 landed |
| 8.4.3 | Settings | Auto-play on reveal | Integration | Study-session reveal triggers TTS per settings | Implemented | 8.4.1, 4.3.2 | `lib/presentation/features/study/widgets/study_session_recall_mode_view.dart` (`_maybeAutoPlay`, `_autoPlayIfEnabled`); fill mode has speak-front only (no auto-play per spec) | `12652e7` | No action — implemented |
| 8.5.1 | Settings | Account settings screen V1 | FE | Replace `/settings/account` placeholder with linked/unlinked display | Implemented | 1.1.3 | `lib/presentation/features/settings/screens/account_settings_screen.dart`, `lib/presentation/features/settings/widgets/account_settings_group.dart`, `lib/presentation/features/settings/viewmodels/account_settings_viewmodel.dart`, `lib/domain/models/cloud_account_link.dart`, `lib/data/datasources/local/preferences/cloud_account_store.dart`, `test/presentation/features/settings/account_settings_screen_test.dart`, `test/presentation/features/settings/account_settings_screen_golden_test.dart`, `test/data/datasources/local/preferences/cloud_account_store_test.dart` | `60d394bb` | Display-only V1; sign-in/Drive actions land in 8.6.1/8.6.2 |
| 8.6.1 | Settings | Google account linking BE | BE | Optional sign-in, account statuses, SharedPreferences link store | Specified | 8.5.1 | `docs/business/account-sync/account-sync.md` | TBD | High-risk; defer until core loop complete |
| 8.6.2 | Settings | Drive backup/restore BE | BE | AppData-scope upload/restore via platform snapshot gateways | Specified | 8.6.1 | `docs/business/account-sync/account-sync.md` | TBD | Defer; requires 8.6.1 |
| 8.6.3 | Settings | Silent token refresh + reconnect banner | BE+FE | Per-call silent Drive token refresh (no UI on ~1h expiry); interactive reconnect banner only when silent re-auth fails | Future | 8.6.2 | `docs/business/account-sync/account-sync.md` (§Token lifetime & silent refresh) | TBD | Avoids manual re-login each hour; no backend offline token |
| 8.6.4 | Settings | Auto-backup (opt-in) | BE+FE | Debounced/dirty-flag + periodic background upload-only backup, unmetered-gated, idempotent via fingerprint; never auto-restore | Future | 8.6.3 | `docs/business/account-sync/account-sync.md` (§Auto-backup) | TBD | Needs approved dep (workmanager/bg scheduler) + perf/security review; web best-effort |
| 8.6.5 | Settings | Server-API-backed sync (own DB) | BE+FE | Conflict-free multi-device sync via a backend API with its own database (record/operation-level merge) + server-mediated token exchange; replaces blob last-write-wins | Future | 8.6.2 | `docs/business/account-sync/account-sync.md` (§Design phasing & non-goals) | TBD | Deferred — product decision pending; explicitly NOT client-side CRDT/oplog. Resolves the V1 concurrent-divergence non-goal |
| 8.7.1 | Settings | Deck export CSV BE V1 | BE | CSV export of one deck (escaping, file name sanitizing) + tests | Implemented | 2.11.1 | `lib/domain/models/deck_csv_export.dart`, `lib/domain/usecases/flashcard/export_deck_csv_usecase.dart`, `lib/data/repositories/flashcard_export_writer.dart`, `lib/data/repositories/flashcard_repository_impl_export.dart`, `lib/data/repositories/flashcard_repository_impl.dart`, `test/domain/usecases/flashcard/export_deck_csv_usecase_test.dart`, `test/data/repositories/deck_export_test.dart`, `test/data/repositories/flashcard_export_writer_test.dart` | `a91fe342` | **Early priority** — only data-out path until Drive sync; V1 cut: CSV, deck scope only |
| 8.7.2 | Settings | Deck export FE V1 | FE | Export action on deck actions sheet → share/save (`share_plus`, needs dependency approval) | Specified | 8.7.1 | `docs/business/export/export.md` | TBD | Stop-and-ask for `share_plus` approval before wiring |
| 8.8.1 | Settings | Appearance/locale settings | FE | Theme/language switches | Future | 8.2.1 | settings hub disabled rows | TBD | Do not implement without promotion |
| 8.9.1 | Settings | Bulk operations V1 | BE | Transactional bulk delete only (selected-ID snapshot, skip missing rows, cascade local data) + tests | Implemented | 2.13.1 | `lib/domain/repositories/flashcard_bulk_repository.dart`, `lib/domain/usecases/bulk/delete_flashcards_usecase.dart`, `lib/data/repositories/flashcard_bulk_repository_impl.dart`, `test/data/repositories/flashcard_bulk_repository_impl_test.dart`, `test/domain/usecases/bulk/delete_flashcards_usecase_test.dart` | `7c34ea3c` | No action |
| 8.9.2 | Settings | Bulk selection mode FE | FE | Long-press selection mode in flashcard list | Specified | 8.9.1 | `docs/business/bulk/bulk-operations.md` | TBD | Implement with first bulk action |

### Group 9 — Cross-cutting quality

| WBS ID | Flow | Function | Layer | Deliverable | Status | Depends on | Evidence/Source | Commit ID | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 9.1 | Quality | Route contract gate | Test | No raw route strings; `RouteNames`/`RoutePaths` only; route-order guard | Ongoing | 1.1.3 | router tests under `test/**` | TBD | Enforce on every route change |
| 9.2 | Quality | Riverpod usage gate | Test | No `ref.watch` in callbacks; watch/read/listen per state contract | Ongoing | 1.1.1 | `docs/state/state-management-contract.md` | TBD | Enforce per task |
| 9.3 | Quality | Hooks boundary gate | Test | Hooks only in approved presentation scopes | Ongoing | 1.1.1 | `lib/presentation/features/flashcards/hooks/**` | `75675b94` | Enforce per task |
| 9.4 | Quality | Transaction safety gate | Test | Multi-table writes always transactional (import, session, finalize, future bulk/tags) | Ongoing | 1.1.5 | `test/data/repositories/study_repository_test.dart` | TBD | Enforce per task |
| 9.5 | Quality | Schema/migration gate | Test | Version bump + `onUpgrade` + migration test + schema docs per change | Ongoing | 1.1.5 | `test/data/migrations/**` | TBD | Enforce per schema change |
| 9.6 | Quality | l10n coverage gate | Test | No hardcoded user-facing strings; ARB keys per copy change | Ongoing | 1.1.4 | `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb` | TBD | Enforce per task |
| 9.7 | Quality | State-coverage gate | Test | Loading/empty/error/no-results states on every screen | Ongoing | 1.1.2 | shared `Mx*` state widgets | TBD | Enforce per screen task |
| 9.8 | Quality | Docs-code parity gate | Docs | 8-step pre-commit parity check per `CLAUDE.md` | Ongoing | 1.1.7 | `CLAUDE.md`, `docs/checklist/implementation-checklist.md` | TBD | Enforce per commit |
| 9.9 | Quality | Guard/analyzer/test gate | Test | `dart fix` + `dart format` + `flutter analyze` + targeted tests (+ guard when present) | Ongoing | 1.1.6 | `docs/checklist/implementation-checklist.md` | TBD | Enforce per task |
| 9.10 | Quality | CI status checks | Test | GitHub workflow running analyze/test on PRs | Specified | 1.1.6 | TBD (no workflow visible) | TBD | Add minimal CI workflow |
| 9.11 | Quality | doc_guard docs/process gate | Test | `node tool/doc_guard/run.mjs check`: doc path/symbol/test-ref existence, WBS hygiene (columns, status vocab, commit hashes), ARB duplicate/missing keys, schema version drift; baseline mechanism for pre-existing findings | Implemented | 1.1.7 | `tool/doc_guard/run.mjs`, `tool/doc_guard/baseline.json`, `CLAUDE.md` §Verification commands | `4d936642` | Run in every task's verification chain |
| 9.12 | Quality | doc_guard baseline burn-down | Docs | Reduce `tool/doc_guard/baseline.json` (57 findings: decision-table phantom test refs, wireframe target-widget refs, contract stale paths) to zero | Specified | 9.11 | `tool/doc_guard/baseline.json` | TBD | Fix per area when touching it; refresh with `--update-baseline` |
| 9.13 | Quality | Repo-map cold-start snapshot | Docs | `docs/_generated/repo-map.md` generated summary (schema, routes+placeholders, use cases, screens, tests) for agent session bootstrap | Implemented | 9.11 | `docs/_generated/repo-map.md`, `tool/doc_guard/run.mjs` (`generate`) | `4d936642` | Regenerate in commits that change routes/schema/use cases/screens |
| 9.14 | Quality | Golden-diff visual parity runner | Test | `python tool/golden_diff/diff.py`: pixel-diff Flutter golden vs mock shot, mismatch % + diff region; text feedback loop for no-vision agents | Implemented | 1.1.6 | `tool/golden_diff/diff.py` (runner only; the per-screen golden-test gate remains Specified) | `4d936642` | Add golden tests with each UI task (start at 4.1.3) and wire diff into its verification |
| 9.15 | Quality | Unified verify entry point — ENFORCED | Test | `node tool/verify/run.mjs`: one command, canonical chain, scope auto-detection, single summary. **Enforcement (2026-06-12, after piecemeal-verify relapse):** `--quick` legalizes the inner dev loop through the same entry; a docs/code PASS writes a content-state-bound pass-marker; the pre-commit hook (`--check-marker`) rejects commits without a matching marker and requires a code-chain marker when code is staged. Running verification commands individually is now a hard-rule violation AND technically uncommittable | Implemented | 9.11 | `tool/verify/run.mjs`, `.githooks/pre-commit`, `CLAUDE.md` §Hard rules + §Verification; enforcement live-tested (commit blocked without marker → PASS → commit allowed) | `dbb96759` | New clones: `git config core.hooksPath .githooks` |
| 9.16 | Quality | Where-is feature index | Docs | `docs/_generated/where-is.md`: deterministic feature → docs/source/tests/mock-shots/WBS cross-reference (42 features; file lists resolved LIVE per generate; output linted by doc_guard); AGENTS.md fast-lookup table routes Codex to the same infra | Implemented | 9.13 | `docs/_generated/where-is.md`, `tool/doc_guard/run.mjs` (`WHERE_IS` registry), `AGENTS.md` §Where to look for what | `a9d79468` | Add a registry row when a new feature area lands; regen with `generate` |
| 9.17 | Quality | Pre-commit hook + repo hygiene | Test | `.githooks/pre-commit` runs doc_guard + whitespace check on every commit (opt-in `git config core.hooksPath .githooks`, activated in this clone); `.gitattributes` normalizes line endings ending the CRLF warning flood | Implemented | 9.11 | `.githooks/pre-commit`, `.gitattributes`; live-tested on the landing commit | `0dacbc83` | New clones run the one-time `core.hooksPath` config (documented in hook header + `tool/README.md`) |

### Group 10 — Release readiness

| WBS ID | Flow | Function | Layer | Deliverable | Status | Depends on | Evidence/Source | Commit ID | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 10.1 | Release | MVP smoke path | Integration | Create folder → deck → cards → study → finish → see progress, verified end-to-end | Partial | 2.x, 4.x, 7.5.1 | study/content flows and progress screen implemented; end-to-end script missing | TBD | Script/checklist the smoke path |
| 10.2 | Release | Android readiness | Integration | DB path, lifecycle, back behavior verified on Android | Specified | 10.1 | `lib/data/datasources/local/connection/database_connection_native.dart` | TBD | Manual verification pass + fixes |
| 10.3 | Release | Web readiness | Integration | Wasm/worker DB connection verified on web | Partial | 10.1 | `lib/data/datasources/local/connection/database_connection_web.dart` | `68c67656` | Verify persistence + study flow on web |
| 10.4 | Release | Windows readiness | Integration | Desktop DB + layout verified on Windows | Specified | 10.1 | `lib/data/datasources/local/connection/database_connection_native.dart` | TBD | Manual verification pass + fixes |
| 10.5 | Release | Known deferred list | Docs | Maintained register of deferred/Future/Rejected scope | Implemented | 1.1.7 | §6 of this file | `177c03153` | Keep updated per promotion/deferral |
| 10.6 | Release | Release acceptance checklist | Docs | Final acceptance checklist (smoke path, platforms, quality gates) | Specified | 10.1 | TBD | TBD | Author when Group 7 lands |

## 5. Next 10 Tasks (in delivery order)

Reprioritized per BA review 2026-06-10: fix the study entry path and protect user data first;
"look back" features (Progress) come after the core loop is whole. Each row is one agent prompt.

1. **7.1.1 + 7.2.1 + 7.3.1 + 7.4.1 Progress read model BE V1** — due summary, box distribution,
   stats, composed read model; tests.
2. **4.1.3 Deck study CTA FE V1** — study-entry section on Flashcard List; the only study entry
   today is the Dashboard Today CTA, so the core loop has one fragile door.
3. **4.1.4 Folder study CTA FE V1** — same wiring on Folder Detail.
4. **2.21.1 Folder delete blast-radius confirm FE V1** — delete dialog shows subtree counts;
   pairs with export as the data-safety duo.
5. ~~**7.5.1 + 7.5.2 Progress screen FE V1**~~ — done 2026-06-12 (with 7.4.2 overview BE); see §10.
6. **2.17.1 + 2.17.2 Flashcard status filters** — BE queries then chips/badges.
7. **8.7.2 Deck export FE V1** — share/save action (needs `share_plus` approval — stop and ask).
8. **6.6.2 Import duplicate preview FE V1** — surface backend-detected duplicates in preview.
9. **4.11.3 In-session bury/suspend action FE V1** — action UI, queue removal, undo affordance.
10. **8.1.2 Settings release polish FE V1** — hide fabricated mock state before release; cheap cleanup before user testing.

## 6. Deferred / Future / Rejected Register

| Item | Status | Reason / unblock condition |
| --- | --- | --- |
| Onboarding wizard (UI kit screen 01) | Rejected | V1 boots to Library; `lib/app/router/route_paths.dart` comment forbids onboarding. |
| Card history (UI kit screen 09) | Implemented | Promoted 2026-06-13; `last_reset_at` shipped v6. See WBS 7.6.1–7.6.3. Suspend/unsuspend overflow + timeline-row→result remain deferred (4.11.x). |
| Tags/recent/popular search sections | Future | Requires tag subsystem promotion (8.3.1) and SharedPreferences approval. |
| Excel import | Future | Requires dependency approval (6.8.1). |
| Daily goal / reminders / engagement persistence | Future | SharedPreferences-backed; not promoted. |
| Independent Korean/English TTS setting sets | Target | Requires migration/product decision. |
| Stats screen (UI kit screen 18) | Future | Needs aggregate read model; distinct from Progress screen (7.5.1). |
| Export with metadata | Rejected | Use Drive sync for backup instead. |
| Drive sync / account linking | Specified, deferred | High-risk; after core offline loop incl. progress (8.6.x). |
| Bulk reset progress | Blocked | Requires `last_reset_at`. |

## 7. Known Risks / Review Notes

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Settings screens are static mock previews | Agents may assume settings persist; they do not | 8.1–8.4 rows mark shells as Partial with BE rows Specified; wire FE only after BE lands. |
| Prior WBS over-claimed in-session bury/suspend as implemented | Wrong baseline for study-action prompts | Resolved 2026-06-10: WBS rows reset earlier; `docs/business/study-actions/bury-suspend.md` status header rewritten to Partial (schema + exclusion Current; actions Specified) in the docs-reconciliation commit. |
| Stale SRS doc claims (2026-06-10 verification) | `docs/business/srs/srs-review.md` claimed a runtime mismatch and pending columns that already shipped | Resolved 2026-06-10: srs-review header/interval notes rewritten to match verified runtime; table-driven tests pin the contract (4.6.2 Implemented). |
| Docs written against a previous project iteration (schema v10–v13, Prompts 20/45/46/47) | Agents build on phantom APIs (`ResumeStudySessionUseCase`, `DropCurrentStudyItemUseCase`, TTS DAO, progress feature) or refuse work blocked by nonexistent migrations | Reconciled 2026-06-10 across business docs/wireframes/contracts: false "Current/Implemented" claims downgraded, shipped-but-marked-pending columns corrected, phantom file refs replaced, scope-gate refs repointed to §6 of this file. Open product decisions are now explicit notes: C1 SRS demotion reachability (`srs-review.md`), `perfect` vs `initial_passed` definition (`glossary.md`), streak-pause persistence (`dashboard-engagement.md`). |
| Docs can be ahead of source | Agent may implement Future behavior accidentally | Check source + docs; respect §6 register. |
| Schema changes are high risk | Missing migration breaks existing DBs | 9.5 gate: version bump + onUpgrade + migration test + docs per change. |
| CI not visible | Cannot claim full pass from GitHub checks | 9.10 Specified; report source-level verification until CI exists. |
| Commit anchors for docs-baseline rows | History spans many commits; no single anchor | Rows 1.1.7/9.x use `TBD` by design; §10 log carries per-commit history. |

## 8. Legacy WBS ID Mapping

The Commit Traceability Log (§10) rows dated before 2026-06-10 reference the **legacy** WBS IDs from the previous revision of this file. Mapping of the most-referenced legacy IDs:

| Legacy ID(s) | Legacy meaning | Current ID(s) |
| --- | --- | --- |
| 3.8, 5.1–5.10 | Deck import route + import feature | 6.1.1–6.9.1 |
| 6.1–6.6 | Global search | 3.5.1–3.5.3 |
| 4.2, 4.3 | Flashcard create/edit screens | 2.11.2, 2.12.2 |
| 9.6–9.13 | Study entry/session/resume | 4.1.x–4.5.1, 4.8.1–4.10.1 |
| 10.4, 10.8 | Recall mode / review shell | 4.5.11, 4.3.2 |
| 11.5, 11.6 | Attempt classification / finalization | 4.4.1, 4.6.1 |
| 13.2, 13.3 | Dashboard today CTA / resume card | 5.2.2, 5.1.2 |
| 1.3.3 | Library branch routes | 1.1.3, 3.3.1 |
| 19.3 | Widget tests | 9.7 |
| 20.6, 18.9 | WBS document / UI kit contract | this file, 1.1.2 |

## 9. WBS Maintenance Rules

Update this WBS when:

- A placeholder route becomes a real screen.
- A Future/Target feature is promoted to Current.
- A schema migration changes the current DB version.
- A function row's implementation status changes (BE, FE, or Integration separately).
- New docs or decision-table rows materially change scope.
- Source reveals a doc-code parity drift that affects planning.

When updating, include:

- New baseline commit.
- Changed WBS rows only.
- Evidence paths.
- Any new priority/next-task adjustment.

Status discipline:

- BE and FE status are tracked on separate rows; never mark a feature Implemented because one side exists.
- UI shells without real data wiring stay Partial (FE) with the BE row Specified.
- Implemented requires source + test/docs evidence and, where practical, a verified commit anchor.
- Never invent commit hashes; use `TBD` when history cannot be verified.
- Do not write the current WBS-update commit hash into rows; report it in the task output and §10.

### Commit tracking rule

Every commit that creates, advances, or completes a WBS work package MUST append a row to the **Commit Traceability Log (§10)** in the same commit, listing the short commit id, date, the WBS ID(s) it touches, and a one-line summary. This keeps a bidirectional link (WBS ID ↔ commit id) without bloating the feature tables with per-row commit churn.

- Use the 8-char short hash (e.g. `5fbdf96d`).
- One commit may map to multiple WBS IDs; list them comma-separated.
- Feature/source commits should be logged by the WBS update that reviews them.
- Pure WBS traceability-maintenance commits do not need their own log row.
- Pure tooling/formatting commits that touch no WBS row may be omitted.
- The "Baseline reviewed" line at the top still tracks the latest reviewed commit; the log tracks per-task history.
- Log rows dated before 2026-06-10 use legacy WBS IDs; see §8 for the mapping.

## 10. Commit Traceability Log

Append-only, newest first. Each row links a landed commit to the WBS work package(s) it advanced. See the Commit tracking rule in §9. Rows before 2026-06-10 reference legacy WBS IDs (§8).

| Commit | Date | WBS IDs | Summary |
| --- | --- | --- | --- |
| `666db551` | 2026-06-16 | 3.2.3, 4.5.10 | New cards count as NEW not due: stop writing `due_at=now` on create + migration v11 (clear due_at for `review_count=0`); `new_count` read model on folder-detail deck/subfolder rows; folder summary `{n} new`/`{m} due` + Study new / Review due CTAs; deck-row new badge; srs-review/flashcard/contract/wireframe/WBS parity |
| `6aa7a8f3` | 2026-06-16 | 4.5.12, 4.1.2 | Study mode-chain persistence backbone: `StudyFlow`/`StudyFlowPlan` + `StudyFlowResolver`, schema v10 (`study_sessions.study_flow`/`current_mode`) + migration/test, persist flow+firstMode at create (new deck/folder → `new_full_cycle`), behavior-preserving; plus study-entry deep-link fixes (`goBackOrLibrary` safe-back, NotFound vs invalid-params copy) |
| `079b531f` | 2026-06-15 | 8.5.1 | Mock-parity (recursive review vs kit shot 21-account-sync--signed-out + business doc): rebuild signed-out as hero MxCard + "What stays local" 3-row MxListTile card + disabled Google sign-in; AppBar "Account & Drive sync"; l10n en/vi reworked; goldens regenerated; wireframe 19 notes canonical kit shot |
| `55732d01` | 2026-06-15 | 8.5.1 | Recursive-review fixes: raw CircleAvatar→MxAvatar (design-system hard rule), assert display-only sign-in button disabled + unsupported-state widget test; goldens regenerated |
| `60d394bb` | 2026-06-15 | 8.5.1 | Account Settings V1 (display-only) + cloud-account foundation: CloudAccountLink model/enums + corruption-tolerant store, repository/use case (Result), Riverpod DI + accountSettingsView resolver, AccountSettingsScreen replacing the placeholder (7 states) with Mx components, en/vi l10n; store/entity/resolver/usecase/widget tests + 5-state goldens (light/dark). flutter analyze clean |
| `e5b6da26` | 2026-06-15 | 8.6.5, 8.6.2 | Record V1 phasing decision: replace-DB blob backup now, conflict-free multi-device sync deferred to a future server-API-with-own-DB (not client-side CRDT/oplog); document the accepted V1 concurrent-divergence non-goal; add Future row 8.6.5 |
| `6de345cf` | 2026-06-14 | 8.6.3, 8.6.4, 8.6.1, 8.6.2 | Fix wireframe-19 model-B drift (fingerprint/token-store/12-field manifest); document silent token refresh for the ~1h access-token expiry (SY23) + industry-standard opt-in auto-backup proposal (SY24) across business spec/contracts/wireframe; add Future WBS rows 8.6.3 (silent refresh + reconnect banner) and 8.6.4 (auto-backup) |
| `44cb1486` | 2026-06-14 | 8.6.1, 8.6.2 | Reconcile Drive sync repository/use-case contracts with the business spec (model A): DriveSyncRepository + DriveSyncRunResult, composite-string fingerprint, .zip snapshot, drop obsolete flutter_secure_storage token store (google_sign_in 7.x owns tokens), add restore-of-older-schema migration rule (SY22) + V1 no-encryption decision; fix stale 5-field manifest cross-refs. Rows stay Specified |
| `9173a54f` | 2026-06-14 | 4.5.9 | Fill mode FE V1: typed-input study shell, strict trim-only evaluator, hint/retry/feedback affordances, and fill-mode tests/docs parity |
| `c46900e1` | 2026-06-14 | 4.5.11 | Recall mode FE V1: dedicated timed reveal/self-grade shell, countdown token, edit-pause resume, and result navigation wiring |
| `62752e9e` | 2026-06-14 | 7.6.1, 7.6.2, 7.6.3 | Card History activity feed (all 5 kit states): schema v7 (`study_attempts.duration_ms` + `card_events`); created/edited/reset event logging + duration capture in study viewmodel; unified attempt+lifecycle feed (full load, "Beginning of history") replacing cursor pagination; "All events" filter; partial-row + duration-not-logged affordances; resolved attempts-only→feed doc conflict; ARB/tests/docs parity |
| `acb021e5` | 2026-06-13 | 7.6.1, 7.6.2, 7.6.3 | Card History mock parity: breadcrumb + Box n/8 header chip + CURRENT PROGRESS card (box stepper + 6-stat grid: Due/Reviews/Recall rate/Lapses/Correct streak/Since added) + timeline rail with status chips/descriptions; single CustomScrollView; Edit pill + Reset/Delete overflow; BE header enriched (event count, correct streak, deck/breadcrumb); duration omitted (no schema column); ARB/tests/docs parity |
| `8c8039d1` | 2026-06-13 | 7.6.1, 7.6.2, 7.6.3, 1.1.5 | Card History promoted to V1: schema v6 `flashcard_progress.last_reset_at` (+migration/test); BE history query/DAO/repo + header/page/reset use cases + DI; `CardHistoryScreen` (header + cursor-paginated timeline + reset divider, 5 states) on route `/library/deck/:deckId/flashcards/:flashcardId/history` via row-action "View history"; reset keeps cumulative counters; ARB en/vi; widget/repo/migration tests; docs + decision table (H1-H7, N8/N9) + WBS parity |
| `619a4e75` | 2026-06-13 | 2.11.2, 2.12.2 | Editor input consistency: drop non-functional TTS speaker from Pronunciation field (all optional inputs share one box style); fix doubled "+" on Add-tag chip (ARB label drops literal "+", Icons.add provides it) |
| `650a4dfd` | 2026-06-13 | 2.11.2, 2.12.2 | Polish editor field labels to mock 07/08: optional fields get leading icon + uppercase tracked label + muted "optional" suffix; Front/Back + edit "OPTIONAL DETAILS" uppercased via `StringUtils.uppercased` (ARB stays title-case) |
| `ff76eeaa` | 2026-06-13 | 2.11.2 | Flatten create Add-details section: drop the nested bordered card so the toggle pill + expanded example/hint/pronunciation fields match mock 07 details-open (edit mode unchanged) |
| `d090cc2c` | 2026-06-13 | 2.11.2, 2.12.2, 3.4.2 | Flashcard List/Create/Edit FE mock-first refinement: 06 count/reorder headers + leading handles + reframed empty + delete-card preview; 07 Saving…/Retry-save bottom framing; 08 back-arrow + always-open Optional details + real last-edited·reviews meta strip (recall/History Future); shared confirm-dialog content slot + FlashcardDeletePreview; real data only, no schema change |
| `99cf2942` | 2026-06-13 | 3.2.2 | Folder detail FE rebuild: subfolders detail body reworked to mock — search-empty rendered as `MxCard` state, skeleton/secondary-button affordances, typography token wiring; folder_detail_test updated |
| `b1eae6cf` | 2026-06-13 | 3.1.2 | Library overview FE: remove fabricated folder mastery fallback — mastery bar only renders when a real mastery read-model value exists (no synthetic due/total ratio); library_overview_test updated |
| `47d78350` | 2026-06-13 | 3.1.2 | Library overview UI refresh: mock-aligned loading, empty, search-no-results, and error states with localized copy and tighter shell spacing |
| `8389ab44` | 2026-06-12 | 4.5.1 | Seal `StudyModeStrategy` into three interaction families (BinaryGrade/TypedAnswer/Board), remove UnsupportedError grading stubs from Fill/Match, full pattern dartdoc, decision rows S48/S49/S58, study-flow hierarchy doc |
| `1359edb4` | 2026-06-12 | 5.4.1, 7.7.1 | Dashboard progress summary backend V1: progress summary read model, provider wiring, local-day attempt aggregation, and consistency coverage |
| `b1b925ea` | 2026-06-12 | 4.5.1, 4.5.2, 4.5.6, 4.5.8, 8.2.1 | Restore study mode strategy wiring and WBS parity for previously implemented Review/Guess/Fill and learning-settings rows |
| `8fe3ce3a` | 2026-06-12 | 4.5.4 | Match persistence backend wave: append-only Match evaluation schema/migration, repository API, transactional finalization derivation, factory wiring, tests, and contract/docs updates |
| `3b4c3232` | 2026-06-12 | 7.4.2, 7.5.1, 7.5.2 | Progress screen V1: overview BE (range activity, study-day streak, card states), kit-mock screen with all 7 states, widget + golden tests, docs reconciled |
| `dbb96759` | 2026-06-12 | 9.15 | Enforce single-entry verification after piecemeal relapse: `--quick` inner loop qua cùng entry, pass-marker gắn content-state, hook `--check-marker` chặn commit chưa verify; CLAUDE.md hard rule cấm lệnh verify rời |
| `0dacbc83` | 2026-06-11 | 9.17, 9.15, 9.11, 1.1.7 | Agent-friendliness pass: `.gitattributes` (hết CRLF noise), pre-commit hook chạy doc_guard, CLAUDE.md 393→263 dòng (gỡ khối bash/verify lỗi thời), implementation-checklist trỏ verify entry, decision-table section index, tool/README thêm trigger matrix + portability guide; checkArb sửa đếm key top-level |
| `a9d79468` | 2026-06-11 | 9.16 | Where-is feature index (42 features, live-resolved, doc_guard-linted) + AGENTS.md fast-lookup table + repo-map/where-is into required reading |
| `259baae8` | 2026-06-11 | 9.15 | Unified verify entry (`tool/verify/run.mjs`): scope auto-detection, canonical chain order, single summary; CLAUDE.md points agents at one command |
| `4d936642` | 2026-06-11 | 9.11, 9.12, 9.13, 9.14 | Token-saving toolchain: doc_guard gate (path/symbol/test-ref/WBS/ARB/schema checks + baseline of 57 pre-existing findings), repo-map cold-start generator, golden-diff runner; status headers fixed on account-sync/state-contract/tag-system docs; wired into CLAUDE.md verification chain |
| `0ce64355` | 2026-06-11 | 1.1.2, 1.1.7, 9.8 | DOM-spec exporter for low-vision agents: 23 `specs/*.md` (measured element trees + token-resolved styles + per-state deltas) via `export_specs.mjs`; routed in kit README, mock-design-index, CLAUDE.md |
| `dacfefe5` | 2026-06-11 | 1.1.2, 1.1.7, 9.8 | UI kit agent-consumption path: export 270 per-state mock PNGs (23 screens × 135 states × light/dark) + `shots/INDEX.md` manifest via `tool/ui_kit_shots/`; line-index in kit README; CLAUDE.md + mock-design-index route UI tasks to shots with all-states parity rule |
| `7c34ea3c` | 2026-06-10 | 2.19.1, 2.20.1, 8.3.1, 8.9.1 | Add backend content operations for deck move, manual duplicate soft-warning, tag management, and bulk delete |
| `d50cceb2` | 2026-06-10 | 3.7.1, 4.11.1, 4.11.2 | Add in-session bury/suspend backend, due-count coverage, and study eligibility regressions |
| `48795861` | 2026-06-10 | 4.5.10 | Bound daily new quota to the local-day window and keep cancelled new-card sessions consuming quota |
| `53fae583` | 2026-06-10 | 4.2.4, 4.5.10, 4.6.4, 4.10.2 | Add study session batch cap, daily new cap, local-midnight due normalization, and updated_at resumable expiry |
| `93efe3e1` | 2026-06-10 | 8.7.1 | Guard-compliance cleanup for deck export filename sanitizing helper |
| `b63998a7` | 2026-06-10 | 2.19–2.21, 4.1.3, 4.1.4, 4.2.4, 4.4.3, 4.5.10, 4.6.4, 4.10.2, 8.1.2, 8.2.1, 8.7.1, 8.7.2 | Adopt BA-review improvements: resolve C1/M2/M3 (first-attempt SRS, result terms, streak pause), spec recall-default SRS review, session batch limit, daily new limit, due-day normalization, deck move, dup soft-warning, delete blast-radius, export priority, mock-state release rules; reorder next-10 |
| `a91fe342` | 2026-06-10 | 8.7.1 | Implement deck export CSV backend V1 with deterministic front/back CSV and safe filename generation |
| `e84f5115` | 2026-06-10 | 6.6.1 | Prevent import duplicate commit bypass with repository guard + tests |
| `44407390` | 2026-06-10 | 6.6.1, 6.9.1 | Import duplicate detection + structured text backend |
| `a35f32f1` | 2026-06-10 | 2.17.1, 2.18.1 | Flashcard list status + tag backend filters |
| `4d1eba04` | 2026-06-10 | 7.1.1, 7.2.1, 7.3.1, 7.4.1 | Progress read model backend V1 |
| `bde2a3dc` | 2026-06-10 | 1.1.7, 9.8 | Reconcile 43 docs with source reality: downgrade phantom Implemented claims (bury/suspend, resume banners, TTS, progress screen, Prompt 45/46/47), correct shipped-but-marked-pending schema claims, repoint scope gate to WBS §6, flag open product decisions (SRS demotion, perfect vs initial_passed, streak pause) |
| `aa5f9a76` | 2026-06-10 | 4.6.2 | Verify SRS box transition + interval ladder vs doc contract; table-driven tests S11–S15; fix phantom decision-table test refs |
| `7b3c1691` | 2026-06-10 | 3.8, 5.2, 5.5, 5.7, 5.8, 5.9, 5.10 | Commit deck import with CSV paste preview and transactional insert flow |
| `dd8688a` | 2026-06-09 | 20.6, 18.9, 5.1–5.9, 6.1–6.6 | Update WBS and UI kit references for accuracy and traceability |
| `5fbdf96d` | 2026-06-10 | 6.1–6.6 | Refactor `GlobalSearchScreen` / `SearchAppBarField` query handling |
| `38af6d94` | 2026-06-09 | 4.2, 4.3 | `FlashcardEditorDraft` focus management in editor view |
| `c1e89cf5` | 2026-06-09 | 3.8, 5.2, 5.5, 5.7 | Deck import CSV paste + parse + validation preview |
| `66bf1460` | 2026-06-09 | 3.8, 5.1 | Deck import route shell |
| `0c2b3a50` | 2026-06-09 | 1.3.3 | Fix folder route registry comment (docs/source) |
| `0cd918dd` | 2026-06-09 | 9.11 | Align persistence recovery decision table |
| `93dec233` | 2026-06-09 | 9.11, 19.3 | Test session persistence recovery |
| `7645e9e8` | 2026-06-09 | 13.3 | Simplify continue-studying card v1 |
| `40e3c8b0` | 2026-06-09 | 9.10 | Confirm active-session exit |
| `30075fbf` | 2026-06-09 | 9.13, 10.4 | Study mode strategy v1 |
| `b2ea71ce` | 2026-06-09 | 9.6 | Make start-over restart transactional |
| `5339d8e5` | 2026-06-09 | 9.6 | Resume / start-over choice v1 |
| `4477dd86` | 2026-06-09 | 9.9, 10.8 | Study result screen v1 |
| `d5ae03f0` | 2026-06-09 | 11.6 | Study session finalization |
| `f3740591` | 2026-06-09 | 10.4, 11.5 | Study session self grading |
| `2971d800` | 2026-06-09 | 9.8 | Study session card navigation |
| `41e049af` | 2026-06-09 | 13.2 | Dashboard today CTA |
