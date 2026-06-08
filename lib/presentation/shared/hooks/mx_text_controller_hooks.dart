import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/core/utils/string_utils.dart';

/// Text controller state used by local presentation hooks.
final class MxTextSubmitState {
  const MxTextSubmitState({
    required this.controller,
    required this.text,
    required this.trimmedText,
    required this.canSubmit,
  });

  final TextEditingController controller;
  final String text;
  final String trimmedText;
  final bool canSubmit;
}

/// Subscribes to a controller's current text without leaking the controller
/// ownership into the caller.
String useMxTextValue(TextEditingController controller) {
  useListenable(controller);
  return controller.text;
}

/// Creates a local text controller and derives submit state from its trimmed
/// value.
MxTextSubmitState useMxTextSubmitState({
  String initialText = '',
  bool Function(String trimmedText)? canSubmit,
}) {
  final TextEditingController controller = useTextEditingController(
    text: initialText,
  );
  final String text = useMxTextValue(controller);
  final String trimmedText = StringUtils.trimmed(text);
  return MxTextSubmitState(
    controller: controller,
    text: text,
    trimmedText: trimmedText,
    canSubmit: canSubmit?.call(trimmedText) ?? trimmedText.isNotEmpty,
  );
}
