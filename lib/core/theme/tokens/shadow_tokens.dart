/// Shadow token scale.
///
/// Block Q of the design-token reference. Shadow values stay semantic so UI
/// surfaces can refer to the intended depth instead of hardcoding blur/spread.
abstract final class ShadowTokens {
  ShadowTokens._();

  static const double blurTiny = 3;
  static const double blurSm = 6;
  static const double blurPopover = 24;
  static const double blurDialog = 36;
  static const double blurModal = 40;

  static const double spreadHalo = 2;
  static const double spreadOutline = 4;
}
