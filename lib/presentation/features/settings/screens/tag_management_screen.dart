import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/widgets/tag_management_settings_content.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

export 'package:memox/presentation/features/settings/widgets/tag_management_settings_content.dart'
    show TagManagementState;

/// Tag management screen.
///
/// The screen renders the mobile UI kit mock as a static preview with state
/// variants for loaded, loading, empty, search-empty, sheet, rename,
/// rename-to-merge, merge, delete, busy-row, and op-error.
class SettingsTagManagementScreen extends StatelessWidget {
  const SettingsTagManagementScreen({
    this.state = TagManagementState.loaded,
    super.key,
  });

  final TagManagementState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(
        titleText: l10n.settingsManageTagsTitle,
        leading: MxIconButton(
          icon: Icons.arrow_back,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
      ),
      body: TagManagementSettingsContent(state: state),
    );
  }
}
