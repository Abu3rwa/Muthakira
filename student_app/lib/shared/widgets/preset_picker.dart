/// A dropdown of presets with an optional free-text "Other" escape hatch.
/// Reports the effective value, so the parent never inspects the widget.
library;

import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import 'app_text_field.dart';

class ChoiceOption {
  const ChoiceOption({required this.value, required this.label});

  final String value;
  final String label;
}

class PresetPicker extends StatefulWidget {
  const PresetPicker({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.initialValue,
    this.otherLabel,
    this.noneLabel,
    this.hint,
    this.errorText,
  });

  final String label;
  final List<ChoiceOption> options;
  final ValueChanged<String?> onChanged;
  final String? initialValue;
  final String? otherLabel;
  final String? noneLabel;
  final String? hint;
  final String? errorText;

  static const String otherSentinel = '__other__';
  static const String noneSentinel = '__none__';

  @override
  State<PresetPicker> createState() => _PresetPickerState();
}

class _PresetPickerState extends State<PresetPicker> {
  late final TextEditingController _other = TextEditingController(text: _initialOtherText());
  late String? _selected = _initialSelection();

  String _initialOtherText() {
    final String? initial = widget.initialValue;
    if (initial == null || initial.isEmpty) return '';
    return widget.options.any((ChoiceOption o) => o.value == initial) ? '' : initial;
  }

  String? _initialSelection() {
    final String? initial = widget.initialValue;
    if (initial == null) return null;
    if (initial.isEmpty) return PresetPicker.noneSentinel;
    return widget.options.any((ChoiceOption o) => o.value == initial)
        ? initial
        : PresetPicker.otherSentinel;
  }

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  void _emit() {
    final String? selected = _selected;
    if (selected == null || selected == PresetPicker.noneSentinel) {
      widget.onChanged(null);
    } else if (selected == PresetPicker.otherSentinel) {
      final String text = _other.text.trim();
      widget.onChanged(text.isEmpty ? null : text);
    } else {
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[
      if (widget.noneLabel != null)
        DropdownMenuItem<String>(value: PresetPicker.noneSentinel, child: Text(widget.noneLabel!)),
      for (final ChoiceOption option in widget.options)
        DropdownMenuItem<String>(value: option.value, child: Text(option.label)),
      if (widget.otherLabel != null)
        DropdownMenuItem<String>(value: PresetPicker.otherSentinel, child: Text(widget.otherLabel!)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DropdownButtonFormField<String>(
          value: _selected,
          items: items,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            errorText: widget.errorText,
          ),
          onChanged: (String? value) {
            setState(() => _selected = value);
            _emit();
          },
        ),
        if (_selected == PresetPicker.otherSentinel) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: l10n.other,
            controller: _other,
            maxLength: 80,
            onChanged: (_) => _emit(),
          ),
        ],
      ],
    );
  }
}