import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Async renderer for push-from-list / refetch-heavy screens.
///
/// Lives in `shared/async` (app-wiring-adjacent), not the provider-free
/// `shared/widgets` layer. Distinct from `AppAsyncBuilder` in that the
/// **first** load renders a [skeletonBuilder] (not a high-contrast spinner) —
/// required by `memox.retained_async_state_requires_skeleton` — and previous
/// [data] is retained while a watched provider refetches
/// (`memox.async_refetch_blanks_screen`).
///
/// Purpose:
/// Provides a reusable MemoX async widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared async surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - value: public configuration.
/// - skeletonBuilder: public property.
/// Category:
/// async
class MxRetainedAsyncState<T> extends StatelessWidget {
  const MxRetainedAsyncState({
    required this.value,
    required this.data,
    required this.skeletonBuilder,
    required this.errorBuilder,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  /// Rendered only on the very first load (no value yet).
  final WidgetBuilder skeletonBuilder;

  /// Rendered when the first load fails (no value to retain).
  final Widget Function(Object error, StackTrace? stackTrace) errorBuilder;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<T> v = value;
    if (v.hasValue) {
      return data(v.requireValue);
    }
    if (v.hasError) {
      return errorBuilder(v.error!, v.stackTrace);
    }
    return skeletonBuilder(context);
  }
}
