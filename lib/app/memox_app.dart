import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/types/app_language.dart';
import 'package:memox/domain/types/app_theme_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/appearance_controller.dart';
import 'package:memox/presentation/features/settings/controllers/language_controller.dart';

class MemoXApp extends ConsumerWidget {
  const MemoXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The persisted theme preference (kit screen 24); `system` until it loads.
    final AppThemeMode mode =
        ref.watch(appearanceControllerProvider).asData?.value ??
        AppThemeMode.system;
    // The persisted UI language (kit screen 25); `system` (null locale) until it
    // loads → follow the device locale.
    final AppLanguage language =
        ref.watch(languageControllerProvider).asData?.value ??
        AppLanguage.system;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: MxTheme.light,
      darkTheme: MxTheme.dark,
      themeMode: mode.materialThemeMode,
      locale: language.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: createAppRouter(),
    );
  }
}
