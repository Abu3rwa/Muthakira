/// Student-facing labels for the API's class-level and stream keys.
library;

import 'package:flutter/widgets.dart';

import '../app/app_context.dart';

String? classLabel(BuildContext context, String? value) => switch (value) {
  'secondary_1' => context.l10n.secondary1,
  'secondary_2' => context.l10n.secondary2,
  'secondary_3' => context.l10n.secondary3,
  _ => null,
};

String? streamLabel(BuildContext context, String? value) => switch (value) {
  'science' => context.l10n.streamScience,
  'literary' => context.l10n.streamLiterary,
  _ => null,
};
