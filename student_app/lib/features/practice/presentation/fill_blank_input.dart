/// Fill-in-the-blank input rendered inside the sentence: every blank marker
/// in the prompt (`___`, `.........` or `…`) becomes an inline text field in
/// the flow of the text.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/content_text.dart';

final RegExp _marker = RegExp(r'_{3,}|\.{3,}|…+');

class FillBlankInput extends StatefulWidget {
  const FillBlankInput({
    super.key,
    required this.text,
    required this.initial,
    required this.onChanged,
    this.enabled = true,
  });

  final String text;
  final Object? initial;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;

  @override
  State<FillBlankInput> createState() => _FillBlankInputState();
}

class _FillBlankInputState extends State<FillBlankInput> {
  final List<TextEditingController> _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    final List<String> values = widget.initial is List
        ? (widget.initial as List).map((Object? item) => item?.toString() ?? '').toList()
        : <String>[];
    final int markers = _marker.allMatches(widget.text).length;
    final int fields = markers > 0 ? markers : 1;
    for (var index = 0; index < fields; index += 1) {
      _controllers.add(TextEditingController(text: index < values.length ? values[index] : ''));
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _emit() =>
      widget.onChanged(_controllers.map((TextEditingController controller) => controller.text.trim()).toList());

  @override
  Widget build(BuildContext context) {
    final TextStyle prompt = context.text.bodyLarge?.copyWith(height: 1.7) ?? const TextStyle();
    final TextDirection direction = contentDirection(widget.text);
    final List<String> parts = widget.text.split(_marker);
    if (parts.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ContentText(widget.text, style: prompt),
          const SizedBox(height: AppSpacing.sm),
          _field(context, 0, prompt),
        ],
      );
    }
    final List<InlineSpan> spans = <InlineSpan>[];
    for (var index = 0; index < parts.length; index += 1) {
      if (parts[index].isNotEmpty) spans.add(TextSpan(text: parts[index]));
      if (index < _controllers.length) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: SizedBox(width: 110, child: _field(context, index, prompt)),
            ),
          ),
        );
      }
    }
    return Directionality(
      textDirection: direction,
      child: Text.rich(TextSpan(style: prompt, children: spans)),
    );
  }

  Widget _field(BuildContext context, int index, TextStyle prompt) {
    return TextField(
      controller: _controllers[index],
      enabled: widget.enabled,
      textDirection: contentDirection(widget.text),
      textAlign: TextAlign.center,
      style: prompt.copyWith(
        fontWeight: FontWeight.w600,
        color: widget.enabled ? context.scheme.primary : context.scheme.onSurfaceVariant,
      ),
      textInputAction: index == _controllers.length - 1 ? TextInputAction.done : TextInputAction.next,
      onChanged: (_) => _emit(),
      decoration: const InputDecoration(
        isDense: true,
        hintText: '…',
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
        border: UnderlineInputBorder(),
      ),
    );
  }
}