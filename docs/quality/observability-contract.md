---
last_updated: 2026-06-21
status: contract
---

# Observability Contract

Logging and error reporting policy. MemoX is local-first with no remote telemetry. All logs are
local, used for debugging only.

> **As-built (2026-06-21, WBS 1.1.8):** the logging *configuration* is now Current. `package:logging`
> is wired to a single shared [Talker] sink in `lib/core/logging/log_config.dart` (`MxLog.init`),
> booted from `lib/app/bootstrap/app_bootstrap.dart` inside the guarded zone; uncaught
> Flutter/platform/zone errors are logged `SEVERE` (no longer swallowed), and provider lifecycle is
> logged via `TalkerRiverpodObserver` on the root `ProviderScope`. Talker renders the console line
> (timestamp + level + payload) in debug and keeps an in-memory history for a future in-app viewer.
> **Still deferred:** the persistent rotating log **file** (`persistent_log_writer.dart`) and the
> in-app **log-viewer screen** (Settings → About → Show logs) — both await their owning tasks; see
> §Error reporting and §Talker integration. Per-use-case entry/exit logging is rolled out per feature
> task, not retrofitted in bulk.

## Logging library

`package:logging` (Dart standard) is the **only** logging API features use. One logger per feature,
accessed via:

```dart
final _log = Logger('study.session');
```

Logger naming follows feature folder path with dots: `dashboard`, `library`, `library.search`,
`study.session`, `study.srs`, `data.sync`, `core.tts`, `core.auth`. The app-shell boundary logger is
`app.shell` (uncaught errors + boot).

Features **must not** import `package:talker*` directly — Talker is an implementation detail of the
sink wired in `log_config.dart`. Log through `Logger(...)` and the record reaches Talker
automatically.

## Levels

| Level           | When                                                                                                                              |
|-----------------|-----------------------------------------------------------------------------------------------------------------------------------|
| `Level.SEVERE`  | `IntegrityFailure`, unrecoverable storage error, programmer error caught at boundary, uncaught exception in app shell             |
| `Level.WARNING` | Unexpected `StorageFailure`, retry exhausted on network, token refresh failed, migration rollback                                 |
| `Level.INFO`    | Use case entry/exit for significant ops (session create, finalize, import commit, sync upload/restore), migration steps, app boot |
| `Level.FINE`    | Use case entry/exit for routine ops (read flashcard list), provider invalidation                                                  |
| `Level.FINER`   | Per-card grade attempt (in dev mode only)                                                                                         |
| `Level.FINEST`  | Detailed loop trace (off by default)                                                                                              |

In production builds, level threshold is `Level.INFO`. In debug builds, `Level.FINE`. Set from the
`kReleaseMode` flag in `MxLog.init` (`Logger.root.level = kReleaseMode ? Level.INFO : Level.FINE`).
Records below the threshold are dropped by `package:logging` before they reach the Talker sink.

## What to log

| Event                     | Level     | Content                                       |
|---------------------------|-----------|-----------------------------------------------|
| Use case entry            | INFO/FINE | Use case name + non-PII params                |
| Use case exit success     | INFO/FINE | Use case name + result type                   |
| Use case exit failure     | WARNING   | Use case name + failure type (not user data)  |
| Migration applied         | INFO      | From version → to version                     |
| App boot                  | INFO      | Build flavor + app version                    |
| Provider invalidation     | FINE      | Provider name + reason                        |
| Drift transaction commit  | FINE      | Transaction tag                               |
| Sync upload start/end     | INFO      | Manifest size, duration                       |
| Sync restore start/end    | INFO      | Manifest device label + uploaded_at, duration |
| Snapshot creation         | INFO      | Path, size                                    |
| Token refresh             | INFO      | Success/fail (no token value)                 |
| TTS engine init           | INFO      | Engine name, language                         |
| TTS playback start        | FINE      | Language, char count (NOT text content)       |
| Uncaught exception (Zone) | SEVERE    | Type, message, stack                          |

## PII rule (strict)

NEVER log:

- Flashcard `front` or `back` text content.
- Tag names (user-created could contain personal info).
- Folder/deck names.
- OAuth tokens, refresh tokens.
- Account email (log a hash/prefix if needed for cross-correlation).
- Fingerprint values.
- File system paths beyond app sandbox root.
- Note / example / pronunciation / hint fields.

Where size or count matters, log the count (e.g., "Imported 18 cards") not the content.

## What to log INSTEAD of PII

- IDs (UUIDs) are OK to log — they're opaque.
- Counts, sizes, durations.
- Failure type and code (`ValidationFailure code=tooLong field=tag`).
- Boolean states (`hasResumable=true`).
- Enum values (`AttemptResult.forgot`).

## Format

The **logical** record content a feature is responsible for is the logger name + message payload:

```
[logger.name] message {key=value, key=value}
```

The active sink (Talker) prepends the timestamp + level when it renders the console line, so the
on-screen form is:

```
[LEVEL] | HH:MM:SS mmm'ms | [logger.name] message {key=value, key=value}
```

Example (console, as-built):

```
[info] | 14:32:18 412ms | [study.session] grade_attempt result=perfect boxBefore=3 boxAfter=4 mode=review duration_ms=42
```

`MxLog._format` produces the `[logger.name] message` part; do not hand-prepend a timestamp or level —
the sink owns those.

## Error handling and logging interplay

| Situation                                   | What to do                                                           |
|---------------------------------------------|----------------------------------------------------------------------|
| Catching expected `Failure` at notifier     | Log WARNING with failure type, update state                          |
| Catching unexpected `Exception` at boundary | Log SEVERE with stack, map to `IntegrityFailure` or `StorageFailure` |
| Empty catch block                           | FORBIDDEN. Either log or rethrow.                                    |
| Catch + ignore (intentional)                | Log FINE with explicit comment explaining why                        |
| Catch + rethrow                             | Log FINE before rethrow if useful context, else just rethrow         |

## Error reporting (no remote)

MemoX v1 does NOT send crash reports. Optional future: opt-in local dump exported when user taps "
Report a bug" in About.

As-built:

- Crashes during development go to the console (Talker), and every uncaught error
  (Flutter / platform / zone) is logged `SEVERE` via the `app.shell` logger → Talker history.
- **Deferred:** the persistent rotating log **file**. Target (unchanged): uncaught zones also written
  to `{appSupportDir}/logs/memox-{date}.log`, rotation keeps the last 7 days, stripped in test builds.
  Implement under its own task (needs `path_provider` file IO + test stripping); until then the
  in-memory Talker history is the only retained record.

## Talker integration (Current — sink; viewer deferred)

Talker is the **as-built sink** for `package:logging` (not optional):

- The root logger pipes every record into one shared `Talker` (`MxLog.talker`) — Talker is the
  console renderer in debug and the in-memory history holder in all builds.
- `TalkerRiverpodObserver(talker: MxLog.talker)` on the root `ProviderScope` logs provider
  add/update/dispose/fail (the FINE "provider invalidation" row).
- Talker history MUST respect the PII rule — the same `Logger(...)` payload rules apply; nothing
  bypasses them because there is no direct `talker.*` call in feature code.
- **Deferred:** the in-app Talker **viewer screen** (Settings → About → Show logs, developer mode
  only). It lands with the Settings/About screen task; Talker's `TalkerScreen` reads `MxLog.talker`.
- Production builds: the viewer MUST NOT be accessible to end users; console mirroring is already off
  in release (`useConsoleLogs: !kReleaseMode`).

## Forbidden patterns

- ❌ `print()` or `debugPrint()` in production code paths.
- ❌ Log PII (see list above).
- ❌ Empty `catch {}` block.
- ❌ Catch + `print(e)`. Use logger.
- ❌ `Logger.severe` for any recoverable case.
- ❌ Same logger name across unrelated features (sharing).
- ❌ Logger as global mutable state. Use `Logger('name')` lookup per call site.

## Required patterns

- ✅ Setup root logger with level threshold — **as-built** in `MxLog.init` (`log_config.dart`),
  called from `app_bootstrap.dart`.
- ✅ Wrap `runApp` in `runZonedGuarded` to catch async uncaught errors → SEVERE log — **as-built**
  (`app.shell` logger; `FlutterError.onError` + `PlatformDispatcher.onError` also log SEVERE).
- ✅ Each use case has one INFO/FINE entry log and one INFO/FINE / WARNING exit log — rolled out per
  feature task (not yet retrofitted across existing use cases).
- ✅ Strip log file writes in test builds — trivially satisfied while the persistent file writer is
  deferred (no file IO exists yet); re-assert when it lands.

## Forbidden in tests

- ❌ Production logger writing to disk in tests. Use in-memory log capture if assertion needed.

## Agent rule

- When implementing a use case: add `_log.info('use_case_name entry params=...')` at start and one
  of:
    - `_log.fine('use_case_name success result=...')` on success
    - `_log.warning('use_case_name failure type=...')` on failure
- When catching exception in data layer: WARNING with failure type, never SEVERE unless
  `IntegrityFailure`.
- When adding a new log site: verify no PII in content.

## Related

**Repo-level:**

- `CLAUDE.md` — code style forbids print/debugPrint

**Contracts:**

- `docs/contracts/error-contract.md` — what to log per failure type
- `docs/contracts/code-style.md` — logger naming
- `docs/quality/performance-contract.md` — trace events for perf-sensitive ops

**Code paths:**

- `lib/core/logging/log_config.dart` — root setup + Talker sink (`MxLog`) — **Current**
- `lib/app/bootstrap/app_bootstrap.dart` — `runZonedGuarded`, SEVERE error handlers, root
  `ProviderScope` observer, app-boot log — **Current** (`lib/main.dart` only calls `AppBootstrap.run`)
- `test/core/logging/log_config_test.dart` — level threshold, record→Talker pipe, level mapping
- `lib/core/logging/persistent_log_writer.dart` — file rotation — **deferred (not yet created)**
