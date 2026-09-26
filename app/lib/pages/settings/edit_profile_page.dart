import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../../l10n/app_localizations.dart';

/// Edit profile page (PATCH /users/me). Returns pop(true) if changes were saved,
/// signaling the parent page (Settings/Profile) to refresh its data.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _service = UserService();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    try {
      final profile = await _service.getMe();
      if (!mounted) return;
      setState(() {
        _usernameController.text = profile.username;
        _emailController.text = profile.email;
        _loading = false;
      });
    } on UserException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        if (e.message == 'connectionError') {
          _error = l10n.connectionError;
        } else if (e.message == 'sessionExpired') {
          _error = l10n.sessionExpired;
        } else {
          _error = l10n.errorLoading;
        }
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    if (username.isEmpty) {
      setState(() => _error = l10n.errorNameEmpty);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _service.updateMe(username: username, email: email);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on UserException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        if (e.message == 'connectionError') {
          _error = l10n.connectionError;
        } else if (e.message == 'sessionExpired') {
          _error = l10n.sessionExpired;
        } else if (e.message == 'emailAlreadyExists') {
          _error = l10n.emailAlreadyExists;
        } else if (e.message == 'errorNameEmpty') {
          _error = l10n.errorNameEmpty;
        } else {
          _error = l10n.errorGeneric;
        }
      });
    } finally {
      if (mounted) setState(() => _saving = false);
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
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              label: l10n.usernameLabel,
                              hintText: l10n.usernameHint,
                              icon: Icons.person_outline,
                              controller: _usernameController,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: l10n.emailLabel,
                              hintText: l10n.emailHint,
                              icon: Icons.email_outlined,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Text(_error!, style: context.pwHint.copyWith(color: Colors.red)),
                            ],
                            const SizedBox(height: 26),
                            GradientButton(
                              text: _saving ? l10n.loading : l10n.saveChanges,
                              onPressed: _saving ? () {} : _handleSave,
                            ),
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
            onTap: () => Navigator.of(context).pop(false),
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
          Text(l10n.editProfile, style: context.sectionTitle.copyWith(fontSize: 16.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
