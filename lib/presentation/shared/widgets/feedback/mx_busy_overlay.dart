import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// A blocking busy overlay — a centered spinner + label card over a dim scrim
/// (kit `BusyOverlay`).
///
/// Purpose:
/// One owner for the "operation in progress" modal so long-running mutations
/// (rename/merge/delete a tag, etc.) show a consistent blocking spinner instead
/// of ad-hoc `showDialog(CircularProgressIndicator)` calls.
///
/// Use when:
/// Awaiting a short, non-cancellable mutation that should block interaction.
///
/// Category:
/// feedback
///
/// Public API:
/// - label: the in-progress message (e.g. "Merging tags…").
class MxBusyOverlay extends StatelessWidget {
  const MxBusyOverlay({required this.label, super.key});

  /// The in-progress message shown beside the spinner.
  final String label;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    // Transparent — the host (e.g. `showDialog`'s barrier) provides the scrim.
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.space6,
            vertical: MxSpacing.space5,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: MxRadius.lgAll,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: MxSpacing.space5,
                height: MxSpacing.space5,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colors.accent,
                ),
              ),
              const SizedBox(width: MxSpacing.space4),
              MxText(label, role: MxTextRole.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
