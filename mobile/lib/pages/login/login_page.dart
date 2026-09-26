import 'package:flutter/material.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/gradient_button.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../home/home_page.dart';
import '../signup/signup.dart';
import '../../l10n/app_localizations.dart';
/// Login page.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Reset error message before new attempt
    });

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Since manual login bypasses AuthGate, the user's backend preferences
      // (theme, language) must be manually fetched and applied to ensure
      // they aren't seeing settings left over from a previous session or user.
      await UserService().syncPreferencesFromBackend();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on AuthException catch (e) {
      // Catch logical authentication errors (e.g., wrong password, user not found)
      // and display the corresponding localized error message.
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      switch (e.message) {
        case 'connectionError':
          setState(() => _errorMessage = l10n.connectionError);
          break;
        case 'invalidCredentials':
          setState(() => _errorMessage = l10n.invalidCredentials);
          break;
        default:
          setState(() => _errorMessage = l10n.errorGeneric);
      }
    } finally {
      // The finally block ensures the loading spinner is turned off regardless
      // of whether the login attempt succeeded or failed.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: context.colors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              _buildHero(l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        label: l10n.emailOrPhone,
                        hintText: 'you@email.com',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: l10n.passwordLabel,
                        hintText: '••••••',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        trailing: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 16,
                            color: context.colors.ink400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Show error message only if a failed attempt occurred.
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: context.pwHint.copyWith(color: Colors.red),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Display a loading indicator instead of the button when processing,
                      // preventing multiple simultaneous requests.
                      _isLoading
                          ? Container(
                              height: 54,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: AppColors.buttonGradient,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: context.colors.shadowButton,
                              ),
                              child: const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : GradientButton(
                              text: l10n.loginTitle,
                              icon: Directionality.of(context) == TextDirection.rtl
                                  ? Icons.arrow_back
                                  : Icons.arrow_forward,
                              onPressed: _handleLogin,
                            ),

                      const SizedBox(height: 24),
                      _buildSignupRow(context, l10n),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildHero(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 34),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(top: -80, left: -60, child: _decorCircle(200, 0.08)),
            Positioned(bottom: -60, right: -40, child: _decorCircle(140, 0.07)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🎙', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.loginHeroTitle,
                  style: context.heroTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.loginHeroSubtitle,
                  textAlign: TextAlign.center,
                  style: context.heroSubtitle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }

  Widget _buildSignupRow(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.noAccount, style: context.loginRowText),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SignupPage()),
            );
          },
          child: Text(l10n.signupLink, style: context.loginRowLink),
        ),
      ],
    );
  }
}
