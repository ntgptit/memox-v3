import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

/// App-wide theme mode (light / dark / system).
///
/// Base scaffolding: defaults to [ThemeMode.system]. Persistence of the user's
/// choice belongs to a settings use case + preferences store and is wired when
/// the settings feature lands — not held only in provider memory long term.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) => state = mode;
}
