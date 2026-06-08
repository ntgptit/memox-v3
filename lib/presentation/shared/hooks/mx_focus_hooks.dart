import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Requests focus after the current frame when [trigger] changes.
///
/// Callers must provide an explicit trigger object; passing `null` leaves the
/// hook inert.
void useMxRequestFocusAfterFrame({
  required FocusNode focusNode,
  required Object? trigger,
}) {
  final BuildContext context = useContext();
  useEffect(() {
    if (trigger == null) {
      return null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      focusNode.requestFocus();
    });
    return null;
  }, <Object?>[trigger]);
}
