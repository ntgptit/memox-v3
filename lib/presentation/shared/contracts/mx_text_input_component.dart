/// Capability contract for a text input component.
library;

import 'package:flutter/material.dart';

/// Shared component text-input capability.
abstract interface class MxTextInputComponent {
  TextEditingController? get controller;
  ValueChanged<String>? get onChanged;
}
