import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_extension.dart';

/// Shared bottom navigation bar, reused identically across the four main
/// screens (Home, History, Analytics, Profile) with only the active tab
/// changing.
class BottomNav extends StatelessWidget {
  /// Index of the currently active tab (0=Home, 1=History, 2=Analytics, 3=Profile)
  final int currentIndex;

  /// Called when the user taps a tab. The parent screen (e.g. HomePage)
  /// decides what to do with the index (usually navigation).
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (icon: Icons.home_rounded, label: l10n.navHome),
      (icon: Icons.calendar_month_rounded, label: l10n.navHistory),
      (icon: Icons.bar_chart_rounded, label: l10n.navAnalytics),
      (icon: Icons.person_rounded, label: l10n.navProfile),
    ];

    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 82 + bottomSafeArea,
      padding: EdgeInsets.only(top: 10, bottom: bottomSafeArea),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: context.colors.line)),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.blue100 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      item.icon,
                      size: 17,
                      color: isActive ? AppColors.blue700 : context.colors.ink400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: context.navLabel.copyWith(
                      color: isActive ? AppColors.blue700 : context.colors.ink400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
