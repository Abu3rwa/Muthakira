import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'مذكرة'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'ذاكر بذكاء'**
  String get tagline;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسنًا'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @continueLabel.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueLabel;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @copy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get copied;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @filters.
  ///
  /// In ar, this message translates to:
  /// **'التصفية'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح التصفية'**
  String get clearFilters;

  /// No description provided for @apply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get apply;

  /// No description provided for @viewPaper.
  ///
  /// In ar, this message translates to:
  /// **'عرض الورقة'**
  String get viewPaper;

  /// No description provided for @previewQuestions.
  ///
  /// In ar, this message translates to:
  /// **'معاينة الأسئلة'**
  String get previewQuestions;

  /// No description provided for @topUpBalance.
  ///
  /// In ar, this message translates to:
  /// **'شحن الرصيد'**
  String get topUpBalance;

  /// No description provided for @browseExams.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح الامتحانات'**
  String get browseExams;

  /// No description provided for @balanceShort.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get balanceShort;

  /// No description provided for @walletUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديث الرصيد'**
  String get walletUnavailable;

  /// No description provided for @showMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In ar, this message translates to:
  /// **'أقل'**
  String get showLess;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل…'**
  String get loading;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريبًا'**
  String get comingSoon;

  /// No description provided for @comingSoonHint.
  ///
  /// In ar, this message translates to:
  /// **'هذه الميزة غير متوفرة بعد. نعمل عليها.'**
  String get comingSoonHint;

  /// No description provided for @offline.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال'**
  String get offline;

  /// No description provided for @offlineBanner.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل. تعرض البيانات المحفوظة.'**
  String get offlineBanner;

  /// No description provided for @serverWaking.
  ///
  /// In ar, this message translates to:
  /// **'الخادم يستيقظ…'**
  String get serverWaking;

  /// No description provided for @serverWakingHint.
  ///
  /// In ar, this message translates to:
  /// **'قد يستغرق التشغيل الأول بضع ثوانٍ. شكرًا لصبرك.'**
  String get serverWakingHint;

  /// No description provided for @errorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إكمال الطلب'**
  String get errorTitle;

  /// No description provided for @emptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد شيء هنا بعد'**
  String get emptyTitle;

  /// No description provided for @lastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث {time}'**
  String lastUpdated(String time);

  /// No description provided for @savedBadge.
  ///
  /// In ar, this message translates to:
  /// **'محفوظ'**
  String get savedBadge;

  /// No description provided for @pendingSyncBadge.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المزامنة'**
  String get pendingSyncBadge;

  /// No description provided for @requiredField.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get requiredField;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @seeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get seeAll;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {value}'**
  String version(String value);

  /// No description provided for @support.
  ///
  /// In ar, this message translates to:
  /// **'الدعم'**
  String get support;

  /// No description provided for @contactSupport.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم'**
  String get contactSupport;

  /// No description provided for @terms.
  ///
  /// In ar, this message translates to:
  /// **'الشروط'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get privacy;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج؟'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف البيانات المحفوظة على هذا الجهاز. ستحتاج إلى تسجيل الدخول مرة أخرى.'**
  String get logoutConfirmBody;

  /// No description provided for @sdg.
  ///
  /// In ar, this message translates to:
  /// **'جنيه'**
  String get sdg;

  /// No description provided for @creditsLabel.
  ///
  /// In ar, this message translates to:
  /// **'رصيد'**
  String get creditsLabel;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'المتاح'**
  String get available;

  /// No description provided for @reserved.
  ///
  /// In ar, this message translates to:
  /// **'المحجوز'**
  String get reserved;

  /// No description provided for @balance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get balance;

  /// No description provided for @notAvailable.
  ///
  /// In ar, this message translates to:
  /// **'—'**
  String get notAvailable;

  /// No description provided for @chooseLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get chooseLanguage;

  /// No description provided for @chooseLanguageHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تغييرها لاحقًا من الإعدادات.'**
  String get chooseLanguageHint;

  /// No description provided for @preferredLanguage.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق المفضلة'**
  String get preferredLanguage;

  /// No description provided for @preferredLanguageHint.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ مع حسابك وتُغيّر لغة الواجهة.'**
  String get preferredLanguageHint;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @welcomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'امتحانات الشهادة السودانية بين يديك'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In ar, this message translates to:
  /// **'ذاكر بذكاء مع امتحانات السنوات السابقة وتصحيح فوري.'**
  String get welcomeBody;

  /// No description provided for @welcomePoint1.
  ///
  /// In ar, this message translates to:
  /// **'امتحانات رسمية مصنّفة حسب المادة والسنة'**
  String get welcomePoint1;

  /// No description provided for @welcomePoint2.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح فوري لكل سؤال مع الإجابة النموذجية'**
  String get welcomePoint2;

  /// No description provided for @welcomePoint3.
  ///
  /// In ar, this message translates to:
  /// **'اشترِ رصيدًا عبر بنكك بسهولة'**
  String get welcomePoint3;

  /// No description provided for @getStarted.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get getStarted;

  /// No description provided for @haveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب؟ تسجيل الدخول'**
  String get haveAccount;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get signUp;

  /// No description provided for @name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In ar, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @newPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPassword;

  /// No description provided for @classLevel.
  ///
  /// In ar, this message translates to:
  /// **'الصف الدراسي'**
  String get classLevel;

  /// No description provided for @stream.
  ///
  /// In ar, this message translates to:
  /// **'الشعبة'**
  String get stream;

  /// No description provided for @other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get other;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @termsAccept.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على الشروط وسياسة الخصوصية'**
  String get termsAccept;

  /// No description provided for @termsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get termsTitle;

  /// No description provided for @privacyTitle.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyTitle;

  /// No description provided for @recoveryCodeTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمز الاسترجاع الخاص بك'**
  String get recoveryCodeTitle;

  /// No description provided for @recoveryCodeBody.
  ///
  /// In ar, this message translates to:
  /// **'هذا هو الرمز الوحيد الذي يتيح لك إعادة تعيين كلمة المرور إذا نسيتها. احفظه في مكان آمن.'**
  String get recoveryCodeBody;

  /// No description provided for @recoveryCodeWarning.
  ///
  /// In ar, this message translates to:
  /// **'لن نعرض هذا الرمز مرة أخرى. لا تشاركه مع أحد.'**
  String get recoveryCodeWarning;

  /// No description provided for @iSavedIt.
  ///
  /// In ar, this message translates to:
  /// **'لقد حفظت الرمز في مكان آمن'**
  String get iSavedIt;

  /// No description provided for @recoveryCodeCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ رمز الاسترجاع'**
  String get recoveryCodeCopied;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة كلمة المرور'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني وسنرسل لك رمزًا من ٦ أرقام لإعادة تعيين كلمة المرور.'**
  String get forgotPasswordBody;

  /// No description provided for @forgotPasswordCodeBody.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكوّن من ٦ أرقام من البريد، ثم اختر كلمة مرور جديدة.'**
  String get forgotPasswordCodeBody;

  /// No description provided for @resetCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز إعادة التعيين'**
  String get resetCode;

  /// No description provided for @resetCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'الرمز المكوّن من ٦ أرقام من البريد'**
  String get resetCodeHint;

  /// No description provided for @resetCodeSentTo.
  ///
  /// In ar, this message translates to:
  /// **'إذا كان {email} مسجّلًا لدينا فسيصلك رمز الآن. تحقق من مجلد الرسائل المزعجة أيضًا.'**
  String resetCodeSentTo(String email);

  /// No description provided for @sendResetCode.
  ///
  /// In ar, this message translates to:
  /// **'أرسل لي رمزًا بالبريد'**
  String get sendResetCode;

  /// No description provided for @resendCode.
  ///
  /// In ar, this message translates to:
  /// **'أرسل رمزًا جديدًا'**
  String get resendCode;

  /// No description provided for @useSavedRecoveryCode.
  ///
  /// In ar, this message translates to:
  /// **'استخدام رمز الاسترجاع المحفوظ'**
  String get useSavedRecoveryCode;

  /// No description provided for @useEmailedCode.
  ///
  /// In ar, this message translates to:
  /// **'استخدام رمز البريد الإلكتروني'**
  String get useEmailedCode;

  /// No description provided for @resetCodeExpiry.
  ///
  /// In ar, this message translates to:
  /// **'تنتهي صلاحية الرمز خلال {minutes} دقيقة.'**
  String resetCodeExpiry(int minutes);

  /// No description provided for @passwordChangedBody.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور. سجّل الدخول بكلمة المرور الجديدة.'**
  String get passwordChangedBody;

  /// No description provided for @recoveryCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الاسترجاع'**
  String get recoveryCode;

  /// No description provided for @resetPassword.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get resetPassword;

  /// No description provided for @resetSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور'**
  String get resetSuccessTitle;

  /// No description provided for @resetSuccessBody.
  ///
  /// In ar, this message translates to:
  /// **'احفظ رمز الاسترجاع الجديد، ثم سجّل الدخول بكلمة المرور الجديدة.'**
  String get resetSuccessBody;

  /// No description provided for @blockedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب موقوف'**
  String get blockedTitle;

  /// No description provided for @blockedBody.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف هذا الحساب. تواصل مع الدعم للمساعدة.'**
  String get blockedBody;

  /// No description provided for @phoneHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 0912345678'**
  String get phoneHint;

  /// No description provided for @passwordHint.
  ///
  /// In ar, this message translates to:
  /// **'٨ أحرف على الأقل'**
  String get passwordHint;

  /// No description provided for @nameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسمك كما يظهر في الشهادة'**
  String get nameHint;

  /// No description provided for @classLevelHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر صفك الدراسي'**
  String get classLevelHint;

  /// No description provided for @streamHint.
  ///
  /// In ar, this message translates to:
  /// **'علمي أو أدبي'**
  String get streamHint;

  /// No description provided for @showPassword.
  ///
  /// In ar, this message translates to:
  /// **'إظهار كلمة المرور'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء كلمة المرور'**
  String get hidePassword;

  /// No description provided for @passwordWeak.
  ///
  /// In ar, this message translates to:
  /// **'ضعيفة'**
  String get passwordWeak;

  /// No description provided for @passwordMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسطة'**
  String get passwordMedium;

  /// No description provided for @passwordStrong.
  ///
  /// In ar, this message translates to:
  /// **'قوية'**
  String get passwordStrong;

  /// No description provided for @secondary1.
  ///
  /// In ar, this message translates to:
  /// **'الأول الثانوي'**
  String get secondary1;

  /// No description provided for @secondary2.
  ///
  /// In ar, this message translates to:
  /// **'الثاني الثانوي'**
  String get secondary2;

  /// No description provided for @secondary3.
  ///
  /// In ar, this message translates to:
  /// **'الثالث الثانوي (الشهادة السودانية)'**
  String get secondary3;

  /// No description provided for @streamScience.
  ///
  /// In ar, this message translates to:
  /// **'علمي'**
  String get streamScience;

  /// No description provided for @streamLiterary.
  ///
  /// In ar, this message translates to:
  /// **'أدبي'**
  String get streamLiterary;

  /// No description provided for @sessionExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. سجّل الدخول مرة أخرى.'**
  String get sessionExpired;

  /// No description provided for @walletTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get walletTitle;

  /// No description provided for @availableCredits.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح'**
  String get availableCredits;

  /// No description provided for @reservedHint.
  ///
  /// In ar, this message translates to:
  /// **'{count} من رصيدك محجوز لطلب دفع قيد المراجعة.'**
  String reservedHint(int count);

  /// No description provided for @nextExpiry.
  ///
  /// In ar, this message translates to:
  /// **'أقرب انتهاء صلاحية'**
  String get nextExpiry;

  /// No description provided for @expirySoon.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي جزء من رصيدك في {date}. استخدمه قبل ذلك.'**
  String expirySoon(String date);

  /// No description provided for @lowCredits.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك منخفض. أضف رصيدًا لمواصلة المذاكرة.'**
  String get lowCredits;

  /// No description provided for @addCredit.
  ///
  /// In ar, this message translates to:
  /// **'إضافة رصيد'**
  String get addCredit;

  /// No description provided for @ledgerTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل الرصيد'**
  String get ledgerTitle;

  /// No description provided for @ledgerEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات بعد'**
  String get ledgerEmpty;

  /// No description provided for @ledgerEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا كل إضافة أو استخدام للرصيد.'**
  String get ledgerEmptyHint;

  /// No description provided for @entrySignupBonus.
  ///
  /// In ar, this message translates to:
  /// **'رصيد الترحيب'**
  String get entrySignupBonus;

  /// No description provided for @entryPurchase.
  ///
  /// In ar, this message translates to:
  /// **'شراء رصيد'**
  String get entryPurchase;

  /// No description provided for @entrySpend.
  ///
  /// In ar, this message translates to:
  /// **'استخدام رصيد'**
  String get entrySpend;

  /// No description provided for @entryExpiry.
  ///
  /// In ar, this message translates to:
  /// **'انتهاء صلاحية الرصيد'**
  String get entryExpiry;

  /// No description provided for @entryAdminAdjust.
  ///
  /// In ar, this message translates to:
  /// **'تعديل من الإدارة'**
  String get entryAdminAdjust;

  /// No description provided for @entryExamUnlock.
  ///
  /// In ar, this message translates to:
  /// **'فتح امتحان {key}'**
  String entryExamUnlock(String key);

  /// No description provided for @entryPaymentApproved.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد الدفع {code}'**
  String entryPaymentApproved(String code);

  /// No description provided for @entryUnlockShort.
  ///
  /// In ar, this message translates to:
  /// **'فتح ورقة'**
  String get entryUnlockShort;

  /// No description provided for @entryPaymentApprovedShort.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد دفع'**
  String get entryPaymentApprovedShort;

  /// No description provided for @creditsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا رصيد} one{رصيد واحد} two{رصيدان} few{{count} أرصدة} many{{count} رصيدًا} other{{count} رصيد}}'**
  String creditsCount(int count);

  /// No description provided for @examsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الامتحانات'**
  String get examsTitle;

  /// No description provided for @subject.
  ///
  /// In ar, this message translates to:
  /// **'المادة'**
  String get subject;

  /// No description provided for @year.
  ///
  /// In ar, this message translates to:
  /// **'السنة'**
  String get year;

  /// No description provided for @session.
  ///
  /// In ar, this message translates to:
  /// **'الدورة'**
  String get session;

  /// No description provided for @allSubjects.
  ///
  /// In ar, this message translates to:
  /// **'كل المواد'**
  String get allSubjects;

  /// No description provided for @allYears.
  ///
  /// In ar, this message translates to:
  /// **'كل السنوات'**
  String get allYears;

  /// No description provided for @allSessions.
  ///
  /// In ar, this message translates to:
  /// **'كل الدورات'**
  String get allSessions;

  /// No description provided for @allLanguages.
  ///
  /// In ar, this message translates to:
  /// **'كل اللغات'**
  String get allLanguages;

  /// No description provided for @free.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get free;

  /// No description provided for @unlocked.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get unlocked;

  /// No description provided for @locked.
  ///
  /// In ar, this message translates to:
  /// **'مقفل'**
  String get locked;

  /// No description provided for @lockedFor.
  ///
  /// In ar, this message translates to:
  /// **'مقفل · {count}'**
  String lockedFor(String count);

  /// No description provided for @unlockFor.
  ///
  /// In ar, this message translates to:
  /// **'افتح مقابل {count}'**
  String unlockFor(String count);

  /// No description provided for @unlockConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'فتح هذا الامتحان؟'**
  String get unlockConfirmTitle;

  /// No description provided for @unlockConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُخصم {cost} من رصيدك. رصيدك الحالي {balance}.'**
  String unlockConfirmBody(String cost, String balance);

  /// No description provided for @balanceAfter.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد بعد الفتح (تقديري): {value}'**
  String balanceAfter(String value);

  /// No description provided for @unlock.
  ///
  /// In ar, this message translates to:
  /// **'فتح الامتحان'**
  String get unlock;

  /// No description provided for @unlockSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم فتح الامتحان. بالتوفيق!'**
  String get unlockSuccess;

  /// No description provided for @startPractice.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التدريب'**
  String get startPractice;

  /// No description provided for @resumePractice.
  ///
  /// In ar, this message translates to:
  /// **'أكمل التدريب'**
  String get resumePractice;

  /// No description provided for @practiceDisabled.
  ///
  /// In ar, this message translates to:
  /// **'التدريب غير متاح'**
  String get practiceDisabled;

  /// No description provided for @practiceDisabledHint.
  ///
  /// In ar, this message translates to:
  /// **'أوقفت الإدارة التدريب على هذا الامتحان. يمكنك قراءته فقط.'**
  String get practiceDisabledHint;

  /// No description provided for @paperViewer.
  ///
  /// In ar, this message translates to:
  /// **'قراءة الامتحان'**
  String get paperViewer;

  /// No description provided for @instructions.
  ///
  /// In ar, this message translates to:
  /// **'التعليمات'**
  String get instructions;

  /// No description provided for @totalMarks.
  ///
  /// In ar, this message translates to:
  /// **'{count} درجة'**
  String totalMarks(String count);

  /// No description provided for @durationMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{بدون وقت} one{دقيقة واحدة} two{دقيقتان} few{{count} دقائق} many{{count} دقيقة} other{{count} دقيقة}}'**
  String durationMinutes(int count);

  /// No description provided for @questionCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا أسئلة} one{سؤال واحد} two{سؤالان} few{{count} أسئلة} many{{count} سؤالًا} other{{count} سؤال}}'**
  String questionCount(int count);

  /// No description provided for @myUnlocks.
  ///
  /// In ar, this message translates to:
  /// **'امتحاناتي المفتوحة'**
  String get myUnlocks;

  /// No description provided for @myUnlocksEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم تفتح أي امتحان بعد'**
  String get myUnlocksEmpty;

  /// No description provided for @myUnlocksEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'افتح امتحانًا ليظهر هنا ويصبح متاحًا دون اتصال.'**
  String get myUnlocksEmptyHint;

  /// No description provided for @yourOpenPapers.
  ///
  /// In ar, this message translates to:
  /// **'أوراقك المفتوحة'**
  String get yourOpenPapers;

  /// No description provided for @partialPapersFailed.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{تعذّر تحميل بعض الأوراق} one{تعذّرت ورقة واحدة} two{تعذّرت ورقتان} few{تعذّر تحميل {count} أوراق} many{تعذّر تحميل {count} ورقة} other{تعذّر تحميل {count} ورقة}}'**
  String partialPapersFailed(int count);

  /// No description provided for @viewKeys.
  ///
  /// In ar, this message translates to:
  /// **'الإجابات النموذجية'**
  String get viewKeys;

  /// No description provided for @trialBadge.
  ///
  /// In ar, this message translates to:
  /// **'تجريبي'**
  String get trialBadge;

  /// No description provided for @examNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على هذا الامتحان'**
  String get examNotFound;

  /// No description provided for @noExams.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد امتحانات مطابقة'**
  String get noExams;

  /// No description provided for @noExamsHint.
  ///
  /// In ar, this message translates to:
  /// **'جرّب تغيير التصفية أو البحث بكلمة أخرى.'**
  String get noExamsHint;

  /// No description provided for @searchExams.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مادة أو سنة'**
  String get searchExams;

  /// No description provided for @stimulusTitle.
  ///
  /// In ar, this message translates to:
  /// **'النص'**
  String get stimulusTitle;

  /// No description provided for @questionLabel.
  ///
  /// In ar, this message translates to:
  /// **'سؤال {path}'**
  String questionLabel(String path);

  /// No description provided for @answerKey.
  ///
  /// In ar, this message translates to:
  /// **'الإجابة الصحيحة'**
  String get answerKey;

  /// No description provided for @explanation.
  ///
  /// In ar, this message translates to:
  /// **'الشرح'**
  String get explanation;

  /// No description provided for @modelAnswer.
  ///
  /// In ar, this message translates to:
  /// **'إجابة نموذجية'**
  String get modelAnswer;

  /// No description provided for @criteria.
  ///
  /// In ar, this message translates to:
  /// **'معايير التصحيح'**
  String get criteria;

  /// No description provided for @acceptedAlternatives.
  ///
  /// In ar, this message translates to:
  /// **'إجابات بديلة مقبولة'**
  String get acceptedAlternatives;

  /// No description provided for @lockedQuestionHint.
  ///
  /// In ar, this message translates to:
  /// **'افتح الامتحان لرؤية هذا السؤال وإجابته.'**
  String get lockedQuestionHint;

  /// No description provided for @fieldTooShort.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا يقل عن {min} حرفًا'**
  String fieldTooShort(int min);

  /// No description provided for @fieldTooLong.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا يزيد عن {max} حرفًا'**
  String fieldTooLong(int max);

  /// No description provided for @fieldPhoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف صحيح'**
  String get fieldPhoneInvalid;

  /// No description provided for @fieldPasswordShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون ٨ أحرف على الأقل'**
  String get fieldPasswordShort;

  /// No description provided for @fieldTermsRequired.
  ///
  /// In ar, this message translates to:
  /// **'عليك الموافقة على الشروط للمتابعة'**
  String get fieldTermsRequired;

  /// No description provided for @fieldAnswerRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب إجابتك أولًا'**
  String get fieldAnswerRequired;

  /// No description provided for @practiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'التدريب'**
  String get practiceTitle;

  /// No description provided for @questionOf.
  ///
  /// In ar, this message translates to:
  /// **'سؤال {current} من {total}'**
  String questionOf(String current, String total);

  /// No description provided for @checkAnswer.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من الإجابة'**
  String get checkAnswer;

  /// No description provided for @nextQuestion.
  ///
  /// In ar, this message translates to:
  /// **'السؤال التالي'**
  String get nextQuestion;

  /// No description provided for @previousQuestion.
  ///
  /// In ar, this message translates to:
  /// **'السؤال السابق'**
  String get previousQuestion;

  /// No description provided for @finishPractice.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء التدريب'**
  String get finishPractice;

  /// No description provided for @finishConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء جلسة التدريب؟'**
  String get finishConfirmTitle;

  /// No description provided for @finishConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك مراجعة إجاباتك لاحقًا في شاشة النتيجة.'**
  String get finishConfirmBody;

  /// No description provided for @correct.
  ///
  /// In ar, this message translates to:
  /// **'إجابة صحيحة'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In ar, this message translates to:
  /// **'إجابة غير صحيحة'**
  String get incorrect;

  /// No description provided for @partlyCorrect.
  ///
  /// In ar, this message translates to:
  /// **'صحيح جزئيًا — {awarded} من {total}'**
  String partlyCorrect(String awarded, String total);

  /// No description provided for @marksAwarded.
  ///
  /// In ar, this message translates to:
  /// **'{value} درجة'**
  String marksAwarded(String value);

  /// No description provided for @marksWorth.
  ///
  /// In ar, this message translates to:
  /// **'تساوي {value} درجة'**
  String marksWorth(String value);

  /// No description provided for @answerSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ إجابتك'**
  String get answerSaved;

  /// No description provided for @answerSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل للتصحيح'**
  String get answerSubmitted;

  /// No description provided for @savedOnDevice.
  ///
  /// In ar, this message translates to:
  /// **'محفوظ على هذا الجهاز'**
  String get savedOnDevice;

  /// No description provided for @waitingToSend.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الإرسال'**
  String get waitingToSend;

  /// No description provided for @checkDisabledHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر إجابة أو اكتبها لتفعيل التحقق.'**
  String get checkDisabledHint;

  /// No description provided for @moveUp.
  ///
  /// In ar, this message translates to:
  /// **'تحريك لأعلى'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In ar, this message translates to:
  /// **'تحريك لأسفل'**
  String get moveDown;

  /// No description provided for @structureUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'لا تتوفر بيانات كافية لعرض هذا النوع من الأسئلة. أبلغ عن السؤال لتتم مراجعته.'**
  String get structureUnavailable;

  /// No description provided for @currentLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالي'**
  String get currentLabel;

  /// No description provided for @backToQuestions.
  ///
  /// In ar, this message translates to:
  /// **'العودة للأسئلة'**
  String get backToQuestions;

  /// No description provided for @pendingUploadCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{إجابة واحدة بانتظار الإرسال} two{إجابتان بانتظار الإرسال} few{{count} إجابات بانتظار الإرسال} many{{count} إجابة بانتظار الإرسال} other{{count} إجابة بانتظار الإرسال}}'**
  String pendingUploadCount(int count);

  /// No description provided for @provisionalScore.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة مبدئية'**
  String get provisionalScore;

  /// No description provided for @finalScore.
  ///
  /// In ar, this message translates to:
  /// **'النتيجة النهائية'**
  String get finalScore;

  /// No description provided for @newPractice.
  ///
  /// In ar, this message translates to:
  /// **'تدريب جديد'**
  String get newPractice;

  /// No description provided for @yourAnswerUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'إجابتك غير متاحة على هذا الجهاز.'**
  String get yourAnswerUnavailable;

  /// No description provided for @keyUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الإجابة غير متاحة حاليًا.'**
  String get keyUnavailable;

  /// No description provided for @pendingSelf.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ. صحّح هذا السؤال بنفسك بمقارنة إجابتك بالإجابة النموذجية.'**
  String get pendingSelf;

  /// No description provided for @pendingAi.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ. يمكنك طلب تصحيح بالذكاء الاصطناعي عبر زر مستقل.'**
  String get pendingAi;

  /// No description provided for @tryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get tryAgain;

  /// No description provided for @tryAgainAiWarning.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإجابة على سؤال صُحّح بالذكاء الاصطناعي تتطلب تصحيحًا جديدًا مدفوعًا.'**
  String get tryAgainAiWarning;

  /// No description provided for @reportTextHint.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل إضافية (اختياري، ٥ أحرف على الأقل)'**
  String get reportTextHint;

  /// No description provided for @attemptsCount.
  ///
  /// In ar, this message translates to:
  /// **'المحاولة {count}'**
  String attemptsCount(String count);

  /// No description provided for @questionNavigator.
  ///
  /// In ar, this message translates to:
  /// **'خريطة الأسئلة'**
  String get questionNavigator;

  /// No description provided for @answeredLabel.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإجابة'**
  String get answeredLabel;

  /// No description provided for @unansweredLabel.
  ///
  /// In ar, this message translates to:
  /// **'بدون إجابة'**
  String get unansweredLabel;

  /// No description provided for @pendingLabel.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار التصحيح'**
  String get pendingLabel;

  /// No description provided for @reportQuestion.
  ///
  /// In ar, this message translates to:
  /// **'أبلغ عن سؤال'**
  String get reportQuestion;

  /// No description provided for @reportReasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'ما المشكلة؟'**
  String get reportReasonLabel;

  /// No description provided for @reportReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'اشرح المشكلة (٥ أحرف على الأقل)'**
  String get reportReasonHint;

  /// No description provided for @reportSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال البلاغ. شكرًا لك.'**
  String get reportSent;

  /// No description provided for @resultTitle.
  ///
  /// In ar, this message translates to:
  /// **'النتيجة'**
  String get resultTitle;

  /// No description provided for @scoreOf.
  ///
  /// In ar, this message translates to:
  /// **'{awarded} من {total}'**
  String scoreOf(String awarded, String total);

  /// No description provided for @resultPendingNote.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة التي لم تُصحّح بعد غير محسوبة في الدرجة.'**
  String get resultPendingNote;

  /// No description provided for @reviewAnswers.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الإجابات'**
  String get reviewAnswers;

  /// No description provided for @retryWrong.
  ///
  /// In ar, this message translates to:
  /// **'أعد الأسئلة الخاطئة'**
  String get retryWrong;

  /// No description provided for @backToExams.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الامتحانات'**
  String get backToExams;

  /// No description provided for @sectionBreakdown.
  ///
  /// In ar, this message translates to:
  /// **'حسب الأقسام'**
  String get sectionBreakdown;

  /// No description provided for @yourAnswer.
  ///
  /// In ar, this message translates to:
  /// **'إجابتك'**
  String get yourAnswer;

  /// No description provided for @noAnswer.
  ///
  /// In ar, this message translates to:
  /// **'لم تُجب'**
  String get noAnswer;

  /// No description provided for @answerHintText.
  ///
  /// In ar, this message translates to:
  /// **'اكتب إجابتك هنا'**
  String get answerHintText;

  /// No description provided for @selectOne.
  ///
  /// In ar, this message translates to:
  /// **'اختر إجابة واحدة'**
  String get selectOne;

  /// No description provided for @selectAllThatApply.
  ///
  /// In ar, this message translates to:
  /// **'اختر كل الإجابات الصحيحة'**
  String get selectAllThatApply;

  /// No description provided for @trueLabel.
  ///
  /// In ar, this message translates to:
  /// **'صح'**
  String get trueLabel;

  /// No description provided for @falseLabel.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get falseLabel;

  /// No description provided for @blankLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفراغ {index}'**
  String blankLabel(String index);

  /// No description provided for @cellLabel.
  ///
  /// In ar, this message translates to:
  /// **'صف {row}، عمود {column}'**
  String cellLabel(String row, String column);

  /// No description provided for @reorderHint.
  ///
  /// In ar, this message translates to:
  /// **'اسحب لترتيب العناصر'**
  String get reorderHint;

  /// No description provided for @orderingItemLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنصر {index} من {total}'**
  String orderingItemLabel(String index, String total);

  /// No description provided for @numericKeyboardHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقمًا (تُقبل الأرقام العربية والفواصل العشرية)'**
  String get numericKeyboardHint;

  /// No description provided for @matchWith.
  ///
  /// In ar, this message translates to:
  /// **'طابق مع'**
  String get matchWith;

  /// No description provided for @numericHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقمًا'**
  String get numericHint;

  /// No description provided for @selfMarkTitle.
  ///
  /// In ar, this message translates to:
  /// **'صحّح بنفسك'**
  String get selfMarkTitle;

  /// No description provided for @selfMarkHint.
  ///
  /// In ar, this message translates to:
  /// **'قارن إجابتك بالإجابة النموذجية ثم قيّم نفسك. تُرسل الدرجة إلى الخادم وتُحتسب في نتيجتك.'**
  String get selfMarkHint;

  /// No description provided for @selfMarkGotIt.
  ///
  /// In ar, this message translates to:
  /// **'أجبت بشكل صحيح'**
  String get selfMarkGotIt;

  /// No description provided for @selfMarkPartial.
  ///
  /// In ar, this message translates to:
  /// **'أجبت جزئيًا'**
  String get selfMarkPartial;

  /// No description provided for @selfMarkMissed.
  ///
  /// In ar, this message translates to:
  /// **'لم أُجب بشكل صحيح'**
  String get selfMarkMissed;

  /// No description provided for @offlineQueued.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال. حُفظت إجابتك وستُرسل عند عودة الاتصال.'**
  String get offlineQueued;

  /// No description provided for @attemptClosedTitle.
  ///
  /// In ar, this message translates to:
  /// **'أُغلقت الجلسة'**
  String get attemptClosedTitle;

  /// No description provided for @startNewAttempt.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ جلسة جديدة'**
  String get startNewAttempt;

  /// No description provided for @resumeTitle.
  ///
  /// In ar, this message translates to:
  /// **'أكمل من حيث توقفت'**
  String get resumeTitle;

  /// No description provided for @packagesTitle.
  ///
  /// In ar, this message translates to:
  /// **'باقات الرصيد'**
  String get packagesTitle;

  /// No description provided for @pricePerCredit.
  ///
  /// In ar, this message translates to:
  /// **'{value} للرصيد الواحد'**
  String pricePerCredit(String value);

  /// No description provided for @buyPackage.
  ///
  /// In ar, this message translates to:
  /// **'اشترِ هذه الباقة'**
  String get buyPackage;

  /// No description provided for @paymentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مدفوعاتي'**
  String get paymentsTitle;

  /// No description provided for @paymentsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات دفع'**
  String get paymentsEmpty;

  /// No description provided for @paymentsEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر باقة رصيد وحوّل المبلغ عبر بنكك، ثم ارفع الإيصال هنا.'**
  String get paymentsEmptyHint;

  /// No description provided for @paymentInstructionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentInstructionsTitle;

  /// No description provided for @stepAmount.
  ///
  /// In ar, this message translates to:
  /// **'١. حوّل هذا المبلغ بالضبط'**
  String get stepAmount;

  /// No description provided for @stepBank.
  ///
  /// In ar, this message translates to:
  /// **'٢. إلى هذا الحساب'**
  String get stepBank;

  /// No description provided for @stepBankak.
  ///
  /// In ar, this message translates to:
  /// **'٣. أتم التحويل من تطبيق بنكك'**
  String get stepBankak;

  /// No description provided for @stepReceipt.
  ///
  /// In ar, this message translates to:
  /// **'٤. ارفع الإيصال وأدخل رقم العملية'**
  String get stepReceipt;

  /// No description provided for @stepStatus.
  ///
  /// In ar, this message translates to:
  /// **'٥. تابع حالة الطلب'**
  String get stepStatus;

  /// No description provided for @exactAmountWarning.
  ///
  /// In ar, this message translates to:
  /// **'حوّل نفس المبلغ تمامًا. أي اختلاف يؤخر الاعتماد.'**
  String get exactAmountWarning;

  /// No description provided for @bankName.
  ///
  /// In ar, this message translates to:
  /// **'اسم البنك'**
  String get bankName;

  /// No description provided for @accountName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الحساب'**
  String get accountName;

  /// No description provided for @accountNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحساب'**
  String get accountNumber;

  /// No description provided for @paymentCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الدفع'**
  String get paymentCode;

  /// No description provided for @openBankak.
  ///
  /// In ar, this message translates to:
  /// **'افتح تطبيق بنكك'**
  String get openBankak;

  /// No description provided for @bankakNotInstalled.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق بنكك غير مثبت على هذا الجهاز.'**
  String get bankakNotInstalled;

  /// No description provided for @reviewTimeHint.
  ///
  /// In ar, this message translates to:
  /// **'تُراجع الطلبات عادة خلال بضع ساعات.'**
  String get reviewTimeHint;

  /// No description provided for @referenceLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم العملية'**
  String get referenceLabel;

  /// No description provided for @senderNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المرسل'**
  String get senderNameLabel;

  /// No description provided for @receiptLabel.
  ///
  /// In ar, this message translates to:
  /// **'صورة الإيصال'**
  String get receiptLabel;

  /// No description provided for @takePhoto.
  ///
  /// In ar, this message translates to:
  /// **'التقط صورة'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختر من المعرض'**
  String get chooseFromGallery;

  /// No description provided for @choosePdf.
  ///
  /// In ar, this message translates to:
  /// **'اختر ملف PDF'**
  String get choosePdf;

  /// No description provided for @receiptPreview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة الإيصال'**
  String get receiptPreview;

  /// No description provided for @submitReceipt.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الإيصال'**
  String get submitReceipt;

  /// No description provided for @receiptUploading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ رفع الإيصال…'**
  String get receiptUploading;

  /// No description provided for @receiptTooLargeLocal.
  ///
  /// In ar, this message translates to:
  /// **'الملف أكبر من ٨ ميغابايت. اختر صورة أصغر.'**
  String get receiptTooLargeLocal;

  /// No description provided for @receiptTypeInvalidLocal.
  ///
  /// In ar, this message translates to:
  /// **'نوع الملف غير مدعوم. استخدم JPEG أو PNG أو WebP أو PDF.'**
  String get receiptTypeInvalidLocal;

  /// No description provided for @cameraRationaleTitle.
  ///
  /// In ar, this message translates to:
  /// **'نحتاج إذن الكاميرا'**
  String get cameraRationaleTitle;

  /// No description provided for @cameraRationaleBody.
  ///
  /// In ar, this message translates to:
  /// **'نستخدم الكاميرا لتصوير إيصال التحويل فقط. لا نصل إلى أي صور أخرى بدون اختيارك.'**
  String get cameraRationaleBody;

  /// No description provided for @statusPendingPayment.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الدفع'**
  String get statusPendingPayment;

  /// No description provided for @statusSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل'**
  String get statusSubmitted;

  /// No description provided for @statusUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get statusUnderReview;

  /// No description provided for @statusNeedsInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات ناقصة'**
  String get statusNeedsInfo;

  /// No description provided for @statusApproved.
  ///
  /// In ar, this message translates to:
  /// **'معتمد'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get statusRejected;

  /// No description provided for @statusExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get statusExpired;

  /// No description provided for @statusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get statusCancelled;

  /// No description provided for @timelineCreated.
  ///
  /// In ar, this message translates to:
  /// **'أُنشئ الطلب'**
  String get timelineCreated;

  /// No description provided for @timelineSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل الإيصال'**
  String get timelineSubmitted;

  /// No description provided for @timelineReviewed.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get timelineReviewed;

  /// No description provided for @timelineDecided.
  ///
  /// In ar, this message translates to:
  /// **'القرار'**
  String get timelineDecided;

  /// No description provided for @rejectReasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض'**
  String get rejectReasonLabel;

  /// No description provided for @resubmit.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get resubmit;

  /// No description provided for @cancelRequest.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get cancelRequest;

  /// No description provided for @cancelConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء طلب الدفع؟'**
  String get cancelConfirmTitle;

  /// No description provided for @cancelConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُلغى هذا الطلب ويمكنك إنشاء طلب جديد لاحقًا.'**
  String get cancelConfirmBody;

  /// No description provided for @paymentApprovedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة الرصيد!'**
  String get paymentApprovedTitle;

  /// No description provided for @viewReceipt.
  ///
  /// In ar, this message translates to:
  /// **'عرض الإيصال'**
  String get viewReceipt;

  /// No description provided for @expectedAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المطلوب تحويله'**
  String get expectedAmountLabel;

  /// No description provided for @homeTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homeTitle;

  /// No description provided for @greeting.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا {name}'**
  String greeting(String name);

  /// No description provided for @recommendedForYou.
  ///
  /// In ar, this message translates to:
  /// **'مقترح لك'**
  String get recommendedForYou;

  /// No description provided for @quickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get quickActions;

  /// No description provided for @newPapers.
  ///
  /// In ar, this message translates to:
  /// **'أحدث الامتحانات'**
  String get newPapers;

  /// No description provided for @continueStudying.
  ///
  /// In ar, this message translates to:
  /// **'أكمل المذاكرة'**
  String get continueStudying;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @appearanceHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر المظهر الذي يريح عينك.'**
  String get appearanceHint;

  /// No description provided for @groupReading.
  ///
  /// In ar, this message translates to:
  /// **'القراءة'**
  String get groupReading;

  /// No description provided for @groupLanguageNumbers.
  ///
  /// In ar, this message translates to:
  /// **'اللغة والأرقام'**
  String get groupLanguageNumbers;

  /// No description provided for @groupData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات والتخزين'**
  String get groupData;

  /// No description provided for @groupHelp.
  ///
  /// In ar, this message translates to:
  /// **'الدعم والتشخيص'**
  String get groupHelp;

  /// No description provided for @readingSample.
  ///
  /// In ar, this message translates to:
  /// **'اقْرَأْ بِتَمَهُّلٍ، وَرَاجِعْ دَرْسَكَ كُلَّ يَوْمٍ.'**
  String get readingSample;

  /// No description provided for @appLanguageHint.
  ///
  /// In ar, this message translates to:
  /// **'لغة الأزرار والقوائم والرسائل.'**
  String get appLanguageHint;

  /// No description provided for @digitStyleHint.
  ///
  /// In ar, this message translates to:
  /// **'شكل الأرقام فقط؛ لا يغيّر اللغة.'**
  String get digitStyleHint;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// No description provided for @textSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم النص'**
  String get textSize;

  /// No description provided for @digitStyle.
  ///
  /// In ar, this message translates to:
  /// **'شكل الأرقام'**
  String get digitStyle;

  /// No description provided for @digitsArabic.
  ///
  /// In ar, this message translates to:
  /// **'١٢٣ عربية'**
  String get digitsArabic;

  /// No description provided for @digitsWestern.
  ///
  /// In ar, this message translates to:
  /// **'123 غربية'**
  String get digitsWestern;

  /// No description provided for @dataSaver.
  ///
  /// In ar, this message translates to:
  /// **'توفير البيانات'**
  String get dataSaver;

  /// No description provided for @dataSaverHint.
  ///
  /// In ar, this message translates to:
  /// **'لا تُنزّل الإجابات النموذجية أو الأوراق الكبيرة تلقائيًا.'**
  String get dataSaverHint;

  /// No description provided for @clearCache.
  ///
  /// In ar, this message translates to:
  /// **'مسح البيانات المحفوظة'**
  String get clearCache;

  /// No description provided for @clearCacheConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسح البيانات المحفوظة؟'**
  String get clearCacheConfirmTitle;

  /// No description provided for @clearCacheConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف الأوراق والإجابات المحفوظة والمسودات والإجابات التي لم تُرسَل بعد من هذا الجهاز. يبقى رصيدك وحسابك وتسجيل الدخول كما هي.'**
  String get clearCacheConfirmBody;

  /// No description provided for @clearCacheIncludesQueue.
  ///
  /// In ar, this message translates to:
  /// **'المسودات والإجابات المنتظرة للإرسال ستُحذف أيضًا.'**
  String get clearCacheIncludesQueue;

  /// No description provided for @cacheCleared.
  ///
  /// In ar, this message translates to:
  /// **'تم مسح البيانات المحفوظة'**
  String get cacheCleared;

  /// No description provided for @paymentHelp.
  ///
  /// In ar, this message translates to:
  /// **'مساعدة الدفع'**
  String get paymentHelp;

  /// No description provided for @reportProblem.
  ///
  /// In ar, this message translates to:
  /// **'أبلغ عن مشكلة'**
  String get reportProblem;

  /// No description provided for @reportProblemHint.
  ///
  /// In ar, this message translates to:
  /// **'يشارك سجل الأخطاء الأخير بدون أي بيانات شخصية.'**
  String get reportProblemHint;

  /// No description provided for @deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccount;

  /// No description provided for @deleteAccountHint.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب غير متاح آليًا بعد. تواصل مع الدعم وسنقوم به يدويًا.'**
  String get deleteAccountHint;

  /// No description provided for @aboutAndLegal.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق والقانون'**
  String get aboutAndLegal;

  /// No description provided for @appLanguage.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get appLanguage;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @diagnosticsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أخطاء مسجلة'**
  String get diagnosticsEmpty;

  /// No description provided for @sendReport.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقرير'**
  String get sendReport;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديث مطلوب'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateBody.
  ///
  /// In ar, this message translates to:
  /// **'يتوفر إصدار أحدث. حدّث التطبيق من المتجر ثم افتحه من جديد.'**
  String get forceUpdateBody;

  /// No description provided for @notFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة غير موجودة'**
  String get notFoundTitle;

  /// No description provided for @maintenanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة غير متاحة مؤقتًا'**
  String get maintenanceTitle;

  /// No description provided for @errorUnauthorized.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. سجّل الدخول مرة أخرى.'**
  String get errorUnauthorized;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو كلمة المرور غير صحيحة.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorInvalidToken.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. سجّل الدخول مرة أخرى.'**
  String get errorInvalidToken;

  /// No description provided for @errorInvalidRefreshToken.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. سجّل الدخول مرة أخرى.'**
  String get errorInvalidRefreshToken;

  /// No description provided for @errorAccountBlocked.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحساب موقوف. تواصل مع الدعم.'**
  String get errorAccountBlocked;

  /// No description provided for @errorForbidden.
  ///
  /// In ar, this message translates to:
  /// **'لا تملك صلاحية لهذا الإجراء.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على ما تبحث عنه.'**
  String get errorNotFound;

  /// No description provided for @errorPhoneTaken.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف مسجّل بالفعل. جرّب تسجيل الدخول.'**
  String get errorPhoneTaken;

  /// No description provided for @errorEmailTaken.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد الإلكتروني مسجّل بالفعل. جرّب تسجيل الدخول.'**
  String get errorEmailTaken;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدًا إلكترونيًا صحيحًا.'**
  String get errorInvalidEmail;

  /// No description provided for @errorInvalidResetCode.
  ///
  /// In ar, this message translates to:
  /// **'الرمز غير صحيح أو انتهت صلاحيته.'**
  String get errorInvalidResetCode;

  /// No description provided for @errorMailNotConfigured.
  ///
  /// In ar, this message translates to:
  /// **'إرسال البريد غير مُهيّأ على الخادم بعد. تواصل مع الدعم.'**
  String get errorMailNotConfigured;

  /// No description provided for @errorMailSendFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إرسال البريد. حاول بعد قليل.'**
  String get errorMailSendFailed;

  /// No description provided for @errorInvalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف سوداني صحيح، مثال: 0912345678.'**
  String get errorInvalidPhone;

  /// No description provided for @errorReceiptUploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر رفع الإيصال. حاول مرة أخرى.'**
  String get errorReceiptUploadFailed;

  /// No description provided for @errorStudentOnly.
  ///
  /// In ar, this message translates to:
  /// **'هذا الإجراء متاح للطلاب فقط.'**
  String get errorStudentOnly;

  /// No description provided for @errorInvalidRecoveryCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الاسترجاع غير صحيح.'**
  String get errorInvalidRecoveryCode;

  /// No description provided for @errorValidationError.
  ///
  /// In ar, this message translates to:
  /// **'راجع الحقول المشار إليها بالأحمر.'**
  String get errorValidationError;

  /// No description provided for @errorRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'طلبات كثيرة جدًا. انتظر لحظة ثم حاول مجددًا.'**
  String get errorRateLimited;

  /// No description provided for @errorInsufficientCredits.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك لا يكفي. أضف رصيدًا للمتابعة.'**
  String get errorInsufficientCredits;

  /// No description provided for @errorExamNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على هذا الامتحان.'**
  String get errorExamNotFound;

  /// No description provided for @errorExamLocked.
  ///
  /// In ar, this message translates to:
  /// **'هذا الامتحان مقفل. افتحه أولًا.'**
  String get errorExamLocked;

  /// No description provided for @errorPracticeDisabled.
  ///
  /// In ar, this message translates to:
  /// **'التدريب غير متاح لهذا الامتحان.'**
  String get errorPracticeDisabled;

  /// No description provided for @errorQuestionNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على هذا السؤال.'**
  String get errorQuestionNotFound;

  /// No description provided for @errorQuestionNotAnswerable.
  ///
  /// In ar, this message translates to:
  /// **'أجب عن الأسئلة الفرعية، وليس عن القسم نفسه.'**
  String get errorQuestionNotAnswerable;

  /// No description provided for @errorAttemptNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على جلسة التدريب.'**
  String get errorAttemptNotFound;

  /// No description provided for @errorAttemptClosed.
  ///
  /// In ar, this message translates to:
  /// **'أُغلقت جلسة التدريب. ابدأ جلسة جديدة.'**
  String get errorAttemptClosed;

  /// No description provided for @errorDuplicateValue.
  ///
  /// In ar, this message translates to:
  /// **'هذه القيمة مستخدمة بالفعل.'**
  String get errorDuplicateValue;

  /// No description provided for @errorPackageNotFound.
  ///
  /// In ar, this message translates to:
  /// **'باقة الرصيد هذه لم تعد متاحة.'**
  String get errorPackageNotFound;

  /// No description provided for @errorPaymentAccountNotConfigured.
  ///
  /// In ar, this message translates to:
  /// **'حساب الاستلام غير مهيأ بعد. تواصل مع الدعم.'**
  String get errorPaymentAccountNotConfigured;

  /// No description provided for @errorTooManyOpenPayments.
  ///
  /// In ar, this message translates to:
  /// **'لديك طلبات دفع مفتوحة. أكمل أحدها أو ألغِه أولًا.'**
  String get errorTooManyOpenPayments;

  /// No description provided for @errorPaymentAmountsExhausted.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مبالغ متاحة الآن. حاول بعد قليل.'**
  String get errorPaymentAmountsExhausted;

  /// No description provided for @errorPaymentRequestNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على طلب الدفع.'**
  String get errorPaymentRequestNotFound;

  /// No description provided for @errorPaymentNotSubmittable.
  ///
  /// In ar, this message translates to:
  /// **'لم يعد بالإمكان إرسال هذا الطلب.'**
  String get errorPaymentNotSubmittable;

  /// No description provided for @errorPaymentNotCancellable.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن إلغاء طلب أُرسل بالفعل.'**
  String get errorPaymentNotCancellable;

  /// No description provided for @errorInvalidReference.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم العملية من بنكك (٤ أحرف على الأقل).'**
  String get errorInvalidReference;

  /// No description provided for @errorReferenceAlreadyUsed.
  ///
  /// In ar, this message translates to:
  /// **'رقم العملية هذا مستخدم في طلب دفع آخر.'**
  String get errorReferenceAlreadyUsed;

  /// No description provided for @errorReceiptNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على الإيصال.'**
  String get errorReceiptNotFound;

  /// No description provided for @errorReceiptAlreadyAttached.
  ///
  /// In ar, this message translates to:
  /// **'هذا الإيصال مرتبط بطلب دفع آخر.'**
  String get errorReceiptAlreadyAttached;

  /// No description provided for @errorReceiptTooLarge.
  ///
  /// In ar, this message translates to:
  /// **'حجم الإيصال كبير جدًا. الحد الأقصى ٨ ميغابايت.'**
  String get errorReceiptTooLarge;

  /// No description provided for @errorReceiptTypeNotAllowed.
  ///
  /// In ar, this message translates to:
  /// **'ارفع صورة JPEG أو PNG أو WebP أو ملف PDF.'**
  String get errorReceiptTypeNotAllowed;

  /// No description provided for @errorReceiptFieldInvalid.
  ///
  /// In ar, this message translates to:
  /// **'ملف الإيصال غير صالح.'**
  String get errorReceiptFieldInvalid;

  /// No description provided for @errorReceiptRequired.
  ///
  /// In ar, this message translates to:
  /// **'أرفق صورة الإيصال أولًا.'**
  String get errorReceiptRequired;

  /// No description provided for @errorReceiptFileMissing.
  ///
  /// In ar, this message translates to:
  /// **'لم يصل الملف. حاول مرة أخرى.'**
  String get errorReceiptFileMissing;

  /// No description provided for @errorReportAlreadyOpen.
  ///
  /// In ar, this message translates to:
  /// **'لقد أبلغت عن هذا السؤال بالفعل. نحن نراجعه.'**
  String get errorReportAlreadyOpen;

  /// No description provided for @errorInvalidCursor.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل المزيد. حدّث القائمة.'**
  String get errorInvalidCursor;

  /// No description provided for @errorInternalError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في الخادم. حاول مرة أخرى.'**
  String get errorInternalError;

  /// No description provided for @errorNetworkError.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مجددًا.'**
  String get errorNetworkError;

  /// No description provided for @errorCacheError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر قراءة البيانات المحفوظة.'**
  String get errorCacheError;

  /// No description provided for @errorUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. حاول مرة أخرى.'**
  String get errorUnknown;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطٍ'**
  String get skip;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @show.
  ///
  /// In ar, this message translates to:
  /// **'إظهار'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get hide;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @errorHint.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك ثم حاول مرة أخرى.'**
  String get errorHint;

  /// No description provided for @errorTimeout.
  ///
  /// In ar, this message translates to:
  /// **'استغرق الخادم وقتًا طويلًا. حاول مرة أخرى.'**
  String get errorTimeout;

  /// No description provided for @errorFallback.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع ({code}).'**
  String errorFallback(String code);

  /// No description provided for @termsBody.
  ///
  /// In ar, this message translates to:
  /// **'باستخدامك مذكرة فإنك توافق على استخدام التطبيق للدراسة الشخصية فقط. الأوراق مملوكة لجهاتها الأصلية وتُعرض لأغراض تعليمية. نحتفظ برقم هاتفك واسمك وسجل مدفوعاتك لتشغيل حسابك، ولا نشاركها مع جهات أخرى. لا تشارك رمز الاستعادة مع أي شخص.'**
  String get termsBody;

  /// No description provided for @aboutBody.
  ///
  /// In ar, this message translates to:
  /// **'مذكرة تطبيق لطلاب الشهادة السودانية: أوراق رسمية، تدريب بتصحيح فوري، وشراء رصيد عبر بنكك.'**
  String get aboutBody;

  /// No description provided for @maintenanceBody.
  ///
  /// In ar, this message translates to:
  /// **'نحدّث الخدمة الآن. حاول بعد قليل.'**
  String get maintenanceBody;

  /// No description provided for @notFoundBody.
  ///
  /// In ar, this message translates to:
  /// **'الرابط غير صحيح أو تغيّر.'**
  String get notFoundBody;

  /// No description provided for @goHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get goHome;

  /// No description provided for @designGallery.
  ///
  /// In ar, this message translates to:
  /// **'معرض التصميم'**
  String get designGallery;

  /// No description provided for @reportReason1.
  ///
  /// In ar, this message translates to:
  /// **'السؤال غير واضح'**
  String get reportReason1;

  /// No description provided for @reportReason2.
  ///
  /// In ar, this message translates to:
  /// **'الإجابة النموذجية خاطئة'**
  String get reportReason2;

  /// No description provided for @reportReason3.
  ///
  /// In ar, this message translates to:
  /// **'خطأ مطبعي في النص'**
  String get reportReason3;

  /// No description provided for @reportReason4.
  ///
  /// In ar, this message translates to:
  /// **'مشكلة أخرى'**
  String get reportReason4;

  /// No description provided for @matchingInstruction.
  ///
  /// In ar, this message translates to:
  /// **'اختر الحرف المناسب لكل عنصر'**
  String get matchingInstruction;

  /// No description provided for @orderingInstruction.
  ///
  /// In ar, this message translates to:
  /// **'رتّب العناصر بالترتيب الصحيح'**
  String get orderingInstruction;

  /// No description provided for @tableInstruction.
  ///
  /// In ar, this message translates to:
  /// **'أكمل خلايا الجدول'**
  String get tableInstruction;

  /// No description provided for @matrixInstruction.
  ///
  /// In ar, this message translates to:
  /// **'أدخل قيم المصفوفة في الخلايا'**
  String get matrixInstruction;

  /// No description provided for @truthTableInstruction.
  ///
  /// In ar, this message translates to:
  /// **'أكمل عمود الناتج في جدول الحقيقة'**
  String get truthTableInstruction;

  /// No description provided for @truthTableOutput.
  ///
  /// In ar, this message translates to:
  /// **'الناتج'**
  String get truthTableOutput;

  /// No description provided for @multiInstruction.
  ///
  /// In ar, this message translates to:
  /// **'اختر كل الإجابات الصحيحة'**
  String get multiInstruction;

  /// No description provided for @diacriticsInstruction.
  ///
  /// In ar, this message translates to:
  /// **'اكتب النص مع التشكيل الكامل'**
  String get diacriticsInstruction;

  /// No description provided for @fillBlankInstruction.
  ///
  /// In ar, this message translates to:
  /// **'أكمل الفراغات داخل النص'**
  String get fillBlankInstruction;

  /// No description provided for @blueprint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة: يمكنك استخدام ورقة وقلم للحساب.'**
  String get blueprint;

  /// No description provided for @streamNone.
  ///
  /// In ar, this message translates to:
  /// **'بدون شعبة'**
  String get streamNone;

  /// No description provided for @otherOption.
  ///
  /// In ar, this message translates to:
  /// **'أخرى (اكتبها)'**
  String get otherOption;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا بعودتك'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لمتابعة مذاكرتك.'**
  String get loginSubtitle;

  /// No description provided for @signupTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حسابك'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'دقائق وتكون جاهزًا للتدريب.'**
  String get signupSubtitle;

  /// No description provided for @noAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get noAccount;

  /// No description provided for @recoverySavedHint.
  ///
  /// In ar, this message translates to:
  /// **'ضع علامة بعد حفظ الرمز في مكان آمن للمتابعة.'**
  String get recoverySavedHint;

  /// No description provided for @signupBonus.
  ///
  /// In ar, this message translates to:
  /// **'رصيد ترحيبي في حسابك'**
  String get signupBonus;

  /// No description provided for @cooldownTitle.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة'**
  String get cooldownTitle;

  /// No description provided for @cooldownBody.
  ///
  /// In ar, this message translates to:
  /// **'انتظر قليلًا قبل المحاولة مرة أخرى.'**
  String get cooldownBody;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @exams.
  ///
  /// In ar, this message translates to:
  /// **'الاوراق'**
  String get exams;

  /// No description provided for @practice.
  ///
  /// In ar, this message translates to:
  /// **'التدريب'**
  String get practice;

  /// No description provided for @wallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get wallet;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get profile;

  /// No description provided for @continueBody.
  ///
  /// In ar, this message translates to:
  /// **'لديك جلسة تدريب مفتوحة على {paper}.'**
  String continueBody(String paper);

  /// No description provided for @pendingPaymentBanner.
  ///
  /// In ar, this message translates to:
  /// **'لديك طلب دفع قيد المراجعة.'**
  String get pendingPaymentBanner;

  /// No description provided for @viewPayment.
  ///
  /// In ar, this message translates to:
  /// **'عرض الطلب'**
  String get viewPayment;

  /// No description provided for @paperContents.
  ///
  /// In ar, this message translates to:
  /// **'محتويات الورقة'**
  String get paperContents;

  /// No description provided for @insufficientTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد لا يكفي'**
  String get insufficientTitle;

  /// No description provided for @insufficientBody.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج {needed} إضافية لفتح هذه الورقة.'**
  String insufficientBody(String needed);

  /// No description provided for @keysLocked.
  ///
  /// In ar, this message translates to:
  /// **'افتح الورقة لعرض الإجابات.'**
  String get keysLocked;

  /// No description provided for @answeredCount.
  ///
  /// In ar, this message translates to:
  /// **'أجبت عن {count}'**
  String answeredCount(int count);

  /// No description provided for @emptyPractice.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أوراق للتدريب بعد'**
  String get emptyPractice;

  /// No description provided for @emptyPracticeHint.
  ///
  /// In ar, this message translates to:
  /// **'افتح ورقة من تبويب الأوراق أولًا.'**
  String get emptyPracticeHint;

  /// No description provided for @noPackages.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد باقات متاحة'**
  String get noPackages;

  /// No description provided for @noPackagesHint.
  ///
  /// In ar, this message translates to:
  /// **'حاول لاحقًا أو تواصل مع الدعم.'**
  String get noPackagesHint;

  /// No description provided for @confirmPackageTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب'**
  String get confirmPackageTitle;

  /// No description provided for @confirmPackageBody.
  ///
  /// In ar, this message translates to:
  /// **'سننشئ طلب دفع بقيمة {price} لباقة {credits}.'**
  String confirmPackageBody(String price, String credits);

  /// No description provided for @confirmPackage.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ طلب الدفع'**
  String get confirmPackage;

  /// No description provided for @packageCredits.
  ///
  /// In ar, this message translates to:
  /// **'{count} رصيد'**
  String packageCredits(int count);

  /// No description provided for @choosePackage.
  ///
  /// In ar, this message translates to:
  /// **'اختر باقة'**
  String get choosePackage;

  /// No description provided for @referenceHint.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الظاهر في إشعار التحويل'**
  String get referenceHint;

  /// No description provided for @paymentSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'وصل طلبك. سنراجعه قريبًا.'**
  String get paymentSubmitted;

  /// No description provided for @timeline.
  ///
  /// In ar, this message translates to:
  /// **'مراحل الطلب'**
  String get timeline;

  /// No description provided for @requestCancelled.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي الطلب.'**
  String get requestCancelled;

  /// No description provided for @receiptMissing.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد إيصال مرفق'**
  String get receiptMissing;

  /// No description provided for @paymentHelpBody.
  ///
  /// In ar, this message translates to:
  /// **'إذا تأخرت المراجعة أو رُفض الطلب، تواصل مع الدعم مع رمز الدفع.'**
  String get paymentHelpBody;

  /// No description provided for @expectedAmountCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ المبلغ'**
  String get expectedAmountCopy;

  /// No description provided for @openReceiptFile.
  ///
  /// In ar, this message translates to:
  /// **'فتح الملف'**
  String get openReceiptFile;

  /// No description provided for @removeFile.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الملف'**
  String get removeFile;

  /// No description provided for @receiptLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر عرض الإيصال. حاول مرة أخرى.'**
  String get receiptLoadFailed;

  /// No description provided for @availableNow.
  ///
  /// In ar, this message translates to:
  /// **'متاح للاستخدام الآن'**
  String get availableNow;

  /// No description provided for @reservedNotSpendable.
  ///
  /// In ar, this message translates to:
  /// **'المحجوز مرتبط بطلب دفع قيد المراجعة ولا يمكن استخدامه الآن.'**
  String get reservedNotSpendable;

  /// No description provided for @balanceStaleHint.
  ///
  /// In ar, this message translates to:
  /// **'هذا الرصيد محفوظ من آخر تحديث ناجح. اسحب لأسفل للتحديث.'**
  String get balanceStaleHint;

  /// No description provided for @loadMoreLedger.
  ///
  /// In ar, this message translates to:
  /// **'تحميل حركات أقدم'**
  String get loadMoreLedger;

  /// No description provided for @ledgerLoadMoreFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل المزيد. الحركات المعروضة تبقى كما هي.'**
  String get ledgerLoadMoreFailed;

  /// No description provided for @ledgerAllShown.
  ///
  /// In ar, this message translates to:
  /// **'عرضت كل الحركات'**
  String get ledgerAllShown;

  /// No description provided for @selectPackageHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر باقة ثم تابع الدفع إلى صفحة التحويل.'**
  String get selectPackageHint;

  /// No description provided for @continueToPayment.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الدفع'**
  String get continueToPayment;

  /// No description provided for @openRequestNotice.
  ///
  /// In ar, this message translates to:
  /// **'لديك طلب دفع مفتوح. أكمل إرسال إيصاله أو ألغِه قبل إنشاء طلب جديد.'**
  String get openRequestNotice;

  /// No description provided for @manualReviewNotice.
  ///
  /// In ar, this message translates to:
  /// **'يراجع فريق الدعم الإيصال يدويًا قبل إضافة الرصيد.'**
  String get manualReviewNotice;

  /// No description provided for @nextActionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإجراء التالي'**
  String get nextActionLabel;

  /// No description provided for @refreshStatus.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الحالة'**
  String get refreshStatus;

  /// No description provided for @paymentStatusExplainPending.
  ///
  /// In ar, this message translates to:
  /// **'لم يُرسل الإيصال بعد. حوّل المبلغ بالضبط ثم أرفق الإيصال.'**
  String get paymentStatusExplainPending;

  /// No description provided for @paymentStatusExplainSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'وصل طلبك وهو بانتظار بدء المراجعة. لا حاجة لأي إجراء الآن.'**
  String get paymentStatusExplainSubmitted;

  /// No description provided for @paymentStatusExplainUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'يراجع فريق الدعم الإيصال الآن. لا حاجة لأي إجراء.'**
  String get paymentStatusExplainUnderReview;

  /// No description provided for @paymentStatusExplainNeedsInfo.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج الإدارة معلومات إضافية. راجع الملاحظة ثم أعد إرسال الإيصال.'**
  String get paymentStatusExplainNeedsInfo;

  /// No description provided for @paymentStatusExplainApproved.
  ///
  /// In ar, this message translates to:
  /// **'اعتُمد الطلب وأُضيف الرصيد إلى محفظتك.'**
  String get paymentStatusExplainApproved;

  /// No description provided for @paymentStatusExplainRejected.
  ///
  /// In ar, this message translates to:
  /// **'رُفض الإيصال. راجع السبب قبل إرسال طلب جديد.'**
  String get paymentStatusExplainRejected;

  /// No description provided for @paymentStatusExplainExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية الطلب دون إرساله. ابدأ طلبًا جديدًا من الباقات.'**
  String get paymentStatusExplainExpired;

  /// No description provided for @paymentStatusExplainCancelled.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي هذا الطلب ولن يُضاف رصيد.'**
  String get paymentStatusExplainCancelled;

  /// No description provided for @paymentStatusExplainUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حالة الطلب غير معروفة. حدّث الحالة أو تواصل مع الدعم.'**
  String get paymentStatusExplainUnknown;

  /// No description provided for @requestSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الطلب'**
  String get requestSummaryTitle;

  /// No description provided for @receiptSourceTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر مصدر الإيصال'**
  String get receiptSourceTitle;

  /// No description provided for @galleryRationaleTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختيار صورة من المعرض'**
  String get galleryRationaleTitle;

  /// No description provided for @galleryRationaleBody.
  ///
  /// In ar, this message translates to:
  /// **'سنفتح معرض الصور لاختيار صورة الإيصال فقط.'**
  String get galleryRationaleBody;

  /// No description provided for @receiptPrepareFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تجهيز الملف. جرّب صورة أخرى أو ملف PDF.'**
  String get receiptPrepareFailed;

  /// No description provided for @receiptReading.
  ///
  /// In ar, this message translates to:
  /// **'نقرأ رقم العملية من الإيصال…'**
  String get receiptReading;

  /// No description provided for @receiptExtracted.
  ///
  /// In ar, this message translates to:
  /// **'كتبنا لك رقم العملية واسم المحوّل من الإيصال. راجعهما قبل الإرسال.'**
  String get receiptExtracted;

  /// No description provided for @receiptExtractManual.
  ///
  /// In ar, this message translates to:
  /// **'لم نستطع قراءة رقم العملية من الإيصال. اكتبه بنفسك من الإيصال.'**
  String get receiptExtractManual;

  /// No description provided for @receiptAcceptedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملفات المقبولة'**
  String get receiptAcceptedTitle;

  /// No description provided for @receiptAcceptedValue.
  ///
  /// In ar, this message translates to:
  /// **'JPEG أو PNG أو WebP أو PDF · حتى {size}'**
  String receiptAcceptedValue(String size);

  /// No description provided for @receiptPickHint.
  ///
  /// In ar, this message translates to:
  /// **'صورة واضحة تُظهر المبلغ ورقم العملية.'**
  String get receiptPickHint;

  /// No description provided for @receiptReady.
  ///
  /// In ar, this message translates to:
  /// **'الملف جاهز للإرسال'**
  String get receiptReady;

  /// No description provided for @preparingReceipt.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تجهيز الملف…'**
  String get preparingReceipt;

  /// No description provided for @replaceFile.
  ///
  /// In ar, this message translates to:
  /// **'استبدال الملف'**
  String get replaceFile;

  /// No description provided for @fileTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get fileTypeLabel;

  /// No description provided for @fileSizeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحجم'**
  String get fileSizeLabel;

  /// No description provided for @attachmentKeepNotice.
  ///
  /// In ar, this message translates to:
  /// **'الإيصال المرفوع يبقى محفوظًا؛ لن تحتاج إلى رفعه مرة أخرى.'**
  String get attachmentKeepNotice;

  /// No description provided for @receiptCompressedHint.
  ///
  /// In ar, this message translates to:
  /// **'تم ضغط الصورة لتقليل حجم الرفع.'**
  String get receiptCompressedHint;

  /// No description provided for @receiptOpenFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح الملف. تأكد من وجود تطبيق يدعم PDF.'**
  String get receiptOpenFailed;

  /// No description provided for @openPayments.
  ///
  /// In ar, this message translates to:
  /// **'طلبات مفتوحة'**
  String get openPayments;

  /// No description provided for @paymentHistory.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get paymentHistory;

  /// No description provided for @diagnosticsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التشخيص'**
  String get diagnosticsTitle;

  /// No description provided for @serverUrl.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الخادم'**
  String get serverUrl;

  /// No description provided for @appVersionLabel.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get appVersionLabel;

  /// No description provided for @connectionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاتصال'**
  String get connectionLabel;

  /// No description provided for @online.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get online;

  /// No description provided for @pendingAnswers.
  ///
  /// In ar, this message translates to:
  /// **'إجابات بانتظار الإرسال'**
  String get pendingAnswers;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @callSupport.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get callSupport;

  /// No description provided for @supportPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get supportPhoneLabel;

  /// No description provided for @supportWhatsAppLabel.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get supportWhatsAppLabel;

  /// No description provided for @openWhatsApp.
  ///
  /// In ar, this message translates to:
  /// **'فتح واتساب'**
  String get openWhatsApp;

  /// No description provided for @galleryColors.
  ///
  /// In ar, this message translates to:
  /// **'الألوان'**
  String get galleryColors;

  /// No description provided for @galleryTypography.
  ///
  /// In ar, this message translates to:
  /// **'الخطوط'**
  String get galleryTypography;

  /// No description provided for @galleryComponents.
  ///
  /// In ar, this message translates to:
  /// **'المكونات'**
  String get galleryComponents;

  /// No description provided for @accountDetails.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الحساب'**
  String get accountDetails;

  /// No description provided for @apiMode.
  ///
  /// In ar, this message translates to:
  /// **'مصدر البيانات'**
  String get apiMode;

  /// No description provided for @diagnosticsIntro.
  ///
  /// In ar, this message translates to:
  /// **'معلومات تساعد فريق الدعم على فهم المشكلة. لا تحتوي على كلمة المرور أو رمز الاسترجاع.'**
  String get diagnosticsIntro;

  /// No description provided for @diagnosticsConnectionHint.
  ///
  /// In ar, this message translates to:
  /// **'حالة الشبكة كما يراها التطبيق الآن.'**
  String get diagnosticsConnectionHint;

  /// No description provided for @diagnosticsPendingHint.
  ///
  /// In ar, this message translates to:
  /// **'إجابات محفوظة على هذا الجهاز ولم تُرسَل بعد.'**
  String get diagnosticsPendingHint;

  /// No description provided for @diagnosticsApiHint.
  ///
  /// In ar, this message translates to:
  /// **'الخادم الذي يقرأ منه هذا الإصدار بياناته.'**
  String get diagnosticsApiHint;

  /// No description provided for @lastChecked.
  ///
  /// In ar, this message translates to:
  /// **'آخر فحص: {time}'**
  String lastChecked(String time);

  /// No description provided for @splashBusyHint.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحقق من جلستك… قد يستغرق ذلك حتى ١٢ ثانية على اتصال بطيء.'**
  String get splashBusyHint;

  /// No description provided for @fakeApi.
  ///
  /// In ar, this message translates to:
  /// **'بيانات تجريبية'**
  String get fakeApi;

  /// No description provided for @liveApi.
  ///
  /// In ar, this message translates to:
  /// **'الخادم المباشر'**
  String get liveApi;

  /// No description provided for @couldNotOpen.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح التطبيق. حاول مرة أخرى.'**
  String get couldNotOpen;

  /// No description provided for @reportShared.
  ///
  /// In ar, this message translates to:
  /// **'شكرًا، شاركنا التقرير.'**
  String get reportShared;

  /// No description provided for @privacyBody.
  ///
  /// In ar, this message translates to:
  /// **'تحتفظ مذكرة برقم هاتفك واسمك وسجلّ المدفوعات لتشغيل حسابك فقط، ولا نشاركها مع أي طرف. تُستخدم بياناتك لفتح الأوراق ومتابعة تقدّمك. يمكنك طلب حذف حسابك من صفحة الملف الشخصي.'**
  String get privacyBody;

  /// No description provided for @adaptivePractice.
  ///
  /// In ar, this message translates to:
  /// **'تدريب تكيفي'**
  String get adaptivePractice;

  /// No description provided for @adaptiveEntryHint.
  ///
  /// In ar, this message translates to:
  /// **'يختار الخادم السؤال التالي حسب إجاباتك السابقة.'**
  String get adaptiveEntryHint;

  /// No description provided for @adaptiveClassContext.
  ///
  /// In ar, this message translates to:
  /// **'صفك: {className}'**
  String adaptiveClassContext(String className);

  /// No description provided for @adaptivePickPaper.
  ///
  /// In ar, this message translates to:
  /// **'اختر ورقة للتدريب التكيفي'**
  String get adaptivePickPaper;

  /// No description provided for @adaptiveFreeNote.
  ///
  /// In ar, this message translates to:
  /// **'اختيار السؤال التكيفي مجاني ولا يستهلك رصيدًا. الأسئلة المدفوعة تتطلب فتح الورقة.'**
  String get adaptiveFreeNote;

  /// No description provided for @adaptiveNoControls.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اختيار يدوي للموضوع أو الصعوبة؛ الخادم يضبط الصعوبة من نتائجك.'**
  String get adaptiveNoControls;

  /// No description provided for @adaptiveStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التدريب التكيفي'**
  String get adaptiveStart;

  /// No description provided for @adaptiveRemaining.
  ///
  /// In ar, this message translates to:
  /// **'متبقٍ من الأسئلة: {count}'**
  String adaptiveRemaining(int count);

  /// No description provided for @adaptiveNoQuestions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أسئلة متاحة'**
  String get adaptiveNoQuestions;

  /// No description provided for @adaptiveNoAccess.
  ///
  /// In ar, this message translates to:
  /// **'لم نجد أسئلة متاحة دون فتح الورقة. افتح الورقة ثم عد.'**
  String get adaptiveNoAccess;

  /// No description provided for @adaptiveExhausted.
  ///
  /// In ar, this message translates to:
  /// **'أجبت عن كل الأسئلة المتاحة في هذه الورقة.'**
  String get adaptiveExhausted;

  /// No description provided for @adaptiveAutoLevel.
  ///
  /// In ar, this message translates to:
  /// **'الصعوبة تُختار تلقائيًا'**
  String get adaptiveAutoLevel;

  /// No description provided for @aiGradeTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح بالذكاء الاصطناعي'**
  String get aiGradeTitle;

  /// No description provided for @aiGradeConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح بالذكاء الاصطناعي؟'**
  String get aiGradeConfirmTitle;

  /// No description provided for @aiGradeBody.
  ///
  /// In ar, this message translates to:
  /// **'تُصحَّح إجابتك وفق الإجابة النموذجية، وتُراجع بشريًا إذا كانت الثقة منخفضة.'**
  String get aiGradeBody;

  /// No description provided for @aiGradeUnofficial.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة غير رسمية'**
  String get aiGradeUnofficial;

  /// No description provided for @aiGradeCostNote.
  ///
  /// In ar, this message translates to:
  /// **'تُحدد الرسوم من الخادم وتُحجز عند الطلب، ولا تُخصم إلا بعد اعتماد النتيجة. تُعاد كاملة إذا رُفضت أو فشل الطلب.'**
  String get aiGradeCostNote;

  /// No description provided for @aiGradeCharged.
  ///
  /// In ar, this message translates to:
  /// **'خُصم {credits} رصيد مقابل التصحيح.'**
  String aiGradeCharged(int credits);

  /// No description provided for @aiGradeReviewPending.
  ///
  /// In ar, this message translates to:
  /// **'إجابتك بانتظار مراجعة بشرية'**
  String get aiGradeReviewPending;

  /// No description provided for @aiGradeReviewBody.
  ///
  /// In ar, this message translates to:
  /// **'تم تصحيح أولي بالذكاء الاصطناعي، والدرجة النهائية تُعتمد بعد المراجعة.'**
  String get aiGradeReviewBody;

  /// No description provided for @aiGradeReviewNoCharge.
  ///
  /// In ar, this message translates to:
  /// **'لا تُخصم أي رسوم الآن؛ تبقى محجوزة حتى تُعتمد المراجعة، وتُعاد إذا رُفضت.'**
  String get aiGradeReviewNoCharge;

  /// No description provided for @aiGradeInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التصحيح بالذكاء الاصطناعي…'**
  String get aiGradeInProgress;

  /// No description provided for @aiGradeInProgressHint.
  ///
  /// In ar, this message translates to:
  /// **'قد يستغرق حتى دقيقة. إن انقطع الاتصال ستُسترجع النتيجة المحفوظة تلقائيًا دون رسوم إضافية.'**
  String get aiGradeInProgressHint;

  /// No description provided for @aiGradeRecovered.
  ///
  /// In ar, this message translates to:
  /// **'استُرجعت النتيجة المحفوظة من الخادم دون رسوم إضافية.'**
  String get aiGradeRecovered;

  /// No description provided for @aiGradeRejectedTitle.
  ///
  /// In ar, this message translates to:
  /// **'رُفضت نتيجة المراجعة'**
  String get aiGradeRejectedTitle;

  /// No description provided for @aiGradeRejectedBody.
  ///
  /// In ar, this message translates to:
  /// **'أُعيدت الرسوم المحجوزة إلى رصيدك. يمكنك إعادة إرسال الإجابة أو طلب تصحيح جديد بالذكاء الاصطناعي.'**
  String get aiGradeRejectedBody;

  /// No description provided for @aiGradeVoidedTitle.
  ///
  /// In ar, this message translates to:
  /// **'أُلغيت المراجعة'**
  String get aiGradeVoidedTitle;

  /// No description provided for @aiGradeVoidedBody.
  ///
  /// In ar, this message translates to:
  /// **'تغيّرت إجابتك بعد طلب المراجعة، فأُلغيت وأُعيدت الرسوم. اطلب التصحيح من جديد للإجابة الحالية.'**
  String get aiGradeVoidedBody;

  /// No description provided for @aiGradeTimeoutHint.
  ///
  /// In ar, this message translates to:
  /// **'استغرق الطلب وقتًا أطول من المتوقع. إن كان التصحيح قد اكتمل فستظهر نتيجته المحفوظة، ولن تُخصم رسوم مرتين.'**
  String get aiGradeTimeoutHint;

  /// No description provided for @aiGradeMissingPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاط ناقصة'**
  String get aiGradeMissingPoints;

  /// No description provided for @aiGradeFailed.
  ///
  /// In ar, this message translates to:
  /// **'لم يكتمل التصحيح. إجابتك محفوظة، ويمكنك المحاولة لاحقًا.'**
  String get aiGradeFailed;

  /// No description provided for @aiGradeUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'خدمة الذكاء الاصطناعي غير متاحة الآن.'**
  String get aiGradeUnavailable;

  /// No description provided for @aiGrading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التصحيح…'**
  String get aiGrading;

  /// No description provided for @myMaterials.
  ///
  /// In ar, this message translates to:
  /// **'موادي'**
  String get myMaterials;

  /// No description provided for @materialsEntryHint.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ أسئلة تدريب من دروسك بعد مراجعة الفريق.'**
  String get materialsEntryHint;

  /// No description provided for @materialsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواد بعد'**
  String get materialsEmpty;

  /// No description provided for @materialsEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف نصًا أو صورة من درسك لإنشاء أسئلة تدريب.'**
  String get materialsEmptyHint;

  /// No description provided for @materialAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مادة'**
  String get materialAdd;

  /// No description provided for @materialKindText.
  ///
  /// In ar, this message translates to:
  /// **'نص'**
  String get materialKindText;

  /// No description provided for @materialKindImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة'**
  String get materialKindImage;

  /// No description provided for @materialPrivate.
  ///
  /// In ar, this message translates to:
  /// **'خاصة بحسابك'**
  String get materialPrivate;

  /// No description provided for @materialStatusReview.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة'**
  String get materialStatusReview;

  /// No description provided for @materialStatusReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهزة'**
  String get materialStatusReady;

  /// No description provided for @materialStatusFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل الإنشاء'**
  String get materialStatusFailed;

  /// No description provided for @materialStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get materialStatusRejected;

  /// No description provided for @materialNoGeneration.
  ///
  /// In ar, this message translates to:
  /// **'لم تُنشأ أسئلة'**
  String get materialNoGeneration;

  /// No description provided for @materialGenerate.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء أسئلة'**
  String get materialGenerate;

  /// No description provided for @materialSourcePaste.
  ///
  /// In ar, this message translates to:
  /// **'نص ملصق'**
  String get materialSourcePaste;

  /// No description provided for @materialSourceFile.
  ///
  /// In ar, this message translates to:
  /// **'ملف نصي'**
  String get materialSourceFile;

  /// No description provided for @materialSourcePhoto.
  ///
  /// In ar, this message translates to:
  /// **'صورة صفحة'**
  String get materialSourcePhoto;

  /// No description provided for @materialSource.
  ///
  /// In ar, this message translates to:
  /// **'المصدر'**
  String get materialSource;

  /// No description provided for @materialCreatedAt.
  ///
  /// In ar, this message translates to:
  /// **'أُضيفت {date}'**
  String materialCreatedAt(String date);

  /// No description provided for @materialTextLabel.
  ///
  /// In ar, this message translates to:
  /// **'نص المادة'**
  String get materialTextLabel;

  /// No description provided for @materialTextHint.
  ///
  /// In ar, this message translates to:
  /// **'الصق نص الدرس هنا (١٠٠ حرف على الأقل).'**
  String get materialTextHint;

  /// No description provided for @materialTooShort.
  ///
  /// In ar, this message translates to:
  /// **'النص قصير. أضف ١٠٠ حرف على الأقل.'**
  String get materialTooShort;

  /// No description provided for @materialPickFile.
  ///
  /// In ar, this message translates to:
  /// **'اختيار ملف'**
  String get materialPickFile;

  /// No description provided for @materialNoFile.
  ///
  /// In ar, this message translates to:
  /// **'لم تختر ملفًا بعد.'**
  String get materialNoFile;

  /// No description provided for @materialFileHint.
  ///
  /// In ar, this message translates to:
  /// **'.txt أو .md أو صورة PNG/JPEG، بحد أقصى ٨ ميغابايت.'**
  String get materialFileHint;

  /// No description provided for @materialPdfDisabled.
  ///
  /// In ar, this message translates to:
  /// **'استخراج النص من PDF غير مدعوم بعد. ارفع صورة للصفحة أو الصق النص.'**
  String get materialPdfDisabled;

  /// No description provided for @materialPrivacyNote.
  ///
  /// In ar, this message translates to:
  /// **'تبقى المادة خاصة بحسابك، ولا تُنشر للآخرين.'**
  String get materialPrivacyNote;

  /// No description provided for @materialDraftKept.
  ///
  /// In ar, this message translates to:
  /// **'احتفظنا بمادتك. أعد المحاولة بعد عودة الاتصال.'**
  String get materialDraftKept;

  /// No description provided for @materialSaved.
  ///
  /// In ar, this message translates to:
  /// **'أُضيفت المادة'**
  String get materialSaved;

  /// No description provided for @materialGradeHint.
  ///
  /// In ar, this message translates to:
  /// **'الصف الثانوي مطلوب لإنشاء الأسئلة.'**
  String get materialGradeHint;

  /// No description provided for @materialSubjectHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر مادة من المنهج أو اكتبها.'**
  String get materialSubjectHint;

  /// No description provided for @materialGradeRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختر الصف الدراسي.'**
  String get materialGradeRequired;

  /// No description provided for @materialSubjectRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم المادة.'**
  String get materialSubjectRequired;

  /// No description provided for @materialContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get materialContinue;

  /// No description provided for @generationConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء أسئلة'**
  String get generationConfirmTitle;

  /// No description provided for @generationFrom.
  ///
  /// In ar, this message translates to:
  /// **'من مادة: {name}'**
  String generationFrom(String name);

  /// No description provided for @generationCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأسئلة'**
  String get generationCount;

  /// No description provided for @generationTypes.
  ///
  /// In ar, this message translates to:
  /// **'الأنواع المدعومة: اختيار من متعدد، صح/خطأ، إكمال الفراغ، إجابة قصيرة.'**
  String get generationTypes;

  /// No description provided for @generationReviewNote.
  ///
  /// In ar, this message translates to:
  /// **'تُراجع الأسئلة المولّدة قبل الاستخدام. لا تظهر المفاتيح ولا يبدأ التدريب قبل الاعتماد.'**
  String get generationReviewNote;

  /// No description provided for @generationCostNote.
  ///
  /// In ar, this message translates to:
  /// **'تُحتسب الرسوم من الخادم عند التأكيد وتُحجز من رصيدك. يعيد الخادم المبلغ إذا فشل الطلب أو رُفضت الأسئلة.'**
  String get generationCostNote;

  /// No description provided for @generationPriceServer.
  ///
  /// In ar, this message translates to:
  /// **'تحدد الرسوم من الخادم عند الإنشاء'**
  String get generationPriceServer;

  /// No description provided for @generationAck.
  ///
  /// In ar, this message translates to:
  /// **'فهمت أن الأسئلة تحتاج مراجعة قبل التدريب.'**
  String get generationAck;

  /// No description provided for @generationConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإنشاء'**
  String get generationConfirm;

  /// No description provided for @generationProcessing.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ إنشاء الأسئلة…'**
  String get generationProcessing;

  /// No description provided for @generationReviewStatus.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار مراجعة الفريق'**
  String get generationReviewStatus;

  /// No description provided for @generationReviewBody.
  ///
  /// In ar, this message translates to:
  /// **'وصلت أسئلتك وستُراجع قريبًا. يمكنك ترك الصفحة والعودة لاحقًا.'**
  String get generationReviewBody;

  /// No description provided for @generationReadyBody.
  ///
  /// In ar, this message translates to:
  /// **'أنشأنا مجموعة خاصة من مادتك وراجعها الفريق. افتحها للتدريب.'**
  String get generationReadyBody;

  /// No description provided for @generationFailedBody.
  ///
  /// In ar, this message translates to:
  /// **'لم يكتمل الإنشاء ولم تُخصم رسوم. يمكنك المحاولة مرة أخرى.'**
  String get generationFailedBody;

  /// No description provided for @generationUnsafe.
  ///
  /// In ar, this message translates to:
  /// **'لم تجتز الأسئلة فحص السلامة، ولم تُخصم رسوم.'**
  String get generationUnsafe;

  /// No description provided for @generationRejectedBody.
  ///
  /// In ar, this message translates to:
  /// **'لم تُعتمد الأسئلة. أُعيد رصيدك إن كان قد خُصم.'**
  String get generationRejectedBody;

  /// No description provided for @generationOrigin.
  ///
  /// In ar, this message translates to:
  /// **'مولّدة من مادتك ومراجعة من الفريق، وليست امتحانًا رسميًا.'**
  String get generationOrigin;

  /// No description provided for @generationOpen.
  ///
  /// In ar, this message translates to:
  /// **'فتح المجموعة'**
  String get generationOpen;

  /// No description provided for @generationRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الحالة'**
  String get generationRefresh;

  /// No description provided for @generationRefreshFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديث الحالة. لم نبدأ طلبًا جديدًا.'**
  String get generationRefreshFailed;

  /// No description provided for @generationCharged.
  ///
  /// In ar, this message translates to:
  /// **'خُصم {credits} رصيد.'**
  String generationCharged(int credits);

  /// No description provided for @generationNoCharge.
  ///
  /// In ar, this message translates to:
  /// **'لم تُخصم رسوم.'**
  String get generationNoCharge;

  /// No description provided for @generationStatusTitle.
  ///
  /// In ar, this message translates to:
  /// **'حالة الإنشاء'**
  String get generationStatusTitle;

  /// No description provided for @generationBack.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى موادي'**
  String get generationBack;

  /// No description provided for @generationFailedStatus.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الإنشاء'**
  String get generationFailedStatus;

  /// No description provided for @setByServer.
  ///
  /// In ar, this message translates to:
  /// **'يحددها الخادم'**
  String get setByServer;

  /// No description provided for @acknowledge.
  ///
  /// In ar, this message translates to:
  /// **'فهمت'**
  String get acknowledge;

  /// No description provided for @errorAiDisabled.
  ///
  /// In ar, this message translates to:
  /// **'خدمة الذكاء الاصطناعي متوقفة حاليًا.'**
  String get errorAiDisabled;

  /// No description provided for @errorAiBudgetExceeded.
  ///
  /// In ar, this message translates to:
  /// **'توقفت خدمة الذكاء الاصطناعي مؤقتًا حتى تحسين الميزانية. جرّب لاحقًا.'**
  String get errorAiBudgetExceeded;

  /// No description provided for @errorAiInvalidOutput.
  ///
  /// In ar, this message translates to:
  /// **'لم يكتمل طلب الذكاء الاصطناعي. حاول مرة أخرى.'**
  String get errorAiInvalidOutput;

  /// No description provided for @errorAiContentUnsafe.
  ///
  /// In ar, this message translates to:
  /// **'لم تجتز الأسئلة فحص السلامة، ولم تُخصم رسوم.'**
  String get errorAiContentUnsafe;

  /// No description provided for @errorNotAiMarkable.
  ///
  /// In ar, this message translates to:
  /// **'هذا السؤال لا يُصحَّح بالذكاء الاصطناعي.'**
  String get errorNotAiMarkable;

  /// No description provided for @errorAnswerAlreadyMarked.
  ///
  /// In ar, this message translates to:
  /// **'تم تصحيح هذه الإجابة بالفعل.'**
  String get errorAnswerAlreadyMarked;

  /// No description provided for @errorReviewAlreadyPending.
  ///
  /// In ar, this message translates to:
  /// **'إجابتك بانتظار مراجعة بشرية بالفعل.'**
  String get errorReviewAlreadyPending;

  /// No description provided for @errorAiInFlight.
  ///
  /// In ar, this message translates to:
  /// **'التصحيح بالذكاء الاصطناعي قيد التنفيذ لهذه الإجابة بالفعل. انتظر اكتماله ثم حدّث.'**
  String get errorAiInFlight;

  /// No description provided for @errorEmptyAnswer.
  ///
  /// In ar, this message translates to:
  /// **'اكتب إجابة قبل طلب التصحيح.'**
  String get errorEmptyAnswer;

  /// No description provided for @errorClassLevelRequired.
  ///
  /// In ar, this message translates to:
  /// **'حدّد صفك الدراسي في حسابك أولًا.'**
  String get errorClassLevelRequired;

  /// No description provided for @errorMaterialRequired.
  ///
  /// In ar, this message translates to:
  /// **'أرفق مادة أولًا.'**
  String get errorMaterialRequired;

  /// No description provided for @errorMaterialNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على هذه المادة.'**
  String get errorMaterialNotFound;

  /// No description provided for @errorMaterialFileMissing.
  ///
  /// In ar, this message translates to:
  /// **'ملف المادة لم يعد موجودًا. أضفها من جديد.'**
  String get errorMaterialFileMissing;

  /// No description provided for @errorMaterialTypeNotAllowed.
  ///
  /// In ar, this message translates to:
  /// **'ارفع .txt أو .md أو صورة PNG/JPEG.'**
  String get errorMaterialTypeNotAllowed;

  /// No description provided for @errorMaterialPdfNotSupported.
  ///
  /// In ar, this message translates to:
  /// **'استخراج PDF غير مدعوم بعد؛ ارفع صورة أو نصًا.'**
  String get errorMaterialPdfNotSupported;

  /// No description provided for @errorMaterialTooLarge.
  ///
  /// In ar, this message translates to:
  /// **'حجم المادة كبير جدًا. الحد الأقصى ٨ ميغابايت.'**
  String get errorMaterialTooLarge;

  /// No description provided for @errorMaterialTooShort.
  ///
  /// In ar, this message translates to:
  /// **'المادة قصيرة جدًا. أضف ١٠٠ حرف على الأقل.'**
  String get errorMaterialTooShort;

  /// No description provided for @errorMaterialTooLong.
  ///
  /// In ar, this message translates to:
  /// **'المادة طويلة جدًا. قسّمها إلى أجزاء أصغر.'**
  String get errorMaterialTooLong;

  /// No description provided for @errorMaterialUploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر رفع المادة. حاول مرة أخرى.'**
  String get errorMaterialUploadFailed;

  /// No description provided for @errorMaterialFieldInvalid.
  ///
  /// In ar, this message translates to:
  /// **'ملف المادة غير صالح. أعد اختياره.'**
  String get errorMaterialFieldInvalid;

  /// No description provided for @errorGenerationNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على طلب الإنشاء.'**
  String get errorGenerationNotFound;

  /// No description provided for @errorAiTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة خدمة الذكاء الاصطناعي. حاول مرة أخرى.'**
  String get errorAiTimeout;

  /// No description provided for @errorAiUpstream.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الوصول إلى خدمة الذكاء الاصطناعي. حاول لاحقًا.'**
  String get errorAiUpstream;

  /// No description provided for @errorAiUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'خدمة الذكاء الاصطناعي غير متاحة الآن.'**
  String get errorAiUnavailable;

  /// No description provided for @generationUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حالة غير معروفة'**
  String get generationUnknown;

  /// No description provided for @generationUnknownBody.
  ///
  /// In ar, this message translates to:
  /// **'لم نتعرف على حالة هذا الطلب. حدّث الحالة، أو تواصل مع الدعم إن تكرر ذلك.'**
  String get generationUnknownBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
