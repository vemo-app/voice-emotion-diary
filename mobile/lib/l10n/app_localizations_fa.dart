// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'دفترچه خاطرات صوتی';

  @override
  String get homeTitle => 'خاطرات امروز';

  @override
  String get homeGreeting => 'سلام! امروز چطوری؟';

  @override
  String todayLabel(Object day, Object month, Object weekday, Object year) {
    return '$weekday، $day $month $year';
  }

  @override
  String get emotionChartTitle => 'نمودار احساسات امروز';

  @override
  String emotionChartSubtitle(Object count) {
    return 'بر اساس $count خاطره ثبت‌شده';
  }

  @override
  String memoriesCount(Object count) {
    return '$count خاطره';
  }

  @override
  String get dominantEmotion => 'شادی غالب';

  @override
  String get noMemoriesToday => 'امروز هنوز خاطره‌ای ثبت نکردی';

  @override
  String get recordNewMemory => 'ضبط خاطره جدید';

  @override
  String get historyTitle => 'تاریخچه خاطرات';

  @override
  String get historySubtitle => 'روز موردنظرت رو انتخاب کن';

  @override
  String get analyticsTitle => 'تحلیل‌ها';

  @override
  String get analyticsSubtitle => 'روند احساسات تو در طول زمان';

  @override
  String get profileTitle => 'پروفایل';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get editProfile => 'ویرایش پروفایل';

  @override
  String get changePassword => 'تغییر رمز عبور';

  @override
  String get logout => 'خروج از حساب کاربری';

  @override
  String get deleteAccount => 'حذف حساب کاربری';

  @override
  String get cancel => 'انصراف';

  @override
  String get confirm => 'تأیید';

  @override
  String get save => 'ذخیره';

  @override
  String get saveChanges => 'ذخیره تغییرات';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'ویرایش';

  @override
  String get tryAgain => 'تلاش دوباره';

  @override
  String get loading => 'در حال بارگذاری...';

  @override
  String get errorLoading => 'خطا در بارگذاری اطلاعات. دوباره تلاش کنید.';

  @override
  String get logoutConfirmation => 'مطمئنی می‌خوای از حسابت خارج بشی؟';

  @override
  String get deleteAccountConfirmation =>
      'این کار برگشت‌ناپذیره. همه‌ی خاطرات، تحلیل‌ها و اطلاعات حسابت برای همیشه پاک می‌شه.';

  @override
  String get deleteAccountTitle => 'حذف حساب کاربری';

  @override
  String get deletePermanently => 'حذف برای همیشه';

  @override
  String get darkModeLabel => 'حالت دارک';

  @override
  String get languageLabel => 'زبان';

  @override
  String get notificationsLabel => 'اعلان‌ها';

  @override
  String get accountSettings => 'حساب کاربری';

  @override
  String get appSettings => 'تنظیمات برنامه';

  @override
  String get dangerZone => 'دسترسی به حساب';

  @override
  String joinedDate(Object date) {
    return 'عضو از $date';
  }

  @override
  String get totalMemories => 'کل خاطرات';

  @override
  String get emotionDistribution => 'توزیع احساسات کلی';

  @override
  String get noData => 'هنوز داده‌ای برای نمایش نیست';

  @override
  String get aiFeedback => 'بازخورد همیار';

  @override
  String get aiWriting => 'همیار در حال نوشتن...';

  @override
  String get newMemoryTitle => 'خاطره جدید';

  @override
  String get editMemoryTitle => 'ویرایش خاطره';

  @override
  String get memoryTitleLabel => 'عنوان خاطره';

  @override
  String get required => 'اجباری';

  @override
  String get addToMemory => 'افزودن به این خاطره';

  @override
  String get note => 'یادداشت';

  @override
  String get notePlaceholder => 'یک نوت متنی اضافه کن';

  @override
  String get photo => 'عکس';

  @override
  String get photoPlaceholder => 'تصویر اضافه کن';

  @override
  String get add => 'افزودن';

  @override
  String get change => 'تغییر';

  @override
  String recordedAt(Object time) {
    return 'ثبت‌شده ساعت $time';
  }

  @override
  String get playbackPrompt => 'برای شنیدن دوباره لمس کن';

  @override
  String get audioLoading => 'در حال بارگذاری صدا...';

  @override
  String get audioError => 'خطا در بارگذاری صدا';

  @override
  String get deleteMemoryTitle => 'حذف خاطره';

  @override
  String deleteMemoryConfirmation(Object title) {
    return '«$title» برای همیشه حذف بشه؟ این کار برگشت‌ناپذیره.';
  }

  @override
  String get loginTitle => 'ورود به حساب';

  @override
  String get signupTitle => 'ساخت حساب کاربری';

  @override
  String get noAccount => 'حساب کاربری نداری؟';

  @override
  String get signupLink => 'ثبت‌نام کن';

  @override
  String get hasAccount => 'قبلاً حساب ساختی؟';

  @override
  String get loginLink => 'وارد شو';

  @override
  String get passwordStrong => 'رمز عبور امن است';

  @override
  String get passwordShort => 'رمز عبور باید حداقل ۸ کاراکتر باشد';

  @override
  String get emailLabel => 'ایمیل';

  @override
  String get passwordLabel => 'رمز عبور';

  @override
  String get nameLabel => 'نام و نام‌خانوادگی';

  @override
  String get year => 'سال';

  @override
  String get month => 'ماه';

  @override
  String get day => 'روز';

  @override
  String get systemDefault => 'پیش‌فرض سیستم';

  @override
  String get persian => 'فارسی';

  @override
  String get english => 'English';

  @override
  String get happiness => 'شادی';

  @override
  String get sadness => 'ناراحتی';

  @override
  String get anger => 'خشم';

  @override
  String get neutral => 'خنثی';

  @override
  String get happinessEmoji => '😊';

  @override
  String get sadnessEmoji => '😢';

  @override
  String get angerEmoji => '😠';

  @override
  String get neutralEmoji => '😐';

  @override
  String get monthJan => 'ژانویه';

  @override
  String get monthFeb => 'فوریه';

  @override
  String get monthMar => 'مارس';

  @override
  String get monthApr => 'آوریل';

  @override
  String get monthMay => 'مه';

  @override
  String get monthJun => 'ژوئن';

  @override
  String get monthJul => 'ژوئیه';

  @override
  String get monthAug => 'اوت';

  @override
  String get monthSep => 'سپتامبر';

  @override
  String get monthOct => 'اکتبر';

  @override
  String get monthNov => 'نوامبر';

  @override
  String get monthDec => 'دسامبر';

  @override
  String get monthFarvardin => 'فروردین';

  @override
  String get monthOrdibehesht => 'اردیبهشت';

  @override
  String get monthKhordad => 'خرداد';

  @override
  String get monthTir => 'تیر';

  @override
  String get monthMordad => 'مرداد';

  @override
  String get monthShahrivar => 'شهریور';

  @override
  String get monthMehr => 'مهر';

  @override
  String get monthAban => 'آبان';

  @override
  String get monthAzar => 'آذر';

  @override
  String get monthDey => 'دی';

  @override
  String get monthBahman => 'بهمن';

  @override
  String get monthEsfand => 'اسفند';

  @override
  String get weekdaySat => 'شنبه';

  @override
  String get weekdaySun => 'یکشنبه';

  @override
  String get weekdayMon => 'دوشنبه';

  @override
  String get weekdayTue => 'سه‌شنبه';

  @override
  String get weekdayWed => 'چهارشنبه';

  @override
  String get weekdayThu => 'پنجشنبه';

  @override
  String get weekdayFri => 'جمعه';

  @override
  String get weekdaySatShort => 'ش';

  @override
  String get weekdaySunShort => 'ی';

  @override
  String get weekdayMonShort => 'د';

  @override
  String get weekdayTueShort => 'س';

  @override
  String get weekdayWedShort => 'چ';

  @override
  String get weekdayThuShort => 'پ';

  @override
  String get weekdayFriShort => 'ج';

  @override
  String comingSoon(Object feature) {
    return '$feature به‌زودی اضافه می‌شه';
  }

  @override
  String get passwordChangedSuccess => 'رمز عبور با موفقیت تغییر کرد';

  @override
  String get updateProfile => 'به‌روزرسانی پروفایل';

  @override
  String get selectLanguage => 'انتخاب زبان';

  @override
  String percent(Object value) {
    return '$value٪';
  }

  @override
  String get navHome => 'خانه';

  @override
  String get navHistory => 'تاریخچه';

  @override
  String get navAnalytics => 'تحلیل‌ها';

  @override
  String get navProfile => 'پروفایل';

  @override
  String get loginHeroTitle => 'خوش برگشتی';

  @override
  String get loginHeroSubtitle =>
      'وارد شو و به خاطرات و روند\nاحساساتت سر بزن.';

  @override
  String get signupHeroSubtitle =>
      'به دفترچه خاطرات صوتی خوش اومدی؛\nحس‌هات رو با صدا ثبت کن و روندشو ببین.';

  @override
  String get termsPrefix => 'با ثبت‌نام، ';

  @override
  String get termsAnd => ' و ';

  @override
  String get termsSuffix => ' دفترچه خاطرات صوتی رو می‌پذیرم.';

  @override
  String get privacyPolicy => 'حریم خصوصی';

  @override
  String get termsOfService => 'قوانین و مقررات';

  @override
  String get enterFullName => 'لطفاً نام و نام خانوادگی را وارد کنید';

  @override
  String get acceptTerms => 'لطفاً قوانین و مقررات را بپذیرید';

  @override
  String get fullNameHint => 'مثلاً: یاسمن احمدی';

  @override
  String get emailOrPhone => 'ایمیل یا شماره موبایل';

  @override
  String get passwordHint => 'حداقل ۸ کاراکتر';

  @override
  String get editProfileDesc => 'نام، ایمیل';

  @override
  String get connectionError =>
      'اتصال به سرور برقرار نشد. اینترنت یا آدرس سرور را چک کنید.';

  @override
  String get invalidCredentials => 'ایمیل یا رمز عبور اشتباه است';

  @override
  String get emailAlreadyExists => 'این ایمیل قبلاً ثبت شده است';

  @override
  String get sessionExpired => 'نشست شما منقضی شده، دوباره وارد شوید.';

  @override
  String get errorGeneric => 'خطایی رخ داد. دوباره تلاش کنید.';

  @override
  String get errorSaveMemory => 'خطا در ذخیره‌ی خاطره';

  @override
  String get errorMemoryNotFound => 'این خاطره پیدا نشد (شاید حذف شده).';

  @override
  String get errorDownloadAudio => 'خطا در دریافت فایل صوتی.';

  @override
  String get errorDownloadPhoto => 'خطا در دریافت عکس.';

  @override
  String get errorDeleteMemory => 'خطا در حذف خاطره.';

  @override
  String get errorNoFeedback => 'بازخوردی برای این خاطره ساخته نشد.';

  @override
  String get errorProcessing =>
      'هنوز پردازش این خاطره تمام نشده - چند لحظه دیگه دوباره امتحان کن.';

  @override
  String get errorLoadAnalytics => 'خطا در دریافت اطلاعات تحلیل.';

  @override
  String get errorCheckInsight => 'خطا در بررسی بینش.';

  @override
  String get weekly => 'هفتگی';

  @override
  String get monthly => 'ماهانه';

  @override
  String get monthlyOverview => 'نمای کلی ماهانه';

  @override
  String get thisMonth => 'این ماه';

  @override
  String get thisWeek => 'این هفته';

  @override
  String get weeklyEmotionChart => 'نمودار هفتگی احساسات';

  @override
  String get weeklyTrend => 'روند هفته‌به‌هفته';

  @override
  String get compareLast4Weeks => 'مقایسه چهار هفته اخیر';

  @override
  String weeksCount(Object count) {
    return '$count هفته';
  }

  @override
  String get getWeeklyInsight =>
      'برای گرفتن تحلیل هوشمند این هفته، اینجا رو بزن';

  @override
  String get getMonthlyInsight =>
      'برای گرفتن تحلیل هوشمند این ماه، اینجا رو بزن';

  @override
  String dayDetail(Object day) {
    return 'جزئیات روز $day';
  }

  @override
  String get noMemoriesRecorded => 'هنوز خاطره‌ای برای این هفته ثبت نشده';

  @override
  String get view => 'مشاهده';

  @override
  String get selectYear => 'انتخاب سال';

  @override
  String get selectMonth => 'انتخاب ماه';

  @override
  String get noMemoriesThisDay => 'خاطره‌ای ثبت نشده';

  @override
  String dominantEmotionLabel(Object emotion) {
    return 'حس غالب: $emotion';
  }

  @override
  String get emotionChartThisMemory => 'نمودار احساسات این خاطره';

  @override
  String get usernameLabel => 'نام کاربری';

  @override
  String get usernameHint => 'نام‌ت رو بنویس';

  @override
  String get emailHint => 'ایمیل‌ت رو بنویس';

  @override
  String get errorNameEmpty => 'نام نمی‌تواند خالی باشد.';

  @override
  String get currentPasswordLabel => 'رمز عبور فعلی';

  @override
  String get newPasswordLabel => 'رمز عبور جدید';

  @override
  String get confirmPasswordLabel => 'تکرار رمز عبور جدید';

  @override
  String get errorAllFieldsRequired => 'همه‌ی فیلدها اجباری‌ان.';

  @override
  String get errorPasswordMismatch => 'تکرار رمز عبور با رمز جدید یکی نیست.';

  @override
  String get memoriesThisDay => 'خاطرات این روز';

  @override
  String get emotionChartDay => 'نمودار احساسات روز';

  @override
  String averageEmotionAcross(Object count) {
    return 'میانگین حس در طول $count خاطره';
  }

  @override
  String memoriesRecordedThisDay(Object count) {
    return '$count خاطره ثبت‌شده در این روز';
  }

  @override
  String get today => 'امروز';

  @override
  String get processing => 'در حال پردازش…';

  @override
  String get errorMicPermission =>
      'برای ضبط خاطره، دسترسی میکروفون رو تایید کن.';

  @override
  String get weeklyOverview => 'تحلیل کامل این هفته';

  @override
  String get errorFetchEntries => 'خطا در دریافت خاطرات.';

  @override
  String get errorFetchDailyReport => 'خطا در دریافت گزارش روزانه.';

  @override
  String get errorTitleRequired => 'عنوان اجباری است';

  @override
  String get errorLoadCalendar => 'خطا در بارگذاری تقویم';

  @override
  String get errorStartRecording => 'شروع ضبط با خطا مواجه شد.';

  @override
  String get errorGenerateInsight => 'خطا در تولید بینش. دوباره تلاش کن.';

  @override
  String get errorNoNotesThisWeek =>
      'برای این هفته هنوز خاطره‌ای ثبت نشده است.';

  @override
  String get memoryTitleHint => 'مثلاً: یه روز خوب';

  @override
  String get tapToStartRecording => 'برای شروع ضبط لمس کن';

  @override
  String get recordingInProgress => 'در حال ضبط...';

  @override
  String get tapToReRecord => 'برای ضبط دوباره لمس کن';

  @override
  String get monthlyEmotionChartTitle => 'نمودار احساسات ماه';

  @override
  String get monthEmotionChartTitle => 'نمودار احساسات ماه';
}
