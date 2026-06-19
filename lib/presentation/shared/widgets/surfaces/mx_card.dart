import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_shadows.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// The standard MemoX surface: a rounded, bordered card with a quiet shadow.
///
/// Purpose:
/// One consistent elevated surface for grouping content so the app never uses
/// raw `Card`/`Container` surfaces with ad-hoc radius, border, or shadow.
///
/// Use when:
/// Grouping related content or a tappable summary onto a single raised surface.
///
/// Do not use when:
/// You only need plain spacing or a full-bleed section — use layout widgets
/// instead of a card.
///
/// Category:
/// card
///
/// Public API:
/// - child: the card content.
/// - padding: inner padding (defaults to the card spacing token).
/// - onTap: optional tap handler; when set the card shows a shaped ink ripple.
///
/// States:
/// - tappable vs static, controlled by whether [onTap] is provided.
class MxCard extends StatelessWidget {
  const MxCard({required this.child, this.padding, this.onTap, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: MxRadius.cardAll,
        border: Border.all(color: colors.border),
        boxShadow: context.mxShadows.sm,
      ),
      child: MxTappable(
        onTap: onTap,
        borderRadius: MxRadius.cardAll,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(MxSpacing.card),
          child: child,
        ),
      ),
    );
  }
}
