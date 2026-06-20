import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';

/// The folder color/icon token catalog — the single source of truth that maps
/// the opaque `folders.color` / `folders.icon` token strings (WBS 2.22.1) to a
/// concrete [Color] / [IconData].
///
/// Tokens are stored as design-system-stable strings (never the rendered value)
/// so the persisted choice survives theme changes; `null` means "no custom
/// token" and falls back to the theme accent / default folder glyph. The ordered
/// `values` lists drive the create/edit pickers
/// (`docs/design/screens/library-overview.visual-contract.md` §`03g`).

/// The eight folder tint tokens — the existing `note-*` palette
/// (`lib/core/theme/mx_colors.dart`). `null` → theme [MxColors.accent].
enum FolderColorToken {
  yellow('yellow'),
  amber('amber'),
  green('green'),
  teal('teal'),
  blue('blue'),
  violet('violet'),
  pink('pink'),
  clay('clay');

  const FolderColorToken(this.token);

  /// The opaque string persisted in `folders.color`.
  final String token;

  /// Parses a stored token, or `null` when absent/unknown (→ accent fallback).
  static FolderColorToken? parse(String? token) {
    if (token == null) return null;
    for (final FolderColorToken c in values) {
      if (c.token == token) return c;
    }
    return null;
  }

  /// Resolves this token against the active theme palette.
  Color resolve(MxColors colors) => switch (this) {
    FolderColorToken.yellow => colors.noteYellow,
    FolderColorToken.amber => colors.noteAmber,
    FolderColorToken.green => colors.noteGreen,
    FolderColorToken.teal => colors.noteTeal,
    FolderColorToken.blue => colors.noteBlue,
    FolderColorToken.violet => colors.noteViolet,
    FolderColorToken.pink => colors.notePink,
    FolderColorToken.clay => colors.noteClay,
  };
}

/// The twelve folder icon tokens. `null`/unknown → [Icons.folder_outlined].
enum FolderIconToken {
  folder('folder', Icons.folder_outlined),
  translate('translate', Icons.translate),
  science('science', Icons.science_outlined),
  accountBalance('account_balance', Icons.account_balance_outlined),
  work('work', Icons.work_outline),
  menuBook('menu_book', Icons.menu_book_outlined),
  public('public', Icons.public),
  calculate('calculate', Icons.calculate_outlined),
  musicNote('music_note', Icons.music_note_outlined),
  palette('palette', Icons.palette_outlined),
  sportsEsports('sports_esports', Icons.sports_esports_outlined),
  favorite('favorite', Icons.favorite_outline);

  const FolderIconToken(this.token, this.icon);

  /// The opaque string persisted in `folders.icon`.
  final String token;

  /// The glyph this token renders.
  final IconData icon;

  /// Parses a stored token, or `null` when absent/unknown (→ folder fallback).
  static FolderIconToken? parse(String? token) {
    if (token == null) return null;
    for (final FolderIconToken i in values) {
      if (i.token == token) return i;
    }
    return null;
  }
}

/// Resolves a stored color token to a tint color, defaulting to the accent.
Color folderTint(MxColors colors, String? colorToken) =>
    FolderColorToken.parse(colorToken)?.resolve(colors) ?? colors.accent;

/// Resolves a stored icon token to a glyph, defaulting to the folder glyph.
IconData folderGlyph(String? iconToken) =>
    FolderIconToken.parse(iconToken)?.icon ?? Icons.folder_outlined;
