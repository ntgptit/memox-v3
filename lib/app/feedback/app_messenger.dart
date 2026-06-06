import 'package:flutter/material.dart';

/// App-wide [ScaffoldMessengerState] handle.
///
/// Wired into `MaterialApp.router(scaffoldMessengerKey: ...)` so feedback can be
/// shown without a screen [BuildContext] — e.g. from the global provider
/// observer that surfaces retained-data refetch failures
/// (`docs/contracts/error-contract.md`).
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>(debugLabel: 'appMessenger');
