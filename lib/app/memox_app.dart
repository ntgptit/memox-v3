import 'package:flutter/material.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/core/theme/mx_theme.dart';

class MemoXApp extends StatelessWidget {
  const MemoXApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'MemoX',
    theme: MxTheme.light,
    darkTheme: MxTheme.dark,
    routerConfig: createAppRouter(),
  );
}
