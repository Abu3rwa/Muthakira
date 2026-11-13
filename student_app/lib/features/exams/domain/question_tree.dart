import 'exam_models.dart';

/// A leaf question plus the section headings and stimulus that give it context.
class PracticeEntry {
  const PracticeEntry({
    required this.question,
    this.sections = const [],
    this.stimulus,
  });

  final Question question;
  final List<Question> sections;
  final Stimulus? stimulus;
}

/// Flattens the paper tree into the ordered list of answerable leaves.
class QuestionTree {
  const QuestionTree._();

  static List<PracticeEntry> flatten(ExamDetail exam) {
    final byId = {for (final question in exam.questions) question.id: question};
    final sorted = [...exam.questions]..sort((left, right) => comparePaths(left.path, right.path));
    final entries = <PracticeEntry>[];

    for (final question in sorted) {
      if (question.isContainer) continue;
      final sections = <Question>[];
      var parent = question.parentId == null ? null : byId[question.parentId];
      var guard = 0;
      Question? matchingParent;
      while (parent != null && guard < 10) {
        if (parent.isContainer) sections.insert(0, parent);
        if (parent.type == 'matching') matchingParent = parent;
        parent = parent.parentId == null ? null : byId[parent.parentId];
        guard += 1;
      }
      // A matching_item has no options of its own; the bank sits on the matching
      // container, so borrow it to render the choices the student picks from.
      final answerable = question.type == 'matching_item' && question.options.isEmpty && matchingParent != null
          ? question.withOptions(matchingParent.options)
          : question;
      final stimulusId = question.stimulusId ??
          sections.reversed.map((section) => section.stimulusId).firstWhere((id) => id != null, orElse: () => null);
      entries.add(
        PracticeEntry(
          question: answerable,
          sections: sections,
          stimulus: stimulusId == null ? null : exam.stimuli.where((item) => item.id == stimulusId).firstOrNull,
        ),
      );
    }
    return entries;
  }

  /// Where a session opens: an explicit jump wins, otherwise the first
  /// unanswered question, otherwise the start.
  static int resumeIndex(List<PracticeEntry> entries, Set<String> answeredIds, {int requested = 0}) {
    if (entries.isEmpty) return 0;
    if (requested > 0) return requested.clamp(0, entries.length - 1);
    for (var index = 0; index < entries.length; index += 1) {
      if (!answeredIds.contains(entries[index].question.id)) return index;
    }
    return 0;
  }

  /// Natural ordering for paths like `1.10.b`.
  static int comparePaths(String left, String right) {
    final a = left.split('.');
    final b = right.split('.');
    final length = a.length < b.length ? a.length : b.length;
    for (var index = 0; index < length; index += 1) {
      final leftNumber = int.tryParse(a[index]);
      final rightNumber = int.tryParse(b[index]);
      final comparison = leftNumber != null && rightNumber != null
          ? leftNumber.compareTo(rightNumber)
          : a[index].compareTo(b[index]);
      if (comparison != 0) return comparison;
    }
    return a.length.compareTo(b.length);
  }

  /// Section (top-level container) for a leaf, used in the result breakdown.
  static Question? topSection(Question question, Map<String, Question> byId) {
    Question? current = byId[question.parentId];
    Question? top;
    var guard = 0;
    while (current != null && guard < 10) {
      top = current.isContainer ? current : top;
      current = byId[current.parentId];
      guard += 1;
    }
    return top;
  }
}
