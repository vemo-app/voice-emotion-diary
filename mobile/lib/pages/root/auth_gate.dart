import 'package:flutter/material.dart';
import '../../services/token_storage.dart';
import '../../services/user_service.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../home/home_page.dart';
import '../login/login_page.dart';

/// Initial entry point of the application. It performs two main tasks:
/// 1) Verifies if a valid stored token exists to decide whether to navigate
///    to the HomePage or LoginPage.
/// 2) If authenticated, fetches user preferences from the backend to sync
///    the local theme and language settings.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Future is initialized once to prevent re-execution during UI rebuilds.
  late final Future<bool> _isLoggedInFuture = _checkLoginAndSyncPrefs();

  Future<bool> _checkLoginAndSyncPrefs() async {
    final loggedIn = await TokenStorage.isLoggedIn();
    if (!loggedIn) return false;
    await UserService().syncPreferencesFromBackend();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: context.colors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final loggedIn = snapshot.data ?? false;
        return loggedIn ? const HomePage() : const LoginPage();
      },
    );
  }
}
