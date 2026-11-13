/// Maps an API error code to a localised message. The English `message` from
/// the server is never shown to students.
library;

import '../errors/error_codes.dart';
import '../errors/failure.dart';
import '../l10n/generated/app_localizations.dart';

String failureMessage(AppLocalizations l10n, AppFailure failure) {
  if (failure.kind == FailureKind.network) return l10n.errorNetworkError;
  if (failure.kind == FailureKind.server) return l10n.errorInternalError;
  return switch (failure.code) {
    ErrorCodes.unauthorized => l10n.errorUnauthorized,
    ErrorCodes.invalidCredentials => l10n.errorInvalidCredentials,
    ErrorCodes.invalidToken => l10n.errorInvalidToken,
    ErrorCodes.invalidRefreshToken => l10n.errorInvalidRefreshToken,
    ErrorCodes.accountBlocked => l10n.errorAccountBlocked,
    ErrorCodes.forbidden => l10n.errorForbidden,
    ErrorCodes.notFound => l10n.errorNotFound,
    ErrorCodes.phoneTaken => l10n.errorPhoneTaken,
    ErrorCodes.invalidPhone => l10n.errorInvalidPhone,
    ErrorCodes.emailTaken => l10n.errorEmailTaken,
    ErrorCodes.invalidEmail => l10n.errorInvalidEmail,
    ErrorCodes.invalidResetCode => l10n.errorInvalidResetCode,
    ErrorCodes.invalidRecoveryCode => l10n.errorInvalidRecoveryCode,
    ErrorCodes.mailNotConfigured => l10n.errorMailNotConfigured,
    ErrorCodes.mailSendFailed => l10n.errorMailSendFailed,
    ErrorCodes.mailVerifyFailed => l10n.errorMailSendFailed,
    ErrorCodes.validationError => l10n.errorValidationError,
    ErrorCodes.rateLimited => l10n.errorRateLimited,
    ErrorCodes.insufficientCredits => l10n.errorInsufficientCredits,
    ErrorCodes.examNotFound => l10n.errorExamNotFound,
    ErrorCodes.examLocked => l10n.errorExamLocked,
    ErrorCodes.practiceDisabled => l10n.errorPracticeDisabled,
    ErrorCodes.questionNotFound => l10n.errorQuestionNotFound,
    ErrorCodes.questionNotAnswerable => l10n.errorQuestionNotAnswerable,
    ErrorCodes.attemptNotFound => l10n.errorAttemptNotFound,
    ErrorCodes.attemptClosed => l10n.errorAttemptClosed,
    ErrorCodes.answerNotFound => l10n.errorNotFound,
    ErrorCodes.duplicateValue => l10n.errorDuplicateValue,
    ErrorCodes.packageNotFound => l10n.errorPackageNotFound,
    ErrorCodes.paymentAccountNotConfigured => l10n.errorPaymentAccountNotConfigured,
    ErrorCodes.tooManyOpenPayments => l10n.errorTooManyOpenPayments,
    ErrorCodes.paymentAmountsExhausted => l10n.errorPaymentAmountsExhausted,
    ErrorCodes.paymentRequestNotFound => l10n.errorPaymentRequestNotFound,
    ErrorCodes.paymentNotSubmittable => l10n.errorPaymentNotSubmittable,
    ErrorCodes.paymentNotCancellable => l10n.errorPaymentNotCancellable,
    ErrorCodes.invalidReference => l10n.errorInvalidReference,
    ErrorCodes.referenceAlreadyUsed => l10n.errorReferenceAlreadyUsed,
    ErrorCodes.receiptNotFound => l10n.errorReceiptNotFound,
    ErrorCodes.receiptAlreadyAttached => l10n.errorReceiptAlreadyAttached,
    ErrorCodes.receiptTooLarge => l10n.errorReceiptTooLarge,
    ErrorCodes.receiptTypeNotAllowed => l10n.errorReceiptTypeNotAllowed,
    ErrorCodes.receiptFieldInvalid => l10n.errorReceiptFieldInvalid,
    ErrorCodes.receiptRequired => l10n.errorReceiptRequired,
    ErrorCodes.receiptFileMissing => l10n.errorReceiptFileMissing,
    ErrorCodes.receiptUploadFailed => l10n.errorReceiptUploadFailed,
    ErrorCodes.aiDisabled => l10n.errorAiDisabled,
    ErrorCodes.aiNotConfigured => l10n.errorAiDisabled,
    ErrorCodes.aiBudgetExceeded => l10n.errorAiBudgetExceeded,
    ErrorCodes.aiInvalidOutput => l10n.errorAiInvalidOutput,
    ErrorCodes.aiContentUnsafe => l10n.errorAiContentUnsafe,
    ErrorCodes.aiTimeout => l10n.errorAiTimeout,
    ErrorCodes.aiUpstreamError => l10n.errorAiUpstream,
    ErrorCodes.notAiMarkable => l10n.errorNotAiMarkable,
    ErrorCodes.answerAlreadyMarked => l10n.errorAnswerAlreadyMarked,
    ErrorCodes.reviewAlreadyPending => l10n.errorReviewAlreadyPending,
    ErrorCodes.aiInFlight => l10n.errorAiInFlight,
    ErrorCodes.emptyAnswer => l10n.errorEmptyAnswer,
    ErrorCodes.classLevelRequired => l10n.errorClassLevelRequired,
    ErrorCodes.materialRequired => l10n.errorMaterialRequired,
    ErrorCodes.materialNotFound => l10n.errorMaterialNotFound,
    ErrorCodes.materialFileMissing => l10n.errorMaterialFileMissing,
    ErrorCodes.materialTypeNotAllowed => l10n.errorMaterialTypeNotAllowed,
    ErrorCodes.materialPdfNotSupported => l10n.errorMaterialPdfNotSupported,
    ErrorCodes.materialTooLarge => l10n.errorMaterialTooLarge,
    ErrorCodes.materialTooShort => l10n.errorMaterialTooShort,
    ErrorCodes.materialTooLong => l10n.errorMaterialTooLong,
    ErrorCodes.materialUploadFailed => l10n.errorMaterialUploadFailed,
    ErrorCodes.materialFieldInvalid => l10n.errorMaterialFieldInvalid,
    ErrorCodes.generationJobNotFound => l10n.errorGenerationNotFound,
    ErrorCodes.studentOnly => l10n.errorStudentOnly,
    ErrorCodes.roleForbidden => l10n.errorForbidden,
    ErrorCodes.reportAlreadyOpen => l10n.errorReportAlreadyOpen,
    ErrorCodes.invalidCursor => l10n.errorInvalidCursor,
    ErrorCodes.internalError => l10n.errorInternalError,
    ErrorCodes.cacheError => l10n.errorCacheError,
    _ => l10n.errorUnknown,
  };
}

/// Field-level message for a 422 detail, falling back to the generic copy.
String fieldMessage(AppLocalizations l10n, AppFailure failure, String field) {
  final String? detail = failure.fieldErrors[field];
  if (detail == null || detail.isEmpty) return l10n.errorValidationError;
  return detail;
}