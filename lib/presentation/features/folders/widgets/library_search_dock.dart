import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_stroke.dart';
import 'package:memox/presentation/features/folders/widgets/library_search_field.dart';

/// The Library search-mode bottom dock (kit `03` Search state, `search-dock`):
/// a pinned bar at the foot of the screen — a top hairline over a surface fill —
/// hosting the autofocused folder [LibrarySearchField]. The regular Library app
/// bar (title + sort) stays in place above it, and the FAB is suppressed while
/// searching, matching the mock.
///
/// Mounted in the `Scaffold.bottomNavigationBar` slot (via `MxScaffold`) so it
/// renders flat and full-bleed — no rounded/elevated BottomSheet chrome — and
/// reserves its own foot room under the content. WBS 3.1.2.
class LibrarySearchDock extends StatelessWidget {
  const LibrarySearchDock({super.key});

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.divider, width: MxStroke.hairline),
        ),
      ),
      child: const SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MxSpacing.screen,
            vertical: MxSpacing.space3,
          ),
          child: LibrarySearchField(autofocus: true),
        ),
      ),
    );
  }
}
