import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

/// Temporary stand-in for a not-yet-implemented screen.
///
/// The presentation layer (`lib/presentation/features/**`) is built out
/// feature by feature. Until a real `*Screen` lands, the router points the
/// corresponding route here so the app boots and navigation is verifiable.
/// Replace the builder in `app_router.dart`, not this widget, as screens ship.
class RoutePlaceholder extends StatelessWidget {
  const RoutePlaceholder({
    required this.routeName,
    this.params = const <String, String>{},
    super.key,
  });

  final String routeName;
  final Map<String, String> params;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paramText = params.isEmpty
        ? null
        : params.entries.map((e) => '${e.key}: ${e.value}').join('\n');

    return Scaffold(
      appBar: AppBar(title: Text(routeName)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.construction_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(routeName, style: theme.textTheme.titleMedium),
            if (paramText != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.sm),
              Text(
                paramText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
