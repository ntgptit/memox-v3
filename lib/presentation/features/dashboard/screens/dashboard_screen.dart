import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/widgets/dashboard_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Dashboard — the `/home` destination (design redesign).
///
/// A quiet "refer to work" surface: a due snapshot + shortcuts to Progress and
/// the Library. No app-bar search (Search is the top-level `/search` tab) and no
/// daily goal / streak (those live on Progress). The shell stays watch-free —
/// [DashboardBody] owns the summary watch. WBS 5.x.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(title: l10n.homeTitle),
      body: const DashboardBody(),
    );
  }
}
