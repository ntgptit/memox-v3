import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// Foundation placeholder rendered by routes whose real screen is not built yet.
///
/// Placeholder discipline (WBS 1.1.3): an unbuilt destination renders this
/// widget — never fake product content. It is deliberately plain and clearly
/// labelled with its [routeName] so it can never be mistaken for a finished
/// screen. Feature route registries replace the `builder` with the real screen
/// when that screen ships (see `docs/business/navigation/navigation-flow.md`).
///
/// Lives under `lib/app/router/` (not a feature screen), so it intentionally
/// uses a raw [Scaffold]: the `Mx*` screen-shell widgets (WBS 1.2.x) do not
/// exist yet, and this surface is replaced before any user-facing release.
class RoutePlaceholder extends StatelessWidget {
  const RoutePlaceholder({required this.routeName, super.key});

  /// The `RouteNames.*` identifier of the destination this placeholder stands in
  /// for. Shown as a technical label, not user-facing copy.
  final String routeName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.construction_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: MxSpacing.space3),
            Text(
              routeName,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
