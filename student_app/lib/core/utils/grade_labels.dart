/// Maps the class values the API uses to their student-facing names.
library;

import '../l10n/generated/app_localizations.dart';

/// Accepts both signup keys (`secondary_2`) and material grades (`2`).
String gradeLabel(AppLocalizations l10n, String? value) => switch (value) {
  'secondary_1' || '1' => l10n.secondary1,
  'secondary_2' || '2' => l10n.secondary2,
  'secondary_3' || '3' => l10n.secondary3,
  final String other when other.trim().isNotEmpty => other.trim(),
  _ => l10n.notAvailable,
};

/// The materials API takes the bare grade (`1`..`3`), not the signup key.
String? materialGradeValue(String? profileClassLevel) => switch (profileClassLevel) {
  'secondary_1' || '1' => '1',
  'secondary_2' || '2' => '2',
  'secondary_3' || '3' => '3',
  _ => null,
};
