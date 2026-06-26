import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// One clean text-typography spec for a kit component, read from the GENERATED
/// contract `tool/parity/contracts/component-contracts.json` (produced by
/// `tool/parity/gen_component_contract.mjs`). See `docs/design/visual-parity-plan.md`.
class ComponentTextSpec {
  const ComponentTextSpec({required this.fontSize, required this.fontWeight});

  /// Spec font size in logical pixels.
  final double fontSize;

  /// Spec font weight as a raw int (e.g. 700) — compare to `FontWeight.w700.value`.
  final int fontWeight;
}

/// Reads the single clean text font for [component] from the generated component
/// contract — the ONE source for kit spec font numbers, so a spec-gate test asserts
/// against it instead of a hardcoded constant.
///
/// FAILS LOUDLY (never returns a guess) when the component is missing or its status
/// is not `ok` — i.e. it is `needs-variant` (the font depends on a size/style variant)
/// or `no-font` (the text lives on a descendant). Centralizing a single number for
/// such a component would false-green on the wrong variant; the caller must resolve
/// the variant explicitly (a curated variant layer) before reading from here.
ComponentTextSpec componentTextSpec(String component) {
  final File file = File('tool/parity/contracts/component-contracts.json');
  final Map<String, dynamic> data =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final Object? entry = (data['components'] as Map<String, dynamic>)[component];
  if (entry is! Map) {
    fail(
      'component-contracts.json has no "$component". '
      'Run `node tool/parity/gen_component_contract.mjs --write`.',
    );
  }
  final Object? status = entry['status'];
  if (status != 'ok') {
    fail(
      'Component "$component" is "$status" (needs-variant / no-font / unknown) — it '
      'has no single clean font to centralize. Resolve the variant explicitly '
      '(curated variant layer) instead of reading a number from here.',
    );
  }
  // Guard every structural assumption with fail() (not raw casts) — a malformed/
  // stale contract must surface an actionable message, never a TypeError or a
  // garbage number.
  final Object? textRaw = entry['text'];
  if (textRaw is! Map) {
    fail(
      'Component "$component" is "ok" but has no "text" map — regenerate the '
      'contract: `node tool/parity/gen_component_contract.mjs --write`.',
    );
  }
  final Object? rawSize = textRaw['fontSize'];
  final Object? rawWeight = textRaw['fontWeight'];
  if (rawSize is! num || rawWeight is! int) {
    fail(
      'Component "$component" text spec is incomplete or malformed '
      '(fontSize=$rawSize, fontWeight=$rawWeight).',
    );
  }
  return ComponentTextSpec(fontSize: rawSize.toDouble(), fontWeight: rawWeight);
}
