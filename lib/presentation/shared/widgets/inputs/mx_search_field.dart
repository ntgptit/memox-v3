import 'package:flutter/material.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';

/// A search input: a leading search glyph and a clear button that appears with
/// text.
///
/// Purpose:
/// One search-entry primitive that owns its leading icon and trailing clear
/// affordance, so every search box aligns identically and the clear keycap can
/// never be misplaced by a consumer (geometry is fixed here).
///
/// Use when:
/// Filtering or searching a list/collection.
///
/// Do not use when:
/// Collecting free-form text (use `MxTextField`).
///
/// Category:
/// input
///
/// Public API:
/// - controller: optional external controller (an internal one is used if null).
/// - hintText: placeholder copy (already-localized).
/// - onChanged: fires on every edit (including when cleared).
/// - onSubmitted: fires on keyboard submit.
/// - autofocus: focus the field on mount.
class MxSearchField extends StatefulWidget {
  const MxSearchField({
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<MxSearchField> createState() => _MxSearchFieldState();
}

class _MxSearchFieldState extends State<MxSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = _controller.text.isNotEmpty;
    return MxTextField(
      controller: _controller,
      hintText: widget.hintText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: hasText
          ? IconButton(icon: const Icon(Icons.close), onPressed: _clear)
          : null,
    );
  }
}
