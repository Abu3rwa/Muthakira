/// Semantic colours that Material's ColorScheme does not define.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.credit,
    required this.onCredit,
    required this.creditContainer,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color credit;
  final Color onCredit;
  final Color creditContainer;

  static const SemanticColors light = SemanticColors(
    success: AppColors.success,
    onSuccess: Color(0xFFFFFFFF),
    successContainer: AppColors.sageLight,
    warning: AppColors.warning,
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFF7EEDC),
    info: AppColors.info,
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFE4EEEF),
    credit: AppColors.accent,
    onCredit: Color(0xFFFFFFFF),
    creditContainer: AppColors.clayLight,
  );

  static const SemanticColors dark = SemanticColors(
    success: AppColors.successDark,
    onSuccess: Color(0xFF04301C),
    successContainer: Color(0xFF234036),
    warning: AppColors.warningDark,
    onWarning: Color(0xFF3A2A00),
    warningContainer: Color(0xFF3E3216),
    info: AppColors.infoDark,
    onInfo: Color(0xFF0B2529),
    infoContainer: Color(0xFF1E3C42),
    credit: Color(0xFFE9AD86),
    onCredit: Color(0xFF3F2A00),
    creditContainer: AppColors.clayDark,
  );

  @override
  SemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? credit,
    Color? onCredit,
    Color? creditContainer,
  }) => SemanticColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    successContainer: successContainer ?? this.successContainer,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    warningContainer: warningContainer ?? this.warningContainer,
    info: info ?? this.info,
    onInfo: onInfo ?? this.onInfo,
    infoContainer: infoContainer ?? this.infoContainer,
    credit: credit ?? this.credit,
    onCredit: onCredit ?? this.onCredit,
    creditContainer: creditContainer ?? this.creditContainer,
  );

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      credit: Color.lerp(credit, other.credit, t)!,
      onCredit: Color.lerp(onCredit, other.onCredit, t)!,
      creditContainer: Color.lerp(creditContainer, other.creditContainer, t)!,
    );
  }
}

extension SemanticColorsX on BuildContext {
  SemanticColors get semantics => Theme.of(this).extension<SemanticColors>()!;
}