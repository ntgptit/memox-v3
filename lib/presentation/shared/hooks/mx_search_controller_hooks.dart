import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/presentation/shared/hooks/mx_text_controller_hooks.dart';

/// Controller state for local presentation search fields.
final class MxSearchControllerState {
  const MxSearchControllerState({
    required this.controller,
    required this.text,
    required this.hasText,
  });

  final TextEditingController controller;
  final String text;
  final bool hasText;
}

/// Clears a controller when the owner-provided text is cleared externally.
///
/// This only reacts to the empty-string transition and never calls provider or
/// repository methods.
void useMxClearControllerWhenExternalTextCleared({
  required TextEditingController controller,
  required String externalText,
  required bool enabled,
}) {
  useEffect(() {
    if (!enabled) {
      return null;
    }

    if (externalText.isEmpty && controller.text.isNotEmpty) {
      controller.clear();
    }
    return null;
  }, <Object?>[controller, externalText, enabled]);
}

/// Creates a local search controller and optionally mirrors external clears.
MxSearchControllerState useMxSearchController({
  String externalText = '',
  bool clearWhenExternalTextEmpty = false,
}) {
  final TextEditingController controller = useTextEditingController(
    text: externalText,
  );
  final String text = useMxTextValue(controller);
  useMxClearControllerWhenExternalTextCleared(
    controller: controller,
    externalText: externalText,
    enabled: clearWhenExternalTextEmpty,
  );
  return MxSearchControllerState(
    controller: controller,
    text: text,
    hasText: text.isNotEmpty,
  );
}
