import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Walks the pumped widget tree and writes the global rect of every
/// content-bearing render box (text/icon glyphs, images, filled boxes) to
/// `test/_parity_dump/<name>.json`, on the same 390×780 logical frame the UI-kit
/// specs use (pump with [kGoldenSurface] + devicePixelRatio 1.0 first).
///
/// This is the deterministic, theme-independent input for the structural parity
/// inventory (`tool/parity/structural_inventory.mjs`): "for each node the spec
/// declares, is anything actually rendered in its box?" — geometry, not pixels,
/// so it catches a MISSING node even on a dark theme where pixel colour ≈
/// background.
Future<void> dumpStructure(WidgetTester tester, String name) async {
  final List<Map<String, Object?>> nodes = <Map<String, Object?>>[];
  for (final Element el in tester.allElements) {
    final RenderObject? ro = el.renderObject;
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) continue;
    final Widget w = el.widget;
    String? kind;
    String? text;
    if (w is RichText) {
      kind = 'text';
      text = w.text.toPlainText();
    } else if (w is Text) {
      kind = 'text';
      text = w.data;
    } else if (w is Image || w is RawImage) {
      kind = 'image';
    } else if (w is DecoratedBox ||
        w is ColoredBox ||
        w is PhysicalModel ||
        w is PhysicalShape) {
      kind = 'fill';
    }
    if (kind == null) continue;
    final Size s = ro.size;
    if (s.width < 1 || s.height < 1) continue;
    final Offset o = ro.localToGlobal(Offset.zero);
    nodes.add(<String, Object?>{
      'kind': kind,
      if (text != null && text.trim().isNotEmpty) 'text': text.trim(),
      'x': o.dx.round(),
      'y': o.dy.round(),
      'w': s.width.round(),
      'h': s.height.round(),
    });
  }
  nodes.sort((a, b) {
    final int dy = (a['y']! as int).compareTo(b['y']! as int);
    return dy != 0 ? dy : (a['x']! as int).compareTo(b['x']! as int);
  });
  final Directory dir = Directory('test/_parity_dump');
  dir.createSync(recursive: true);
  File(
    '${dir.path}/$name.json',
  ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(nodes));
}
