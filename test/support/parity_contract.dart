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
