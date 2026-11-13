/// Editable grid for `table_fill`. The visible skeleton is transcribed into the
/// question text as a pipe table: a header row then data rows whose first cell
/// is a static row label and whose remaining cells are blanks. Answers emit as
/// `{"<row>.<column>": value}` (1-based), the shape the server marker expects.
/// The stored key is never used to build the grid, so nothing leaks before unlock.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/content_text.dart';
import '../../exams/domain/exam_models.dart';

class _Grid {
  const _Grid(this.headers, this.rows);

  final List<String> headers;
  final List<List<String>> rows;

  int get columns => headers.length - 1;
}

_Grid? _parseGrid(String text) {
  final List<List<String>> lines = <List<String>>[];
  for (final String raw in text.split('\n')) {
    if (!raw.contains('|')) continue;
    final List<String> cells = raw.split('|').map((String c) => c.trim()).toList();
    if (cells.isNotEmpty && cells.first.isEmpty) cells.removeAt(0);
    if (cells.isNotEmpty && cells.last.isEmpty) cells.removeLast();
    if (cells.isEmpty) continue;
    final bool separator = cells.every((String c) => RegExp(r'^:?-{2,}:?$').hasMatch(c));
    if (separator) continue;
    lines.add(cells);
  }
  if (lines.length < 2 || lines.first.length < 2) return null;
  final List<String> headers = lines.first;
  final int width = headers.length;
  final List<List<String>> rows = lines
      .skip(1)
      .map((List<String> r) => List<String>.generate(width, (int i) => i < r.length ? r[i] : ''))
      .toList();
  return _Grid(headers, rows);
}

class TableFillInput extends StatefulWidget {
  const TableFillInput({
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
  State<TableFillInput> createState() => _TableFillInputState();
}

class _TableFillInputState extends State<TableFillInput> {
  late final _Grid? _grid = _parseGrid(widget.question.text);
  final Map<String, TextEditingController> _cells = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    final _Grid? grid = _grid;
    if (grid == null) return;
    final Map<Object?, Object?> saved = widget.initial is Map ? widget.initial as Map : const <Object?, Object?>{};
    for (var r = 1; r <= grid.rows.length; r += 1) {
      for (var c = 1; c <= grid.columns; c += 1) {
        final String key = '$r.$c';
        _cells[key] = TextEditingController(text: saved[key]?.toString() ?? '');
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
    final Map<String, String> map = <String, String>{};
    _cells.forEach((String key, TextEditingController controller) {
      final String text = controller.text.trim();
      if (text.isNotEmpty) map[key] = text;
    });
    widget.onChanged(map);
  }

  @override
  Widget build(BuildContext context) {
    final _Grid? grid = _grid;
    final ColorScheme scheme = context.scheme;
    if (grid == null) {
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
    return Table(
      border: TableBorder.all(color: scheme.outlineVariant),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        TableRow(
          decoration: BoxDecoration(color: scheme.surfaceContainerHigh),
          children: <Widget>[
            for (final String header in grid.headers)
              _label(context, header, bold: true),
          ],
        ),
        for (var r = 0; r < grid.rows.length; r += 1)
          TableRow(
            children: <Widget>[
              for (var c = 0; c < grid.headers.length; c += 1)
                if (c == 0)
                  _label(context, grid.rows[r][0])
                else
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxs),
                    child: TextField(
                      controller: _cells['${r + 1}.$c'],
                      enabled: widget.enabled,
                      textDirection: contentDirection(widget.question.text),
                      onChanged: (_) => _emit(),
                      style: context.text.bodyMedium,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: context.l10n.cellLabel('${r + 1}', '$c'),
                        hintStyle: context.text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.input)),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
      ],
    );
  }

  Widget _label(BuildContext context, String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: ContentText(
        text,
        style: bold
            ? context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600)
            : context.text.bodyMedium,
      ),
    );
  }
}
