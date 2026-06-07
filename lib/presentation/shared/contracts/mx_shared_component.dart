/// Capability contract for a shared MemoX component.
library;

import 'mx_component_type.dart';

/// Common metadata that guard rules can inspect on shared components.
abstract interface class MxSharedComponent {
  String get componentName;
  MxComponentType get componentType;
}
