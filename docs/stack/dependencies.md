---
last_updated: 2026-06-19
applies_to: pubspec.yaml
---

# MemoX — Dependency Reference

Tài liệu này liệt kê tất cả thư viện trong `pubspec.yaml`, mô tả vai trò trong kiến trúc, và ghi chú về cách sử dụng đúng.

**SDK environment:** Dart `^3.11.5`

---

## Runtime dependencies

### Flutter SDK

| Package | Version | Role |
| --- | --- | --- |
| `flutter` | SDK | Framework chính |
| `flutter_localizations` | SDK | Hỗ trợ l10n đa ngôn ngữ (ARB pipeline) |

### UI / Material

| Package | Version | Role |
| --- | --- | --- |
| `cupertino_icons` | `^1.0.8` | Icon set iOS style (dùng hạn chế, ưu tiên Material icons) |
| `fl_chart` | `^1.2.0` | Biểu đồ học tập trên màn hình Progress (bar chart, line chart) |

### State management

| Package | Version | Role |
| --- | --- | --- |
| `flutter_riverpod` | `^3.3.1` | Riverpod v3 — DI + reactive state management |
| `hooks_riverpod` | `^3.3.1` | Riverpod tích hợp flutter_hooks |
| `riverpod_annotation` | `^4.0.2` | Annotation cho code generation (`@riverpod`) |
| `flutter_hooks` | `^0.21.3+1` | Flutter Hooks (useState, useEffect, useAnimationController…) — chỉ dùng trong presentation layer |

### Navigation

| Package | Version | Role |
| --- | --- | --- |
| `go_router` | `^17.2.1` | Declarative routing. Route constants: `RouteNames` / `RoutePaths`. Không được hardcode route string. |

### Database / Persistence

| Package | Version | Role |
| --- | --- | --- |
| `drift` | `^2.31.0` | SQLite ORM — Drift (formerly Moor). Toàn bộ domain data lưu ở đây. |
| `sqlite3_flutter_libs` | `^0.5.24` | Native SQLite3 binaries cho Android/iOS/Desktop |
| `shared_preferences` | `^2.5.5` | Key-value store cho: learning settings, TTS settings, cloud account link. KHÔNG dùng cho domain data. |
| `path_provider` | `^2.1.4` | Lấy app documents directory cho database file path |
| `path` | `^1.9.0` | Path manipulation utilities |

### Code generation (model / serialization)

| Package | Version | Role |
| --- | --- | --- |
| `freezed_annotation` | `^3.1.0` | Annotation cho `@freezed` sealed/data classes |
| `json_annotation` | `^4.11.0` | Annotation cho `@JsonSerializable` |

### Networking

| Package | Version | Role |
| --- | --- | --- |
| `http` | `^1.6.0` | HTTP client — dùng cho Google Drive AppData API calls |
| `web` | `^1.1.1` | Dart web interop package (Wasm/JS target) |

### Google Account / Drive sync

| Package | Version | Role |
| --- | --- | --- |
| `google_sign_in` | `^7.2.0` | Google OAuth sign-in (Android/iOS/Desktop) |
| `google_sign_in_web` | `^1.1.3` | Google OAuth sign-in (Web platform) |

### Text-To-Speech

| Package | Version | Role |
| --- | --- | --- |
| `flutter_tts` | `^4.2.5` | TTS engine wrapper — Korean + English playback |

### Notifications

| Package | Version | Role |
| --- | --- | --- |
| `flutter_local_notifications` | `^19.4.2` | Local push notifications (study reminders — Future feature) |
| `timezone` | `^0.10.0` | Timezone-aware scheduling cho local notifications |

### File / Import

| Package | Version | Role |
| --- | --- | --- |
| `file_picker` | `^11.0.2` | File picker dialog — import CSV từ device storage |

### Localization

| Package | Version | Role |
| --- | --- | --- |
| `intl` | `^0.20.2` | Date/number formatting, plural forms cho ARB localization |

### Logging / Observability

| Package | Version | Role |
| --- | --- | --- |
| `logging` | `^1.3.0` | Dart standard logging framework |
| `talker_flutter` | `^5.1.16` | Structured logging UI + talker core (debug overlay) |
| `talker_riverpod_logger` | `^5.1.16` | Riverpod observer → talker (log provider state changes) |
| `stack_trace` | `^1.12.1` | Human-readable stack traces (error reporting) |

---

## Dev dependencies

| Package | Version | Role |
| --- | --- | --- |
| `build_runner` | `^2.13.1` | Code generation runner (`dart run build_runner build`) |
| `drift_dev` | `^2.31.0` | Drift code generator (DAO, queries, schema) |
| `freezed` | `^3.2.5` | Freezed code generator cho `@freezed` classes |
| `json_serializable` | `^6.11.2` | JSON serialization code generator |
| `riverpod_generator` | `^4.0.0` | Riverpod annotation code generator |
| `riverpod_lint` | `3.1.3` | Riverpod lint rules — installed nhưng **chưa enable** trong `analysis_options.yaml` (xem ghi chú) |
| `flutter_launcher_icons` | `^0.14.4` | Generate app icon cho tất cả platforms |
| `flutter_native_splash` | `^2.4.7` | Generate native splash screen |
| `flutter_lints` | `^6.0.0` | Recommended Flutter lint rules |
| `riverpod` | `^3.2.1` | Riverpod core — khai báo tường minh để tests import `package:riverpod/misc.dart` |
| `flutter_test` | SDK | Flutter test framework |
| `integration_test` | SDK | Integration test framework |

---

## Ghi chú quan trọng

### riverpod_lint
Đã pin ở `3.1.3` (tương thích với `analyzer ^9` / `freezed 3.2.5` / `riverpod 3.2.1`).
**Chưa enable** trong `analysis_options.yaml` vì phiên bản này có vấn đề với `analysis_server_plugin` trên SDK hiện tại.
Enable khi migrate lên `analyzer ^12` / `riverpod 3.3.x` (`riverpod_lint 3.1.4+`).

### Fonts
- **Plus Jakarta Sans** — variable font (`PlusJakartaSans[wght].ttf`), weight 400 và 600.
- Khai báo trong `pubspec.yaml` flutter.fonts section.

### Code generation workflow
Bắt buộc chạy sau khi thay đổi annotated files:
```
dart run build_runner build --delete-conflicting-outputs
```
Các file generated KHÔNG được commit thủ công:
- `*.g.dart` — JSON/Riverpod generated
- `*.freezed.dart` — Freezed generated
- `lib/l10n/generated/**` — ARB generated

### Thêm dependency mới
Per `CLAUDE.md` Hard rules: **KHÔNG tự thêm dependency vào pubspec.yaml** mà không được user approve trước.
Stop và ask khi task yêu cầu package mới.

---

## Kiến trúc liên quan

- `docs/architecture/clean-architecture-contract.md` — dependency flow (domain ← data ← presentation)
- `docs/database/drift-guide.md` — cách dùng Drift DAO pattern
- `docs/state/state-management-contract.md` — Riverpod usage rules
- `docs/contracts/code-style.md` — naming, structure conventions
