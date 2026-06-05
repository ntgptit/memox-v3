import 'package:flutter/widgets.dart';

/// Responsive form factor derived from available width.
enum FormFactor { mobile, tablet, desktop }

/// Layout breakpoints and width conventions.
///
/// Breakpoints are 600dp (mobile/tablet) and 1024dp (tablet/desktop) per
/// `docs/ui-ux/ui-ux-contract.md`. [maxBodyWidth] (block S, 720) keeps reading
/// content from stretching too wide on large screens.
abstract final class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double desktop = 1024;

  /// Readable max content width (convention, not an enumerated token).
  static const double maxBodyWidth = 720;

  static FormFactor of(double width) {
    if (width >= desktop) {
      return FormFactor.desktop;
    }
    if (width >= mobile) {
      return FormFactor.tablet;
    }
    return FormFactor.mobile;
  }

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}

/// `context.formFactor` / width helpers for widgets.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  FormFactor get formFactor => Breakpoints.of(screenWidth);
  bool get isMobile => Breakpoints.isMobile(screenWidth);
  bool get isTablet => Breakpoints.isTablet(screenWidth);
  bool get isDesktop => Breakpoints.isDesktop(screenWidth);
}
