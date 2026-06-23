import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Hosts a state panel ([MxEmptyState] / [MxErrorState] / [MxNoResultsState])
/// inside the screen's grouped content card — top-anchored by default, or
/// vertically centered via [centered].
///
/// Purpose:
/// Several content screens (Library overview, Folder detail) render their
/// empty / error message *inside the same card the loaded list uses*, sitting at
/// the top of the body — not as a bare, full-height–centered panel. This is the
/// one owner for that composition so screens don't each re-wrap a panel in an
/// ad-hoc `ListView` + `MxCard` (which would drift).
///
/// Use when:
/// A content screen whose mock shows the empty/error panel inside the content
/// card needs to host an `Mx*State` panel.
///
/// Do not use when:
/// The mock shows a state panel WITHOUT card chrome (e.g. a full-screen
/// study-session screen) — pass the `Mx*State` panel directly. For a
/// card-wrapped centered state, use [centered] = true instead. The parent must
/// supply a finite height (e.g. via `Expanded`) when [centered] is true.
///
/// Category:
/// feedback
///
/// The card padding is zeroed so the panel's own inset (`MxSpacing.space6` = 24)
/// is the card's inner pad, matching the kit card pad 24 (the panel keeps a
/// single source for its inset).
///
/// Vertical anchoring follows the kit per screen:
/// - [centered] = false (default): card sits at the TOP of the scroll body
///   (kit Library overview `03` / Folder detail `04` empty/error).
/// - [centered] = true: card is vertically CENTERED in the body, scrolling only
///   when it overflows (kit Flashcard list `06` empty/error).
class MxStateCard extends StatelessWidget {
  const MxStateCard({required this.child, this.centered = false, super.key});

  /// The state panel to host (an `MxEmptyState` / `MxErrorState` / etc.).
  final Widget child;

  /// Whether the card is vertically centered (true) or top-anchored (false).
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final Widget card = MxCard(padding: EdgeInsets.zero, child: child);
    if (!centered) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
        children: <Widget>[card],
      );
    }
    // Centered, but scroll-safe: the card centers when it fits and scrolls when
    // it is taller than the viewport (narrow height / large textScaleFactor).
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - MxSpacing.space3 * 2,
              ),
              child: Center(child: card),
            ),
          ),
    );
  }
}
