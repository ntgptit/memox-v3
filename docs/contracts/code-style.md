---
last_updated: 2026-06-08
status: contract
---

# Code Style Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. If the project has not yet adopted `fpdart`, do not add it during
> ordinary feature implementation. First run an approved dependency/API migration task, or use the
> existing repository error/result pattern until that migration is approved.

Naming, file organization, import order, and forbidden patterns for MemoX Flutter code. This
contract supplements (does NOT replace) `analysis_options.yaml`. When linter and this doc disagree,
fix the linter rule, not the convention.

## File and folder layout

### Feature-first under presentation

```
lib/presentation/features/{feature}/
├── screens/                  # full-screen widgets, one per route
│   └── {feature}_screen.dart
├── widgets/                  # feature-private widgets
├── viewmodels/               # screen state, query providers, Riverpod action controllers
├── providers/                # feature-scoped providers when not owned by a viewmodel file
└── models/                   # presentation-layer view-models (rare; prefer freezed in shared)
```

### Domain (layer-first)

```
lib/domain/
├── entities/                 # pure entity classes (freezed)
├── enums/                    # current enum owners
├── repositories/             # repository INTERFACES (abstract)
├── services/                 # domain service interfaces/policies
├── usecases/                 # use case classes grouped by feature file
├── value_objects/            # cross-feature read models and query objects
├── tag/                      # tag validation logic
└── study/                    # study entities, SRS policy, strategies, mode helpers, repo port
```

`docs/contracts/types-catalog.md` remains the semantic registry for domain
types. The current code owners are `lib/domain/enums/**`,
`lib/domain/value_objects/**`, and selected `lib/domain/study/**` files; a
future consolidation into `lib/domain/types/**` requires an explicit migration.

### Data (layer-first)

```
lib/data/
├── datasources/local/
│   ├── tables/               # Drift table definitions
│   ├── daos/                 # Drift DAOs
│   ├── migrations/           # one file per migration step
│   ├── preferences/          # SharedPreferences wrappers
│   └── app_database.dart
├── repositories/             # repository IMPLEMENTATIONS
├── mappers/                  # entity ↔ row mappers
└── sync/                     # Drive sync, snapshot, manifest
```

### Core + presentation shared infrastructure

```
lib/core/
├── theme/                    # tokens, schemes, component themes, responsive helpers
└── ...

lib/presentation/shared/
├── bottom_sheets/            # shared composed sheet entrypoints
├── dialogs/                  # Mx* dialogs and sheet primitives
├── feedback/                 # snackbars, banners, failure text
├── layouts/                  # shell/layout primitives
├── motion/                   # shared durations/transition helpers
├── options/                  # shared option models
├── providers/                # cross-feature presentation providers
├── viewmodels/               # shared presentation action helpers
└── widgets/                  # Mx* buttons, cards, chips, inputs, navigation, states
```

### App (boot)

```
lib/app/
├── router/                   # route_names, route_paths, app_router, redirect
├── di/                       # provider overrides at boot if any
└── theme_provider.dart
```

### L10n

```
lib/l10n/
├── app_en.arb                # source of truth (English)
├── app_vi.arb                # Vietnamese
├── app_ko.arb                # Korean (planned; not present until added with l10n generation)
└── generated/                # codegen output; DO NOT EDIT
```

## Naming conventions

### Files

- Always `snake_case.dart`.
- Match the primary public class: `class DashboardScreen` → `dashboard_screen.dart`.
- Test files: `{source_filename}_test.dart` or `{flow_name}_test.dart` for integration.

### Classes

| Kind                      | Suffix                                | Example                             |
|---------------------------|---------------------------------------|-------------------------------------|
| Screen widget             | `Screen`                              | `DashboardScreen`                   |
| Bottom-sheet widget       | `Sheet` (with `Mx` prefix if shared)  | `MxSheetTagPicker`                  |
| Dialog widget             | `Dialog` (with `Mx` prefix if shared) | `MxDialogDeleteConfirm`             |
| Use case                  | `UseCase`                             | `GradeAttemptUseCase`               |
| Repository interface      | `Repository`                          | `FlashcardRepository`               |
| Repository implementation | `RepositoryImpl`                      | `FlashcardRepositoryImpl`           |
| DAO                       | `Dao`                                 | `FlashcardDao`                      |
| Notifier (Riverpod)       | `Notifier`                            | `DashboardNotifier`                 |
| Service (cross-cutting)   | `Service`                             | `TtsService`, `DriveSyncService`    |
| Mapper                    | `Mapper`                              | `FlashcardMapper`                   |
| Entity / model            | no suffix                             | `Flashcard`, `Folder`, `Deck`       |
| Failure                   | `Failure`                             | `StorageFailure`, `NotFoundFailure` |
| Enum                      | no suffix                             | `AttemptResult`, `StudyMode`        |
| Shared widget             | `Mx` prefix                           | `MxPrimaryButton`, `MxScaffold`     |
| Feature-private widget    | no `Mx` prefix                        | `ResumeCard`, `GoalRing`            |

### Per-folder naming control (guard-enforced)

File names and the primary public class name are not free choices — each layer folder
owns a suffix, and `code-verification-guard` (ruleset `memox`) rejects a misnamed file
or class at the gate. The file name must always match the primary public class
(`class CreateDeckUseCase` → `create_deck_usecase.dart`), so enforcing the file suffix
also pins the class name.

| Folder | File name (enforced) | Public class | Guard rule id(s) |
|--------|----------------------|--------------|------------------|
| `lib/domain/usecases/**` | `*_usecase.dart` (`*_usecases.dart` when grouping) | `*UseCase` | `memox.layer_naming.usecase_file_suffix`, `memox.layer_naming.usecase_class_suffix` |
| `lib/domain/repositories/**` | `*_repository.dart` | `abstract interface class *Repository` | `memox.layer_naming.repository_interface_file_suffix`, `memox.layer_naming.repository_interface_class_suffix` |
| `lib/data/datasources/local/daos/**` | `*_dao.dart` | name contains `Dao` (`FlashcardDao`, `FlashcardDaoManager`) | `memox.layer_naming.dao_file_suffix`, `memox.layer_naming.dao_class_suffix` |
| `lib/data/mappers/**` | `*_mapper.dart` | `abstract final class *Mapper` | `memox.layer_naming.mapper_file_suffix`, `memox.layer_naming.mapper_class_suffix` |
| `lib/data/datasources/local/migrations/**` | `v<N>_<desc>.dart` | — | `memox.layer_naming.migration_file_prefix` |
| `lib/data/repositories/**` | contains `repo` (canonical `*_repository_impl.dart`) — **warning** | `*RepositoryImpl` | `memox.layer_naming.repository_impl_file_token` |
| `lib/presentation/features/*/routes/**` | `*_routes.dart` | — | `memox.layer_naming.route_file_suffix` |
| `lib/presentation/features/*/screens/**` | `*_screen.dart` / `*_page.dart` | `*Screen` | `memox.coding.screen_file_naming`, `memox.coding.crud_screen_class_naming` |
| `lib/presentation/features/*/viewmodels/**`, `*/providers/**`, `lib/app/di/**` | `*_viewmodel.dart` / `*_notifier.dart` / `*_provider(s).dart` | `*Controller` / `*Notifier` | `memox.coding.provider_file_naming`, `memox.coding.crud_controller_class_naming` |
| `lib/presentation/shared/{widgets,layouts,dialogs,feedback,bottom_sheets}/**` | `mx_*.dart` | `Mx*` (classes, enums, typedefs) | `memox.shared_widget.file_naming_mx_prefix`, `memox.shared_widget.public_type_mx_prefix` |
| all of `lib/**` | `snake_case.dart` | — | `memox.dart_convention.file_name_snake_case` |

Notes:

- Layers with **no suffix** by design — `domain/entities`, `domain/types`, `domain/models` —
  are intentionally absent from the table. They carry no public-suffix rule (only the global
  `snake_case` file rule); their type names follow the [Classes](#classes) table above.
- `data/repositories` is a **warning** only because legacy impl names are mixed
  (`*_repository_impl`, `*_repo_impl`, split helpers). Promote
  `memox.layer_naming.repository_impl_file_token` to `error` once every impl is renamed to
  `<entity>_repository_impl.dart`.
- The `memox.layer_naming.*` rules live in
  `code-verification-guard/registries/projects/memox/rules/memox-layer-naming-rules.yaml`.
  To add or change a layer rule, edit that file and keep this table in the same commit.

### Functions and variables

- lowerCamelCase always.
- Boolean: prefix with `is`, `has`, `can`, `should` (`isSuspended`, `hasUnsavedChanges`,
  `canCommit`).
- Private: leading underscore (`_buildHeader`, `_currentDeckProvider`).
- Stream getter: `watchXxx()` (matches Drift convention).
- Future single: `getXxx()`, `findXxx()`, `loadXxx()`.

### Providers (Riverpod v3 annotation codegen)

| Need           | Pattern                                                                                                |
|----------------|--------------------------------------------------------------------------------------------------------|
| Query provider | `@riverpod {ReturnType} {entity}({Ref} ref, ...)` → `{entity}Provider`                                 |
| Notifier       | `@riverpod class {Feature}Notifier extends _$ {Feature}Notifier { ... }` → `{feature}NotifierProvider` |
| Scoped/family  | use `family` parameter; never manual key construction                                                  |

Examples:

```dart
@riverpod
Future<List<Flashcard>> dueFlashcards(DueFlashcardsRef ref, DeckId deckId) async { ... }
// usage: ref.watch(dueFlashcardsProvider('deck-1'))

@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override Future<DashboardState> build() async { ... }
}
// usage: ref.watch(dashboardNotifierProvider)
```

Forbidden:

- Manual `Provider`/`StateProvider`/`StateNotifierProvider` (use annotation codegen).
- Two providers with same logical purpose but different names (e.g., `flashcardListProvider` AND
  `currentDeckFlashcardsProvider`).
- Provider for `BuildContext` or other transient.

## Imports order

The import example below includes `fpdart` as target architecture. Omit `package:fpdart/fpdart.dart`
until the dependency/API migration is approved and applied.

```dart
// 1. dart: imports
import 'dart:async';
import 'dart:convert';

// 2. flutter/ imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. third-party packages (alphabetical)
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 4. local (alphabetical by full path)
import 'package:memox/core/error/failure.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/types/study_mode.dart';

// 5. part directives last
part 'dashboard_notifier.g.dart';
part 'dashboard_state.freezed.dart';
```

Use absolute `package:memox/...` imports for local code, NOT relative `../../`. Easier to grep and
move.

## Const, final, var

- Default to `const` for compile-time constants.
- `final` for runtime-immutable.
- `var` only for genuinely mutable locals.
- `const Widget()` constructors wherever possible (perf + linter happy).

## Async / Future / Stream

- `async`/`await` always (no raw `.then()`).
- Don't `await` what you don't need; let unrelated futures run in parallel via `Future.wait`.
- Cancel streams: use `StreamSubscription` with `cancel()` in `dispose()`/`onDispose`.
- Riverpod `AsyncValue` for UI state — never expose raw `Future<T>` to UI.

## Either<Failure, T>

```dart
// Use case signature
Future<Either<Failure, Flashcard>> call(FlashcardId id) async { ... }

// Caller pattern (notifier)
final result = await getFlashcardUseCase(id);
result.fold(
  (failure) => state = AsyncError(failure, StackTrace.current),
  (flashcard) => state = AsyncData(flashcard),
);
```

Forbidden:

- `result.toNullable()` to ignore error.
- `result.getOrElse(() => somethingFake)` without logging the failure.
- Pattern-matching on string of failure: always pattern-match on type.

## Widget build rules

- One widget per file when widget is non-trivial (>~30 lines or used outside).
- Build method: short. Extract `_buildXxx()` methods OR sub-widgets.
- No business logic in build (no DB call, no validation, no transformation that should be in
  notifier/use case).
- `BuildContext` only inside build / callbacks; never store.
- `MediaQuery.of(context)` once at top of build; reuse the result.

## Flutter Hooks policy

- Hooks are allowed only in `lib/presentation/**`.
- Hooks are forbidden in `lib/domain/**`, `lib/data/**`, `lib/core/**`,
  `lib/app/router/**`, `lib/app/di/**`, and `lib/app/bootstrap/**`.
- Use `HookWidget` when a widget only needs local UI lifecycle state.
- Use `HookConsumerWidget` when a widget needs both hooks and Riverpod.
- Do not use hooks for business state, SRS state, database state, route state,
  auth/sync state, or repository/use-case result state.
- Shared design-system widgets stay controlled and mostly
  `StatelessWidget`; do not convert `MxTextField`, `MxSearchField`,
  `MxSliderField`, `MxFlashcard`, `MxRatingBar`, `MxSelfAssessment`,
  `MxButton`, `MxCard`, `MxScaffold`, `MxAppBar`, or `MxBottomNav`
  to hooks unless a documented exception is approved.
- Custom hooks must start with `use`.
- Custom shared hooks must not call repositories, use cases, DAOs, or
  navigation.
- Do not call hooks conditionally inside `if`, `for`, or callbacks.
- Do not use `useEffect` for business operations without explicit approval.

## Forbidden in production code

| Forbidden                                                      | Why                            | Replacement                          |
|----------------------------------------------------------------|--------------------------------|--------------------------------------|
| `print()`                                                      | Goes to stdout, not log levels | `Logger('feature').info(...)`        |
| `debugPrint()`                                                 | Same problem                   | `Logger(...)`                        |
| Hardcoded route string                                         | Breaks rename                  | `RouteNames.xxx`, `RoutePaths.xxx`   |
| Hardcoded color hex                                            | Breaks theme                   | `Theme.of(context).colorScheme.xxx`  |
| Hardcoded TextStyle                                            | Breaks theme                   | `Theme.of(context).textTheme.xxx`    |
| Hardcoded duration                                             | Breaks settings consistency    | `MxDurations.fast/medium/slow`       |
| Hardcoded user-facing string                                   | Breaks l10n                    | `AppLocalizations.of(context).xxx`   |
| `DateTime.now()`                                               | Untestable                     | `clock.now()` (package:clock)        |
| `Random()`                                                     | Untestable                     | injected `Random`                    |
| `Container(decoration: BoxDecoration(...))` for known patterns | Duplicates design system       | Use `Mx*` widget                     |
| `// TODO` without ticket                                       | Drift accumulates              | `// TODO(#123): ...` with issue link |

## Required patterns

- ✅ One screen per route.
- ✅ One notifier per screen (mostly).
- ✅ Repository returns `Either<Failure, T>` or `Stream<T>`.
- ✅ Use case takes raw inputs, returns `Either<Failure, T>`.
- ✅ DI via Riverpod providers; constructors take dependencies explicitly.
- ✅ Freezed for any non-trivial data class (entity, state, value object).
- ✅ `equatable` not used (freezed handles equality).

## Generated files

Generated files (`*.g.dart`, `*.freezed.dart`, Drift `*.g.dart`, l10n `app_localizations*.dart`):

- ARE checked into git (so reviewers see schema changes).
- Never hand-edit.
- Regenerate via:

  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

- L10n regenerate via:

  ```bash
  flutter gen-l10n
  ```

## Commit message convention

Conventional commits:

```
feat(study): add fill mode char-by-char input
fix(folder): prevent move into descendant
refactor(repository): extract flashcard mapper
docs(wireframe): update 18-study-result Done semantics
test(srs): add box transition table tests
chore(deps): bump drift to 2.x
```

Scopes match top-level feature folder names. Footer for breaking changes:

```
BREAKING CHANGE: AttemptResult enum case renamed (hypothetical example). Update all DB rows and l10n keys.
```

## Branch and PR

- Branch: `feat/{feature-slug}`, `fix/{bug-slug}`, `refactor/{slug}`.
- One PR = one logical change. Avoid mega-PRs.
- PR description must reference: business spec, decision row IDs, related wireframe, related docs
  that changed.

## Forbidden in tests

See `docs/testing/test-strategy.md`.

## Agent rule

- Follow this contract strictly. Lint failures = task failure.
- When a new pattern is needed (e.g., new widget category, new naming case), update this contract
  FIRST, then implement.
- When you encounter legacy code violating this contract, fix it in the same PR if scoped, else file
  a TODO with ticket.

## Related

**Repo-level:**

- `CLAUDE.md` §Hard rules (overlap)
- `AGENTS.md` self-audit
- `analysis_options.yaml` (lint rules, enforced by CI)

**Contracts:**

- `docs/contracts/types-catalog.md` — type names this contract refers to
- `docs/contracts/error-contract.md` — Failure naming
- `docs/testing/test-strategy.md` — test naming
- `docs/quality/observability-contract.md` — logging API
- `docs/quality/performance-contract.md` — perf-related patterns

**Architecture:**

- `docs/architecture/clean-architecture-contract.md` — layer boundaries
- `docs/state/state-management-contract.md` — Riverpod patterns
- `docs/ui-ux/ui-ux-contract.md` — design tokens
