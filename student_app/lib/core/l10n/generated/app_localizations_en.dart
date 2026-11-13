// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mothakira';

  @override
  String get tagline => 'Study smarter';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Try again';

  @override
  String get save => 'Save';

  @override
  String get continueLabel => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get share => 'Share';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search';

  @override
  String get filters => 'Filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get apply => 'Apply';

  @override
  String get viewPaper => 'View paper';

  @override
  String get previewQuestions => 'Preview questions';

  @override
  String get topUpBalance => 'Top up';

  @override
  String get browseExams => 'Browse exams';

  @override
  String get balanceShort => 'Balance';

  @override
  String get walletUnavailable => 'Balance unavailable';

  @override
  String get showMore => 'More';

  @override
  String get showLess => 'Less';

  @override
  String get loading => 'Loading…';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonHint =>
      'This feature is not available yet. We are working on it.';

  @override
  String get offline => 'No connection';

  @override
  String get offlineBanner => 'You are offline. Showing saved data.';

  @override
  String get serverWaking => 'Server is waking up…';

  @override
  String get serverWakingHint =>
      'The first request can take a few seconds. Thanks for waiting.';

  @override
  String get errorTitle => 'That did not work';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String lastUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get savedBadge => 'Saved';

  @override
  String get pendingSyncBadge => 'Waiting to sync';

  @override
  String get requiredField => 'This field is required';

  @override
  String get optional => 'Optional';

  @override
  String get seeAll => 'See all';

  @override
  String version(String value) {
    return 'Version $value';
  }

  @override
  String get support => 'Support';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get terms => 'Terms';

  @override
  String get privacy => 'Privacy';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirmTitle => 'Sign out?';

  @override
  String get logoutConfirmBody =>
      'Saved data on this device will be removed. You will need to sign in again.';

  @override
  String get sdg => 'SDG';

  @override
  String get creditsLabel => 'Credits';

  @override
  String get available => 'Available';

  @override
  String get reserved => 'Reserved';

  @override
  String get balance => 'Balance';

  @override
  String get notAvailable => '—';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get chooseLanguageHint => 'You can change this later in Settings.';

  @override
  String get preferredLanguage => 'Preferred language';

  @override
  String get preferredLanguageHint =>
      'Saved with your account and sets the app language.';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get welcomeTitle => 'Sudan Certificate exams in your pocket';

  @override
  String get welcomeBody =>
      'Study smarter with past papers and instant marking.';

  @override
  String get welcomePoint1 => 'Official exams sorted by subject and year';

  @override
  String get welcomePoint2 =>
      'Instant marking with the model answer for every question';

  @override
  String get welcomePoint3 => 'Top up credits easily through Bankak';

  @override
  String get getStarted => 'Get started';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get phone => 'Phone number';

  @override
  String get password => 'Password';

  @override
  String get newPassword => 'New password';

  @override
  String get classLevel => 'Class';

  @override
  String get stream => 'Stream';

  @override
  String get other => 'Other';

  @override
  String get language => 'Language';

  @override
  String get termsAccept => 'I agree to the Terms and the Privacy Policy';

  @override
  String get termsTitle => 'Terms and conditions';

  @override
  String get privacyTitle => 'Privacy policy';

  @override
  String get recoveryCodeTitle => 'Your recovery code';

  @override
  String get recoveryCodeBody =>
      'This is the only code that lets you reset your password if you forget it. Keep it somewhere safe.';

  @override
  String get recoveryCodeWarning =>
      'We will not show this code again. Do not share it with anyone.';

  @override
  String get iSavedIt => 'I saved the code somewhere safe';

  @override
  String get recoveryCodeCopied => 'Recovery code copied';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordBody =>
      'Enter your email and we will send you a 6-digit code to reset your password.';

  @override
  String get forgotPasswordCodeBody =>
      'Enter the 6-digit code from the email, then choose a new password.';

  @override
  String get resetCode => 'Reset code';

  @override
  String get resetCodeHint => 'The 6-digit code from the email';

  @override
  String resetCodeSentTo(String email) {
    return 'If $email has an account, a code is on its way. Check the spam folder too.';
  }

  @override
  String get sendResetCode => 'Email me a code';

  @override
  String get resendCode => 'Send a new code';

  @override
  String get useSavedRecoveryCode => 'Use a saved recovery code instead';

  @override
  String get useEmailedCode => 'Use an emailed code instead';

  @override
  String resetCodeExpiry(int minutes) {
    return 'The code expires in $minutes minutes.';
  }

  @override
  String get passwordChangedBody =>
      'Your password has been changed. Sign in with the new one.';

  @override
  String get recoveryCode => 'Recovery code';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetSuccessTitle => 'Password changed';

  @override
  String get resetSuccessBody =>
      'Save your new recovery code, then sign in with your new password.';

  @override
  String get blockedTitle => 'Account suspended';

  @override
  String get blockedBody =>
      'This account has been suspended. Contact support for help.';

  @override
  String get phoneHint => 'Example: 0912345678';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get nameHint => 'Your name as it appears on your certificate';

  @override
  String get classLevelHint => 'Choose your class';

  @override
  String get streamHint => 'Science or literary';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordMedium => 'Medium';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get secondary1 => 'Secondary 1';

  @override
  String get secondary2 => 'Secondary 2';

  @override
  String get secondary3 => 'Secondary 3 (Sudan Certificate)';

  @override
  String get streamScience => 'Science';

  @override
  String get streamLiterary => 'Literary';

  @override
  String get sessionExpired => 'Your session ended. Please sign in again.';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get availableCredits => 'Available credits';

  @override
  String reservedHint(int count) {
    return '$count of your credits are held for a payment under review.';
  }

  @override
  String get nextExpiry => 'Next expiry';

  @override
  String expirySoon(String date) {
    return 'Some of your credits expire on $date. Use them before then.';
  }

  @override
  String get lowCredits => 'Your credits are low. Top up to keep studying.';

  @override
  String get addCredit => 'Add credits';

  @override
  String get ledgerTitle => 'Credit history';

  @override
  String get ledgerEmpty => 'No activity yet';

  @override
  String get ledgerEmptyHint => 'Every credit added or used will show up here.';

  @override
  String get entrySignupBonus => 'Welcome credits';

  @override
  String get entryPurchase => 'Credit purchase';

  @override
  String get entrySpend => 'Credits used';

  @override
  String get entryExpiry => 'Credits expired';

  @override
  String get entryAdminAdjust => 'Admin adjustment';

  @override
  String entryExamUnlock(String key) {
    return 'Unlocked exam $key';
  }

  @override
  String entryPaymentApproved(String code) {
    return 'Payment $code approved';
  }

  @override
  String get entryUnlockShort => 'Paper unlocked';

  @override
  String get entryPaymentApprovedShort => 'Payment approved';

  @override
  String creditsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits',
      one: '1 credit',
    );
    return '$_temp0';
  }

  @override
  String get examsTitle => 'Exams';

  @override
  String get subject => 'Subject';

  @override
  String get year => 'Year';

  @override
  String get session => 'Session';

  @override
  String get allSubjects => 'All subjects';

  @override
  String get allYears => 'All years';

  @override
  String get allSessions => 'All sessions';

  @override
  String get allLanguages => 'All languages';

  @override
  String get free => 'Free';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get locked => 'Locked';

  @override
  String lockedFor(String count) {
    return 'Locked · $count';
  }

  @override
  String unlockFor(String count) {
    return 'Unlock for $count';
  }

  @override
  String get unlockConfirmTitle => 'Unlock this exam?';

  @override
  String unlockConfirmBody(String cost, String balance) {
    return '$cost will be taken from your credits. You currently have $balance.';
  }

  @override
  String balanceAfter(String value) {
    return 'Balance after unlocking (estimate): $value';
  }

  @override
  String get unlock => 'Unlock exam';

  @override
  String get unlockSuccess => 'Exam unlocked. Good luck!';

  @override
  String get startPractice => 'Start practice';

  @override
  String get resumePractice => 'Resume practice';

  @override
  String get practiceDisabled => 'Practice unavailable';

  @override
  String get practiceDisabledHint =>
      'Practice on this exam has been turned off by the admin. You can still read it.';

  @override
  String get paperViewer => 'Read the paper';

  @override
  String get instructions => 'Instructions';

  @override
  String totalMarks(String count) {
    return '$count marks';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String questionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String get myUnlocks => 'My unlocked exams';

  @override
  String get myUnlocksEmpty => 'You have not unlocked an exam yet';

  @override
  String get myUnlocksEmptyHint =>
      'Unlock an exam and it will appear here, available offline.';

  @override
  String get yourOpenPapers => 'Your open papers';

  @override
  String partialPapersFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count papers could not load',
      one: 'One paper could not load',
    );
    return '$_temp0';
  }

  @override
  String get viewKeys => 'Model answers';

  @override
  String get trialBadge => 'Trial';

  @override
  String get examNotFound => 'We could not find that exam';

  @override
  String get noExams => 'No exams match your filters';

  @override
  String get noExamsHint => 'Try different filters or another search word.';

  @override
  String get searchExams => 'Search a subject or year';

  @override
  String get stimulusTitle => 'Passage';

  @override
  String questionLabel(String path) {
    return 'Question $path';
  }

  @override
  String get answerKey => 'Correct answer';

  @override
  String get explanation => 'Explanation';

  @override
  String get modelAnswer => 'Model answer';

  @override
  String get criteria => 'Marking criteria';

  @override
  String get acceptedAlternatives => 'Accepted alternatives';

  @override
  String get lockedQuestionHint =>
      'Unlock the exam to see this question and its answer.';

  @override
  String fieldTooShort(int min) {
    return 'Use at least $min characters';
  }

  @override
  String fieldTooLong(int max) {
    return 'Use at most $max characters';
  }

  @override
  String get fieldPhoneInvalid => 'Enter a valid phone number';

  @override
  String get fieldPasswordShort => 'Your password needs at least 8 characters';

  @override
  String get fieldTermsRequired => 'Please accept the terms to continue';

  @override
  String get fieldAnswerRequired => 'Write your answer first';

  @override
  String get practiceTitle => 'Practice';

  @override
  String questionOf(String current, String total) {
    return 'Question $current of $total';
  }

  @override
  String get checkAnswer => 'Check answer';

  @override
  String get nextQuestion => 'Next question';

  @override
  String get previousQuestion => 'Previous question';

  @override
  String get finishPractice => 'Finish practice';

  @override
  String get finishConfirmTitle => 'Finish this practice session?';

  @override
  String get finishConfirmBody =>
      'You can review your answers afterwards on the result screen.';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Not correct';

  @override
  String partlyCorrect(String awarded, String total) {
    return 'Partly correct — $awarded of $total';
  }

  @override
  String marksAwarded(String value) {
    return '$value marks';
  }

  @override
  String marksWorth(String value) {
    return 'Worth $value marks';
  }

  @override
  String get answerSaved => 'Your answer was saved';

  @override
  String get answerSubmitted => 'Submitted for marking';

  @override
  String get savedOnDevice => 'Saved on this device';

  @override
  String get waitingToSend => 'Waiting to send';

  @override
  String get checkDisabledHint =>
      'Choose or write an answer to enable checking.';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get structureUnavailable =>
      'There isn\'t enough data to show this question type. Report the question so we can review it.';

  @override
  String get currentLabel => 'Current';

  @override
  String get backToQuestions => 'Back to questions';

  @override
  String pendingUploadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answers waiting to send',
      one: 'One answer waiting to send',
    );
    return '$_temp0';
  }

  @override
  String get provisionalScore => 'Provisional result';

  @override
  String get finalScore => 'Final result';

  @override
  String get newPractice => 'New practice';

  @override
  String get yourAnswerUnavailable =>
      'Your answer isn\'t available on this device.';

  @override
  String get keyUnavailable => 'The answer isn\'t available yet.';

  @override
  String get pendingSelf =>
      'Saved. Mark this question yourself by comparing your answer with the model answer.';

  @override
  String get pendingAi =>
      'Saved. You can request AI marking with a separate button.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get tryAgainAiWarning =>
      'Re-answering an AI-marked question needs a new (paid) AI grading.';

  @override
  String get reportTextHint =>
      'Extra details (optional, at least 5 characters)';

  @override
  String attemptsCount(String count) {
    return 'Attempt $count';
  }

  @override
  String get questionNavigator => 'Question map';

  @override
  String get answeredLabel => 'Answered';

  @override
  String get unansweredLabel => 'Not answered';

  @override
  String get pendingLabel => 'Waiting for marking';

  @override
  String get reportQuestion => 'Report a question';

  @override
  String get reportReasonLabel => 'What is wrong?';

  @override
  String get reportReasonHint => 'Describe the problem (at least 5 characters)';

  @override
  String get reportSent => 'Report sent. Thank you.';

  @override
  String get resultTitle => 'Result';

  @override
  String scoreOf(String awarded, String total) {
    return '$awarded of $total';
  }

  @override
  String get resultPendingNote =>
      'Questions that are not marked yet are not included in the score.';

  @override
  String get reviewAnswers => 'Review answers';

  @override
  String get retryWrong => 'Retry wrong questions';

  @override
  String get backToExams => 'Back to exams';

  @override
  String get sectionBreakdown => 'By section';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get noAnswer => 'No answer';

  @override
  String get answerHintText => 'Write your answer here';

  @override
  String get selectOne => 'Choose one answer';

  @override
  String get selectAllThatApply => 'Choose all correct answers';

  @override
  String get trueLabel => 'True';

  @override
  String get falseLabel => 'False';

  @override
  String blankLabel(String index) {
    return 'Blank $index';
  }

  @override
  String cellLabel(String row, String column) {
    return 'Row $row, column $column';
  }

  @override
  String get reorderHint => 'Drag to reorder';

  @override
  String orderingItemLabel(String index, String total) {
    return 'Item $index of $total';
  }

  @override
  String get numericKeyboardHint =>
      'Enter a number (Arabic digits and decimal commas accepted)';

  @override
  String get matchWith => 'Match with';

  @override
  String get numericHint => 'Enter a number';

  @override
  String get selfMarkTitle => 'Mark yourself';

  @override
  String get selfMarkHint =>
      'Compare your answer with the model answer, then rate yourself. The mark is sent to the server and counts towards your result.';

  @override
  String get selfMarkGotIt => 'I got it right';

  @override
  String get selfMarkPartial => 'Partly right';

  @override
  String get selfMarkMissed => 'I did not get it right';

  @override
  String get offlineQueued =>
      'You are offline. Your answer was saved and will be sent when you reconnect.';

  @override
  String get attemptClosedTitle => 'Session closed';

  @override
  String get startNewAttempt => 'Start a new session';

  @override
  String get resumeTitle => 'Pick up where you left off';

  @override
  String get packagesTitle => 'Credit packages';

  @override
  String pricePerCredit(String value) {
    return '$value per credit';
  }

  @override
  String get buyPackage => 'Buy this package';

  @override
  String get paymentsTitle => 'My payments';

  @override
  String get paymentsEmpty => 'No payment requests';

  @override
  String get paymentsEmptyHint =>
      'Choose a credit package, transfer the amount through Bankak, then upload the receipt here.';

  @override
  String get paymentInstructionsTitle => 'How to pay';

  @override
  String get stepAmount => '1. Transfer this exact amount';

  @override
  String get stepBank => '2. To this account';

  @override
  String get stepBankak => '3. Complete the transfer in the Bankak app';

  @override
  String get stepReceipt =>
      '4. Upload the receipt and enter the transaction reference';

  @override
  String get stepStatus => '5. Follow the request status';

  @override
  String get exactAmountWarning =>
      'Transfer the exact same amount. Any difference delays approval.';

  @override
  String get bankName => 'Bank';

  @override
  String get accountName => 'Account name';

  @override
  String get accountNumber => 'Account number';

  @override
  String get paymentCode => 'Payment code';

  @override
  String get openBankak => 'Open Bankak app';

  @override
  String get bankakNotInstalled =>
      'The Bankak app is not installed on this device.';

  @override
  String get reviewTimeHint =>
      'Requests are usually reviewed within a few hours.';

  @override
  String get referenceLabel => 'Transaction reference';

  @override
  String get senderNameLabel => 'Sender name';

  @override
  String get receiptLabel => 'Receipt image';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get choosePdf => 'Choose a PDF file';

  @override
  String get receiptPreview => 'Receipt preview';

  @override
  String get submitReceipt => 'Submit receipt';

  @override
  String get receiptUploading => 'Uploading receipt…';

  @override
  String get receiptTooLargeLocal =>
      'The file is larger than 8 MB. Choose a smaller image.';

  @override
  String get receiptTypeInvalidLocal =>
      'That file type is not supported. Use JPEG, PNG, WebP or PDF.';

  @override
  String get cameraRationaleTitle => 'We need camera access';

  @override
  String get cameraRationaleBody =>
      'We use the camera only to photograph your transfer receipt. We never reach any other photos unless you pick them.';

  @override
  String get statusPendingPayment => 'Waiting for payment';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusUnderReview => 'Under review';

  @override
  String get statusNeedsInfo => 'Needs information';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get timelineCreated => 'Request created';

  @override
  String get timelineSubmitted => 'Receipt submitted';

  @override
  String get timelineReviewed => 'Under review';

  @override
  String get timelineDecided => 'Decision';

  @override
  String get rejectReasonLabel => 'Reason for rejection';

  @override
  String get resubmit => 'Submit again';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get cancelConfirmTitle => 'Cancel this payment request?';

  @override
  String get cancelConfirmBody =>
      'This request will be cancelled and you can create a new one afterwards.';

  @override
  String get paymentApprovedTitle => 'Credits added!';

  @override
  String get viewReceipt => 'View receipt';

  @override
  String get expectedAmountLabel => 'Amount to transfer';

  @override
  String get homeTitle => 'Home';

  @override
  String greeting(String name) {
    return 'Hello $name';
  }

  @override
  String get recommendedForYou => 'Recommended for you';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get newPapers => 'Newest papers';

  @override
  String get continueStudying => 'Continue studying';

  @override
  String get profileTitle => 'My account';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceHint => 'Pick the look that is easiest on your eyes.';

  @override
  String get groupReading => 'Reading';

  @override
  String get groupLanguageNumbers => 'Language and numbers';

  @override
  String get groupData => 'Data and storage';

  @override
  String get groupHelp => 'Support and diagnostics';

  @override
  String get readingSample => 'Read slowly, and review your lesson every day.';

  @override
  String get appLanguageHint => 'The language of buttons, menus and messages.';

  @override
  String get digitStyleHint =>
      'Number shape only; it does not change the language.';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get textSize => 'Text size';

  @override
  String get digitStyle => 'Digit style';

  @override
  String get digitsArabic => 'Arabic ١٢٣';

  @override
  String get digitsWestern => 'Western 123';

  @override
  String get dataSaver => 'Data saver';

  @override
  String get dataSaverHint =>
      'Do not download model answers or large papers automatically.';

  @override
  String get clearCache => 'Clear saved data';

  @override
  String get clearCacheConfirmTitle => 'Clear saved data?';

  @override
  String get clearCacheConfirmBody =>
      'Saved papers, answers, drafts and answers waiting to upload will be removed from this device. Your credits, account and sign-in stay the same.';

  @override
  String get clearCacheIncludesQueue =>
      'Drafts and answers waiting to upload will also be deleted.';

  @override
  String get cacheCleared => 'Saved data cleared';

  @override
  String get paymentHelp => 'Payment help';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get reportProblemHint =>
      'Shares the recent error log without any personal data.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountHint =>
      'Automatic account deletion is not available yet. Contact support and we will do it manually.';

  @override
  String get aboutAndLegal => 'About and legal';

  @override
  String get appLanguage => 'App language';

  @override
  String get aboutApp => 'About the app';

  @override
  String get diagnosticsEmpty => 'No errors recorded';

  @override
  String get sendReport => 'Send report';

  @override
  String get forceUpdateTitle => 'Update required';

  @override
  String get forceUpdateBody =>
      'A newer version is available. Update the app from the store, then open it again.';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get maintenanceTitle => 'Service temporarily unavailable';

  @override
  String get errorUnauthorized => 'Your session ended. Please sign in again.';

  @override
  String get errorInvalidCredentials =>
      'That email or password is not correct.';

  @override
  String get errorInvalidToken => 'Your session ended. Please sign in again.';

  @override
  String get errorInvalidRefreshToken =>
      'Your session ended. Please sign in again.';

  @override
  String get errorAccountBlocked =>
      'This account is suspended. Contact support.';

  @override
  String get errorForbidden => 'You do not have permission for that action.';

  @override
  String get errorNotFound => 'We could not find what you were looking for.';

  @override
  String get errorPhoneTaken =>
      'That phone number is already registered. Try signing in.';

  @override
  String get errorEmailTaken =>
      'That email is already registered. Try signing in.';

  @override
  String get errorInvalidEmail => 'Enter a valid email address.';

  @override
  String get errorInvalidResetCode =>
      'That code is not correct or has expired.';

  @override
  String get errorMailNotConfigured =>
      'Email is not set up on the server yet. Contact support.';

  @override
  String get errorMailSendFailed =>
      'The email could not be sent. Try again in a moment.';

  @override
  String get errorInvalidPhone =>
      'Enter a valid Sudanese mobile number, for example 0912345678.';

  @override
  String get errorReceiptUploadFailed =>
      'The receipt could not be uploaded. Try again.';

  @override
  String get errorStudentOnly => 'This action is available to students only.';

  @override
  String get errorInvalidRecoveryCode => 'That recovery code is not correct.';

  @override
  String get errorValidationError => 'Please check the fields marked in red.';

  @override
  String get errorRateLimited =>
      'Too many requests. Wait a moment and try again.';

  @override
  String get errorInsufficientCredits =>
      'You do not have enough credits. Top up to continue.';

  @override
  String get errorExamNotFound => 'We could not find that exam.';

  @override
  String get errorExamLocked => 'This exam is locked. Unlock it first.';

  @override
  String get errorPracticeDisabled =>
      'Practice is not available for this exam.';

  @override
  String get errorQuestionNotFound => 'We could not find that question.';

  @override
  String get errorQuestionNotAnswerable =>
      'Answer the sub-questions, not the section itself.';

  @override
  String get errorAttemptNotFound => 'We could not find that practice session.';

  @override
  String get errorAttemptClosed =>
      'That practice session is closed. Start a new one.';

  @override
  String get errorDuplicateValue => 'That value is already in use.';

  @override
  String get errorPackageNotFound =>
      'That credit package is no longer available.';

  @override
  String get errorPaymentAccountNotConfigured =>
      'The receiving account is not set up yet. Contact support.';

  @override
  String get errorTooManyOpenPayments =>
      'You have open payment requests. Finish or cancel one first.';

  @override
  String get errorPaymentAmountsExhausted =>
      'No amounts are free right now. Try again shortly.';

  @override
  String get errorPaymentRequestNotFound =>
      'We could not find that payment request.';

  @override
  String get errorPaymentNotSubmittable =>
      'This request can no longer be submitted.';

  @override
  String get errorPaymentNotCancellable =>
      'A request that was already submitted cannot be cancelled.';

  @override
  String get errorInvalidReference =>
      'Enter the Bankak transaction reference (at least 4 characters).';

  @override
  String get errorReferenceAlreadyUsed =>
      'That transaction reference is already used for another payment request.';

  @override
  String get errorReceiptNotFound => 'We could not find that receipt.';

  @override
  String get errorReceiptAlreadyAttached =>
      'That receipt is already attached to another payment request.';

  @override
  String get errorReceiptTooLarge =>
      'The receipt is too large. The limit is 8 MB.';

  @override
  String get errorReceiptTypeNotAllowed =>
      'Upload a JPEG, PNG or WebP image, or a PDF file.';

  @override
  String get errorReceiptFieldInvalid => 'That receipt file is not valid.';

  @override
  String get errorReceiptRequired => 'Attach the receipt image first.';

  @override
  String get errorReceiptFileMissing =>
      'The file did not arrive. Please try again.';

  @override
  String get errorReportAlreadyOpen =>
      'You already reported this question. We are reviewing it.';

  @override
  String get errorInvalidCursor => 'Could not load more. Refresh the list.';

  @override
  String get errorInternalError =>
      'Something went wrong on the server. Please try again.';

  @override
  String get errorNetworkError =>
      'No internet connection. Check your network and try again.';

  @override
  String get errorCacheError => 'Could not read the saved data.';

  @override
  String get errorUnknown => 'Something unexpected happened. Please try again.';

  @override
  String get skip => 'Skip';

  @override
  String get all => 'All';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get errorHint => 'Check your connection and try again.';

  @override
  String get errorTimeout => 'The server took too long. Try again.';

  @override
  String errorFallback(String code) {
    return 'Unexpected error ($code).';
  }

  @override
  String get termsBody =>
      'By using Mothakira you agree to use the app for personal study only. Papers belong to their original owners and are shown for educational use. We keep your phone number, name and payment history to run your account and do not share them. Never share your recovery code.';

  @override
  String get aboutBody =>
      'Mothakira helps Sudan Certificate students study with official papers, instant marking and credit bought through Bankak.';

  @override
  String get maintenanceBody =>
      'We are updating the service. Try again shortly.';

  @override
  String get notFoundBody => 'The link is wrong or has changed.';

  @override
  String get goHome => 'Home';

  @override
  String get designGallery => 'Design gallery';

  @override
  String get reportReason1 => 'The question is unclear';

  @override
  String get reportReason2 => 'The answer key is wrong';

  @override
  String get reportReason3 => 'A typo in the text';

  @override
  String get reportReason4 => 'Something else';

  @override
  String get matchingInstruction => 'Pick the matching letter for each item';

  @override
  String get orderingInstruction => 'Put the items in the correct order';

  @override
  String get tableInstruction => 'Fill in the table cells';

  @override
  String get matrixInstruction => 'Enter the matrix values in the cells';

  @override
  String get truthTableInstruction =>
      'Complete the output column of the truth table';

  @override
  String get truthTableOutput => 'Output';

  @override
  String get multiInstruction => 'Choose every correct answer';

  @override
  String get diacriticsInstruction => 'Write the text with full diacritics';

  @override
  String get fillBlankInstruction => 'Fill in the blanks inside the text';

  @override
  String get blueprint => 'Tip: use paper and pen for working out.';

  @override
  String get streamNone => 'No stream';

  @override
  String get otherOption => 'Other (type it)';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue studying.';

  @override
  String get signupTitle => 'Create your account';

  @override
  String get signupSubtitle => 'A minute and you are ready to practise.';

  @override
  String get noAccount => 'No account yet?';

  @override
  String get recoverySavedHint =>
      'Tick the box once you have saved the code somewhere safe to continue.';

  @override
  String get signupBonus => 'A welcome credit is in your account';

  @override
  String get cooldownTitle => 'Too many attempts';

  @override
  String get cooldownBody => 'Wait a moment before trying again.';

  @override
  String get home => 'Home';

  @override
  String get exams => 'Papers';

  @override
  String get practice => 'Practice';

  @override
  String get wallet => 'Wallet';

  @override
  String get profile => 'Profile';

  @override
  String continueBody(String paper) {
    return 'You have an open practice session on $paper.';
  }

  @override
  String get pendingPaymentBanner => 'You have a payment waiting for review.';

  @override
  String get viewPayment => 'View request';

  @override
  String get paperContents => 'Paper contents';

  @override
  String get insufficientTitle => 'Not enough credit';

  @override
  String insufficientBody(String needed) {
    return 'You need $needed more to unlock this paper.';
  }

  @override
  String get keysLocked => 'Unlock the paper to see the keys.';

  @override
  String answeredCount(int count) {
    return 'Answered $count';
  }

  @override
  String get emptyPractice => 'No papers to practise yet';

  @override
  String get emptyPracticeHint => 'Unlock a paper from the Papers tab first.';

  @override
  String get noPackages => 'No packages available';

  @override
  String get noPackagesHint => 'Try later or contact support.';

  @override
  String get confirmPackageTitle => 'Confirm request';

  @override
  String confirmPackageBody(String price, String credits) {
    return 'We will create a payment request for $price for the $credits package.';
  }

  @override
  String get confirmPackage => 'Create payment request';

  @override
  String packageCredits(int count) {
    return '$count credits';
  }

  @override
  String get choosePackage => 'Choose a package';

  @override
  String get referenceHint => 'The number in your transfer notification';

  @override
  String get paymentSubmitted =>
      'We received your request. It will be reviewed shortly.';

  @override
  String get timeline => 'Request steps';

  @override
  String get requestCancelled => 'Request cancelled.';

  @override
  String get receiptMissing => 'No receipt attached';

  @override
  String get paymentHelpBody =>
      'If review is late or the request was rejected, contact support with your payment code.';

  @override
  String get expectedAmountCopy => 'Copy amount';

  @override
  String get openReceiptFile => 'Open file';

  @override
  String get removeFile => 'Remove file';

  @override
  String get receiptLoadFailed => 'Could not show the receipt. Try again.';

  @override
  String get availableNow => 'Available to use now';

  @override
  String get reservedNotSpendable =>
      'Reserved credits are held for a payment request under review and cannot be used yet.';

  @override
  String get balanceStaleHint =>
      'This balance is saved from the last successful update. Pull down to refresh.';

  @override
  String get loadMoreLedger => 'Load older entries';

  @override
  String get ledgerLoadMoreFailed =>
      'Could not load more. The entries shown stay as they are.';

  @override
  String get ledgerAllShown => 'All entries are shown';

  @override
  String get selectPackageHint =>
      'Pick one package, then continue to the transfer page.';

  @override
  String get continueToPayment => 'Continue to payment';

  @override
  String get openRequestNotice =>
      'You have an open payment request. Finish its receipt or cancel it before starting a new one.';

  @override
  String get manualReviewNotice =>
      'Support reviews the receipt manually before credits are added.';

  @override
  String get nextActionLabel => 'Next action';

  @override
  String get refreshStatus => 'Refresh status';

  @override
  String get paymentStatusExplainPending =>
      'No receipt sent yet. Transfer the exact amount, then attach the receipt.';

  @override
  String get paymentStatusExplainSubmitted =>
      'Your request arrived and is waiting for review to start. Nothing to do now.';

  @override
  String get paymentStatusExplainUnderReview =>
      'Support is reviewing the receipt now. Nothing to do.';

  @override
  String get paymentStatusExplainNeedsInfo =>
      'Support needs more information. Read the note, then resend the receipt.';

  @override
  String get paymentStatusExplainApproved =>
      'The request was approved and credits were added to your wallet.';

  @override
  String get paymentStatusExplainRejected =>
      'The receipt was rejected. Read the reason before starting a new request.';

  @override
  String get paymentStatusExplainExpired =>
      'The request expired before a receipt was sent. Start a new one from packages.';

  @override
  String get paymentStatusExplainCancelled =>
      'This request was cancelled. No credits were added.';

  @override
  String get paymentStatusExplainUnknown =>
      'The request state is unknown. Refresh or contact support.';

  @override
  String get requestSummaryTitle => 'Request summary';

  @override
  String get receiptSourceTitle => 'Choose receipt source';

  @override
  String get galleryRationaleTitle => 'Choose from photo library';

  @override
  String get galleryRationaleBody =>
      'We open your photo library only to pick the receipt image.';

  @override
  String get receiptPrepareFailed =>
      'Could not prepare the file. Try another image or a PDF.';

  @override
  String get receiptReading =>
      'Reading the transaction number from your receipt…';

  @override
  String get receiptExtracted =>
      'We filled the transaction number and your name from the receipt. Check them before sending.';

  @override
  String get receiptExtractManual =>
      'We could not read the transaction number from the receipt. Please type it yourself.';

  @override
  String get receiptAcceptedTitle => 'Accepted files';

  @override
  String receiptAcceptedValue(String size) {
    return 'JPEG, PNG, WebP or PDF · up to $size';
  }

  @override
  String get receiptPickHint =>
      'A clear image showing the amount and the transaction number.';

  @override
  String get receiptReady => 'File ready to send';

  @override
  String get preparingReceipt => 'Preparing the file…';

  @override
  String get replaceFile => 'Replace file';

  @override
  String get fileTypeLabel => 'Type';

  @override
  String get fileSizeLabel => 'Size';

  @override
  String get attachmentKeepNotice =>
      'The uploaded receipt stays attached; you will not need to upload it again.';

  @override
  String get receiptCompressedHint =>
      'The image was compressed to keep the upload small.';

  @override
  String get receiptOpenFailed =>
      'Could not open the file. Make sure an app that opens PDFs is installed.';

  @override
  String get openPayments => 'Open requests';

  @override
  String get paymentHistory => 'History';

  @override
  String get diagnosticsTitle => 'Diagnostics';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get appVersionLabel => 'App version';

  @override
  String get connectionLabel => 'Connection';

  @override
  String get online => 'Online';

  @override
  String get pendingAnswers => 'Answers waiting to sync';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get callSupport => 'Call';

  @override
  String get supportPhoneLabel => 'Phone';

  @override
  String get supportWhatsAppLabel => 'WhatsApp';

  @override
  String get openWhatsApp => 'Open WhatsApp';

  @override
  String get galleryColors => 'Colours';

  @override
  String get galleryTypography => 'Typography';

  @override
  String get galleryComponents => 'Components';

  @override
  String get accountDetails => 'Account details';

  @override
  String get apiMode => 'Data source';

  @override
  String get diagnosticsIntro =>
      'Information that helps support understand the problem. It does not include your password or recovery code.';

  @override
  String get diagnosticsConnectionHint =>
      'The network state as the app sees it right now.';

  @override
  String get diagnosticsPendingHint =>
      'Answers saved on this device that have not been sent yet.';

  @override
  String get diagnosticsApiHint => 'The server this build reads its data from.';

  @override
  String lastChecked(String time) {
    return 'Last checked: $time';
  }

  @override
  String get splashBusyHint =>
      'Checking your session… this can take up to 12 seconds on a slow connection.';

  @override
  String get fakeApi => 'Fake data';

  @override
  String get liveApi => 'Live server';

  @override
  String get couldNotOpen => 'Could not open the app. Try again.';

  @override
  String get reportShared => 'Thank you for sharing the report.';

  @override
  String get privacyBody =>
      'Mothakira keeps your phone number, name and payment history only to run your account, and never shares them. Your data is used to unlock papers and track your progress. You can request account deletion from the profile page.';

  @override
  String get adaptivePractice => 'Adaptive practice';

  @override
  String get adaptiveEntryHint =>
      'The server picks each next question from your earlier answers.';

  @override
  String adaptiveClassContext(String className) {
    return 'Your class: $className';
  }

  @override
  String get adaptivePickPaper => 'Choose a paper to practise adaptively';

  @override
  String get adaptiveFreeNote =>
      'Adaptive selection is free and uses no credits. Paid questions need the paper unlocked.';

  @override
  String get adaptiveNoControls =>
      'There is no manual topic or difficulty choice; the server adjusts difficulty from your results.';

  @override
  String get adaptiveStart => 'Start adaptive practice';

  @override
  String adaptiveRemaining(int count) {
    return 'Questions left: $count';
  }

  @override
  String get adaptiveNoQuestions => 'No questions available';

  @override
  String get adaptiveNoAccess =>
      'No questions are available before unlocking this paper. Unlock it, then come back.';

  @override
  String get adaptiveExhausted =>
      'You answered every available question in this paper.';

  @override
  String get adaptiveAutoLevel => 'Difficulty is chosen automatically';

  @override
  String get aiGradeTitle => 'AI marking';

  @override
  String get aiGradeConfirmTitle => 'Use AI marking?';

  @override
  String get aiGradeBody =>
      'Your answer is marked against the model answer and checked by a person when confidence is low.';

  @override
  String get aiGradeUnofficial => 'Unofficial result';

  @override
  String get aiGradeCostNote =>
      'The server sets the fee and reserves it when you ask. It is only charged once the result is approved, and fully returned if rejected or failed.';

  @override
  String aiGradeCharged(int credits) {
    return 'Charged $credits credits for marking.';
  }

  @override
  String get aiGradeReviewPending => 'Your answer is waiting for human review';

  @override
  String get aiGradeReviewBody =>
      'An initial AI mark was made; the final mark is confirmed after review.';

  @override
  String get aiGradeReviewNoCharge =>
      'No credits are charged now; they stay reserved until the review is approved, and are returned if it is rejected.';

  @override
  String get aiGradeInProgress => 'AI marking in progress…';

  @override
  String get aiGradeInProgressHint =>
      'This can take up to a minute. If the connection drops, the saved result is recovered automatically at no extra charge.';

  @override
  String get aiGradeRecovered =>
      'Restored the server\'s saved result at no extra charge.';

  @override
  String get aiGradeRejectedTitle => 'Review rejected';

  @override
  String get aiGradeRejectedBody =>
      'The reserved credits were returned to your balance. You can re-submit your answer or request a new AI marking.';

  @override
  String get aiGradeVoidedTitle => 'Review cancelled';

  @override
  String get aiGradeVoidedBody =>
      'Your answer changed after the review was requested, so it was cancelled and the credits returned. Request marking again for the current answer.';

  @override
  String get aiGradeTimeoutHint =>
      'The request took longer than expected. If marking finished, its saved result will appear — you are never charged twice.';

  @override
  String get aiGradeMissingPoints => 'Missing points';

  @override
  String get aiGradeFailed =>
      'Marking did not complete. Your answer is saved; you can try again later.';

  @override
  String get aiGradeUnavailable => 'AI marking is unavailable right now.';

  @override
  String get aiGrading => 'Marking…';

  @override
  String get myMaterials => 'My materials';

  @override
  String get materialsEntryHint =>
      'Turn your lessons into practice questions after staff review.';

  @override
  String get materialsEmpty => 'No materials yet';

  @override
  String get materialsEmptyHint =>
      'Add text or a photo of your lesson to generate practice questions.';

  @override
  String get materialAdd => 'Add material';

  @override
  String get materialKindText => 'Text';

  @override
  String get materialKindImage => 'Image';

  @override
  String get materialPrivate => 'Private to your account';

  @override
  String get materialStatusReview => 'Awaiting review';

  @override
  String get materialStatusReady => 'Ready';

  @override
  String get materialStatusFailed => 'Generation failed';

  @override
  String get materialStatusRejected => 'Rejected';

  @override
  String get materialNoGeneration => 'No questions yet';

  @override
  String get materialGenerate => 'Generate questions';

  @override
  String get materialSourcePaste => 'Pasted text';

  @override
  String get materialSourceFile => 'Text file';

  @override
  String get materialSourcePhoto => 'Page photo';

  @override
  String get materialSource => 'Source';

  @override
  String materialCreatedAt(String date) {
    return 'Added $date';
  }

  @override
  String get materialTextLabel => 'Material text';

  @override
  String get materialTextHint =>
      'Paste the lesson text here (at least 100 characters).';

  @override
  String get materialTooShort =>
      'The text is too short. Add at least 100 characters.';

  @override
  String get materialPickFile => 'Choose file';

  @override
  String get materialNoFile => 'No file chosen yet.';

  @override
  String get materialFileHint => '.txt, .md, or a PNG/JPEG image, up to 8 MB.';

  @override
  String get materialPdfDisabled =>
      'PDF extraction is not supported yet. Upload a photo of the page or paste the text.';

  @override
  String get materialPrivacyNote =>
      'The material stays private to your account and is not shared.';

  @override
  String get materialDraftKept =>
      'Your material was kept. Try again when the connection returns.';

  @override
  String get materialSaved => 'Material added';

  @override
  String get materialGradeHint =>
      'A secondary grade is required to generate questions.';

  @override
  String get materialSubjectHint =>
      'Pick a subject from the catalogue or type it.';

  @override
  String get materialGradeRequired => 'Choose the grade.';

  @override
  String get materialSubjectRequired => 'Enter a subject.';

  @override
  String get materialContinue => 'Continue';

  @override
  String get generationConfirmTitle => 'Generate questions';

  @override
  String generationFrom(String name) {
    return 'From material: $name';
  }

  @override
  String get generationCount => 'Number of questions';

  @override
  String get generationTypes =>
      'Supported types: multiple choice, true/false, fill in the blank, short answer.';

  @override
  String get generationReviewNote =>
      'Generated questions are reviewed before use. No answer keys or practice start before approval.';

  @override
  String get generationCostNote =>
      'The server charges when you confirm and reserves from your balance. It refunds if the request fails or the questions are rejected.';

  @override
  String get generationPriceServer =>
      'The fee is set by the server on generation';

  @override
  String get generationAck =>
      'I understand the questions need review before practice.';

  @override
  String get generationConfirm => 'Confirm generation';

  @override
  String get generationProcessing => 'Generating questions…';

  @override
  String get generationReviewStatus => 'Awaiting staff review';

  @override
  String get generationReviewBody =>
      'Your questions arrived and will be reviewed soon. You can leave this page and come back.';

  @override
  String get generationReadyBody =>
      'We made a private set from your material and staff reviewed it. Open it to practise.';

  @override
  String get generationFailedBody =>
      'Generation did not complete and nothing was charged. You can try again.';

  @override
  String get generationUnsafe =>
      'The questions failed the safety check; nothing was charged.';

  @override
  String get generationRejectedBody =>
      'The questions were not approved. Your credits were refunded if charged.';

  @override
  String get generationOrigin =>
      'Generated from your material and reviewed by staff; not an official exam.';

  @override
  String get generationOpen => 'Open the set';

  @override
  String get generationRefresh => 'Refresh status';

  @override
  String get generationRefreshFailed =>
      'Could not refresh the status. No new request was started.';

  @override
  String generationCharged(int credits) {
    return 'Charged $credits credits.';
  }

  @override
  String get generationNoCharge => 'Nothing was charged.';

  @override
  String get generationStatusTitle => 'Generation status';

  @override
  String get generationBack => 'Back to my materials';

  @override
  String get generationFailedStatus => 'Generation failed';

  @override
  String get setByServer => 'Set by the server';

  @override
  String get acknowledge => 'I understand';

  @override
  String get errorAiDisabled => 'AI features are switched off right now.';

  @override
  String get errorAiBudgetExceeded =>
      'AI is paused until the budget is raised. Try later.';

  @override
  String get errorAiInvalidOutput =>
      'The AI request did not complete. Try again.';

  @override
  String get errorAiContentUnsafe =>
      'The questions failed the safety check; nothing was charged.';

  @override
  String get errorNotAiMarkable => 'This question is not marked by AI.';

  @override
  String get errorAnswerAlreadyMarked => 'This answer is already marked.';

  @override
  String get errorReviewAlreadyPending =>
      'Your answer is already waiting for review.';

  @override
  String get errorAiInFlight =>
      'AI marking is already running for this answer. Wait for it to finish, then refresh.';

  @override
  String get errorEmptyAnswer => 'Write an answer before requesting marking.';

  @override
  String get errorClassLevelRequired => 'Set your class in your account first.';

  @override
  String get errorMaterialRequired => 'Attach a material first.';

  @override
  String get errorMaterialNotFound => 'Material not found.';

  @override
  String get errorMaterialFileMissing =>
      'The material file is no longer available. Add it again.';

  @override
  String get errorMaterialTypeNotAllowed =>
      'Upload .txt, .md, or a PNG/JPEG image.';

  @override
  String get errorMaterialPdfNotSupported =>
      'PDF extraction is not supported yet; upload an image or text.';

  @override
  String get errorMaterialTooLarge =>
      'The material is too large. Maximum 8 MB.';

  @override
  String get errorMaterialTooShort =>
      'The material is too short. Add at least 100 characters.';

  @override
  String get errorMaterialTooLong =>
      'The material is too long. Split it into smaller parts.';

  @override
  String get errorMaterialUploadFailed =>
      'Could not upload the material. Try again.';

  @override
  String get errorMaterialFieldInvalid =>
      'The material file is invalid. Choose it again.';

  @override
  String get errorGenerationNotFound => 'Generation request not found.';

  @override
  String get errorAiTimeout => 'The AI service timed out. Try again.';

  @override
  String get errorAiUpstream => 'Could not reach the AI service. Try later.';

  @override
  String get errorAiUnavailable => 'AI is unavailable right now.';

  @override
  String get generationUnknown => 'Unknown status';

  @override
  String get generationUnknownBody =>
      'We could not read this request\'s status. Refresh, or contact support if it keeps happening.';
}
