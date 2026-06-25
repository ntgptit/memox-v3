import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Spec-driven parity contract (identity-based, NOT geometry).
///
/// Each screen declares the elements the DESIGN requires as a map of
/// label → [Finder] (by type / icon / text — position-independent). This asserts
/// every one is actually rendered; if the FE hasn't implemented an element, the
/// test fails with the FULL list of what's missing — so "FE chưa implement đủ →
/// test đỏ", which a golden image (FE-vs-FE regression) can never reveal.
///
/// The required list is the contract derived from the current authoritative
/// design (the kit spec where it is current; the redesign source where the kit is
/// stale). Documented intentional omissions belong in
/// `tool/parity/intent-ledger.json`, not here.
void expectParityContract(String screen, Map<String, Finder> required) {
  final List<String> missing = <String>[
    for (final MapEntry<String, Finder> e in required.entries)
      if (e.value.evaluate().isEmpty) e.key,
  ];
  expect(
    missing,
    isEmpty,
    reason:
        'Parity contract "$screen": ${missing.length}/${required.length} required '
        'element(s) NOT rendered → FE incomplete vs the design: '
        '${missing.join(', ')}',
  );
}

/// The required `mx-node:<id>` keys for [screen] from the GENERATED parity
/// contract (`tool/parity/contracts/contracts.json`, produced by
/// `tool/parity/gen_contract.mjs` from the kit `data-mx-node` ids — the single
/// contract source). Fails when the screen has no entry (its kit nodes carry no
/// `data-mx-node`). Tests run from the repo root, so the file is read relative to
/// the cwd (same as `test/flutter_test_config.dart` reading bundled fonts).
List<String> generatedContractKeys(String screen) {
  final File file = File('tool/parity/contracts/contracts.json');
  final Map<String, dynamic> data =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final Map<String, dynamic> contracts =
      data['contracts'] as Map<String, dynamic>;
  final Object? entry = contracts[screen];
  if (entry is! List) {
    fail(
      'Generated parity contract has no "$screen" entry. Add data-mx-node to the '
      'kit screen, re-export specs, then run `node tool/parity/gen_contract.mjs`.',
    );
  }
  return <String>[for (final Object? e in entry) (e as Map)['key'] as String];
}

/// Asserts every required key for [screen] from the GENERATED contract is
/// rendered (`find.byKey(ValueKey('mx-node:<id>'))`). The required list comes
/// from `contracts.json` (no hand-coded list, no second format); if the FE drops
/// a tagged node its key is absent → this fails listing it.
void expectGeneratedParityContract(String screen) {
  final List<String> keys = generatedContractKeys(screen);
  expect(
    keys,
    isNotEmpty,
    reason: 'Generated parity contract "$screen" has no required keys.',
  );
  final List<String> missing = <String>[
    for (final String key in keys)
      if (find.byKey(ValueKey<String>(key)).evaluate().isEmpty) key,
  ];
  expect(
    missing,
    isEmpty,
    reason:
        'Parity contract "$screen": ${missing.length}/${keys.length} required '
        'key(s) NOT rendered → FE incomplete vs the generated contract: '
        '${missing.join(', ')}',
  );
}

/// Kit components the design intentionally allows to be realized by more than one
/// Flutter class. The kit names a single visual ROLE; the FE may realize it with a
/// sibling where the context requires it. Keyed by kit component → the set of
/// accepted Flutter classes. A raw/other widget still fails (it is in neither set).
const Map<String, Set<String>> _bindingRealizations = <String, Set<String>>{
  // The kit has ONE visual "search dock" (mx:MxSearchDock). The FE realizes it with
  // the global MxSearchDock, or — where the search is scoped (deck / tag) and must
  // host an EXTERNAL controller that plain MxSearchDock cannot — with the sibling
  // MxScopedSearchDock. Both are real docks, so either satisfies the kit's
  // search-dock binding. 05-library-search uses the global one; 06-flashcard-list
  // and 11-tag-management use the scoped one. Centralized here instead of a
  // per-test alias so the accepted-variant decision lives in one reviewed place.
  'MxSearchDock': <String>{'MxSearchDock', 'MxScopedSearchDock'},
};

/// Asserts that every keyed node in [screen]'s GENERATED binding contract
/// (`tool/parity/contracts/bindings.json`, produced by `tool/parity/gen_bindings.mjs`)
/// that names a concrete kit component actually renders that component in its
/// keyed subtree — i.e. the FE realized the kit's component choice. This catches
/// a design-system bypass the presence contract cannot (e.g. a raw `Container`
/// where the kit said `MxCard`: the key is present, but the component is wrong).
///
/// Nodes whose `component` is `?`/absent are skipped (the kit had no suggestion).
/// [aliases] maps a kit component name to the real class when the kit name drifts
/// (e.g. `MxBottomNavigationBar` → `MxBottomNav`). Documented FE↔mock divergences
/// (intent-ledger) are passed via [exempt] as `mx-node:<id>` keys. Pump the screen
/// first, then call this (same harness as [expectGeneratedParityContract]).
void expectGeneratedBindingContract(
  String screen, {
  Map<String, String> aliases = const <String, String>{},
  Set<String> exempt = const <String>{},
}) {
  final File file = File('tool/parity/contracts/bindings.json');
  final Map<String, dynamic> data =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final Object? entry = (data['bindings'] as Map<String, dynamic>)[screen];
  if (entry is! List) {
    fail(
      'Generated binding contract has no "$screen" entry. '
      'Run `node tool/parity/gen_bindings.mjs`.',
    );
  }
  final List<String> problems = <String>[];
  for (final Object? raw in entry) {
    final Map<String, dynamic> node = raw as Map<String, dynamic>;
    final String key = node['key'] as String;
    final Object? comp = node['component'];
    if (comp == null || comp == '?' || exempt.contains(key)) {
      continue;
    }
    final String expected = aliases[comp] ?? comp as String;
    final Set<String> accepted =
        _bindingRealizations[expected] ?? <String>{expected};
    final Finder keyed = find.byKey(ValueKey<String>(key));
    if (keyed.evaluate().isEmpty) {
      continue; // presence is expectGeneratedParityContract's job, not this one.
    }
    final bool realized = find
        .descendant(
          of: keyed,
          matching: find.byWidgetPredicate(
            (Widget w) => accepted.contains(w.runtimeType.toString()),
          ),
          matchRoot: true,
        )
        .evaluate()
        .isNotEmpty;
    if (!realized) {
      problems.add(
        '$key → expected kit component ${accepted.length == 1 ? expected : accepted.join(' or ')}, '
        'keyed widget is ${keyed.evaluate().first.widget.runtimeType}',
      );
    }
  }
  expect(
    problems,
    isEmpty,
    reason:
        'Binding contract "$screen": ${problems.length} node(s) did not realize '
        'the kit component → design-system bypass: ${problems.join('; ')}',
  );
}
