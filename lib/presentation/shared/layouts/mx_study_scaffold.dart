import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_study_top_bar.dart';

/// Scaffold for the five study modes — [MxStudyTopBar] chrome, width-capped
/// body, and an optional pinned bottom action area (e.g. Check / Continue).
///
/// `docs/business/study/study-flow.md`: study chrome is the close + mode badge
/// + progress bar; the [topBar.accent] recolors per mode.
class MxStudyScaffold extends StatelessWidget {
  const MxStudyScaffold({
    required this.topBar,
    required this.body,
    this.bottomAction,
    super.key,
  });

  final MxStudyTopBar topBar;
  final Widget body;
  final Widget? bottomAction;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: topBar,
    body: SafeArea(
      top: false,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.lg),
              child: MxContentShell(child: body),
            ),
          ),
          if (bottomAction != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.lg,
                0,
                SpacingTokens.lg,
                SpacingTokens.md,
              ),
              child: MxContentShell(child: bottomAction!),
            ),
        ],
      ),
    ),
  );
}
