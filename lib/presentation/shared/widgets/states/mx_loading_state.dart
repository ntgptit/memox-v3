import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// Centered loading panel: a progress spinner with an optional caption.
///
/// Purpose:
/// The single in-progress surface for any screen fetching its initial data, so
/// loading looks the same everywhere and never blocks the UI with a bespoke
/// spinner.
///
/// Use when:
/// A screen or section is loading its first data and there is nothing
/// meaningful to show yet.
///
/// Do not use when:
/// Refreshing content already on screen (keep the content and show inline
/// progress instead).
///
/// Category:
/// feedback
///
/// Public API:
/// - message: optional caption under the spinner; pass already-localized copy
///   or omit for a bare spinner.
class MxLoadingState extends StatelessWidget {
  const MxLoadingState({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    final String? message = this.message;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          if (message != null) ...<Widget>[
            const SizedBox(height: MxSpacing.space4),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
