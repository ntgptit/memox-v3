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
/// - elevated: whether the card carries the quiet `sm` shadow (default true).
///   Pass `false` for a flat, border-only surface (a quiet "refer/navigate"
///   affordance such as a shortcut row), per the design system's
///   prefer-a-border-over-a-shadow guidance.
///
/// States:
/// - tappable vs static, controlled by whether [onTap] is provided.
class MxCard extends StatelessWidget {
  const MxCard({
    required this.child,
    this.padding,
    this.onTap,
    this.elevated = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: MxRadius.cardAll,
        border: Border.all(color: colors.border),
        boxShadow: elevated ? context.mxShadows.sm : null,
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
