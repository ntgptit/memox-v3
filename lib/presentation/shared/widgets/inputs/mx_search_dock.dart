import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_stroke.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';

/// A bottom-anchored search bar (the kit `.search-dock`).
///
/// Purpose:
/// One owner for the thumb-reachable search bar that sits at the FOOT of a
/// screen (not the top app bar) so the input stays within reach on tall phones
/// (design redesign). Wraps the shared [MxSearchField] and an optional trailing
/// action on a bordered surface strip.
///
/// Use when:
/// A screen's primary search input should live at the bottom (e.g. global
/// Search). Sits above the app shell's bottom nav, which owns the home-indicator
/// safe area.
///
/// Do not use when:
/// Searching inside a scoped list via an app-bar field — that is the in-place
/// search-mode app bar, not this dock.
///
/// Category:
/// input
///
/// Public API:
/// - hintText / onChanged / onSubmitted / autofocus: forwarded to the inner
///   [MxSearchField] (which owns its controller; callers drive state from
///   [onChanged], so the dock exposes no controller).
/// - trailing: optional trailing action (e.g. a filter button).
class MxSearchDock extends StatelessWidget {
  const MxSearchDock({
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.trailing,
    super.key,
  });

  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final Widget? trailing;

  /// Minimum dock height — the kit `--memox-size-search-dock` (64). Not part of
  /// the spacing scale, so it is named here rather than read from `MxSpacing`.
  static const double minHeight = 64;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final Widget? trailing = this.trailing;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.divider, width: MxStroke.hairline),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.screen,
            vertical: MxSpacing.space3,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: MxSearchField(
                  hintText: hintText,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  autofocus: autofocus,
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: MxSpacing.space2),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
