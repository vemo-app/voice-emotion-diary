import 'package:flutter/material.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/gradient_button.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../home/home_page.dart';
import '../login/login_page.dart';
import '../../l10n/app_localizations.dart';

/// Signup page.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true; // Toggle password visibility
  bool _termsAccepted = false; // Toggle terms acceptance status

  bool _isLoading = false; // Loading state indicator
  String? _errorMessage; // Backend error messages

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = l10n.enterFullName);
      return;
    }
    if (_passwordController.text.length < 8) {
      setState(() => _errorMessage = l10n.passwordShort);
      return;
    }
    if (!_termsAccepted) {
      setState(() => _errorMessage = l10n.acceptTerms);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Sync backend preferences with the local app state, same as login_page.
      await UserService().syncPreferencesFromBackend();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      switch (e.message) {
        case 'connectionError':
          setState(() => _errorMessage = l10n.connectionError);
          break;
        case 'emailAlreadyExists':
          setState(() => _errorMessage = l10n.emailAlreadyExists);
          break;
        default:
          setState(() => _errorMessage = l10n.errorGeneric);
      }
    } finally {
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
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        label: l10n.nameLabel,
                        hintText: l10n.fullNameHint,
                        icon: Icons.person_outline,
                        controller: _nameController,
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        label: l10n.emailLabel,
                        hintText: 'you@email.com',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        label: l10n.passwordLabel,
                        hintText: l10n.passwordHint,
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        // Password visibility toggle icon.
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

                      // Password strength indicator (visible when length >= 8).
                      // We use ValueListenableBuilder to rebuild only this section
                      // on every keystroke rather than the entire page.
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _passwordController,
                        builder: (context, value, _) {
                          if (value.text.length < 8) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
                            child: Row(
                              children: [
                                Icon(Icons.check,
                                    size: 12, color: context.colors.success),
                                const SizedBox(width: 6),
                                Text(l10n.passwordStrong,
                                    style: context.pwHint),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),
                      _buildTermsRow(context, l10n),

                      // Error message displayed after a failed validation or request.
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: context.pwHint.copyWith(color: Colors.red),
                        ),
                      ],

                      const SizedBox(height: 22),

                      // Show loading spinner while processing to prevent multiple requests.
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
                        text: l10n.signupTitle,
                        icon: Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_back
                            : Icons.arrow_forward,
                        onPressed: _handleSignup,
                      ),
                      const SizedBox(height: 22),

                      _buildLoginRow(context, l10n),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  /// Builds the top hero section with gradient, icon, and title.
  Widget _buildHero(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 26),
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
          children: [
            // Decorative circles in the background.
            Positioned(
              top: -70,
              left: -50,
              child: _decorCircle(180, 0.08),
            ),
            Positioned(
              bottom: -50,
              right: -30,
              child: _decorCircle(120, 0.07),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🎙', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(height: 14),
                Text(l10n.signupTitle, style: context.heroTitle),
                const SizedBox(height: 6),
                Text(
                  l10n.signupHeroSubtitle,
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

  /// Terms and conditions checkbox row.
  Widget _buildTermsRow(BuildContext context, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom checkbox.
        GestureDetector(
          onTap: () => setState(() => _termsAccepted = !_termsAccepted),
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              gradient: _termsAccepted ? AppColors.heroGradient : null,
              color: _termsAccepted ? null : context.colors.surface,
              border: _termsAccepted
                  ? null
                  : Border.all(color: context.colors.line, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: _termsAccepted
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: context.termsText,
              children: [
                TextSpan(text: l10n.termsPrefix),
                TextSpan(
                  text: l10n.termsOfService,
                  style: context.termsLink,
                ),
                TextSpan(text: l10n.termsAnd),
                TextSpan(
                  text: l10n.privacyPolicy,
                  style: context.termsLink,
                ),
                TextSpan(
                  text: l10n.termsSuffix,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginRow(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.hasAccount, style: context.loginRowText),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
          child: Text(l10n.loginLink, style: context.loginRowLink),
        ),
      ],
    );
  }
}