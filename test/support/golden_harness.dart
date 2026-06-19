import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';

/// Standard surface for widget kit goldens: a 390×780 phone window.
const Size kGoldenSurface = Size(390, 780);

/// Pumps [child] inside a themed [MaterialApp] on a fixed [kGoldenSurface] for
/// golden capture. Uses a single frame (no `pumpAndSettle`) so widgets with
/// indeterminate animations (e.g. a progress spinner) stay deterministic.
///
/// Resets the test view on teardown. Pass [brightness] to capture light/dark.
Future<void> pumpForGolden(
  WidgetTester tester,
  Widget child, {
  required Brightness brightness,
}) async {
  tester.view.physicalSize = kGoldenSurface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
      home: Scaffold(body: child),
    ),
  );
  await tester.pump();
}

/// Pumps [child] in a themed [MaterialApp] for behaviour/semantics tests
/// (settles animations). Defaults to the light theme.
Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
      home: Scaffold(body: child),
    ),
  );
  await tester.pump();
}
