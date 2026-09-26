// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Voice Diary';

  @override
  String get homeTitle => 'Today\'s Memories';

  @override
  String get homeGreeting => 'Hello! How are you today?';

  @override
  String todayLabel(Object day, Object month, Object weekday, Object year) {
    return '$weekday, $month $day, $year';
  }

  @override
  String get emotionChartTitle => 'Today\'s Emotion Chart';

  @override
  String emotionChartSubtitle(Object count) {
    return 'Based on $count recorded memories';
  }

  @override
  String memoriesCount(Object count) {
    return '$count Memories';
  }

  @override
  String get dominantEmotion => 'Dominant Happiness';

  @override
  String get noMemoriesToday => 'You haven\'t recorded any memories today';

  @override
  String get recordNewMemory => 'Record New Memory';

  @override
  String get historyTitle => 'Memory History';

  @override
  String get historySubtitle => 'Select your desired day';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsSubtitle => 'Your emotion trends over time';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get logout => 'Logout';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get loading => 'Loading...';

  @override
  String get errorLoading => 'Error loading information. Please try again.';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get deleteAccountConfirmation =>
      'This action is irreversible. All your memories, analytics, and account information will be permanently deleted.';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get darkModeLabel => 'Dark Mode';

  @override
  String get languageLabel => 'Language';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get appSettings => 'App Settings';

  @override
  String get dangerZone => 'Account Access';

  @override
  String joinedDate(Object date) {
    return 'Joined since $date';
  }

  @override
  String get totalMemories => 'Total Memories';

  @override
  String get emotionDistribution => 'Overall Emotion Distribution';

  @override
  String get noData => 'No data to display yet';

  @override
  String get aiFeedback => 'AI Feedback';

  @override
  String get aiWriting => 'AI is writing...';

  @override
  String get newMemoryTitle => 'New Memory';

  @override
  String get editMemoryTitle => 'Edit Memory';

  @override
  String get memoryTitleLabel => 'Memory Title';

  @override
  String get required => 'Required';

  @override
  String get addToMemory => 'Add to this memory';

  @override
  String get note => 'Note';

  @override
  String get notePlaceholder => 'Add a text note';

  @override
  String get photo => 'Photo';

  @override
  String get photoPlaceholder => 'Add a photo';

  @override
  String get add => 'Add';

  @override
  String get change => 'Change';

  @override
  String recordedAt(Object time) {
    return 'Recorded at $time';
  }

  @override
  String get playbackPrompt => 'Tap to listen again';

  @override
  String get audioLoading => 'Loading audio...';

  @override
  String get audioError => 'Error loading audio';

  @override
  String get deleteMemoryTitle => 'Delete Memory';

  @override
  String deleteMemoryConfirmation(Object title) {
    return 'Delete \"$title\" permanently? This action is irreversible.';
  }

  @override
  String get loginTitle => 'Login';

  @override
  String get signupTitle => 'Create Account';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signupLink => 'Sign up';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get loginLink => 'Log in';

  @override
  String get passwordStrong => 'Password is secure';

  @override
  String get passwordShort => 'Password must be at least 8 characters';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get nameLabel => 'Full Name';

  @override
  String get year => 'Year';

  @override
  String get month => 'Month';

  @override
  String get day => 'Day';

  @override
  String get systemDefault => 'System Default';

  @override
  String get persian => 'Persian';

  @override
  String get english => 'English';

  @override
  String get happiness => 'Happiness';

  @override
  String get sadness => 'Sadness';

  @override
  String get anger => 'Anger';

  @override
  String get neutral => 'Neutral';

  @override
  String get happinessEmoji => '😊';

  @override
  String get sadnessEmoji => '😢';

  @override
  String get angerEmoji => '😠';

  @override
  String get neutralEmoji => '😐';

  @override
  String get monthJan => 'January';

  @override
  String get monthFeb => 'February';

  @override
  String get monthMar => 'March';

  @override
  String get monthApr => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'June';

  @override
  String get monthJul => 'July';

  @override
  String get monthAug => 'August';

  @override
  String get monthSep => 'September';

  @override
  String get monthOct => 'October';

  @override
  String get monthNov => 'November';

  @override
  String get monthDec => 'December';

  @override
  String get monthFarvardin => 'Farvardin';

  @override
  String get monthOrdibehesht => 'Ordibehesht';

  @override
  String get monthKhordad => 'Khordad';

  @override
  String get monthTir => 'Tir';

  @override
  String get monthMordad => 'Mordad';

  @override
  String get monthShahrivar => 'Shahrivar';

  @override
  String get monthMehr => 'Mehr';

  @override
  String get monthAban => 'Aban';

  @override
  String get monthAzar => 'Azar';

  @override
  String get monthDey => 'Dey';

  @override
  String get monthBahman => 'Bahman';

  @override
  String get monthEsfand => 'Esfand';

  @override
  String get weekdaySat => 'Saturday';

  @override
  String get weekdaySun => 'Sunday';

  @override
  String get weekdayMon => 'Monday';

  @override
  String get weekdayTue => 'Tuesday';

  @override
  String get weekdayWed => 'Wednesday';

  @override
  String get weekdayThu => 'Thursday';

  @override
  String get weekdayFri => 'Friday';

  @override
  String get weekdaySatShort => 'S';

  @override
  String get weekdaySunShort => 'S';

  @override
  String get weekdayMonShort => 'M';

  @override
  String get weekdayTueShort => 'T';

  @override
  String get weekdayWedShort => 'W';

  @override
  String get weekdayThuShort => 'T';

  @override
  String get weekdayFriShort => 'F';

  @override
  String comingSoon(Object feature) {
    return '$feature will be added soon';
  }

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String percent(Object value) {
    return '$value%';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navProfile => 'Profile';

  @override
  String get loginHeroTitle => 'Welcome Back';

  @override
  String get loginHeroSubtitle =>
      'Log in to check your memories and emotion trends.';

  @override
  String get signupHeroSubtitle =>
      'Welcome to Voice Diary; record your feelings with voice and see the trends.';

  @override
  String get termsPrefix => 'By signing up, I accept the ';

  @override
  String get termsAnd => ' and ';

  @override
  String get termsSuffix => ' of Voice Diary.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get enterFullName => 'Please enter your full name';

  @override
  String get acceptTerms => 'Please accept the terms and conditions';

  @override
  String get fullNameHint => 'e.g., Yasaman Ahmadi';

  @override
  String get emailOrPhone => 'Email or Phone Number';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get editProfileDesc => 'Name, Email';

  @override
  String get connectionError =>
      'Could not connect to server. Please check your internet or server address.';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get emailAlreadyExists => 'This email is already registered';

  @override
  String get sessionExpired => 'Session expired, please log in again.';

  @override
  String get errorGeneric => 'An error occurred. Please try again.';

  @override
  String get errorSaveMemory => 'Error saving memory';

  @override
  String get errorMemoryNotFound =>
      'Memory not found (it might have been deleted).';

  @override
  String get errorDownloadAudio => 'Error downloading audio file.';

  @override
  String get errorDownloadPhoto => 'Error downloading photo.';

  @override
  String get errorDeleteMemory => 'Error deleting memory.';

  @override
  String get errorNoFeedback => 'No feedback was created for this memory.';

  @override
  String get errorProcessing =>
      'Memory is still being processed - please try again in a moment.';

  @override
  String get errorLoadAnalytics => 'Error loading analytics information.';

  @override
  String get errorCheckInsight => 'Error checking insight.';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get monthlyOverview => 'Monthly Overview';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisWeek => 'This Week';

  @override
  String get weeklyEmotionChart => 'Weekly Emotion Chart';

  @override
  String get weeklyTrend => 'Weekly Trend';

  @override
  String get compareLast4Weeks => 'Compare last 4 weeks';

  @override
  String weeksCount(Object count) {
    return '$count Weeks';
  }

  @override
  String get getWeeklyInsight => 'Click here for AI insight for this week';

  @override
  String get getMonthlyInsight => 'Click here for monthly AI insight';

  @override
  String dayDetail(Object day) {
    return 'Detail for Day $day';
  }

  @override
  String get noMemoriesRecorded => 'No memories recorded for this week';

  @override
  String get view => 'View';

  @override
  String get selectYear => 'Select Year';

  @override
  String get selectMonth => 'Select Month';

  @override
  String get noMemoriesThisDay => 'No memories recorded';

  @override
  String dominantEmotionLabel(Object emotion) {
    return 'Dominant: $emotion';
  }

  @override
  String get emotionChartThisMemory => 'Emotion Chart for this Memory';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Enter your name';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get errorNameEmpty => 'Name cannot be empty.';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmPasswordLabel => 'Confirm New Password';

  @override
  String get errorAllFieldsRequired => 'All fields are required.';

  @override
  String get errorPasswordMismatch => 'Passwords do not match.';

  @override
  String get memoriesThisDay => 'Memories of this Day';

  @override
  String get emotionChartDay => 'Daily Emotion Chart';

  @override
  String averageEmotionAcross(Object count) {
    return 'Average across $count memories';
  }

  @override
  String memoriesRecordedThisDay(Object count) {
    return '$count memories recorded this day';
  }

  @override
  String get today => 'Today';

  @override
  String get processing => 'Processing…';

  @override
  String get errorMicPermission =>
      'Please allow microphone access to record memories.';

  @override
  String get weeklyOverview => 'Full Analysis This Week';

  @override
  String get errorFetchEntries => 'Error fetching memories.';

  @override
  String get errorFetchDailyReport => 'Error fetching daily report.';

  @override
  String get errorTitleRequired => 'Title is required';

  @override
  String get errorLoadCalendar => 'Error loading calendar.';

  @override
  String get errorStartRecording => 'Failed to start recording.';

  @override
  String get errorGenerateInsight =>
      'Error generating insight. Please try again.';

  @override
  String get errorNoNotesThisWeek =>
      'No memories have been recorded for this week yet.';

  @override
  String get memoryTitleHint => 'e.g., A great day';

  @override
  String get tapToStartRecording => 'Tap to start recording';

  @override
  String get recordingInProgress => 'Recording...';

  @override
  String get tapToReRecord => 'Tap to record again';

  @override
  String get monthlyEmotionChartTitle => 'Monthly Emotion Chart';

  @override
  String get monthEmotionChartTitle => 'This Month\'s Emotion Chart';
}
