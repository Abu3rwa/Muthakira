// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مذكرة';

  @override
  String get tagline => 'ذاكر بذكاء';

  @override
  String get ok => 'حسنًا';

  @override
  String get cancel => 'إلغاء';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get save => 'حفظ';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get done => 'تم';

  @override
  String get close => 'إغلاق';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ';

  @override
  String get share => 'مشاركة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get search => 'بحث';

  @override
  String get filters => 'التصفية';

  @override
  String get clearFilters => 'مسح التصفية';

  @override
  String get apply => 'تطبيق';

  @override
  String get viewPaper => 'عرض الورقة';

  @override
  String get previewQuestions => 'معاينة الأسئلة';

  @override
  String get topUpBalance => 'شحن الرصيد';

  @override
  String get browseExams => 'تصفّح الامتحانات';

  @override
  String get balanceShort => 'الرصيد';

  @override
  String get walletUnavailable => 'تعذّر تحديث الرصيد';

  @override
  String get showMore => 'المزيد';

  @override
  String get showLess => 'أقل';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get comingSoonHint => 'هذه الميزة غير متوفرة بعد. نعمل عليها.';

  @override
  String get offline => 'لا يوجد اتصال';

  @override
  String get offlineBanner => 'أنت غير متصل. تعرض البيانات المحفوظة.';

  @override
  String get serverWaking => 'الخادم يستيقظ…';

  @override
  String get serverWakingHint =>
      'قد يستغرق التشغيل الأول بضع ثوانٍ. شكرًا لصبرك.';

  @override
  String get errorTitle => 'تعذّر إكمال الطلب';

  @override
  String get emptyTitle => 'لا يوجد شيء هنا بعد';

  @override
  String lastUpdated(String time) {
    return 'آخر تحديث $time';
  }

  @override
  String get savedBadge => 'محفوظ';

  @override
  String get pendingSyncBadge => 'بانتظار المزامنة';

  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get optional => 'اختياري';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String version(String value) {
    return 'الإصدار $value';
  }

  @override
  String get support => 'الدعم';

  @override
  String get contactSupport => 'تواصل مع الدعم';

  @override
  String get terms => 'الشروط';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get logoutConfirmBody =>
      'سيتم حذف البيانات المحفوظة على هذا الجهاز. ستحتاج إلى تسجيل الدخول مرة أخرى.';

  @override
  String get sdg => 'جنيه';

  @override
  String get creditsLabel => 'رصيد';

  @override
  String get available => 'المتاح';

  @override
  String get reserved => 'المحجوز';

  @override
  String get balance => 'الرصيد';

  @override
  String get notAvailable => '—';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get chooseLanguageHint => 'يمكنك تغييرها لاحقًا من الإعدادات.';

  @override
  String get preferredLanguage => 'لغة التطبيق المفضلة';

  @override
  String get preferredLanguageHint => 'تُحفظ مع حسابك وتُغيّر لغة الواجهة.';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get welcomeTitle => 'امتحانات الشهادة السودانية بين يديك';

  @override
  String get welcomeBody =>
      'ذاكر بذكاء مع امتحانات السنوات السابقة وتصحيح فوري.';

  @override
  String get welcomePoint1 => 'امتحانات رسمية مصنّفة حسب المادة والسنة';

  @override
  String get welcomePoint2 => 'تصحيح فوري لكل سؤال مع الإجابة النموذجية';

  @override
  String get welcomePoint3 => 'اشترِ رصيدًا عبر بنكك بسهولة';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get haveAccount => 'لديك حساب؟ تسجيل الدخول';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get name => 'الاسم';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get classLevel => 'الصف الدراسي';

  @override
  String get stream => 'الشعبة';

  @override
  String get other => 'أخرى';

  @override
  String get language => 'اللغة';

  @override
  String get termsAccept => 'أوافق على الشروط وسياسة الخصوصية';

  @override
  String get termsTitle => 'الشروط والأحكام';

  @override
  String get privacyTitle => 'سياسة الخصوصية';

  @override
  String get recoveryCodeTitle => 'رمز الاسترجاع الخاص بك';

  @override
  String get recoveryCodeBody =>
      'هذا هو الرمز الوحيد الذي يتيح لك إعادة تعيين كلمة المرور إذا نسيتها. احفظه في مكان آمن.';

  @override
  String get recoveryCodeWarning =>
      'لن نعرض هذا الرمز مرة أخرى. لا تشاركه مع أحد.';

  @override
  String get iSavedIt => 'لقد حفظت الرمز في مكان آمن';

  @override
  String get recoveryCodeCopied => 'تم نسخ رمز الاسترجاع';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordTitle => 'استعادة كلمة المرور';

  @override
  String get forgotPasswordBody =>
      'أدخل بريدك الإلكتروني وسنرسل لك رمزًا من ٦ أرقام لإعادة تعيين كلمة المرور.';

  @override
  String get forgotPasswordCodeBody =>
      'أدخل الرمز المكوّن من ٦ أرقام من البريد، ثم اختر كلمة مرور جديدة.';

  @override
  String get resetCode => 'رمز إعادة التعيين';

  @override
  String get resetCodeHint => 'الرمز المكوّن من ٦ أرقام من البريد';

  @override
  String resetCodeSentTo(String email) {
    return 'إذا كان $email مسجّلًا لدينا فسيصلك رمز الآن. تحقق من مجلد الرسائل المزعجة أيضًا.';
  }

  @override
  String get sendResetCode => 'أرسل لي رمزًا بالبريد';

  @override
  String get resendCode => 'أرسل رمزًا جديدًا';

  @override
  String get useSavedRecoveryCode => 'استخدام رمز الاسترجاع المحفوظ';

  @override
  String get useEmailedCode => 'استخدام رمز البريد الإلكتروني';

  @override
  String resetCodeExpiry(int minutes) {
    return 'تنتهي صلاحية الرمز خلال $minutes دقيقة.';
  }

  @override
  String get passwordChangedBody =>
      'تم تغيير كلمة المرور. سجّل الدخول بكلمة المرور الجديدة.';

  @override
  String get recoveryCode => 'رمز الاسترجاع';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetSuccessTitle => 'تم تغيير كلمة المرور';

  @override
  String get resetSuccessBody =>
      'احفظ رمز الاسترجاع الجديد، ثم سجّل الدخول بكلمة المرور الجديدة.';

  @override
  String get blockedTitle => 'الحساب موقوف';

  @override
  String get blockedBody => 'تم إيقاف هذا الحساب. تواصل مع الدعم للمساعدة.';

  @override
  String get phoneHint => 'مثال: 0912345678';

  @override
  String get passwordHint => '٨ أحرف على الأقل';

  @override
  String get nameHint => 'اسمك كما يظهر في الشهادة';

  @override
  String get classLevelHint => 'اختر صفك الدراسي';

  @override
  String get streamHint => 'علمي أو أدبي';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get passwordWeak => 'ضعيفة';

  @override
  String get passwordMedium => 'متوسطة';

  @override
  String get passwordStrong => 'قوية';

  @override
  String get secondary1 => 'الأول الثانوي';

  @override
  String get secondary2 => 'الثاني الثانوي';

  @override
  String get secondary3 => 'الثالث الثانوي (الشهادة السودانية)';

  @override
  String get streamScience => 'علمي';

  @override
  String get streamLiterary => 'أدبي';

  @override
  String get sessionExpired => 'انتهت الجلسة. سجّل الدخول مرة أخرى.';

  @override
  String get walletTitle => 'المحفظة';

  @override
  String get availableCredits => 'الرصيد المتاح';

  @override
  String reservedHint(int count) {
    return '$count من رصيدك محجوز لطلب دفع قيد المراجعة.';
  }

  @override
  String get nextExpiry => 'أقرب انتهاء صلاحية';

  @override
  String expirySoon(String date) {
    return 'ينتهي جزء من رصيدك في $date. استخدمه قبل ذلك.';
  }

  @override
  String get lowCredits => 'رصيدك منخفض. أضف رصيدًا لمواصلة المذاكرة.';

  @override
  String get addCredit => 'إضافة رصيد';

  @override
  String get ledgerTitle => 'سجل الرصيد';

  @override
  String get ledgerEmpty => 'لا توجد حركات بعد';

  @override
  String get ledgerEmptyHint => 'ستظهر هنا كل إضافة أو استخدام للرصيد.';

  @override
  String get entrySignupBonus => 'رصيد الترحيب';

  @override
  String get entryPurchase => 'شراء رصيد';

  @override
  String get entrySpend => 'استخدام رصيد';

  @override
  String get entryExpiry => 'انتهاء صلاحية الرصيد';

  @override
  String get entryAdminAdjust => 'تعديل من الإدارة';

  @override
  String entryExamUnlock(String key) {
    return 'فتح امتحان $key';
  }

  @override
  String entryPaymentApproved(String code) {
    return 'اعتماد الدفع $code';
  }

  @override
  String get entryUnlockShort => 'فتح ورقة';

  @override
  String get entryPaymentApprovedShort => 'اعتماد دفع';

  @override
  String creditsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رصيد',
      many: '$count رصيدًا',
      few: '$count أرصدة',
      two: 'رصيدان',
      one: 'رصيد واحد',
      zero: 'لا رصيد',
    );
    return '$_temp0';
  }

  @override
  String get examsTitle => 'الامتحانات';

  @override
  String get subject => 'المادة';

  @override
  String get year => 'السنة';

  @override
  String get session => 'الدورة';

  @override
  String get allSubjects => 'كل المواد';

  @override
  String get allYears => 'كل السنوات';

  @override
  String get allSessions => 'كل الدورات';

  @override
  String get allLanguages => 'كل اللغات';

  @override
  String get free => 'مجاني';

  @override
  String get unlocked => 'مفتوح';

  @override
  String get locked => 'مقفل';

  @override
  String lockedFor(String count) {
    return 'مقفل · $count';
  }

  @override
  String unlockFor(String count) {
    return 'افتح مقابل $count';
  }

  @override
  String get unlockConfirmTitle => 'فتح هذا الامتحان؟';

  @override
  String unlockConfirmBody(String cost, String balance) {
    return 'سيُخصم $cost من رصيدك. رصيدك الحالي $balance.';
  }

  @override
  String balanceAfter(String value) {
    return 'الرصيد بعد الفتح (تقديري): $value';
  }

  @override
  String get unlock => 'فتح الامتحان';

  @override
  String get unlockSuccess => 'تم فتح الامتحان. بالتوفيق!';

  @override
  String get startPractice => 'ابدأ التدريب';

  @override
  String get resumePractice => 'أكمل التدريب';

  @override
  String get practiceDisabled => 'التدريب غير متاح';

  @override
  String get practiceDisabledHint =>
      'أوقفت الإدارة التدريب على هذا الامتحان. يمكنك قراءته فقط.';

  @override
  String get paperViewer => 'قراءة الامتحان';

  @override
  String get instructions => 'التعليمات';

  @override
  String totalMarks(String count) {
    return '$count درجة';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      many: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
      zero: 'بدون وقت',
    );
    return '$_temp0';
  }

  @override
  String questionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سؤال',
      many: '$count سؤالًا',
      few: '$count أسئلة',
      two: 'سؤالان',
      one: 'سؤال واحد',
      zero: 'لا أسئلة',
    );
    return '$_temp0';
  }

  @override
  String get myUnlocks => 'امتحاناتي المفتوحة';

  @override
  String get myUnlocksEmpty => 'لم تفتح أي امتحان بعد';

  @override
  String get myUnlocksEmptyHint =>
      'افتح امتحانًا ليظهر هنا ويصبح متاحًا دون اتصال.';

  @override
  String get yourOpenPapers => 'أوراقك المفتوحة';

  @override
  String partialPapersFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تعذّر تحميل $count ورقة',
      many: 'تعذّر تحميل $count ورقة',
      few: 'تعذّر تحميل $count أوراق',
      two: 'تعذّرت ورقتان',
      one: 'تعذّرت ورقة واحدة',
      zero: 'تعذّر تحميل بعض الأوراق',
    );
    return '$_temp0';
  }

  @override
  String get viewKeys => 'الإجابات النموذجية';

  @override
  String get trialBadge => 'تجريبي';

  @override
  String get examNotFound => 'لم نعثر على هذا الامتحان';

  @override
  String get noExams => 'لا توجد امتحانات مطابقة';

  @override
  String get noExamsHint => 'جرّب تغيير التصفية أو البحث بكلمة أخرى.';

  @override
  String get searchExams => 'ابحث عن مادة أو سنة';

  @override
  String get stimulusTitle => 'النص';

  @override
  String questionLabel(String path) {
    return 'سؤال $path';
  }

  @override
  String get answerKey => 'الإجابة الصحيحة';

  @override
  String get explanation => 'الشرح';

  @override
  String get modelAnswer => 'إجابة نموذجية';

  @override
  String get criteria => 'معايير التصحيح';

  @override
  String get acceptedAlternatives => 'إجابات بديلة مقبولة';

  @override
  String get lockedQuestionHint => 'افتح الامتحان لرؤية هذا السؤال وإجابته.';

  @override
  String fieldTooShort(int min) {
    return 'يجب ألا يقل عن $min حرفًا';
  }

  @override
  String fieldTooLong(int max) {
    return 'يجب ألا يزيد عن $max حرفًا';
  }

  @override
  String get fieldPhoneInvalid => 'أدخل رقم هاتف صحيح';

  @override
  String get fieldPasswordShort => 'كلمة المرور يجب أن تكون ٨ أحرف على الأقل';

  @override
  String get fieldTermsRequired => 'عليك الموافقة على الشروط للمتابعة';

  @override
  String get fieldAnswerRequired => 'اكتب إجابتك أولًا';

  @override
  String get practiceTitle => 'التدريب';

  @override
  String questionOf(String current, String total) {
    return 'سؤال $current من $total';
  }

  @override
  String get checkAnswer => 'تحقق من الإجابة';

  @override
  String get nextQuestion => 'السؤال التالي';

  @override
  String get previousQuestion => 'السؤال السابق';

  @override
  String get finishPractice => 'إنهاء التدريب';

  @override
  String get finishConfirmTitle => 'إنهاء جلسة التدريب؟';

  @override
  String get finishConfirmBody =>
      'يمكنك مراجعة إجاباتك لاحقًا في شاشة النتيجة.';

  @override
  String get correct => 'إجابة صحيحة';

  @override
  String get incorrect => 'إجابة غير صحيحة';

  @override
  String partlyCorrect(String awarded, String total) {
    return 'صحيح جزئيًا — $awarded من $total';
  }

  @override
  String marksAwarded(String value) {
    return '$value درجة';
  }

  @override
  String marksWorth(String value) {
    return 'تساوي $value درجة';
  }

  @override
  String get answerSaved => 'تم حفظ إجابتك';

  @override
  String get answerSubmitted => 'أُرسل للتصحيح';

  @override
  String get savedOnDevice => 'محفوظ على هذا الجهاز';

  @override
  String get waitingToSend => 'بانتظار الإرسال';

  @override
  String get checkDisabledHint => 'اختر إجابة أو اكتبها لتفعيل التحقق.';

  @override
  String get moveUp => 'تحريك لأعلى';

  @override
  String get moveDown => 'تحريك لأسفل';

  @override
  String get structureUnavailable =>
      'لا تتوفر بيانات كافية لعرض هذا النوع من الأسئلة. أبلغ عن السؤال لتتم مراجعته.';

  @override
  String get currentLabel => 'الحالي';

  @override
  String get backToQuestions => 'العودة للأسئلة';

  @override
  String pendingUploadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إجابة بانتظار الإرسال',
      many: '$count إجابة بانتظار الإرسال',
      few: '$count إجابات بانتظار الإرسال',
      two: 'إجابتان بانتظار الإرسال',
      one: 'إجابة واحدة بانتظار الإرسال',
    );
    return '$_temp0';
  }

  @override
  String get provisionalScore => 'نتيجة مبدئية';

  @override
  String get finalScore => 'النتيجة النهائية';

  @override
  String get newPractice => 'تدريب جديد';

  @override
  String get yourAnswerUnavailable => 'إجابتك غير متاحة على هذا الجهاز.';

  @override
  String get keyUnavailable => 'الإجابة غير متاحة حاليًا.';

  @override
  String get pendingSelf =>
      'تم الحفظ. صحّح هذا السؤال بنفسك بمقارنة إجابتك بالإجابة النموذجية.';

  @override
  String get pendingAi =>
      'تم الحفظ. يمكنك طلب تصحيح بالذكاء الاصطناعي عبر زر مستقل.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get tryAgainAiWarning =>
      'إعادة الإجابة على سؤال صُحّح بالذكاء الاصطناعي تتطلب تصحيحًا جديدًا مدفوعًا.';

  @override
  String get reportTextHint => 'تفاصيل إضافية (اختياري، ٥ أحرف على الأقل)';

  @override
  String attemptsCount(String count) {
    return 'المحاولة $count';
  }

  @override
  String get questionNavigator => 'خريطة الأسئلة';

  @override
  String get answeredLabel => 'تمت الإجابة';

  @override
  String get unansweredLabel => 'بدون إجابة';

  @override
  String get pendingLabel => 'بانتظار التصحيح';

  @override
  String get reportQuestion => 'أبلغ عن سؤال';

  @override
  String get reportReasonLabel => 'ما المشكلة؟';

  @override
  String get reportReasonHint => 'اشرح المشكلة (٥ أحرف على الأقل)';

  @override
  String get reportSent => 'تم إرسال البلاغ. شكرًا لك.';

  @override
  String get resultTitle => 'النتيجة';

  @override
  String scoreOf(String awarded, String total) {
    return '$awarded من $total';
  }

  @override
  String get resultPendingNote =>
      'الأسئلة التي لم تُصحّح بعد غير محسوبة في الدرجة.';

  @override
  String get reviewAnswers => 'مراجعة الإجابات';

  @override
  String get retryWrong => 'أعد الأسئلة الخاطئة';

  @override
  String get backToExams => 'العودة إلى الامتحانات';

  @override
  String get sectionBreakdown => 'حسب الأقسام';

  @override
  String get yourAnswer => 'إجابتك';

  @override
  String get noAnswer => 'لم تُجب';

  @override
  String get answerHintText => 'اكتب إجابتك هنا';

  @override
  String get selectOne => 'اختر إجابة واحدة';

  @override
  String get selectAllThatApply => 'اختر كل الإجابات الصحيحة';

  @override
  String get trueLabel => 'صح';

  @override
  String get falseLabel => 'خطأ';

  @override
  String blankLabel(String index) {
    return 'الفراغ $index';
  }

  @override
  String cellLabel(String row, String column) {
    return 'صف $row، عمود $column';
  }

  @override
  String get reorderHint => 'اسحب لترتيب العناصر';

  @override
  String orderingItemLabel(String index, String total) {
    return 'العنصر $index من $total';
  }

  @override
  String get numericKeyboardHint =>
      'أدخل رقمًا (تُقبل الأرقام العربية والفواصل العشرية)';

  @override
  String get matchWith => 'طابق مع';

  @override
  String get numericHint => 'أدخل رقمًا';

  @override
  String get selfMarkTitle => 'صحّح بنفسك';

  @override
  String get selfMarkHint =>
      'قارن إجابتك بالإجابة النموذجية ثم قيّم نفسك. تُرسل الدرجة إلى الخادم وتُحتسب في نتيجتك.';

  @override
  String get selfMarkGotIt => 'أجبت بشكل صحيح';

  @override
  String get selfMarkPartial => 'أجبت جزئيًا';

  @override
  String get selfMarkMissed => 'لم أُجب بشكل صحيح';

  @override
  String get offlineQueued =>
      'لا يوجد اتصال. حُفظت إجابتك وستُرسل عند عودة الاتصال.';

  @override
  String get attemptClosedTitle => 'أُغلقت الجلسة';

  @override
  String get startNewAttempt => 'ابدأ جلسة جديدة';

  @override
  String get resumeTitle => 'أكمل من حيث توقفت';

  @override
  String get packagesTitle => 'باقات الرصيد';

  @override
  String pricePerCredit(String value) {
    return '$value للرصيد الواحد';
  }

  @override
  String get buyPackage => 'اشترِ هذه الباقة';

  @override
  String get paymentsTitle => 'مدفوعاتي';

  @override
  String get paymentsEmpty => 'لا توجد طلبات دفع';

  @override
  String get paymentsEmptyHint =>
      'اختر باقة رصيد وحوّل المبلغ عبر بنكك، ثم ارفع الإيصال هنا.';

  @override
  String get paymentInstructionsTitle => 'طريقة الدفع';

  @override
  String get stepAmount => '١. حوّل هذا المبلغ بالضبط';

  @override
  String get stepBank => '٢. إلى هذا الحساب';

  @override
  String get stepBankak => '٣. أتم التحويل من تطبيق بنكك';

  @override
  String get stepReceipt => '٤. ارفع الإيصال وأدخل رقم العملية';

  @override
  String get stepStatus => '٥. تابع حالة الطلب';

  @override
  String get exactAmountWarning =>
      'حوّل نفس المبلغ تمامًا. أي اختلاف يؤخر الاعتماد.';

  @override
  String get bankName => 'اسم البنك';

  @override
  String get accountName => 'اسم الحساب';

  @override
  String get accountNumber => 'رقم الحساب';

  @override
  String get paymentCode => 'رمز الدفع';

  @override
  String get openBankak => 'افتح تطبيق بنكك';

  @override
  String get bankakNotInstalled => 'تطبيق بنكك غير مثبت على هذا الجهاز.';

  @override
  String get reviewTimeHint => 'تُراجع الطلبات عادة خلال بضع ساعات.';

  @override
  String get referenceLabel => 'رقم العملية';

  @override
  String get senderNameLabel => 'اسم المرسل';

  @override
  String get receiptLabel => 'صورة الإيصال';

  @override
  String get takePhoto => 'التقط صورة';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get choosePdf => 'اختر ملف PDF';

  @override
  String get receiptPreview => 'معاينة الإيصال';

  @override
  String get submitReceipt => 'إرسال الإيصال';

  @override
  String get receiptUploading => 'جارٍ رفع الإيصال…';

  @override
  String get receiptTooLargeLocal =>
      'الملف أكبر من ٨ ميغابايت. اختر صورة أصغر.';

  @override
  String get receiptTypeInvalidLocal =>
      'نوع الملف غير مدعوم. استخدم JPEG أو PNG أو WebP أو PDF.';

  @override
  String get cameraRationaleTitle => 'نحتاج إذن الكاميرا';

  @override
  String get cameraRationaleBody =>
      'نستخدم الكاميرا لتصوير إيصال التحويل فقط. لا نصل إلى أي صور أخرى بدون اختيارك.';

  @override
  String get statusPendingPayment => 'بانتظار الدفع';

  @override
  String get statusSubmitted => 'أُرسل';

  @override
  String get statusUnderReview => 'قيد المراجعة';

  @override
  String get statusNeedsInfo => 'معلومات ناقصة';

  @override
  String get statusApproved => 'معتمد';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusExpired => 'منتهي';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get timelineCreated => 'أُنشئ الطلب';

  @override
  String get timelineSubmitted => 'أُرسل الإيصال';

  @override
  String get timelineReviewed => 'قيد المراجعة';

  @override
  String get timelineDecided => 'القرار';

  @override
  String get rejectReasonLabel => 'سبب الرفض';

  @override
  String get resubmit => 'إعادة الإرسال';

  @override
  String get cancelRequest => 'إلغاء الطلب';

  @override
  String get cancelConfirmTitle => 'إلغاء طلب الدفع؟';

  @override
  String get cancelConfirmBody =>
      'سيُلغى هذا الطلب ويمكنك إنشاء طلب جديد لاحقًا.';

  @override
  String get paymentApprovedTitle => 'تمت إضافة الرصيد!';

  @override
  String get viewReceipt => 'عرض الإيصال';

  @override
  String get expectedAmountLabel => 'المبلغ المطلوب تحويله';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String greeting(String name) {
    return 'أهلًا $name';
  }

  @override
  String get recommendedForYou => 'مقترح لك';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get newPapers => 'أحدث الامتحانات';

  @override
  String get continueStudying => 'أكمل المذاكرة';

  @override
  String get profileTitle => 'حسابي';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get appearanceHint => 'اختر المظهر الذي يريح عينك.';

  @override
  String get groupReading => 'القراءة';

  @override
  String get groupLanguageNumbers => 'اللغة والأرقام';

  @override
  String get groupData => 'البيانات والتخزين';

  @override
  String get groupHelp => 'الدعم والتشخيص';

  @override
  String get readingSample =>
      'اقْرَأْ بِتَمَهُّلٍ، وَرَاجِعْ دَرْسَكَ كُلَّ يَوْمٍ.';

  @override
  String get appLanguageHint => 'لغة الأزرار والقوائم والرسائل.';

  @override
  String get digitStyleHint => 'شكل الأرقام فقط؛ لا يغيّر اللغة.';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get textSize => 'حجم النص';

  @override
  String get digitStyle => 'شكل الأرقام';

  @override
  String get digitsArabic => '١٢٣ عربية';

  @override
  String get digitsWestern => '123 غربية';

  @override
  String get dataSaver => 'توفير البيانات';

  @override
  String get dataSaverHint =>
      'لا تُنزّل الإجابات النموذجية أو الأوراق الكبيرة تلقائيًا.';

  @override
  String get clearCache => 'مسح البيانات المحفوظة';

  @override
  String get clearCacheConfirmTitle => 'مسح البيانات المحفوظة؟';

  @override
  String get clearCacheConfirmBody =>
      'سيتم حذف الأوراق والإجابات المحفوظة والمسودات والإجابات التي لم تُرسَل بعد من هذا الجهاز. يبقى رصيدك وحسابك وتسجيل الدخول كما هي.';

  @override
  String get clearCacheIncludesQueue =>
      'المسودات والإجابات المنتظرة للإرسال ستُحذف أيضًا.';

  @override
  String get cacheCleared => 'تم مسح البيانات المحفوظة';

  @override
  String get paymentHelp => 'مساعدة الدفع';

  @override
  String get reportProblem => 'أبلغ عن مشكلة';

  @override
  String get reportProblemHint =>
      'يشارك سجل الأخطاء الأخير بدون أي بيانات شخصية.';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountHint =>
      'حذف الحساب غير متاح آليًا بعد. تواصل مع الدعم وسنقوم به يدويًا.';

  @override
  String get aboutAndLegal => 'عن التطبيق والقانون';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get diagnosticsEmpty => 'لا توجد أخطاء مسجلة';

  @override
  String get sendReport => 'إرسال التقرير';

  @override
  String get forceUpdateTitle => 'تحديث مطلوب';

  @override
  String get forceUpdateBody =>
      'يتوفر إصدار أحدث. حدّث التطبيق من المتجر ثم افتحه من جديد.';

  @override
  String get notFoundTitle => 'الصفحة غير موجودة';

  @override
  String get maintenanceTitle => 'الخدمة غير متاحة مؤقتًا';

  @override
  String get errorUnauthorized => 'انتهت الجلسة. سجّل الدخول مرة أخرى.';

  @override
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errorInvalidToken => 'انتهت الجلسة. سجّل الدخول مرة أخرى.';

  @override
  String get errorInvalidRefreshToken => 'انتهت الجلسة. سجّل الدخول مرة أخرى.';

  @override
  String get errorAccountBlocked => 'هذا الحساب موقوف. تواصل مع الدعم.';

  @override
  String get errorForbidden => 'لا تملك صلاحية لهذا الإجراء.';

  @override
  String get errorNotFound => 'لم نعثر على ما تبحث عنه.';

  @override
  String get errorPhoneTaken => 'رقم الهاتف مسجّل بالفعل. جرّب تسجيل الدخول.';

  @override
  String get errorEmailTaken =>
      'هذا البريد الإلكتروني مسجّل بالفعل. جرّب تسجيل الدخول.';

  @override
  String get errorInvalidEmail => 'أدخل بريدًا إلكترونيًا صحيحًا.';

  @override
  String get errorInvalidResetCode => 'الرمز غير صحيح أو انتهت صلاحيته.';

  @override
  String get errorMailNotConfigured =>
      'إرسال البريد غير مُهيّأ على الخادم بعد. تواصل مع الدعم.';

  @override
  String get errorMailSendFailed => 'تعذّر إرسال البريد. حاول بعد قليل.';

  @override
  String get errorInvalidPhone =>
      'أدخل رقم هاتف سوداني صحيح، مثال: 0912345678.';

  @override
  String get errorReceiptUploadFailed => 'تعذّر رفع الإيصال. حاول مرة أخرى.';

  @override
  String get errorStudentOnly => 'هذا الإجراء متاح للطلاب فقط.';

  @override
  String get errorInvalidRecoveryCode => 'رمز الاسترجاع غير صحيح.';

  @override
  String get errorValidationError => 'راجع الحقول المشار إليها بالأحمر.';

  @override
  String get errorRateLimited => 'طلبات كثيرة جدًا. انتظر لحظة ثم حاول مجددًا.';

  @override
  String get errorInsufficientCredits => 'رصيدك لا يكفي. أضف رصيدًا للمتابعة.';

  @override
  String get errorExamNotFound => 'لم نعثر على هذا الامتحان.';

  @override
  String get errorExamLocked => 'هذا الامتحان مقفل. افتحه أولًا.';

  @override
  String get errorPracticeDisabled => 'التدريب غير متاح لهذا الامتحان.';

  @override
  String get errorQuestionNotFound => 'لم نعثر على هذا السؤال.';

  @override
  String get errorQuestionNotAnswerable =>
      'أجب عن الأسئلة الفرعية، وليس عن القسم نفسه.';

  @override
  String get errorAttemptNotFound => 'لم نعثر على جلسة التدريب.';

  @override
  String get errorAttemptClosed => 'أُغلقت جلسة التدريب. ابدأ جلسة جديدة.';

  @override
  String get errorDuplicateValue => 'هذه القيمة مستخدمة بالفعل.';

  @override
  String get errorPackageNotFound => 'باقة الرصيد هذه لم تعد متاحة.';

  @override
  String get errorPaymentAccountNotConfigured =>
      'حساب الاستلام غير مهيأ بعد. تواصل مع الدعم.';

  @override
  String get errorTooManyOpenPayments =>
      'لديك طلبات دفع مفتوحة. أكمل أحدها أو ألغِه أولًا.';

  @override
  String get errorPaymentAmountsExhausted =>
      'لا توجد مبالغ متاحة الآن. حاول بعد قليل.';

  @override
  String get errorPaymentRequestNotFound => 'لم نعثر على طلب الدفع.';

  @override
  String get errorPaymentNotSubmittable => 'لم يعد بالإمكان إرسال هذا الطلب.';

  @override
  String get errorPaymentNotCancellable => 'لا يمكن إلغاء طلب أُرسل بالفعل.';

  @override
  String get errorInvalidReference =>
      'أدخل رقم العملية من بنكك (٤ أحرف على الأقل).';

  @override
  String get errorReferenceAlreadyUsed =>
      'رقم العملية هذا مستخدم في طلب دفع آخر.';

  @override
  String get errorReceiptNotFound => 'لم نعثر على الإيصال.';

  @override
  String get errorReceiptAlreadyAttached => 'هذا الإيصال مرتبط بطلب دفع آخر.';

  @override
  String get errorReceiptTooLarge =>
      'حجم الإيصال كبير جدًا. الحد الأقصى ٨ ميغابايت.';

  @override
  String get errorReceiptTypeNotAllowed =>
      'ارفع صورة JPEG أو PNG أو WebP أو ملف PDF.';

  @override
  String get errorReceiptFieldInvalid => 'ملف الإيصال غير صالح.';

  @override
  String get errorReceiptRequired => 'أرفق صورة الإيصال أولًا.';

  @override
  String get errorReceiptFileMissing => 'لم يصل الملف. حاول مرة أخرى.';

  @override
  String get errorReportAlreadyOpen =>
      'لقد أبلغت عن هذا السؤال بالفعل. نحن نراجعه.';

  @override
  String get errorInvalidCursor => 'تعذّر تحميل المزيد. حدّث القائمة.';

  @override
  String get errorInternalError => 'حدث خطأ في الخادم. حاول مرة أخرى.';

  @override
  String get errorNetworkError =>
      'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مجددًا.';

  @override
  String get errorCacheError => 'تعذّر قراءة البيانات المحفوظة.';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get skip => 'تخطٍ';

  @override
  String get all => 'الكل';

  @override
  String get show => 'إظهار';

  @override
  String get hide => 'إخفاء';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get errorHint => 'تحقق من اتصالك ثم حاول مرة أخرى.';

  @override
  String get errorTimeout => 'استغرق الخادم وقتًا طويلًا. حاول مرة أخرى.';

  @override
  String errorFallback(String code) {
    return 'حدث خطأ غير متوقع ($code).';
  }

  @override
  String get termsBody =>
      'باستخدامك مذكرة فإنك توافق على استخدام التطبيق للدراسة الشخصية فقط. الأوراق مملوكة لجهاتها الأصلية وتُعرض لأغراض تعليمية. نحتفظ برقم هاتفك واسمك وسجل مدفوعاتك لتشغيل حسابك، ولا نشاركها مع جهات أخرى. لا تشارك رمز الاستعادة مع أي شخص.';

  @override
  String get aboutBody =>
      'مذكرة تطبيق لطلاب الشهادة السودانية: أوراق رسمية، تدريب بتصحيح فوري، وشراء رصيد عبر بنكك.';

  @override
  String get maintenanceBody => 'نحدّث الخدمة الآن. حاول بعد قليل.';

  @override
  String get notFoundBody => 'الرابط غير صحيح أو تغيّر.';

  @override
  String get goHome => 'الرئيسية';

  @override
  String get designGallery => 'معرض التصميم';

  @override
  String get reportReason1 => 'السؤال غير واضح';

  @override
  String get reportReason2 => 'الإجابة النموذجية خاطئة';

  @override
  String get reportReason3 => 'خطأ مطبعي في النص';

  @override
  String get reportReason4 => 'مشكلة أخرى';

  @override
  String get matchingInstruction => 'اختر الحرف المناسب لكل عنصر';

  @override
  String get orderingInstruction => 'رتّب العناصر بالترتيب الصحيح';

  @override
  String get tableInstruction => 'أكمل خلايا الجدول';

  @override
  String get matrixInstruction => 'أدخل قيم المصفوفة في الخلايا';

  @override
  String get truthTableInstruction => 'أكمل عمود الناتج في جدول الحقيقة';

  @override
  String get truthTableOutput => 'الناتج';

  @override
  String get multiInstruction => 'اختر كل الإجابات الصحيحة';

  @override
  String get diacriticsInstruction => 'اكتب النص مع التشكيل الكامل';

  @override
  String get fillBlankInstruction => 'أكمل الفراغات داخل النص';

  @override
  String get blueprint => 'ملاحظة: يمكنك استخدام ورقة وقلم للحساب.';

  @override
  String get streamNone => 'بدون شعبة';

  @override
  String get otherOption => 'أخرى (اكتبها)';

  @override
  String get loginTitle => 'أهلًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول لمتابعة مذاكرتك.';

  @override
  String get signupTitle => 'أنشئ حسابك';

  @override
  String get signupSubtitle => 'دقائق وتكون جاهزًا للتدريب.';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get recoverySavedHint =>
      'ضع علامة بعد حفظ الرمز في مكان آمن للمتابعة.';

  @override
  String get signupBonus => 'رصيد ترحيبي في حسابك';

  @override
  String get cooldownTitle => 'محاولات كثيرة';

  @override
  String get cooldownBody => 'انتظر قليلًا قبل المحاولة مرة أخرى.';

  @override
  String get home => 'الرئيسية';

  @override
  String get exams => 'الاوراق';

  @override
  String get practice => 'التدريب';

  @override
  String get wallet => 'المحفظة';

  @override
  String get profile => 'حسابي';

  @override
  String continueBody(String paper) {
    return 'لديك جلسة تدريب مفتوحة على $paper.';
  }

  @override
  String get pendingPaymentBanner => 'لديك طلب دفع قيد المراجعة.';

  @override
  String get viewPayment => 'عرض الطلب';

  @override
  String get paperContents => 'محتويات الورقة';

  @override
  String get insufficientTitle => 'الرصيد لا يكفي';

  @override
  String insufficientBody(String needed) {
    return 'تحتاج $needed إضافية لفتح هذه الورقة.';
  }

  @override
  String get keysLocked => 'افتح الورقة لعرض الإجابات.';

  @override
  String answeredCount(int count) {
    return 'أجبت عن $count';
  }

  @override
  String get emptyPractice => 'لا توجد أوراق للتدريب بعد';

  @override
  String get emptyPracticeHint => 'افتح ورقة من تبويب الأوراق أولًا.';

  @override
  String get noPackages => 'لا توجد باقات متاحة';

  @override
  String get noPackagesHint => 'حاول لاحقًا أو تواصل مع الدعم.';

  @override
  String get confirmPackageTitle => 'تأكيد الطلب';

  @override
  String confirmPackageBody(String price, String credits) {
    return 'سننشئ طلب دفع بقيمة $price لباقة $credits.';
  }

  @override
  String get confirmPackage => 'أنشئ طلب الدفع';

  @override
  String packageCredits(int count) {
    return '$count رصيد';
  }

  @override
  String get choosePackage => 'اختر باقة';

  @override
  String get referenceHint => 'الرقم الظاهر في إشعار التحويل';

  @override
  String get paymentSubmitted => 'وصل طلبك. سنراجعه قريبًا.';

  @override
  String get timeline => 'مراحل الطلب';

  @override
  String get requestCancelled => 'أُلغي الطلب.';

  @override
  String get receiptMissing => 'لا يوجد إيصال مرفق';

  @override
  String get paymentHelpBody =>
      'إذا تأخرت المراجعة أو رُفض الطلب، تواصل مع الدعم مع رمز الدفع.';

  @override
  String get expectedAmountCopy => 'نسخ المبلغ';

  @override
  String get openReceiptFile => 'فتح الملف';

  @override
  String get removeFile => 'إزالة الملف';

  @override
  String get receiptLoadFailed => 'تعذّر عرض الإيصال. حاول مرة أخرى.';

  @override
  String get availableNow => 'متاح للاستخدام الآن';

  @override
  String get reservedNotSpendable =>
      'المحجوز مرتبط بطلب دفع قيد المراجعة ولا يمكن استخدامه الآن.';

  @override
  String get balanceStaleHint =>
      'هذا الرصيد محفوظ من آخر تحديث ناجح. اسحب لأسفل للتحديث.';

  @override
  String get loadMoreLedger => 'تحميل حركات أقدم';

  @override
  String get ledgerLoadMoreFailed =>
      'تعذّر تحميل المزيد. الحركات المعروضة تبقى كما هي.';

  @override
  String get ledgerAllShown => 'عرضت كل الحركات';

  @override
  String get selectPackageHint => 'اختر باقة ثم تابع الدفع إلى صفحة التحويل.';

  @override
  String get continueToPayment => 'متابعة الدفع';

  @override
  String get openRequestNotice =>
      'لديك طلب دفع مفتوح. أكمل إرسال إيصاله أو ألغِه قبل إنشاء طلب جديد.';

  @override
  String get manualReviewNotice =>
      'يراجع فريق الدعم الإيصال يدويًا قبل إضافة الرصيد.';

  @override
  String get nextActionLabel => 'الإجراء التالي';

  @override
  String get refreshStatus => 'تحديث الحالة';

  @override
  String get paymentStatusExplainPending =>
      'لم يُرسل الإيصال بعد. حوّل المبلغ بالضبط ثم أرفق الإيصال.';

  @override
  String get paymentStatusExplainSubmitted =>
      'وصل طلبك وهو بانتظار بدء المراجعة. لا حاجة لأي إجراء الآن.';

  @override
  String get paymentStatusExplainUnderReview =>
      'يراجع فريق الدعم الإيصال الآن. لا حاجة لأي إجراء.';

  @override
  String get paymentStatusExplainNeedsInfo =>
      'تحتاج الإدارة معلومات إضافية. راجع الملاحظة ثم أعد إرسال الإيصال.';

  @override
  String get paymentStatusExplainApproved =>
      'اعتُمد الطلب وأُضيف الرصيد إلى محفظتك.';

  @override
  String get paymentStatusExplainRejected =>
      'رُفض الإيصال. راجع السبب قبل إرسال طلب جديد.';

  @override
  String get paymentStatusExplainExpired =>
      'انتهت صلاحية الطلب دون إرساله. ابدأ طلبًا جديدًا من الباقات.';

  @override
  String get paymentStatusExplainCancelled => 'أُلغي هذا الطلب ولن يُضاف رصيد.';

  @override
  String get paymentStatusExplainUnknown =>
      'حالة الطلب غير معروفة. حدّث الحالة أو تواصل مع الدعم.';

  @override
  String get requestSummaryTitle => 'ملخص الطلب';

  @override
  String get receiptSourceTitle => 'اختر مصدر الإيصال';

  @override
  String get galleryRationaleTitle => 'اختيار صورة من المعرض';

  @override
  String get galleryRationaleBody =>
      'سنفتح معرض الصور لاختيار صورة الإيصال فقط.';

  @override
  String get receiptPrepareFailed =>
      'تعذّر تجهيز الملف. جرّب صورة أخرى أو ملف PDF.';

  @override
  String get receiptReading => 'نقرأ رقم العملية من الإيصال…';

  @override
  String get receiptExtracted =>
      'كتبنا لك رقم العملية واسم المحوّل من الإيصال. راجعهما قبل الإرسال.';

  @override
  String get receiptExtractManual =>
      'لم نستطع قراءة رقم العملية من الإيصال. اكتبه بنفسك من الإيصال.';

  @override
  String get receiptAcceptedTitle => 'الملفات المقبولة';

  @override
  String receiptAcceptedValue(String size) {
    return 'JPEG أو PNG أو WebP أو PDF · حتى $size';
  }

  @override
  String get receiptPickHint => 'صورة واضحة تُظهر المبلغ ورقم العملية.';

  @override
  String get receiptReady => 'الملف جاهز للإرسال';

  @override
  String get preparingReceipt => 'جارٍ تجهيز الملف…';

  @override
  String get replaceFile => 'استبدال الملف';

  @override
  String get fileTypeLabel => 'النوع';

  @override
  String get fileSizeLabel => 'الحجم';

  @override
  String get attachmentKeepNotice =>
      'الإيصال المرفوع يبقى محفوظًا؛ لن تحتاج إلى رفعه مرة أخرى.';

  @override
  String get receiptCompressedHint => 'تم ضغط الصورة لتقليل حجم الرفع.';

  @override
  String get receiptOpenFailed =>
      'تعذّر فتح الملف. تأكد من وجود تطبيق يدعم PDF.';

  @override
  String get openPayments => 'طلبات مفتوحة';

  @override
  String get paymentHistory => 'السجل';

  @override
  String get diagnosticsTitle => 'التشخيص';

  @override
  String get serverUrl => 'عنوان الخادم';

  @override
  String get appVersionLabel => 'إصدار التطبيق';

  @override
  String get connectionLabel => 'الاتصال';

  @override
  String get online => 'متصل';

  @override
  String get pendingAnswers => 'إجابات بانتظار الإرسال';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get callSupport => 'اتصال';

  @override
  String get supportPhoneLabel => 'الهاتف';

  @override
  String get supportWhatsAppLabel => 'واتساب';

  @override
  String get openWhatsApp => 'فتح واتساب';

  @override
  String get galleryColors => 'الألوان';

  @override
  String get galleryTypography => 'الخطوط';

  @override
  String get galleryComponents => 'المكونات';

  @override
  String get accountDetails => 'بيانات الحساب';

  @override
  String get apiMode => 'مصدر البيانات';

  @override
  String get diagnosticsIntro =>
      'معلومات تساعد فريق الدعم على فهم المشكلة. لا تحتوي على كلمة المرور أو رمز الاسترجاع.';

  @override
  String get diagnosticsConnectionHint => 'حالة الشبكة كما يراها التطبيق الآن.';

  @override
  String get diagnosticsPendingHint =>
      'إجابات محفوظة على هذا الجهاز ولم تُرسَل بعد.';

  @override
  String get diagnosticsApiHint => 'الخادم الذي يقرأ منه هذا الإصدار بياناته.';

  @override
  String lastChecked(String time) {
    return 'آخر فحص: $time';
  }

  @override
  String get splashBusyHint =>
      'جارٍ التحقق من جلستك… قد يستغرق ذلك حتى ١٢ ثانية على اتصال بطيء.';

  @override
  String get fakeApi => 'بيانات تجريبية';

  @override
  String get liveApi => 'الخادم المباشر';

  @override
  String get couldNotOpen => 'تعذّر فتح التطبيق. حاول مرة أخرى.';

  @override
  String get reportShared => 'شكرًا، شاركنا التقرير.';

  @override
  String get privacyBody =>
      'تحتفظ مذكرة برقم هاتفك واسمك وسجلّ المدفوعات لتشغيل حسابك فقط، ولا نشاركها مع أي طرف. تُستخدم بياناتك لفتح الأوراق ومتابعة تقدّمك. يمكنك طلب حذف حسابك من صفحة الملف الشخصي.';

  @override
  String get adaptivePractice => 'تدريب تكيفي';

  @override
  String get adaptiveEntryHint =>
      'يختار الخادم السؤال التالي حسب إجاباتك السابقة.';

  @override
  String adaptiveClassContext(String className) {
    return 'صفك: $className';
  }

  @override
  String get adaptivePickPaper => 'اختر ورقة للتدريب التكيفي';

  @override
  String get adaptiveFreeNote =>
      'اختيار السؤال التكيفي مجاني ولا يستهلك رصيدًا. الأسئلة المدفوعة تتطلب فتح الورقة.';

  @override
  String get adaptiveNoControls =>
      'لا يوجد اختيار يدوي للموضوع أو الصعوبة؛ الخادم يضبط الصعوبة من نتائجك.';

  @override
  String get adaptiveStart => 'ابدأ التدريب التكيفي';

  @override
  String adaptiveRemaining(int count) {
    return 'متبقٍ من الأسئلة: $count';
  }

  @override
  String get adaptiveNoQuestions => 'لا توجد أسئلة متاحة';

  @override
  String get adaptiveNoAccess =>
      'لم نجد أسئلة متاحة دون فتح الورقة. افتح الورقة ثم عد.';

  @override
  String get adaptiveExhausted => 'أجبت عن كل الأسئلة المتاحة في هذه الورقة.';

  @override
  String get adaptiveAutoLevel => 'الصعوبة تُختار تلقائيًا';

  @override
  String get aiGradeTitle => 'تصحيح بالذكاء الاصطناعي';

  @override
  String get aiGradeConfirmTitle => 'تصحيح بالذكاء الاصطناعي؟';

  @override
  String get aiGradeBody =>
      'تُصحَّح إجابتك وفق الإجابة النموذجية، وتُراجع بشريًا إذا كانت الثقة منخفضة.';

  @override
  String get aiGradeUnofficial => 'نتيجة غير رسمية';

  @override
  String get aiGradeCostNote =>
      'تُحدد الرسوم من الخادم وتُحجز عند الطلب، ولا تُخصم إلا بعد اعتماد النتيجة. تُعاد كاملة إذا رُفضت أو فشل الطلب.';

  @override
  String aiGradeCharged(int credits) {
    return 'خُصم $credits رصيد مقابل التصحيح.';
  }

  @override
  String get aiGradeReviewPending => 'إجابتك بانتظار مراجعة بشرية';

  @override
  String get aiGradeReviewBody =>
      'تم تصحيح أولي بالذكاء الاصطناعي، والدرجة النهائية تُعتمد بعد المراجعة.';

  @override
  String get aiGradeReviewNoCharge =>
      'لا تُخصم أي رسوم الآن؛ تبقى محجوزة حتى تُعتمد المراجعة، وتُعاد إذا رُفضت.';

  @override
  String get aiGradeInProgress => 'جارٍ التصحيح بالذكاء الاصطناعي…';

  @override
  String get aiGradeInProgressHint =>
      'قد يستغرق حتى دقيقة. إن انقطع الاتصال ستُسترجع النتيجة المحفوظة تلقائيًا دون رسوم إضافية.';

  @override
  String get aiGradeRecovered =>
      'استُرجعت النتيجة المحفوظة من الخادم دون رسوم إضافية.';

  @override
  String get aiGradeRejectedTitle => 'رُفضت نتيجة المراجعة';

  @override
  String get aiGradeRejectedBody =>
      'أُعيدت الرسوم المحجوزة إلى رصيدك. يمكنك إعادة إرسال الإجابة أو طلب تصحيح جديد بالذكاء الاصطناعي.';

  @override
  String get aiGradeVoidedTitle => 'أُلغيت المراجعة';

  @override
  String get aiGradeVoidedBody =>
      'تغيّرت إجابتك بعد طلب المراجعة، فأُلغيت وأُعيدت الرسوم. اطلب التصحيح من جديد للإجابة الحالية.';

  @override
  String get aiGradeTimeoutHint =>
      'استغرق الطلب وقتًا أطول من المتوقع. إن كان التصحيح قد اكتمل فستظهر نتيجته المحفوظة، ولن تُخصم رسوم مرتين.';

  @override
  String get aiGradeMissingPoints => 'نقاط ناقصة';

  @override
  String get aiGradeFailed =>
      'لم يكتمل التصحيح. إجابتك محفوظة، ويمكنك المحاولة لاحقًا.';

  @override
  String get aiGradeUnavailable => 'خدمة الذكاء الاصطناعي غير متاحة الآن.';

  @override
  String get aiGrading => 'جارٍ التصحيح…';

  @override
  String get myMaterials => 'موادي';

  @override
  String get materialsEntryHint =>
      'أنشئ أسئلة تدريب من دروسك بعد مراجعة الفريق.';

  @override
  String get materialsEmpty => 'لا توجد مواد بعد';

  @override
  String get materialsEmptyHint =>
      'أضف نصًا أو صورة من درسك لإنشاء أسئلة تدريب.';

  @override
  String get materialAdd => 'إضافة مادة';

  @override
  String get materialKindText => 'نص';

  @override
  String get materialKindImage => 'صورة';

  @override
  String get materialPrivate => 'خاصة بحسابك';

  @override
  String get materialStatusReview => 'بانتظار المراجعة';

  @override
  String get materialStatusReady => 'جاهزة';

  @override
  String get materialStatusFailed => 'فشل الإنشاء';

  @override
  String get materialStatusRejected => 'مرفوضة';

  @override
  String get materialNoGeneration => 'لم تُنشأ أسئلة';

  @override
  String get materialGenerate => 'إنشاء أسئلة';

  @override
  String get materialSourcePaste => 'نص ملصق';

  @override
  String get materialSourceFile => 'ملف نصي';

  @override
  String get materialSourcePhoto => 'صورة صفحة';

  @override
  String get materialSource => 'المصدر';

  @override
  String materialCreatedAt(String date) {
    return 'أُضيفت $date';
  }

  @override
  String get materialTextLabel => 'نص المادة';

  @override
  String get materialTextHint => 'الصق نص الدرس هنا (١٠٠ حرف على الأقل).';

  @override
  String get materialTooShort => 'النص قصير. أضف ١٠٠ حرف على الأقل.';

  @override
  String get materialPickFile => 'اختيار ملف';

  @override
  String get materialNoFile => 'لم تختر ملفًا بعد.';

  @override
  String get materialFileHint =>
      '.txt أو .md أو صورة PNG/JPEG، بحد أقصى ٨ ميغابايت.';

  @override
  String get materialPdfDisabled =>
      'استخراج النص من PDF غير مدعوم بعد. ارفع صورة للصفحة أو الصق النص.';

  @override
  String get materialPrivacyNote =>
      'تبقى المادة خاصة بحسابك، ولا تُنشر للآخرين.';

  @override
  String get materialDraftKept =>
      'احتفظنا بمادتك. أعد المحاولة بعد عودة الاتصال.';

  @override
  String get materialSaved => 'أُضيفت المادة';

  @override
  String get materialGradeHint => 'الصف الثانوي مطلوب لإنشاء الأسئلة.';

  @override
  String get materialSubjectHint => 'اختر مادة من المنهج أو اكتبها.';

  @override
  String get materialGradeRequired => 'اختر الصف الدراسي.';

  @override
  String get materialSubjectRequired => 'اكتب اسم المادة.';

  @override
  String get materialContinue => 'متابعة';

  @override
  String get generationConfirmTitle => 'إنشاء أسئلة';

  @override
  String generationFrom(String name) {
    return 'من مادة: $name';
  }

  @override
  String get generationCount => 'عدد الأسئلة';

  @override
  String get generationTypes =>
      'الأنواع المدعومة: اختيار من متعدد، صح/خطأ، إكمال الفراغ، إجابة قصيرة.';

  @override
  String get generationReviewNote =>
      'تُراجع الأسئلة المولّدة قبل الاستخدام. لا تظهر المفاتيح ولا يبدأ التدريب قبل الاعتماد.';

  @override
  String get generationCostNote =>
      'تُحتسب الرسوم من الخادم عند التأكيد وتُحجز من رصيدك. يعيد الخادم المبلغ إذا فشل الطلب أو رُفضت الأسئلة.';

  @override
  String get generationPriceServer => 'تحدد الرسوم من الخادم عند الإنشاء';

  @override
  String get generationAck => 'فهمت أن الأسئلة تحتاج مراجعة قبل التدريب.';

  @override
  String get generationConfirm => 'تأكيد الإنشاء';

  @override
  String get generationProcessing => 'جارٍ إنشاء الأسئلة…';

  @override
  String get generationReviewStatus => 'بانتظار مراجعة الفريق';

  @override
  String get generationReviewBody =>
      'وصلت أسئلتك وستُراجع قريبًا. يمكنك ترك الصفحة والعودة لاحقًا.';

  @override
  String get generationReadyBody =>
      'أنشأنا مجموعة خاصة من مادتك وراجعها الفريق. افتحها للتدريب.';

  @override
  String get generationFailedBody =>
      'لم يكتمل الإنشاء ولم تُخصم رسوم. يمكنك المحاولة مرة أخرى.';

  @override
  String get generationUnsafe => 'لم تجتز الأسئلة فحص السلامة، ولم تُخصم رسوم.';

  @override
  String get generationRejectedBody =>
      'لم تُعتمد الأسئلة. أُعيد رصيدك إن كان قد خُصم.';

  @override
  String get generationOrigin =>
      'مولّدة من مادتك ومراجعة من الفريق، وليست امتحانًا رسميًا.';

  @override
  String get generationOpen => 'فتح المجموعة';

  @override
  String get generationRefresh => 'تحديث الحالة';

  @override
  String get generationRefreshFailed =>
      'تعذّر تحديث الحالة. لم نبدأ طلبًا جديدًا.';

  @override
  String generationCharged(int credits) {
    return 'خُصم $credits رصيد.';
  }

  @override
  String get generationNoCharge => 'لم تُخصم رسوم.';

  @override
  String get generationStatusTitle => 'حالة الإنشاء';

  @override
  String get generationBack => 'العودة إلى موادي';

  @override
  String get generationFailedStatus => 'تعذّر الإنشاء';

  @override
  String get setByServer => 'يحددها الخادم';

  @override
  String get acknowledge => 'فهمت';

  @override
  String get errorAiDisabled => 'خدمة الذكاء الاصطناعي متوقفة حاليًا.';

  @override
  String get errorAiBudgetExceeded =>
      'توقفت خدمة الذكاء الاصطناعي مؤقتًا حتى تحسين الميزانية. جرّب لاحقًا.';

  @override
  String get errorAiInvalidOutput =>
      'لم يكتمل طلب الذكاء الاصطناعي. حاول مرة أخرى.';

  @override
  String get errorAiContentUnsafe =>
      'لم تجتز الأسئلة فحص السلامة، ولم تُخصم رسوم.';

  @override
  String get errorNotAiMarkable => 'هذا السؤال لا يُصحَّح بالذكاء الاصطناعي.';

  @override
  String get errorAnswerAlreadyMarked => 'تم تصحيح هذه الإجابة بالفعل.';

  @override
  String get errorReviewAlreadyPending => 'إجابتك بانتظار مراجعة بشرية بالفعل.';

  @override
  String get errorAiInFlight =>
      'التصحيح بالذكاء الاصطناعي قيد التنفيذ لهذه الإجابة بالفعل. انتظر اكتماله ثم حدّث.';

  @override
  String get errorEmptyAnswer => 'اكتب إجابة قبل طلب التصحيح.';

  @override
  String get errorClassLevelRequired => 'حدّد صفك الدراسي في حسابك أولًا.';

  @override
  String get errorMaterialRequired => 'أرفق مادة أولًا.';

  @override
  String get errorMaterialNotFound => 'لم نعثر على هذه المادة.';

  @override
  String get errorMaterialFileMissing =>
      'ملف المادة لم يعد موجودًا. أضفها من جديد.';

  @override
  String get errorMaterialTypeNotAllowed =>
      'ارفع .txt أو .md أو صورة PNG/JPEG.';

  @override
  String get errorMaterialPdfNotSupported =>
      'استخراج PDF غير مدعوم بعد؛ ارفع صورة أو نصًا.';

  @override
  String get errorMaterialTooLarge =>
      'حجم المادة كبير جدًا. الحد الأقصى ٨ ميغابايت.';

  @override
  String get errorMaterialTooShort =>
      'المادة قصيرة جدًا. أضف ١٠٠ حرف على الأقل.';

  @override
  String get errorMaterialTooLong =>
      'المادة طويلة جدًا. قسّمها إلى أجزاء أصغر.';

  @override
  String get errorMaterialUploadFailed => 'تعذّر رفع المادة. حاول مرة أخرى.';

  @override
  String get errorMaterialFieldInvalid => 'ملف المادة غير صالح. أعد اختياره.';

  @override
  String get errorGenerationNotFound => 'لم نعثر على طلب الإنشاء.';

  @override
  String get errorAiTimeout =>
      'انتهت مهلة خدمة الذكاء الاصطناعي. حاول مرة أخرى.';

  @override
  String get errorAiUpstream =>
      'تعذّر الوصول إلى خدمة الذكاء الاصطناعي. حاول لاحقًا.';

  @override
  String get errorAiUnavailable => 'خدمة الذكاء الاصطناعي غير متاحة الآن.';

  @override
  String get generationUnknown => 'حالة غير معروفة';

  @override
  String get generationUnknownBody =>
      'لم نتعرف على حالة هذا الطلب. حدّث الحالة، أو تواصل مع الدعم إن تكرر ذلك.';
}
