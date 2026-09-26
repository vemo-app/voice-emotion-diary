import 'package:flutter/material.dart';
import 'package:voice_diary/l10n/app_localizations.dart';
import 'package:voice_diary/pages/root/auth_gate.dart';
import 'package:voice_diary/services/locale_service.dart';
import 'package:voice_diary/services/theme_service.dart';
import 'package:voice_diary/widgets/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService().init();
  await LocaleService().init();
  runApp(const VoiceDiaryApp());
}

class VoiceDiaryApp extends StatelessWidget {
  const VoiceDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService(), LocaleService()]),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeService().themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          locale: LocaleService().locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,

          home: const AuthGate(),
        );
      },
    );
  }
}
