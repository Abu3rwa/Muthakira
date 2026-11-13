import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/features/exams/domain/exam_models.dart';
import 'package:student_app/features/exams/domain/question_tree.dart';

const ExamSummary _summary = ExamSummary(
  id: 'exam-1',
  examKey: 'eng-2026',
  examYear: 2026,
  session: 'April',
  classLevel: 'secondary',
  subject: 'English Literature',
  language: 'en',
);

void main() {
  test('a matching_item borrows the parent matching bank', () {
    const List<String> bank = <String>[
      'Speaker 1', 'Speaker 2', 'Speaker 3', 'Speaker 4', 'Speaker 5', 'Speaker 6',
    ];
    const ExamDetail exam = ExamDetail(
      summary: _summary,
      questions: <Question>[
        Question(id: 'q1', path: '1', type: 'container', text: 'Part one', isContainer: true, sortOrder: 1),
        Question(
          id: 'qA', path: '1.A', type: 'matching', text: 'Match the statements to the speakers',
          options: bank, isContainer: true, parentId: 'q1', sortOrder: 1,
        ),
        Question(id: 'qA1', path: '1.A.1', type: 'matching_item', text: 'Who said: I did?', parentId: 'qA', sortOrder: 1),
        Question(id: 'qA2', path: '1.A.2', type: 'matching_item', text: 'Who said: Never again?', parentId: 'qA', sortOrder: 2),
      ],
    );

    final List<PracticeEntry> entries = QuestionTree.flatten(exam);

    expect(entries.length, 2);
    expect(entries.map((PracticeEntry e) => e.question.id).toList(), <String>['qA1', 'qA2']);
    for (final PracticeEntry entry in entries) {
      expect(entry.question.options, bank);
      expect(entry.sections.map((Question s) => s.id).toList(), <String>['q1', 'qA']);
    }
  });

  test('a leaf that already has options is left untouched', () {
    const ExamDetail exam = ExamDetail(
      summary: _summary,
      questions: <Question>[
        Question(id: 'q1', path: '1', type: 'container', text: 'Part', isContainer: true, sortOrder: 1),
        Question(id: 'q1a', path: '1.a', type: 'mcq', text: 'Pick', options: <String>['Umuofia', 'Lagos'], parentId: 'q1', sortOrder: 1),
      ],
    );

    final List<PracticeEntry> entries = QuestionTree.flatten(exam);

    expect(entries.single.question.options, <String>['Umuofia', 'Lagos']);
  });

  group('resumeIndex', () {
    const ExamDetail exam = ExamDetail(
      summary: _summary,
      questions: <Question>[
        Question(id: 'q1', path: '1', type: 'container', text: 'Part', isContainer: true, sortOrder: 1),
        Question(id: 'q1a', path: '1.1', type: 'mcq', text: 'One', options: <String>['a', 'b'], parentId: 'q1', sortOrder: 1),
        Question(id: 'q1b', path: '1.2', type: 'mcq', text: 'Two', options: <String>['a', 'b'], parentId: 'q1', sortOrder: 2),
        Question(id: 'q1c', path: '1.3', type: 'mcq', text: 'Three', options: <String>['a', 'b'], parentId: 'q1', sortOrder: 3),
      ],
    );
    final List<PracticeEntry> entries = QuestionTree.flatten(exam);

    test('opens at the first unanswered question', () {
      expect(QuestionTree.resumeIndex(entries, <String>{'q1a'}), 1);
      expect(QuestionTree.resumeIndex(entries, <String>{'q1a', 'q1b'}), 2);
    });

    test('an explicit jump wins and is clamped to the paper', () {
      expect(QuestionTree.resumeIndex(entries, <String>{'q1a'}, requested: 2), 2);
      expect(QuestionTree.resumeIndex(entries, <String>{}, requested: 99), 2);
    });

    test('a fresh or fully answered paper opens at the start', () {
      expect(QuestionTree.resumeIndex(entries, <String>{}), 0);
      expect(QuestionTree.resumeIndex(entries, <String>{'q1a', 'q1b', 'q1c'}), 0);
      expect(QuestionTree.resumeIndex(<PracticeEntry>[], <String>{}), 0);
    });
  });
}
