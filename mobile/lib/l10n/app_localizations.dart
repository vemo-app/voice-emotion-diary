import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fa, this message translates to:
  /// **'دفترچه خاطرات صوتی'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In fa, this message translates to:
  /// **'خاطرات امروز'**
  String get homeTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In fa, this message translates to:
  /// **'سلام! امروز چطوری؟'**
  String get homeGreeting;

  /// No description provided for @todayLabel.
  ///
  /// In fa, this message translates to:
  /// **'{weekday}، {day} {month} {year}'**
  String todayLabel(Object day, Object month, Object weekday, Object year);

  /// No description provided for @emotionChartTitle.
  ///
  /// In fa, this message translates to:
  /// **'نمودار احساسات امروز'**
  String get emotionChartTitle;

  /// No description provided for @emotionChartSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'بر اساس {count} خاطره ثبت‌شده'**
  String emotionChartSubtitle(Object count);

  /// No description provided for @memoriesCount.
  ///
  /// In fa, this message translates to:
  /// **'{count} خاطره'**
  String memoriesCount(Object count);

  /// No description provided for @dominantEmotion.
  ///
  /// In fa, this message translates to:
  /// **'شادی غالب'**
  String get dominantEmotion;

  /// No description provided for @noMemoriesToday.
  ///
  /// In fa, this message translates to:
  /// **'امروز هنوز خاطره‌ای ثبت نکردی'**
  String get noMemoriesToday;

  /// No description provided for @recordNewMemory.
  ///
  /// In fa, this message translates to:
  /// **'ضبط خاطره جدید'**
  String get recordNewMemory;

  /// No description provided for @historyTitle.
  ///
  /// In fa, this message translates to:
  /// **'تاریخچه خاطرات'**
  String get historyTitle;

  /// No description provided for @historySubtitle.
  ///
  /// In fa, this message translates to:
  /// **'روز موردنظرت رو انتخاب کن'**
  String get historySubtitle;

  /// No description provided for @analyticsTitle.
  ///
  /// In fa, this message translates to:
  /// **'تحلیل‌ها'**
  String get analyticsTitle;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'روند احساسات تو در طول زمان'**
  String get analyticsSubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In fa, this message translates to:
  /// **'پروفایل'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get settingsTitle;

  /// No description provided for @editProfile.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش پروفایل'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In fa, this message translates to:
  /// **'تغییر رمز عبور'**
  String get changePassword;

  /// No description provided for @logout.
  ///
  /// In fa, this message translates to:
  /// **'خروج از حساب کاربری'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In fa, this message translates to:
  /// **'حذف حساب کاربری'**
  String get deleteAccount;

  /// No description provided for @cancel.
  ///
  /// In fa, this message translates to:
  /// **'انصراف'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fa, this message translates to:
  /// **'تأیید'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره تغییرات'**
  String get saveChanges;

  /// No description provided for @delete.
  ///
  /// In fa, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش'**
  String get edit;

  /// No description provided for @tryAgain.
  ///
  /// In fa, this message translates to:
  /// **'تلاش دوباره'**
  String get tryAgain;

  /// No description provided for @loading.
  ///
  /// In fa, this message translates to:
  /// **'در حال بارگذاری...'**
  String get loading;

  /// No description provided for @errorLoading.
  ///
  /// In fa, this message translates to:
  /// **'خطا در بارگذاری اطلاعات. دوباره تلاش کنید.'**
  String get errorLoading;

  /// No description provided for @logoutConfirmation.
  ///
  /// In fa, this message translates to:
  /// **'مطمئنی می‌خوای از حسابت خارج بشی؟'**
  String get logoutConfirmation;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In fa, this message translates to:
  /// **'این کار برگشت‌ناپذیره. همه‌ی خاطرات، تحلیل‌ها و اطلاعات حسابت برای همیشه پاک می‌شه.'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In fa, this message translates to:
  /// **'حذف حساب کاربری'**
  String get deleteAccountTitle;

  /// No description provided for @deletePermanently.
  ///
  /// In fa, this message translates to:
  /// **'حذف برای همیشه'**
  String get deletePermanently;

  /// No description provided for @darkModeLabel.
  ///
  /// In fa, this message translates to:
  /// **'حالت دارک'**
  String get darkModeLabel;

  /// No description provided for @languageLabel.
  ///
  /// In fa, this message translates to:
  /// **'زبان'**
  String get languageLabel;

  /// No description provided for @notificationsLabel.
  ///
  /// In fa, this message translates to:
  /// **'اعلان‌ها'**
  String get notificationsLabel;

  /// No description provided for @accountSettings.
  ///
  /// In fa, this message translates to:
  /// **'حساب کاربری'**
  String get accountSettings;

  /// No description provided for @appSettings.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات برنامه'**
  String get appSettings;

  /// No description provided for @dangerZone.
  ///
  /// In fa, this message translates to:
  /// **'دسترسی به حساب'**
  String get dangerZone;

  /// No description provided for @joinedDate.
  ///
  /// In fa, this message translates to:
  /// **'عضو از {date}'**
  String joinedDate(Object date);

  /// No description provided for @totalMemories.
  ///
  /// In fa, this message translates to:
  /// **'کل خاطرات'**
  String get totalMemories;

  /// No description provided for @emotionDistribution.
  ///
  /// In fa, this message translates to:
  /// **'توزیع احساسات کلی'**
  String get emotionDistribution;

  /// No description provided for @noData.
  ///
  /// In fa, this message translates to:
  /// **'هنوز داده‌ای برای نمایش نیست'**
  String get noData;

  /// No description provided for @aiFeedback.
  ///
  /// In fa, this message translates to:
  /// **'بازخورد همیار'**
  String get aiFeedback;

  /// No description provided for @aiWriting.
  ///
  /// In fa, this message translates to:
  /// **'همیار در حال نوشتن...'**
  String get aiWriting;

  /// No description provided for @newMemoryTitle.
  ///
  /// In fa, this message translates to:
  /// **'خاطره جدید'**
  String get newMemoryTitle;

  /// No description provided for @editMemoryTitle.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش خاطره'**
  String get editMemoryTitle;

  /// No description provided for @memoryTitleLabel.
  ///
  /// In fa, this message translates to:
  /// **'عنوان خاطره'**
  String get memoryTitleLabel;

  /// No description provided for @required.
  ///
  /// In fa, this message translates to:
  /// **'اجباری'**
  String get required;

  /// No description provided for @addToMemory.
  ///
  /// In fa, this message translates to:
  /// **'افزودن به این خاطره'**
  String get addToMemory;

  /// No description provided for @note.
  ///
  /// In fa, this message translates to:
  /// **'یادداشت'**
  String get note;

  /// No description provided for @notePlaceholder.
  ///
  /// In fa, this message translates to:
  /// **'یک نوت متنی اضافه کن'**
  String get notePlaceholder;

  /// No description provided for @photo.
  ///
  /// In fa, this message translates to:
  /// **'عکس'**
  String get photo;

  /// No description provided for @photoPlaceholder.
  ///
  /// In fa, this message translates to:
  /// **'تصویر اضافه کن'**
  String get photoPlaceholder;

  /// No description provided for @add.
  ///
  /// In fa, this message translates to:
  /// **'افزودن'**
  String get add;

  /// No description provided for @change.
  ///
  /// In fa, this message translates to:
  /// **'تغییر'**
  String get change;

  /// No description provided for @recordedAt.
  ///
  /// In fa, this message translates to:
  /// **'ثبت‌شده ساعت {time}'**
  String recordedAt(Object time);

  /// No description provided for @playbackPrompt.
  ///
  /// In fa, this message translates to:
  /// **'برای شنیدن دوباره لمس کن'**
  String get playbackPrompt;

  /// No description provided for @audioLoading.
  ///
  /// In fa, this message translates to:
  /// **'در حال بارگذاری صدا...'**
  String get audioLoading;

  /// No description provided for @audioError.
  ///
  /// In fa, this message translates to:
  /// **'خطا در بارگذاری صدا'**
  String get audioError;

  /// No description provided for @deleteMemoryTitle.
  ///
  /// In fa, this message translates to:
  /// **'حذف خاطره'**
  String get deleteMemoryTitle;

  /// No description provided for @deleteMemoryConfirmation.
  ///
  /// In fa, this message translates to:
  /// **'«{title}» برای همیشه حذف بشه؟ این کار برگشت‌ناپذیره.'**
  String deleteMemoryConfirmation(Object title);

  /// No description provided for @loginTitle.
  ///
  /// In fa, this message translates to:
  /// **'ورود به حساب'**
  String get loginTitle;

  /// No description provided for @signupTitle.
  ///
  /// In fa, this message translates to:
  /// **'ساخت حساب کاربری'**
  String get signupTitle;

  /// No description provided for @noAccount.
  ///
  /// In fa, this message translates to:
  /// **'حساب کاربری نداری؟'**
  String get noAccount;

  /// No description provided for @signupLink.
  ///
  /// In fa, this message translates to:
  /// **'ثبت‌نام کن'**
  String get signupLink;

  /// No description provided for @hasAccount.
  ///
  /// In fa, this message translates to:
  /// **'قبلاً حساب ساختی؟'**
  String get hasAccount;

  /// No description provided for @loginLink.
  ///
  /// In fa, this message translates to:
  /// **'وارد شو'**
  String get loginLink;

  /// No description provided for @passwordStrong.
  ///
  /// In fa, this message translates to:
  /// **'رمز عبور امن است'**
  String get passwordStrong;

  /// No description provided for @passwordShort.
  ///
  /// In fa, this message translates to:
  /// **'رمز عبور باید حداقل ۸ کاراکتر باشد'**
  String get passwordShort;

  /// No description provided for @emailLabel.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fa, this message translates to:
  /// **'رمز عبور'**
  String get passwordLabel;

  /// No description provided for @nameLabel.
  ///
  /// In fa, this message translates to:
  /// **'نام و نام‌خانوادگی'**
  String get nameLabel;

  /// No description provided for @year.
  ///
  /// In fa, this message translates to:
  /// **'سال'**
  String get year;

  /// No description provided for @month.
  ///
  /// In fa, this message translates to:
  /// **'ماه'**
  String get month;

  /// No description provided for @day.
  ///
  /// In fa, this message translates to:
  /// **'روز'**
  String get day;

  /// No description provided for @systemDefault.
  ///
  /// In fa, this message translates to:
  /// **'پیش‌فرض سیستم'**
  String get systemDefault;

  /// No description provided for @persian.
  ///
  /// In fa, this message translates to:
  /// **'فارسی'**
  String get persian;

  /// No description provided for @english.
  ///
  /// In fa, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @happiness.
  ///
  /// In fa, this message translates to:
  /// **'شادی'**
  String get happiness;

  /// No description provided for @sadness.
  ///
  /// In fa, this message translates to:
  /// **'ناراحتی'**
  String get sadness;

  /// No description provided for @anger.
  ///
  /// In fa, this message translates to:
  /// **'خشم'**
  String get anger;

  /// No description provided for @neutral.
  ///
  /// In fa, this message translates to:
  /// **'خنثی'**
  String get neutral;

  /// No description provided for @happinessEmoji.
  ///
  /// In fa, this message translates to:
  /// **'😊'**
  String get happinessEmoji;

  /// No description provided for @sadnessEmoji.
  ///
  /// In fa, this message translates to:
  /// **'😢'**
  String get sadnessEmoji;

  /// No description provided for @angerEmoji.
  ///
  /// In fa, this message translates to:
  /// **'😠'**
  String get angerEmoji;

  /// No description provided for @neutralEmoji.
  ///
  /// In fa, this message translates to:
  /// **'😐'**
  String get neutralEmoji;

  /// No description provided for @monthJan.
  ///
  /// In fa, this message translates to:
  /// **'ژانویه'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In fa, this message translates to:
  /// **'فوریه'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In fa, this message translates to:
  /// **'مارس'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In fa, this message translates to:
  /// **'آوریل'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In fa, this message translates to:
  /// **'مه'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In fa, this message translates to:
  /// **'ژوئن'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In fa, this message translates to:
  /// **'ژوئیه'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In fa, this message translates to:
  /// **'اوت'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In fa, this message translates to:
  /// **'سپتامبر'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In fa, this message translates to:
  /// **'اکتبر'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In fa, this message translates to:
  /// **'نوامبر'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In fa, this message translates to:
  /// **'دسامبر'**
  String get monthDec;

  /// No description provided for @monthFarvardin.
  ///
  /// In fa, this message translates to:
  /// **'فروردین'**
  String get monthFarvardin;

  /// No description provided for @monthOrdibehesht.
  ///
  /// In fa, this message translates to:
  /// **'اردیبهشت'**
  String get monthOrdibehesht;

  /// No description provided for @monthKhordad.
  ///
  /// In fa, this message translates to:
  /// **'خرداد'**
  String get monthKhordad;

  /// No description provided for @monthTir.
  ///
  /// In fa, this message translates to:
  /// **'تیر'**
  String get monthTir;

  /// No description provided for @monthMordad.
  ///
  /// In fa, this message translates to:
  /// **'مرداد'**
  String get monthMordad;

  /// No description provided for @monthShahrivar.
  ///
  /// In fa, this message translates to:
  /// **'شهریور'**
  String get monthShahrivar;

  /// No description provided for @monthMehr.
  ///
  /// In fa, this message translates to:
  /// **'مهر'**
  String get monthMehr;

  /// No description provided for @monthAban.
  ///
  /// In fa, this message translates to:
  /// **'آبان'**
  String get monthAban;

  /// No description provided for @monthAzar.
  ///
  /// In fa, this message translates to:
  /// **'آذر'**
  String get monthAzar;

  /// No description provided for @monthDey.
  ///
  /// In fa, this message translates to:
  /// **'دی'**
  String get monthDey;

  /// No description provided for @monthBahman.
  ///
  /// In fa, this message translates to:
  /// **'بهمن'**
  String get monthBahman;

  /// No description provided for @monthEsfand.
  ///
  /// In fa, this message translates to:
  /// **'اسفند'**
  String get monthEsfand;

  /// No description provided for @weekdaySat.
  ///
  /// In fa, this message translates to:
  /// **'شنبه'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In fa, this message translates to:
  /// **'یکشنبه'**
  String get weekdaySun;

  /// No description provided for @weekdayMon.
  ///
  /// In fa, this message translates to:
  /// **'دوشنبه'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In fa, this message translates to:
  /// **'سه‌شنبه'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In fa, this message translates to:
  /// **'چهارشنبه'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In fa, this message translates to:
  /// **'پنجشنبه'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In fa, this message translates to:
  /// **'جمعه'**
  String get weekdayFri;

  /// No description provided for @weekdaySatShort.
  ///
  /// In fa, this message translates to:
  /// **'ش'**
  String get weekdaySatShort;

  /// No description provided for @weekdaySunShort.
  ///
  /// In fa, this message translates to:
  /// **'ی'**
  String get weekdaySunShort;

  /// No description provided for @weekdayMonShort.
  ///
  /// In fa, this message translates to:
  /// **'د'**
  String get weekdayMonShort;

  /// No description provided for @weekdayTueShort.
  ///
  /// In fa, this message translates to:
  /// **'س'**
  String get weekdayTueShort;

  /// No description provided for @weekdayWedShort.
  ///
  /// In fa, this message translates to:
  /// **'چ'**
  String get weekdayWedShort;

  /// No description provided for @weekdayThuShort.
  ///
  /// In fa, this message translates to:
  /// **'پ'**
  String get weekdayThuShort;

  /// No description provided for @weekdayFriShort.
  ///
  /// In fa, this message translates to:
  /// **'ج'**
  String get weekdayFriShort;

  /// No description provided for @comingSoon.
  ///
  /// In fa, this message translates to:
  /// **'{feature} به‌زودی اضافه می‌شه'**
  String comingSoon(Object feature);

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In fa, this message translates to:
  /// **'رمز عبور با موفقیت تغییر کرد'**
  String get passwordChangedSuccess;

  /// No description provided for @updateProfile.
  ///
  /// In fa, this message translates to:
  /// **'به‌روزرسانی پروفایل'**
  String get updateProfile;

  /// No description provided for @selectLanguage.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب زبان'**
  String get selectLanguage;

  /// No description provided for @percent.
  ///
  /// In fa, this message translates to:
  /// **'{value}٪'**
  String percent(Object value);

  /// No description provided for @navHome.
  ///
  /// In fa, this message translates to:
  /// **'خانه'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In fa, this message translates to:
  /// **'تاریخچه'**
  String get navHistory;

  /// No description provided for @navAnalytics.
  ///
  /// In fa, this message translates to:
  /// **'تحلیل‌ها'**
  String get navAnalytics;

  /// No description provided for @navProfile.
  ///
  /// In fa, this message translates to:
  /// **'پروفایل'**
  String get navProfile;

  /// No description provided for @loginHeroTitle.
  ///
  /// In fa, this message translates to:
  /// **'خوش برگشتی'**
  String get loginHeroTitle;

  /// No description provided for @loginHeroSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'وارد شو و به خاطرات و روند\nاحساساتت سر بزن.'**
  String get loginHeroSubtitle;

  /// No description provided for @signupHeroSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'به دفترچه خاطرات صوتی خوش اومدی؛\nحس‌هات رو با صدا ثبت کن و روندشو ببین.'**
  String get signupHeroSubtitle;

  /// No description provided for @termsPrefix.
  ///
  /// In fa, this message translates to:
  /// **'با ثبت‌نام، '**
  String get termsPrefix;

  /// No description provided for @termsAnd.
  ///
  /// In fa, this message translates to:
  /// **' و '**
  String get termsAnd;

  /// No description provided for @termsSuffix.
  ///
  /// In fa, this message translates to:
  /// **' دفترچه خاطرات صوتی رو می‌پذیرم.'**
  String get termsSuffix;

  /// No description provided for @privacyPolicy.
  ///
  /// In fa, this message translates to:
  /// **'حریم خصوصی'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In fa, this message translates to:
  /// **'قوانین و مقررات'**
  String get termsOfService;

  /// No description provided for @enterFullName.
  ///
  /// In fa, this message translates to:
  /// **'لطفاً نام و نام خانوادگی را وارد کنید'**
  String get enterFullName;

  /// No description provided for @acceptTerms.
  ///
  /// In fa, this message translates to:
  /// **'لطفاً قوانین و مقررات را بپذیرید'**
  String get acceptTerms;

  /// No description provided for @fullNameHint.
  ///
  /// In fa, this message translates to:
  /// **'مثلاً: یاسمن احمدی'**
  String get fullNameHint;

  /// No description provided for @emailOrPhone.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل یا شماره موبایل'**
  String get emailOrPhone;

  /// No description provided for @passwordHint.
  ///
  /// In fa, this message translates to:
  /// **'حداقل ۸ کاراکتر'**
  String get passwordHint;

  /// No description provided for @editProfileDesc.
  ///
  /// In fa, this message translates to:
  /// **'نام، ایمیل'**
  String get editProfileDesc;

  /// No description provided for @connectionError.
  ///
  /// In fa, this message translates to:
  /// **'اتصال به سرور برقرار نشد. اینترنت یا آدرس سرور را چک کنید.'**
  String get connectionError;

  /// No description provided for @invalidCredentials.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل یا رمز عبور اشتباه است'**
  String get invalidCredentials;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In fa, this message translates to:
  /// **'این ایمیل قبلاً ثبت شده است'**
  String get emailAlreadyExists;

  /// No description provided for @sessionExpired.
  ///
  /// In fa, this message translates to:
  /// **'نشست شما منقضی شده، دوباره وارد شوید.'**
  String get sessionExpired;

  /// No description provided for @errorGeneric.
  ///
  /// In fa, this message translates to:
  /// **'خطایی رخ داد. دوباره تلاش کنید.'**
  String get errorGeneric;

  /// No description provided for @errorSaveMemory.
  ///
  /// In fa, this message translates to:
  /// **'خطا در ذخیره‌ی خاطره'**
  String get errorSaveMemory;

  /// No description provided for @errorMemoryNotFound.
  ///
  /// In fa, this message translates to:
  /// **'این خاطره پیدا نشد (شاید حذف شده).'**
  String get errorMemoryNotFound;

  /// No description provided for @errorDownloadAudio.
  ///
  /// In fa, this message translates to:
  /// **'خطا در دریافت فایل صوتی.'**
  String get errorDownloadAudio;

  /// No description provided for @errorDownloadPhoto.
  ///
  /// In fa, this message translates to:
  /// **'خطا در دریافت عکس.'**
  String get errorDownloadPhoto;

  /// No description provided for @errorDeleteMemory.
  ///
  /// In fa, this message translates to:
  /// **'خطا در حذف خاطره.'**
  String get errorDeleteMemory;

  /// No description provided for @errorNoFeedback.
  ///
  /// In fa, this message translates to:
  /// **'بازخوردی برای این خاطره ساخته نشد.'**
  String get errorNoFeedback;

  /// No description provided for @errorProcessing.
  ///
  /// In fa, this message translates to:
  /// **'هنوز پردازش این خاطره تمام نشده - چند لحظه دیگه دوباره امتحان کن.'**
  String get errorProcessing;

  /// No description provided for @errorLoadAnalytics.
  ///
  /// In fa, this message translates to:
  /// **'خطا در دریافت اطلاعات تحلیل.'**
  String get errorLoadAnalytics;

  /// No description provided for @errorCheckInsight.
  ///
  /// In fa, this message translates to:
  /// **'خطا در بررسی بینش.'**
  String get errorCheckInsight;

  /// No description provided for @weekly.
  ///
  /// In fa, this message translates to:
  /// **'هفتگی'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In fa, this message translates to:
  /// **'ماهانه'**
  String get monthly;

  /// No description provided for @monthlyOverview.
  ///
  /// In fa, this message translates to:
  /// **'نمای کلی ماهانه'**
  String get monthlyOverview;

  /// No description provided for @thisMonth.
  ///
  /// In fa, this message translates to:
  /// **'این ماه'**
  String get thisMonth;

  /// No description provided for @thisWeek.
  ///
  /// In fa, this message translates to:
  /// **'این هفته'**
  String get thisWeek;

  /// No description provided for @weeklyEmotionChart.
  ///
  /// In fa, this message translates to:
  /// **'نمودار هفتگی احساسات'**
  String get weeklyEmotionChart;

  /// No description provided for @weeklyTrend.
  ///
  /// In fa, this message translates to:
  /// **'روند هفته‌به‌هفته'**
  String get weeklyTrend;

  /// No description provided for @compareLast4Weeks.
  ///
  /// In fa, this message translates to:
  /// **'مقایسه چهار هفته اخیر'**
  String get compareLast4Weeks;

  /// No description provided for @weeksCount.
  ///
  /// In fa, this message translates to:
  /// **'{count} هفته'**
  String weeksCount(Object count);

  /// No description provided for @getWeeklyInsight.
  ///
  /// In fa, this message translates to:
  /// **'برای گرفتن تحلیل هوشمند این هفته، اینجا رو بزن'**
  String get getWeeklyInsight;

  /// No description provided for @getMonthlyInsight.
  ///
  /// In fa, this message translates to:
  /// **'برای گرفتن تحلیل هوشمند این ماه، اینجا رو بزن'**
  String get getMonthlyInsight;

  /// No description provided for @dayDetail.
  ///
  /// In fa, this message translates to:
  /// **'جزئیات روز {day}'**
  String dayDetail(Object day);

  /// No description provided for @noMemoriesRecorded.
  ///
  /// In fa, this message translates to:
  /// **'هنوز خاطره‌ای برای این هفته ثبت نشده'**
  String get noMemoriesRecorded;

  /// No description provided for @view.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده'**
  String get view;

  /// No description provided for @selectYear.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب سال'**
  String get selectYear;

  /// No description provided for @selectMonth.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب ماه'**
  String get selectMonth;

  /// No description provided for @noMemoriesThisDay.
  ///
  /// In fa, this message translates to:
  /// **'خاطره‌ای ثبت نشده'**
  String get noMemoriesThisDay;

  /// No description provided for @dominantEmotionLabel.
  ///
  /// In fa, this message translates to:
  /// **'حس غالب: {emotion}'**
  String dominantEmotionLabel(Object emotion);

  /// No description provided for @emotionChartThisMemory.
  ///
  /// In fa, this message translates to:
  /// **'نمودار احساسات این خاطره'**
  String get emotionChartThisMemory;

  /// No description provided for @usernameLabel.
  ///
  /// In fa, this message translates to:
  /// **'نام کاربری'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In fa, this message translates to:
  /// **'نام‌ت رو بنویس'**
  String get usernameHint;

  /// No description provided for @emailHint.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل‌ت رو بنویس'**
  String get emailHint;

  /// No description provided for @errorNameEmpty.
  ///
  /// In fa, this message translates to:
  /// **'نام نمی‌تواند خالی باشد.'**
  String get errorNameEmpty;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In fa, this message translates to:
  /// **'رمز عبور فعلی'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In fa, this message translates to:
  /// **'رمز عبور جدید'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In fa, this message translates to:
  /// **'تکرار رمز عبور جدید'**
  String get confirmPasswordLabel;

  /// No description provided for @errorAllFieldsRequired.
  ///
  /// In fa, this message translates to:
  /// **'همه‌ی فیلدها اجباری‌ان.'**
  String get errorAllFieldsRequired;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In fa, this message translates to:
  /// **'تکرار رمز عبور با رمز جدید یکی نیست.'**
  String get errorPasswordMismatch;

  /// No description provided for @memoriesThisDay.
  ///
  /// In fa, this message translates to:
  /// **'خاطرات این روز'**
  String get memoriesThisDay;

  /// No description provided for @emotionChartDay.
  ///
  /// In fa, this message translates to:
  /// **'نمودار احساسات روز'**
  String get emotionChartDay;

  /// No description provided for @averageEmotionAcross.
  ///
  /// In fa, this message translates to:
  /// **'میانگین حس در طول {count} خاطره'**
  String averageEmotionAcross(Object count);

  /// No description provided for @memoriesRecordedThisDay.
  ///
  /// In fa, this message translates to:
  /// **'{count} خاطره ثبت‌شده در این روز'**
  String memoriesRecordedThisDay(Object count);

  /// No description provided for @today.
  ///
  /// In fa, this message translates to:
  /// **'امروز'**
  String get today;

  /// No description provided for @processing.
  ///
  /// In fa, this message translates to:
  /// **'در حال پردازش…'**
  String get processing;

  /// No description provided for @errorMicPermission.
  ///
  /// In fa, this message translates to:
  /// **'برای ضبط خاطره، دسترسی میکروفون رو تایید کن.'**
  String get errorMicPermission;

  /// No description provided for @weeklyOverview.
  ///
  /// In fa, this message translates to:
  /// **'تحلیل کامل این هفته'**
  String get weeklyOverview;

  /// No description provided for @errorFetchEntries.
  ///
  /// In fa, this message translates to:
  /// **'خطا در دریافت خاطرات.'**
  String get errorFetchEntries;

  /// No description provided for @errorFetchDailyReport.
  ///
  /// In fa, this message translates to:
  /// **'خطا در دریافت گزارش روزانه.'**
  String get errorFetchDailyReport;

  /// No description provided for @errorTitleRequired.
  ///
  /// In fa, this message translates to:
  /// **'عنوان اجباری است'**
  String get errorTitleRequired;

  /// No description provided for @errorLoadCalendar.
  ///
  /// In fa, this message translates to:
  /// **'خطا در بارگذاری تقویم'**
  String get errorLoadCalendar;

  /// No description provided for @errorStartRecording.
  ///
  /// In fa, this message translates to:
  /// **'شروع ضبط با خطا مواجه شد.'**
  String get errorStartRecording;

  /// No description provided for @errorGenerateInsight.
  ///
  /// In fa, this message translates to:
  /// **'خطا در تولید بینش. دوباره تلاش کن.'**
  String get errorGenerateInsight;

  /// No description provided for @errorNoNotesThisWeek.
  ///
  /// In fa, this message translates to:
  /// **'برای این هفته هنوز خاطره‌ای ثبت نشده است.'**
  String get errorNoNotesThisWeek;

  /// No description provided for @memoryTitleHint.
  ///
  /// In fa, this message translates to:
  /// **'مثلاً: یه روز خوب'**
  String get memoryTitleHint;

  /// No description provided for @tapToStartRecording.
  ///
  /// In fa, this message translates to:
  /// **'برای شروع ضبط لمس کن'**
  String get tapToStartRecording;

  /// No description provided for @recordingInProgress.
  ///
  /// In fa, this message translates to:
  /// **'در حال ضبط...'**
  String get recordingInProgress;

  /// No description provided for @tapToReRecord.
  ///
  /// In fa, this message translates to:
  /// **'برای ضبط دوباره لمس کن'**
  String get tapToReRecord;

  /// No description provided for @monthlyEmotionChartTitle.
  ///
  /// In fa, this message translates to:
  /// **'نمودار احساسات ماه'**
  String get monthlyEmotionChartTitle;

  /// No description provided for @monthEmotionChartTitle.
  ///
  /// In fa, this message translates to:
  /// **'نمودار احساسات ماه'**
  String get monthEmotionChartTitle;
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
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
