import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/types/app_theme_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/appearance_controller.dart';
import 'package:memox/presentation/features/settings/widgets/appearance_theme_swatch.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_radio.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// The Appearance body (kit screen 24): the "Theme" radio list (Light / Dark /
/// System) over the app-level [AppearanceController], plus the system footnote.
class AppearanceSettingsBody extends ConsumerWidget {
  const AppearanceSettingsBody({super.key});

  // Mock order: Light, Dark, System.
  static const List<AppThemeMode> _order = <AppThemeMode>[
    AppThemeMode.light,
    AppThemeMode.dark,
    AppThemeMode.system,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<AppThemeMode> async = ref.watch(
      appearanceControllerProvider,
    );
    return AppAsyncBuilder<AppThemeMode>(
      value: async,
      loading: (_) => const MxLoadingState(),
      error: (Object error, StackTrace? _) => MxErrorState(
        title: l10n.appearanceErrorTitle,
        message: l10n.appearanceErrorMessage,
      ),
      data: (AppThemeMode selected) => _content(context, ref, l10n, selected),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AppThemeMode selected,
  ) {
    final MxColors colors = context.mxColors;
    final AppearanceController controller = ref.read(
      appearanceControllerProvider.notifier,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        MxSpacing.screen,
        MxSpacing.space4,
        MxSpacing.screen,
        MxSpacing.space6,
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: MxSpacing.space1),
          child: MxText(
            l10n.appearanceThemeLabel,
            role: MxTextRole.labelMedium,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: MxSpacing.space2),
        MxCard(
          key: const ValueKey<String>('mx-node:24-appearance/theme-list'),
          padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < _order.length; i++) ...<Widget>[
                if (i > 0) const MxDivider(),
                _ThemeRow(
                  mode: _order[i],
                  selected: _order[i] == selected,
                  onTap: () => controller.setMode(_order[i]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: MxSpacing.space3),
        _Footnote(text: l10n.appearanceSystemNote),
      ],
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final (String title, String desc) = switch (mode) {
      AppThemeMode.light => (l10n.appearanceLight, l10n.appearanceLightDesc),
      AppThemeMode.dark => (l10n.appearanceDark, l10n.appearanceDarkDesc),
      AppThemeMode.system => (l10n.appearanceSystem, l10n.appearanceSystemDesc),
    };
    return MxListTile(
      leading: ThemeSwatch(mode: mode),
      title: title,
      subtitle: desc,
      trailing: MxRadio(selected: selected),
      onTap: onTap,
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: MxIconSize.sm,
            color: colors.textSecondary,
          ),
          const SizedBox(width: MxSpacing.space2),
          Expanded(
            child: MxText(
              text,
              role: MxTextRole.bodySmall,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
