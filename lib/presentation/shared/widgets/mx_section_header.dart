import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// A section header — the kit `section-head`: a short section label, optionally
/// with a trailing action, sitting above a card or list.
///
/// Purpose:
/// One section-label primitive (mirrors the kit `SectionHead`, used consistently
/// across the kit) so every section title shares the same role and the same
/// title/trailing row layout, instead of ad-hoc `MxText`s per screen.
///
/// Use when:
/// Labelling a content section (a list card, a chart, a settings group) with a
/// short title — optionally with a trailing link/control on the same row.
///
/// Do not use when:
/// The text is body copy or a field label — use [MxText] directly.
///
/// Category:
/// display
///
/// Public API:
/// - title: the section label (rendered in [MxTextRole.titleMedium], the kit's
///   16px section-title role).
/// - trailing: an optional widget pinned to the end of the row (the kit's
///   `flex:row justify:between` — e.g. a "See all" link). Defaults to none.
class MxSectionHeader extends StatelessWidget {
  const MxSectionHeader({required this.title, this.trailing, super.key});

  /// The section label.
  final String title;

  /// Optional trailing widget pinned to the end of the header row.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Widget? trailing = this.trailing;
    return Row(
      children: <Widget>[
        Expanded(child: MxText(title, role: MxTextRole.titleMedium)),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: MxSpacing.space3),
          trailing,
        ],
      ],
    );
  }
}
