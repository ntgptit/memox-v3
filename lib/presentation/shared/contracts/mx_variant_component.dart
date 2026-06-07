/// Capability contract for a component that exposes a variant token.
library;

/// Shared component variant capability.
abstract interface class MxVariantComponent<T> {
  T get variant;
}
