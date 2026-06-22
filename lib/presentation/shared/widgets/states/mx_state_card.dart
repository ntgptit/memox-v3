import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Hosts a centered state panel ([MxEmptyState] / [MxErrorState] /
/// [MxNoResultsState]) inside the screen's grouped content card, anchored at the
/// top of the scroll body.
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
/// The mock shows a full-screen, vertically-centered state (e.g. a study-session
/// screen) — pass the `Mx*State` panel directly instead.
///
/// Category:
/// feedback
///
/// The card padding is zeroed so the panel's own inset (`MxSpacing.space6` = 24)
/// is the card's inner pad, matching the kit card pad 24 (the panel keeps a
/// single source for its inset).
class MxStateCard extends StatelessWidget {
  const MxStateCard({required this.child, super.key});

  /// The state panel to host (an `MxEmptyState` / `MxErrorState` / etc.).
  final Widget child;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
    children: <Widget>[MxCard(padding: EdgeInsets.zero, child: child)],
  );
}
