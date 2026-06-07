/// Capability contract for a component that can be pressed.
library;

import 'package:flutter/material.dart';

/// Shared component action capability.
abstract interface class MxActionableComponent {
  VoidCallback? get onPressed;
}
