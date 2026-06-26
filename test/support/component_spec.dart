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

/// Resolves the text spec for a specific size [variant] of [component] (e.g.
/// `'medium'` / `'compact'`) from the HAND-CURATED `tool/parity/component-variants.json`.
///
/// The generator records a component's DISTINCT observed fonts but can't label which
/// is which variant; the curated file does. To stop a curated number from drifting
/// away from the spec, this CROSS-CHECKS the curated `(fontSize, fontWeight)` against
/// the generator's observed pairs for that component — a curated value that is not a
/// real spec value FAILS LOUD (no fabrication). Also fails loud on a missing
/// component/variant.
ComponentTextSpec componentVariantTextSpec(String component, String variant) {
  final File variantsFile = File('tool/parity/component-variants.json');
  final Map<String, dynamic> variants =
      jsonDecode(variantsFile.readAsStringSync()) as Map<String, dynamic>;
  final Object? comp = variants[component];
  if (comp is! Map) {
    fail(
      'component-variants.json has no "$component" — add a curated variant map.',
    );
  }
  final Object? v = comp[variant];
  if (v is! Map) {
    fail('component-variants.json "$component" has no variant "$variant".');
  }
  final Object? rawSize = v['fontSize'];
  final Object? rawWeight = v['fontWeight'];
  if (rawSize is! num || rawWeight is! int) {
    fail(
      'Curated "$component"/"$variant" is malformed (fontSize=$rawSize, fontWeight=$rawWeight).',
    );
  }
  final double fontSize = rawSize.toDouble();

  // Cross-check against the GENERATED observed pairs — the curated number must be a
  // real spec value the generator extracted, never an invented one.
  final List<({double fontSize, int fontWeight})> observed = _observedPairs(
    component,
  );
  final bool isReal = observed.any(
    (p) => p.fontSize == fontSize && p.fontWeight == rawWeight,
  );
  if (!isReal) {
    fail(
      'Curated "$component"/"$variant" = $fontSize/$rawWeight is NOT among the '
      'spec-extracted observed pairs $observed — fix the curation or regenerate the '
      'contract; a curated number must be a real spec value.',
    );
  }
  return ComponentTextSpec(fontSize: fontSize, fontWeight: rawWeight);
}

/// The generator's observed (size, weight) pairs for [component]: the single `text`
/// pair for an `ok` component, or the `observed` array for `needs-variant`.
List<({double fontSize, int fontWeight})> _observedPairs(String component) {
  final File file = File('tool/parity/contracts/component-contracts.json');
  final Map<String, dynamic> data =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final Object? entry = (data['components'] as Map<String, dynamic>)[component];
  if (entry is! Map) {
    fail(
      'component-contracts.json has no "$component" to cross-check against.',
    );
  }
  final List<Object?> raw = entry['status'] == 'ok'
      ? <Object?>[entry['text']]
      : (entry['observed'] as List<Object?>? ?? <Object?>[]);
  final List<({double fontSize, int fontWeight})> pairs =
      <({double fontSize, int fontWeight})>[];
  for (final Object? p in raw) {
    if (p is! Map) continue;
    // Guard the fields with fail() (not raw casts) — a malformed observed entry
    // must surface an actionable message, not a runtime TypeError.
    final Object? size = p['fontSize'];
    final Object? weight = p['fontWeight'];
    if (size is! num || weight is! int) {
      fail(
        'component-contracts.json "$component" has a malformed observed pair '
        '(fontSize=$size, fontWeight=$weight) — regenerate the contract.',
      );
    }
    pairs.add((fontSize: size.toDouble(), fontWeight: weight));
  }
  return pairs;
}
