import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// The active study session (mock `12`/`13`) — **placeholder shell (WP-SR1a)**.
///
/// The entry gate `pushReplacement`s here once a session is created/resumed. The
/// real review surface (✕ + blue progress bar + the both-sides swipe card) lands
/// in WP-SR2/WP-SR3; for now this renders the immersive shell (✕ exit) over a
/// placeholder so the route + navigation are wired end-to-end. WBS 4.5.3.
class StudySessionScreen extends StatelessWidget {
  const StudySessionScreen({required this.sessionId, super.key});

  /// The persisted session id from the entry gate.
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(
        automaticallyImplyLeading: false,
        leading: MxIconButton.toolbar(
          icon: Icons.close,
          tooltip: l10n.commonCancel,
          onPressed: () => context.pop(),
        ),
        title: l10n.studySessionTitle,
      ),
      body: Center(
        key: const ValueKey<String>('study_session_placeholder'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MxText(l10n.studySessionPlaceholder, role: MxTextRole.bodyMedium),
            const SizedBox(height: MxSpacing.space2),
            MxText(sessionId, role: MxTextRole.bodySmall),
          ],
        ),
      ),
    );
  }
}
