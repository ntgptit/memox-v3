import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';

/// Stable accent seed for folder tiles so sibling rows feel visually distinct.
Color folderAccentFor(Object folderId) {
  final List<Color> accents = <Color>[
    ColorTokens.seedIndigo,
    ColorTokens.seedTeal,
    ColorTokens.seedAmber,
    ColorTokens.seedViolet,
    ColorTokens.seedRose,
    ColorTokens.seedSage,
  ];
  final String key = folderId.toString();
  final int hash = key.codeUnits.fold<int>(
    0,
    (int value, int codeUnit) => ((value * 31) + codeUnit) & 0x1fffffff,
  );
  return accents[hash % accents.length];
}
