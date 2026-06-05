import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

/// The sanctioned way to render an [AsyncValue] — MemoX forbids
/// `AsyncValue.when` directly (`memox.no_async_value_when`).
///
/// Lives in `shared/async` (an app-wiring-adjacent adapter), not in the
/// provider-free `shared/widgets` design-system layer. Retains previous [data]
/// while a watched provider refetches (search / sort / revision changes)
/// instead of blanking the screen (`memox.async_refetch_blanks_screen`); the
/// first load shows [loading].
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
