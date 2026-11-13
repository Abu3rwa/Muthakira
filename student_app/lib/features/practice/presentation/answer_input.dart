/// Renders one question and reports the answer shape the server expects.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/content_text.dart';
import '../../exams/domain/exam_models.dart';
import 'fill_blank_input.dart';
import 'matrix_input.dart';
import 'table_fill_input.dart';
import 'truth_table_input.dart';

class AnswerInput extends StatefulWidget {
  const AnswerInput({
    super.key,
    required this.question,
    required this.letters,
    required this.initial,
    required this.onChanged,
    this.enabled = true,
    this.revealedKey,
  });

  final Question question;
  final List<String> letters;
  final Object? initial;
  final ValueChanged<Object?> onChanged;
  final bool enabled;

  /// Shown once the server reveals the key, so a locked answer still teaches.
  final Object? revealedKey;

  @override
  State<AnswerInput> createState() => _AnswerInputState();
}

class _AnswerInputState extends State<AnswerInput> {
  String? _letter;
  List<String> _letters = <String>[];
  bool? _boolean;
  List<String> _order = <String>[];
  final TextEditingController _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    final Object? initial = widget.initial;
    switch (widget.question.type) {
      case 'mcq':
      case 'matching_item':
        _letter = initial is String ? initial : null;
      case 'multi_select':
        _letters = initial is List ? initial.map((Object? item) => item.toString()).toList() : <String>[];
      case 'true_false':
        _boolean = initial is bool ? initial : null;
      case 'ordering':
        final List<String> options = widget.question.options;
        final List<String> saved = initial is List
            ? initial.map((Object? item) => item.toString()).toList()
            : <String>[];
        // The server accepts letters; older drafts may hold option text.
        _order = saved.length == options.length
            ? saved.map((String item) {
                final int index = options.indexOf(item);
                return index >= 0 && index < widget.letters.length ? widget.letters[index] : item;
              }).toList()
            : widget.letters.take(options.length).toList();
      case 'fill_blank':
      case 'language_analysis':
      case 'table_fill':
      case 'matrix_input':
      case 'truth_table':
        break;
      default:
        _text.text = initial is String ? initial : (initial?.toString() ?? '');
    }
    // An untouched ordering answer is still an answer: emit the shown order
    // once the first frame is done so "Check answer" is enabled immediately.
    if (widget.question.type == 'ordering' && _order.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _emit();
      });
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(switch (widget.question.type) {
      'mcq' || 'matching_item' => _letter,
      'multi_select' => _letters,
      'true_false' => _boolean,
      'ordering' => _order,
      _ => _text.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final Question question = widget.question;
    return switch (question.type) {
      'mcq' || 'matching_item' => _choice(context, multi: false),
      'multi_select' => _choice(context, multi: true),
      'true_false' => _trueFalse(context),
      'ordering' => _ordering(context),
      'fill_blank' || 'language_analysis' => FillBlankInput(
          text: question.text,
          initial: widget.initial,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
        ),
      'table_fill' => TableFillInput(
          question: question,
          initial: widget.initial,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
        ),
      'matrix_input' => MatrixInput(
          question: question,
          initial: widget.initial,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
        ),
      'truth_table' => TruthTableInput(
          question: question,
          initial: widget.initial,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
        ),
      'numeric' => _single(
          context,
          keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true),
          hint: context.l10n.numericKeyboardHint,
          formatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹+\-.,٫٬\s]')),
          ],
        ),
      'diacritics' => _single(context, multiline: true, reading: true),
      'essay' || 'short_answer' => _single(context, multiline: true),
      _ => _single(context),
    };
  }

  /// The revealed key as a set of option letters, for locked styling only.
  Set<String> get _correctLetters {
    final Object? key = widget.revealedKey;
    if (key is String) {
      return key.split('||').map((String item) => item.trim()).where((String item) => item.isNotEmpty).toSet();
    }
    if (key is List) {
      return key.map((Object? item) => item is List ? item.join(' | ') : item.toString().trim()).toSet();
    }
    return const <String>{};
  }

  Widget _choice(BuildContext context, {required bool multi}) {
    final List<String> options = widget.question.options;
    final ColorScheme scheme = context.scheme;
    final SemanticColors colors = context.semantics;
    final Set<String> correct = widget.enabled ? const <String>{} : _correctLetters;
    return Column(
      children: <Widget>[
        for (int index = 0; index < options.length; index++)
          Builder(
            builder: (BuildContext context) {
              final String letter = index < widget.letters.length ? widget.letters[index] : '${index + 1}';
              final bool selected = multi ? _letters.contains(letter) : _letter == letter;
              final bool isCorrect = correct.contains(letter);
              final bool isWrongPick = correct.isNotEmpty && selected && !isCorrect;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Semantics(
                  selected: selected,
                  child: Material(
                    color: isCorrect
                        ? colors.successContainer
                        : isWrongPick
                        ? scheme.errorContainer
                        : selected
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.input),
                      side: BorderSide(
                        color: isCorrect
                            ? colors.success
                            : isWrongPick
                            ? scheme.error
                            : selected
                            ? scheme.primary
                            : scheme.outlineVariant,
                        width: selected || isCorrect ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadii.input),
                      onTap: !widget.enabled
                          ? null
                          : () {
                              setState(() {
                                if (multi) {
                                  selected ? _letters.remove(letter) : _letters.add(letter);
                                } else {
                                  _letter = letter;
                                }
                              });
                              _emit();
                            },
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            children: <Widget>[
                              Text('$letter.', style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: ContentText(options[index], style: context.text.bodyLarge),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Icon(
                                isCorrect
                                    ? Icons.check_circle_rounded
                                    : isWrongPick
                                    ? Icons.cancel_rounded
                                    : multi
                                    ? (selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded)
                                    : (selected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                                color: isCorrect
                                    ? colors.success
                                    : isWrongPick
                                    ? scheme.error
                                    : selected
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _trueFalse(BuildContext context) {
    final List<Widget> choices = <Widget>[
      _choicePill(context, context.l10n.trueLabel, _boolean == true, () {
        setState(() => _boolean = true);
        _emit();
      }),
      _choicePill(context, context.l10n.falseLabel, _boolean == false, () {
        setState(() => _boolean = false);
        _emit();
      }),
    ];
    return Row(
      children: <Widget>[
        Expanded(child: choices[0]),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: choices[1]),
      ],
    );
  }

  Widget _choicePill(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return Semantics(
      selected: selected,
      child: OutlinedButton(
        onPressed: widget.enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? context.scheme.primaryContainer : null,
          side: BorderSide(
            color: selected ? context.scheme.primary : context.scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          minimumSize: const Size.fromHeight(AppSpacing.minTapTarget),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _ordering(BuildContext context) {
    if (_order.isEmpty) return _Unavailable(context.l10n.structureUnavailable);
    final List<String> options = widget.question.options;
    String textOf(String letter) {
      final int index = widget.letters.indexOf(letter);
      return index >= 0 && index < options.length ? options[index] : letter;
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: _order.length,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          final int target = newIndex > oldIndex ? newIndex - 1 : newIndex;
          final String moved = _order.removeAt(oldIndex);
          _order.insert(target, moved);
        });
        _emit();
      },
      itemBuilder: (BuildContext context, int index) {
        final String letter = _order[index];
        return Card(
          key: ValueKey<String>(letter),
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Semantics(
            label: context.l10n.orderingItemLabel('${index + 1}', '${_order.length}'),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 32,
                  child: Center(
                    child: Text('${index + 1}', style: context.text.titleSmall?.copyWith(color: context.scheme.onSurfaceVariant)),
                  ),
                ),
                Expanded(
                  child: ContentText(textOf(letter), style: context.text.bodyLarge),
                ),
                IconButton(
                  onPressed: widget.enabled && index > 0 ? () => _move(index, index - 1) : null,
                  icon: const Icon(Icons.arrow_upward_rounded),
                  tooltip: context.l10n.moveUp,
                ),
                IconButton(
                  onPressed: widget.enabled && index < _order.length - 1 ? () => _move(index, index + 1) : null,
                  icon: const Icon(Icons.arrow_downward_rounded),
                  tooltip: context.l10n.moveDown,
                ),
                if (widget.enabled)
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Icon(Icons.drag_handle_rounded, color: context.scheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _move(int from, int to) {
    setState(() {
      final String moved = _order.removeAt(from);
      _order.insert(to, moved);
    });
    _emit();
  }

  Widget _single(
    BuildContext context, {
    bool multiline = false,
    bool reading = false,
    TextInputType? keyboard,
    String? hint,
    List<TextInputFormatter>? formatters,
  }) {
    return TextField(
      controller: _text,
      enabled: widget.enabled,
      keyboardType: keyboard,
      inputFormatters: formatters,
      textDirection: contentDirection(widget.question.text),
      minLines: multiline ? 4 : 1,
      maxLines: multiline ? null : 1,
      textInputAction: multiline ? TextInputAction.newline : TextInputAction.done,
      style: reading ? AppTheme.reading(scale: 0.82) : context.text.bodyLarge?.copyWith(height: 1.7),
      onChanged: (_) => _emit(),
      decoration: InputDecoration(hintText: hint ?? context.l10n.answerHintText),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Text(
        message,
        style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
      ),
    );
  }
}
