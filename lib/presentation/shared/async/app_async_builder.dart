import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

/// The sanctioned way to render an [AsyncValue] — MemoX forbids
/// `AsyncValue.when` directly in feature code
/// (`memox.state_management.use_app_async_builder`).
///
/// Retains the previous [data] while a watched provider refetches (search /
/// sort / revision changes) instead of blanking the screen; the first load
/// shows [loading]. WBS 1.2.7.
///
/// Purpose:
/// Provides a reusable MemoX async surface that stays aligned with the design
/// system.
///
/// Use when:
/// A screen renders a provider's `AsyncValue`.
///
/// Do not use when:
/// You need bespoke partial-load UI not expressible via the data/loading/error
/// slots.
///
/// Category:
/// async
///
/// Public API:
/// - value: the watched `AsyncValue`.
/// - data: builds the loaded UI.
/// - loading: optional first-load builder (defaults to `MxLoadingState`).
/// - error: optional error builder.
class AppAsyncBuilder<T> extends StatelessWidget {
  const AppAsyncBuilder({
    required this.value,
    required this.data,
    this.loading,
    this.error,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final WidgetBuilder? loading;
  final Widget Function(Object error, StackTrace? stackTrace)? error;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<T> v = value;
    // Retain data through refetch: as long as we have a value, show it.
    if (v.hasValue) {
      return data(v.requireValue);
    }
    if (v.hasError) {
      final Widget Function(Object, StackTrace?) onError =
          error ?? (Object e, StackTrace? s) => const SizedBox.shrink();
      return onError(v.error!, v.stackTrace);
    }
    final WidgetBuilder onLoading =
        loading ?? (BuildContext _) => const MxLoadingState();
    return onLoading(context);
  }
}
