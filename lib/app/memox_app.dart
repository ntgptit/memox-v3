import 'package:flutter/material.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

class MemoXApp extends StatelessWidget {
  const MemoXApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    theme: MxTheme.light,
    darkTheme: MxTheme.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: createAppRouter(),
  );
}
