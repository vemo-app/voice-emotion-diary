import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../../services/theme_service.dart';
import '../../services/locale_service.dart';
import '../../l10n/app_localizations.dart';
import '../login/login_page.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _userService = UserService();
  final _authService = AuthService();

  bool _deleting = false;

  void _setLanguage(Locale? locale) {
    LocaleService().setLocale(locale);
    _syncLanguageToBackend(locale);
  }
  Future<void> _syncLanguageToBackend(Locale? locale) async {
    try {
      await UserService().updateMe(language: LocaleService.localeToBackend(locale));
    } catch (_) {
      // ignore
    }
  }

  Future<void> _syncThemeToBackend(ThemeMode mode) async {
    try {
      await UserService().updateMe(theme: ThemeService.themeModeToBackend(mode));
    } catch (_) {
      // ignore
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: context.sectionTitle.copyWith(fontSize: 17),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _languageOption(
              label: AppLocalizations.of(context)!.systemDefault,
              isSelected: LocaleService().locale == null,
              onTap: () => _setLanguage(null),
            ),
            _languageOption(
              label: AppLocalizations.of(context)!.persian,
              isSelected: LocaleService().locale?.languageCode == 'fa',
              onTap: () => _setLanguage(const Locale('fa')),
            ),
            _languageOption(
              label: AppLocalizations.of(context)!.english,
              isSelected: LocaleService().locale?.languageCode == 'en',
              onTap: () => _setLanguage(const Locale('en')),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _languageOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap();
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.background : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.purple700 : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.memoryTitle.copyWith(
                fontSize: 14,
                color: isSelected ? AppColors.purple700 : context.colors.ink900,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.purple700, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirmation),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.logout,
                style: TextStyle(color: context.colors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(AppLocalizations.of(context)!.deleteAccountTitle,
            style: TextStyle(color: context.colors.danger)),
        content: Text(
          AppLocalizations.of(context)!.deleteAccountConfirmation,
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.deletePermanently,
                style: TextStyle(color: context.colors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      await _userService.deleteAccount();
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on UserException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      final l10n = AppLocalizations.of(context)!;
      String msg = l10n.errorGeneric;
      if (e.message == 'connectionError') msg = l10n.connectionError;
      if (e.message == 'sessionExpired') msg = l10n.sessionExpired;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildGroup(
                        title: l10n.appSettings,
                        rows: [
                          _toggleRow(
                            icon: Icons.dark_mode_outlined,
                            iconBg: AppColors.purple100,
                            iconFg: AppColors.purple700,
                            label: l10n.darkModeLabel,
                            // When themeMode is set to system (the default), the
                            // switch should reflect the actual system brightness,
                            // not just check whether it equals ThemeMode.dark
                            // (which would always be false for system mode).
                            value: ThemeService().themeMode == ThemeMode.dark ||
                                (ThemeService().themeMode == ThemeMode.system &&
                                    MediaQuery.platformBrightnessOf(context) == Brightness.dark),
                            onChanged: (v) {
                              final mode = v ? ThemeMode.dark : ThemeMode.light;
                              ThemeService().setThemeMode(mode);
                              _syncThemeToBackend(mode);
                            },
                          ),
                          _navRow(
                            icon: Icons.language,
                            iconBg: AppColors.blue100,
                            iconFg: AppColors.blue700,
                            label: l10n.languageLabel,
                            value: LocaleService().locale?.languageCode == 'fa'
                                ? l10n.persian
                                : (LocaleService().locale?.languageCode == 'en'
                                    ? l10n.english
                                    : l10n.systemDefault),
                            onTap: _showLanguageSelector,
                            isLast: true,
                          ),
                        ],
                      ),
                      _buildGroup(
                        title: l10n.accountSettings,
                        rows: [
                          _navRow(
                            icon: Icons.person_outline,
                            iconBg: AppColors.blue100,
                            iconFg: AppColors.blue700,
                            label: l10n.editProfile,
                            desc: l10n.editProfileDesc,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const EditProfilePage()),
                              );
                            },
                          ),
                          _navRow(
                            icon: Icons.lock_outline,
                            iconBg: AppColors.purple100,
                            iconFg: AppColors.purple700,
                            label: l10n.changePassword,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                              );
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                      _buildDangerGroup(l10n),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildTopBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(11), boxShadow: context.colors.shadowSoft),
              alignment: Alignment.center,
              child: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_right
                      : Icons.chevron_left,
                  size: 20,
                  color: context.colors.ink900),
            ),
          ),
          const SizedBox(width: 12),
          Text(l10n.settingsTitle, style: context.sectionTitle.copyWith(fontSize: 16.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildGroup({required String title, required List<Widget> rows}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4, left: 4, bottom: 8),
            child: Text(title, style: context.pwHint.copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          Container(
            decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(18), boxShadow: context.colors.shadowSoft),
            clipBehavior: Clip.hardEdge,
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerGroup(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4, left: 4, bottom: 8),
            child: Text(l10n.dangerZone, style: context.pwHint.copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          Container(
            decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(18), boxShadow: context.colors.shadowSoft),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                _rowShell(
                  icon: Icons.logout_rounded,
                  iconBg: context.colors.background,
                  iconFg: context.colors.ink600,
                  child: Text(l10n.logout, style: context.memoryTitle.copyWith(fontSize: 13.5)),
                  trailing: const SizedBox.shrink(),
                  onTap: _handleLogout,
                ),
                _rowShell(
                  icon: Icons.person_off_outlined,
                  iconBg: context.colors.dangerBg,
                  iconFg: context.colors.danger,
                  child: Text(l10n.deleteAccount, style: context.memoryTitle.copyWith(fontSize: 13.5, color: context.colors.danger)),
                  trailing: _deleting
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.danger))
                      : const SizedBox.shrink(),
                  onTap: _deleting ? null : _handleDeleteAccount,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowShell({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required Widget child,
    required Widget trailing,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: context.colors.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: iconFg),
            ),
            const SizedBox(width: 13),
            Expanded(child: child),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _navRow({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String label,
    String? desc,
    String? value,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return _rowShell(
      icon: icon,
      iconBg: iconBg,
      iconFg: iconFg,
      onTap: onTap,
      isLast: isLast,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) ...[
            Text(value, style: context.pwHint.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 2),
          ],
          Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              size: 16,
              color: context.colors.ink400),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.memoryTitle.copyWith(fontSize: 13.5)),
          if (desc != null) Text(desc, style: context.memoryMeta.copyWith(fontSize: 10.5)),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return _rowShell(
      icon: icon,
      iconBg: iconBg,
      iconFg: iconFg,
      isLast: isLast,
      child: Text(label, style: context.memoryTitle.copyWith(fontSize: 13.5)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: AppColors.purple700,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: context.colors.line,
      ),
    );
  }
}
