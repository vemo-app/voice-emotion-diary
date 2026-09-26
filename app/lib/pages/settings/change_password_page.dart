import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../../l10n/app_localizations.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _service = UserService();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _saving = false;
  String? _error;
  bool _success = false;

  bool  _showConfirm = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty || newPass.isEmpty) {
      setState(() => _error = l10n.errorAllFieldsRequired);
      return;
    }
    if (newPass.length < 8) {
      setState(() => _error = l10n.passwordShort);
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = l10n.errorPasswordMismatch);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _service.changePassword(currentPassword: current, newPassword: newPass);
      if (!mounted) return;
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.of(context).pop();
    } on UserException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        if (e.message == 'connectionError') {
          _error = l10n.connectionError;
        } else if (e.message == 'sessionExpired') {
          _error = l10n.sessionExpired;
        } else if (e.message == 'invalidCredentials') {
          _error = l10n.invalidCredentials; // Current password wrong
        } else if (e.message == 'passwordShort') {
          _error = l10n.passwordShort;
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
              _buildTopBar(context, l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        label: l10n.currentPasswordLabel,
                        hintText: '••••••',
                        icon: Icons.lock_outline,
                        controller: _currentController,
                        obscureText: !_showCurrent,
                        trailing: GestureDetector(
                          onTap: () => setState(() => _showCurrent = !_showCurrent),
                          child: Icon(_showCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: context.colors.ink400),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: l10n.newPasswordLabel,
                        hintText: l10n.passwordHint,
                        icon: Icons.lock_outline,
                        controller: _newController,
                        obscureText: !_showNew,
                        trailing: GestureDetector(
                          onTap: () => setState(() => _showNew = !_showNew),
                          child: Icon(_showNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: context.colors.ink400),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: l10n.confirmPasswordLabel,
                        hintText: '••••••',
                        icon: Icons.lock_outline,
                        controller: _confirmController,
                        obscureText: !_showConfirm,
                        trailing: GestureDetector(
                          onTap: () => setState(() => _showConfirm = !_showConfirm),
                          child: Icon(_showConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: context.colors.ink400),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Text(_error!, style: context.pwHint.copyWith(color: Colors.red)),
                      ],
                      if (_success) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: context.colors.success),
                            const SizedBox(width: 6),
                            Text(l10n.passwordChangedSuccess, style: context.pwHint.copyWith(color: context.colors.success)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 26),
                      GradientButton(
                        text: _saving ? l10n.loading : l10n.changePassword,
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

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
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
          Text(l10n.changePassword, style: context.sectionTitle.copyWith(fontSize: 16.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
