import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

/// The sanctioned way to render an [AsyncValue] — MemoX forbids
/// `AsyncValue.when` directly (`memox.state_management.use_app_async_builder`).
///
/// Lives in `shared/async` (an app-wiring-adjacent adapter), not in the
/// provider-free `shared/widgets` design-system layer. Retains previous [data]
/// while a watched provider refetches (search / sort / revision changes)
/// instead of blanking the screen (`memox.performance.no_refetch_blank_screen`); the
/// first load shows [loading].
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
/// - loading: public property.
/// Category:
/// async
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
    return (loading ?? (BuildContext _) => const MxLoadingState())(context);
  }
}
