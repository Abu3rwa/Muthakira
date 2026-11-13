/// Numeric grid for `matrix_input`. The grid size is visible structure on the
/// question's options (`rowsxcols`, e.g. `2x2`); the stored key is never read,
/// so nothing leaks before unlock. Answers emit as rows of cell strings, the
/// shape the server marker expects.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../../exams/domain/exam_models.dart';

const Map<String, String> _arabicDigits = <String, String>{
  '٠': '0',
  '١': '1',
  '٢': '2',
  '٣': '3',
  '٤': '4',
  '٥': '5',
  '٦': '6',
  '٧': '7',
  '٨': '8',
  '٩': '9',
};

String _latinDigits(String text) {
  final StringBuffer buffer = StringBuffer();
  for (final int rune in text.runes) {
    buffer.write(_arabicDigits[String.fromCharCode(rune)] ?? String.fromCharCode(rune));
  }
  return buffer.toString();
}

({int rows, int columns})? _parseDimensions(List<String> options) {
  if (options.length != 1) return null;
  final String raw = _latinDigits(options.first).replaceAll(' ', '').replaceAll('×', 'x').replaceAll('*', 'x');
  final RegExpMatch? match = RegExp(r'^([1-6])x([1-6])$').firstMatch(raw);
  if (match == null) return null;
  return (rows: int.parse(match.group(1)!), columns: int.parse(match.group(2)!));
}

class MatrixInput extends StatefulWidget {
  const MatrixInput({
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
  State<MatrixInput> createState() => _MatrixInputState();
}

class _MatrixInputState extends State<MatrixInput> {
  late final ({int rows, int columns})? _dimensions = _parseDimensions(widget.question.options);
  final Map<String, TextEditingController> _cells = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    final ({int rows, int columns})? dimensions = _dimensions;
    if (dimensions == null) return;
    final Object? saved = widget.initial;
    final List<List<String>> values = <List<String>>[
      if (saved is List)
        for (final Object? row in saved)
          if (row is List)
            <String>[for (final Object? cell in row) cell?.toString() ?? '']
          else
            <String>[row?.toString() ?? ''],
    ];
    for (var r = 0; r < dimensions.rows; r += 1) {
      for (var c = 0; c < dimensions.columns; c += 1) {
        final String? value = r < values.length && c < values[r].length ? values[r][c] : null;
        _cells['$r.$c'] = TextEditingController(text: value ?? '');
      }
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _cells.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _emit() {
    final ({int rows, int columns})? dimensions = _dimensions;
    if (dimensions == null) return;
    widget.onChanged(<List<String>>[
      for (var r = 0; r < dimensions.rows; r += 1)
        <String>[for (var c = 0; c < dimensions.columns; c += 1) _cells['$r.$c']!.text.trim()],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final ({int rows, int columns})? dimensions = _dimensions;
    final ColorScheme scheme = context.scheme;
    if (dimensions == null) {
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
          children: <TableRow>[
            for (var r = 0; r < dimensions.rows; r += 1)
              TableRow(
                children: <Widget>[
                  _bracket(context, open: true),
                  for (var c = 0; c < dimensions.columns; c += 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                      child: SizedBox(
                        width: 72,
                        child: TextField(
                          key: ValueKey<String>('matrix-$r-$c'),
                          controller: _cells['$r.$c'],
                          enabled: widget.enabled,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          onChanged: (_) => _emit(),
                          style: context.text.bodyMedium,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: context.l10n.cellLabel('${r + 1}', '${c + 1}'),
                            hintStyle: context.text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.input)),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xs,
                            ),
                          ),
                        ),
                      ),
                    ),
                  _bracket(context, open: false),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _bracket(BuildContext context, {required bool open}) {
    return SizedBox(
      width: 12,
      child: Text(
        open ? '[' : ']',
        textAlign: TextAlign.center,
        style: context.text.headlineSmall?.copyWith(color: context.scheme.onSurfaceVariant),
      ),
    );
  }
}
