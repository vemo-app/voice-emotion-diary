import 'package:flutter/material.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';

/// Gradient button used on signup, login, and similar screens (e.g. "Save
/// and get feedback" on the transcription page). Kept stateless since it
/// has no internal state to track - it's just a fixed appearance that
/// invokes a callback.
class GradientButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;

  const GradientButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // Wraps the button in Material so the ripple effect works on tap -
      // standard behavior users expect on Android/iOS.
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(100),
            boxShadow: context.colors.shadowButton,
          ),
          child: Container(
            width: double.infinity,
            height: 54,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(text, style: context.buttonText),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 16, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
