import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/types/app_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/language_controller.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_radio.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// The Language body (kit screen 25): the "App language" radio list (System /
/// English / Tiếng Việt) over the app-level [LanguageController], plus the
/// restart footnote.
class LanguageSettingsBody extends ConsumerWidget {
  const LanguageSettingsBody({super.key});

  static const List<AppLanguage> _order = <AppLanguage>[
    AppLanguage.system,
    AppLanguage.english,
    AppLanguage.vietnamese,
  ];

  // Inset past the icon-tile (40) + gap (12) so the hairline aligns with the
  // row text — the kit's `hr inset` (kit 25).
  static const double _rowDividerIndent = MxSpacing.space10 + MxSpacing.space3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<AppLanguage> async = ref.watch(languageControllerProvider);
    return AppAsyncBuilder<AppLanguage>(
      value: async,
      loading: (_) => const MxLoadingState(),
      error: (Object error, StackTrace? _) => MxErrorState(
        title: l10n.languageErrorTitle,
        message: l10n.languageErrorMessage,
      ),
      data: (AppLanguage selected) => _content(context, ref, l10n, selected),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AppLanguage selected,
  ) {
    final MxColors colors = context.mxColors;
    final LanguageController controller = ref.read(
      languageControllerProvider.notifier,
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
            l10n.languageOverline,
            role: MxTextRole.labelMedium,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: MxSpacing.space2),
        MxCard(
          key: const ValueKey<String>('mx-node:25-language/language-list'),
          padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < _order.length; i++) ...<Widget>[
                if (i > 0) const MxDivider(indent: _rowDividerIndent),
                _LanguageRow(
                  language: _order[i],
                  selected: _order[i] == selected,
                  onTap: () => controller.setLanguage(_order[i]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: MxSpacing.space3),
        _Footnote(text: l10n.languageRestartNote),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    final (
      IconData icon,
      Color tint,
      String title,
      String desc,
    ) = switch (language) {
      AppLanguage.system => (
        Icons.smartphone_outlined,
        colors.textSecondary,
        l10n.languageSystemTitle,
        l10n.languageSystemDesc,
      ),
      AppLanguage.english => (
        Icons.language_outlined,
        colors.info,
        l10n.languageEnglishTitle,
        l10n.languageEnglishDesc,
      ),
      AppLanguage.vietnamese => (
        Icons.language_outlined,
        colors.success,
        l10n.languageVietnameseTitle,
        l10n.languageVietnameseDesc,
      ),
    };
    return MxListTile(
      leading: MxIconTile(color: tint, icon: icon),
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
