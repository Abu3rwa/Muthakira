/// One server-chosen adaptive question. Selection is deterministic and free.
library;

import '../../../core/utils/parse.dart';
import '../../exams/domain/exam_models.dart';

const Set<String> _exhaustedReasons = <String>{'exhausted'};
const Set<String> _blockedReasons = <String>{'no_access'};

class AdaptiveStep {
  const AdaptiveStep({
    required this.question,
    required this.reasonCode,
    required this.remainingCount,
    this.stimulus,
    this.targetDifficulty,
    this.ability,
  });

  final Question? question;
  final String reasonCode;
  final int remainingCount;
  final Stimulus? stimulus;
  final int? targetDifficulty;
  final double? ability;

  bool get hasQuestion => question != null;
  bool get exhausted => !hasQuestion && _exhaustedReasons.contains(reasonCode);

  /// Only trial/free questions were eligible because the paper is locked.
  bool get blockedByAccess => !hasQuestion && _blockedReasons.contains(reasonCode);

  factory AdaptiveStep.fromJson(Map<String, Object?> json) {
    final Map<String, Object?>? raw = json['question'] is Map
        ? Parse.map(json['question'])
        : null;
    final Object? rawStimulus = raw?['stimulus'];
    return AdaptiveStep(
      question: raw == null ? null : Question.fromJson(raw),
      stimulus: rawStimulus is Map ? Stimulus.fromJson(Parse.map(rawStimulus)) : null,
      reasonCode: Parse.string(json['reason_code']),
      remainingCount: Parse.integer(json['remaining_count']),
      targetDifficulty: Parse.integerOrNull(json['target_difficulty']),
      ability: Parse.decimalOrNull(json['ability']),
    );
  }
}
