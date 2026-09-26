import 'package:flutter/material.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';

/// A custom input field: top label + white shadowed box + leading icon +
/// optional trailing icon (e.g. password visibility toggle) + a focused
/// state with a purple border. Shared across signup, login, profile, and
/// other screens that need the same field style.
class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText; // true for password fields
  final Widget? trailing; // optional leading-side icon (e.g. password eye)
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.trailing,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(widget.label, style: context.fieldLabel),
        ),
        const SizedBox(height: 8),

        // Field box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: context.colors.shadowSoft,
            border: Border.all(
              color: _isFocused ? AppColors.purple500 : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 17, color: context.colors.ink400),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  style: context.fieldInput,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: context.fieldPlaceholder,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: 10),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
