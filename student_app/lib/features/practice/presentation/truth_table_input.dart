/// Truth-table grid for `truth_table`. The input variables are visible
/// structure on the question's options (e.g. `A||B`); rows follow the dense
/// order used by the key contract, with the first variable as the most
/// significant bit. Only the output column is answered, and it emits as one
/// value per row in that same order.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../../exams/domain/exam_models.dart';

class TruthTableInput extends StatefulWidget {
  const TruthTableInput({
    super.key,
    required this.question,
    required this.initial,
    required this.onChanged,
    this.enabled = true,
  });

  final Question question;
  final Object? initial;
  final ValueChanged<Object?> onChanged;
  final bool enabled;

  @override
  State<TruthTableInput> createState() => _TruthTableInputState();
}

/// Input bits for one truth-table row, counting the first variable as the most
/// significant bit, matching the key order the importer documents.
List<String> truthRowBits(int variables, int row) => <String>[
  for (var variable = 0; variable < variables; variable += 1)
    ((row >> (variables - 1 - variable)) & 1) == 1 ? '1' : '0',
];

class _TruthTableInputState extends State<TruthTableInput> {
  late final List<String> _variables = widget.question.options;
  late final int _rowCount = _variables.isEmpty || _variables.length > 4 ? 0 : 1 << _variables.length;
  late final List<String?> _outputs = List<String?>.filled(_rowCount, null);

  @override
  void initState() {
    super.initState();
    final Object? saved = widget.initial;
    if (saved is! List) return;
    for (var index = 0; index < _rowCount && index < saved.length; index += 1) {
      final Object? value = saved[index];
      if (value is bool) {
        _outputs[index] = value ? '1' : '0';
      } else if (value is num) {
        _outputs[index] = value == 1 ? '1' : '0';
      } else if (value is String && (value == '0' || value == '1')) {
        _outputs[index] = value;
      }
    }
  }

  void _set(int row, String bit) {
    setState(() => _outputs[row] = _outputs[row] == bit ? null : bit);
    widget.onChanged(List<String?>.of(_outputs));
  }

  /// Bit of `variable` for `row`, counting the first variable as the top bit.
  String _bit(int row, int variable) => truthRowBits(_variables.length, row)[variable];

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.scheme;
    if (_rowCount == 0) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Text(
          context.l10n.structureUnavailable,
          style: context.text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(color: scheme.outlineVariant),
          children: <TableRow>[
            TableRow(
              decoration: BoxDecoration(color: scheme.surfaceContainerHigh),
              children: <Widget>[
                for (final String variable in _variables) _cell(context, variable, bold: true),
                _cell(context, context.l10n.truthTableOutput, bold: true),
              ],
            ),
            for (var row = 0; row < _rowCount; row += 1)
              TableRow(
                children: <Widget>[
                  for (var variable = 0; variable < _variables.length; variable += 1)
                    _cell(context, _bit(row, variable)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _bitButton(context, row, '1', context.l10n.trueLabel),
                        const SizedBox(width: AppSpacing.xxs),
                        _bitButton(context, row, '0', context.l10n.falseLabel),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _bitButton(BuildContext context, int row, String bit, String semanticLabel) {
    final bool selected = _outputs[row] == bit;
    return Semantics(
      selected: selected,
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: AppSpacing.minTapTarget,
        height: AppSpacing.minTapTarget,
        child: OutlinedButton(
          onPressed: widget.enabled ? () => _set(row, bit) : null,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: selected ? context.scheme.primaryContainer : null,
            side: BorderSide(
              color: selected ? context.scheme.primary : context.scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(bit, style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Text(
        text,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        style: bold
            ? context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600)
            : context.text.bodyMedium,
      ),
    );
  }
}
