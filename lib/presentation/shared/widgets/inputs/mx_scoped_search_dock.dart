import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_stroke.dart';

/// The flat, full-bleed bottom search-dock chrome (the kit `.search-dock`) that
/// hosts a **caller-provided** scoped search field.
///
/// Purpose:
/// One owner for the search-mode bottom bar that wraps a scope-local search
/// field whose controller is provider-synced (so a no-results `Clear` can reset
/// it) — a top hairline over a surface fill, with the home-indicator safe area
/// reserved. Mounted in the `Scaffold.bottomNavigationBar` slot (via `MxScaffold`)
/// so it renders flat and full-bleed, not as rounded/elevated BottomSheet chrome.
///
/// Use when:
/// A scoped list (Library folders, folder-detail decks) enters search mode and
/// its provider-bound field should pin to the foot while the regular app bar
/// stays above. Pass the field as [child].
///
/// Do not use when:
/// The dock owns its own field and drives state purely from `onChanged` (no
/// external controller) — use [MxSearchDock] instead; it cannot host a
/// provider-synced controller.
///
/// Category:
/// input
///
/// Public API:
/// - child: the scoped search field to host (typically autofocused).
class MxScopedSearchDock extends StatelessWidget {
  const MxScopedSearchDock({required this.child, super.key});

  /// The scoped search field hosted in the dock.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.divider, width: MxStroke.hairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.screen,
            vertical: MxSpacing.space3,
          ),
          child: child,
        ),
      ),
    );
  }
}
